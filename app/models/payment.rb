class Payment < ActiveRecord::Base
  resourcify

  include AASM

  belongs_to :message
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id

  after_create :add_sender_role, :reserve_time_out
  after_save :add_receiver_role

  enum status: {
    pay_request: 10,
    pay_fail: 20,
    pay_success: 30,
    cancel_request: 40,
    cancel_fail: 50,
    cancel_success: 60,
    settled: 70,
    wasted: 80,
  }

  aasm column: :status, enum: true do
    state :pay_request
    state :pay_fail, after_enter: :notify_pay_fail
    state :pay_success, after_enter: :notify_pay_success
    state :cancel_request, after_enter: :send_cancel_request
    state :cancel_fail, after_enter: :notify_cancel_fail
    state :cancel_success, after_enter: :notify_cancel_success
    state :settled, after_enter: :process_settlement
    state :wasted

    event :fail_pay do
      transitions from: :pay_request, to: :pay_fail
    end

    event :succeed_pay do
      transitions from: [:pay_request, :pay_fail], to: :pay_success
    end

    event :request_cancel do
      transitions from: [:pay_success, :cancel_fail], to: :cancel_request
    end

    event :fail_cancel do
      transitions from: :cancel_request, to: :cancel_fail
    end

    event :succeed_cancel do
      transitions from: :cancel_request, to: :cancel_success
    end

    event :settle do
      transitions from: [:pay_success, :cancel_success], to: :settled
    end

    event :waste do
      transitions from: :pay_request, to: :wasted
    end
  end

  def merchant_uid
    "#{id}:#{created_at.strftime('%y%m%d%H%M%S')}"
  end

  def platform_share
    (pay_amount * commission_rate / 100).to_i
  end

  def partner_share
    pay_amount - platform_share
  end

  def add_sender_role
    sender.add_role(:sender, self)
  end

  def add_receiver_role
    receiver.add_role(:receiver, self) if settled?
  end

  def reserve_time_out
    if Rails.env.production?
      MessageTimeOutWorker.perform_in(2.hours, id)
    else
      MessageTimeOutWorker.perform_in(5.minutes, id)
    end
  end

  def time_out
    sender.cancel_payment! if pay_request?
  end

  def send_cancel_request
    CancelRequestJob.perform_later(id)
  end

  def process_settlement
    receiver.update_attributes({balance: receiver.balance + partner_share})
    receiver.notify_profit(self)
    # TODO create settlement
  end

  private

  def notify_pay_success
    message.sender.command(:complete_payment)
  end

  def notify_pay_fail
    message.sender.notify_pay_fail(self)
  end

  def notify_cancel_success
    message.sender.notify_cancel(self)
  end

  def notify_cancel_fail
    Waikiki::MessageSender.send_to_admin("결체취소실패:#{self.id}:#{self.failure_reason}")
  end

end

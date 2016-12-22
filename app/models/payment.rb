class Payment < ActiveRecord::Base
  include AASM

  belongs_to :message

  scope :timed_outs, -> {
    where(status: statuses[:pay_request]).where('created_at < ?', 2.hours.ago)
  }

  enum status: {
    pay_request: 10,
    pay_fail: 20,
    pay_success: 30,
    cancel_request: 40,
    cancel_fail: 50,
    cancel_success: 60,
    wasted: 70
  }

  aasm column: :status, enum: true do
    state :pay_request
    state :pay_fail, after_enter: :notify_pay_fail
    state :pay_success, after_enter: :notify_pay_success
    state :cancel_request, after_enter: :send_cancel_request
    state :cancel_fail
    state :cancel_success, after_enter: :notify_cancel_success
    state :wasted

    event :fail_pay do
      transitions from: :pay_request, to: :pay_fail
    end

    event :succeed_pay do
      transitions from: [:pay_request, :pay_fail], to: :pay_success
    end

    event :request_cancel do
      transitions from: :pay_success, to: :cancel_request
    end

    event :fail_cancel do
      transitions from: :cancel_request, to: :cancel_fail
    end

    event :succeed_cancel do
      transitions from: :cancel_request, to: :cancel_success
    end

    event :waste do
      transitions from: :pay_request, to: :wasted
    end
  end

  def platform_share
    (pay_amount * commission_rate / 100).to_i
  end

  def celeb_share
    pay_amount - platform_share
  end

  def send_cancel_request
    CancelRequestJob.perform_later(id)
  end

  def settle
    celeb = message.receiver.celeb
    celeb.balance += celeb_share
    celeb.save!
    celeb.user.notify_profit(self)
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

end

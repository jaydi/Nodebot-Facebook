class Payment < ActiveRecord::Base
  include AASM

  belongs_to :message
  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id

  enum status: {
    pay_request: 10,
    pay_cancel: 20,
    pay_fail: 30,
    pay_success: 40,
    refund_request: 50,
    refund_fail: 60,
    refund_success: 70
  }

  aasm column: :status, enum: true do
    state :pay_request, initial: true
    state :pay_cancel
    state :pay_fail
    state :pay_success, after_enter: :notify_pay_success
    state :refund_request, after_enter: :send_refund_request
    state :refund_fail
    state :refund_success, after_enter: :notify_refund_success

    event :cancel_pay do
      transitions from: :pay_request, to: :pay_cancel
    end

    event :fail_pay do
      transitions from: :pay_request, to: :pay_fail
    end

    event :succeed_pay do
      transitions from: [:pay_request, :pay_fail], to: :pay_success
    end

    event :request_refund do
      transitions from: :pay_success, to: :refund_request
    end

    event :fail_refund do
      transitions from: :refund_request, to: :refund_fail
    end

    event :succeed_refund do
      transitions from: :refund_request, to: :refund_success
    end
  end

  def send_refund_request
    RefundRequestJob.perform_later(id)
  end

  def notify_pay_success
    sender.command(:CMPT_PAY)
  end

  def notify_refund_success
    sender.notify_refund(self)
  end

end

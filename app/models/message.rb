class Message < ActiveRecord::Base
  include AASM

  has_one :payment
  has_one :reply_message, class_name: 'Message', foreign_key: :initial_message_id

  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id

  scope :sent_by, ->(user_id) {
    where(sending_user_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :received_by, ->(user_id) {
    where(receiving_user_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :in_progress, ->(user_id) {
    where(sending_user_id: user_id).where(status: [statuses[:initiated], statuses[:completed]])
  }

  scope :timed_outs, -> {
    where(status: statuses[:delivered]).where(initial_message_id: nil).where('updated_at < ?', 1.day.ago.beginning_of_day)
  }

  enum kind: {
    fan_message: 10,
    celeb_reply: 20
  }

  enum status: {
    initiated: 10,
    completed: 20,
    delivered: 30,
    read: 40,
    replied: 50,
    wasted: 60,
    cancelled: 70
  }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :completed
    state :delivered, after_enter: [:set_time_out, :after_reply]
    state :read
    state :replied, after_enter: [:settle_payment]
    state :wasted, after_enter: [:refund_payment]
    state :cancelled
    state :withdrawn

    event :complete do
      transitions from: :initiated, to: :completed
    end

    event :deliver do
      transitions from: :completed, to: :delivered
    end

    event :read do
      transitions from: :delivered, to: :read
    end

    event :reply do
      transitions from: :delivered, to: :replied
    end

    event :waste do
      transitions from: :delivered, to: :wasted
    end

    event :cancel do
      transitions from: [:initiated, :completed], to: :cancelled
    end
  end

  def repliable?
    delivered? and payment.present? and payment.pay_success?
  end

  def reply?
    initial_message.present?
  end

  def set_time_out
    if Rails.env.production?
      MessageTimeOutWorker.perform_in(24.hours, id)
    else
      MessageTimeOutWorker.perform_in(15.minutes, id)
    end
  end

  def after_reply
    initial_message.reply! if reply?
    receiver.notify_reply(self) if celeb_reply?
  end

  def settle_payment
    payment.settle if payment.present? and payment.pay_success?
  end

  def refund_payment
    payment.request_cancel! if payment.present? and payment.pay_success?
  end

end

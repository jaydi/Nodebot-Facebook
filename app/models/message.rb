class Message < ActiveRecord::Base
  include AASM

  has_one :payment
  has_one :reply_message, class_name: 'Message', foreign_key: :initial_message_id

  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id

  scope :initials, -> {
    where(initial_message_id: nil)
  }

  scope :replies, -> {
    where.not(initial_message_id: nil)
  }

  scope :sent_by, ->(user_id) {
    where(sending_user_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :received_by, ->(user_id) {
    where(receiving_user_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :in_progress, ->(user_id) {
    where(sending_user_id: user_id).where(status: [statuses[:initiated], statuses[:completed]])
  }

  scope :delivered, -> {
    where(status: statuses[:delivered])
  }

  scope :replied, -> {
    where(status: statuses[:replied])
  }

  scope :timed_outs, -> {
    where(status: statuses[:delivered]).where(initial_message_id: nil).where('updated_at < ?', 1.day.ago.beginning_of_day)
  }

  enum status: {
    initiated: 10,
    completed: 20,
    delivered: 30,
    replied: 40,
    wasted: 50,
    canceled: 60,
    withdrawn: 70
  }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :completed
    state :delivered, after_enter: [:mark_if_reply]
    state :replied, after_enter: [:notify_reply]
    state :wasted, after_enter: [:refund]
    state :canceled
    state :withdrawn

    event :complete do
      transitions from: :initiated, to: :completed
    end

    event :deliver do
      transitions from: :completed, to: :delivered
    end

    event :reply do
      transitions from: :delivered, to: :replied
    end

    event :waste do
      transitions from: :delivered, to: :wasted
    end

    event :cancel do
      transitions from: [:initiated, :completed], to: :canceled
    end

    event :withdraw do
      transitions from: :delivered, to: :withdrawn
    end
  end

  def reply?
    !initial_message.blank?
  end

  def mark_if_reply
    initial_message.reply! if reply?
  end

  def notify_reply
    sender.notify_reply(reply_message)
  end

  def refund
    payment.request_refund! unless payment.blank?
  end

end

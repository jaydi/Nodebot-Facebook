class Message < ActiveRecord::Base
  include AASM

  has_one :payment
  has_one :replying_message, class_name: 'Message', foreign_key: :initial_message_id

  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id

  scope :on_progress, ->(user_id) {
    where(sending_user_id: user_id).where(status: [statuses[:initiated], statuses[:completed]])
  }

  scope :initials_sent_by, ->(user_id) {
    where(sending_user_id: user_id).where(initial_message_id: nil)
  }

  scope :initials_received_by, ->(user_id) {
    where(receiving_user_id: user_id).where(initial_message_id: nil)
  }

  scope :replies_sent_by, ->(user_id) {
    where(sending_user_id: user_id).where.not(initial_message_id: nil)
  }

  scope :replies_received_by, ->(user_id) {
    where(receiving_user_id: user_id).where.not(initial_message_id: nil)
  }

  scope :delivered, -> {
    where(status: statuses[:delivered])
  }

  scope :replied, -> {
    where(status: statuses[:replied])
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
    state :delivered, after_enter: [:send_if_reply]
    state :replied
    state :wasted
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

  def send_if_reply
    if reply?
      initial_message.reply!
      Waikiki::MessageSender.send_text_message(receiver, "Reply arrived from #{sender.celeb.name}")
      # TODO send video
    end
  end



end

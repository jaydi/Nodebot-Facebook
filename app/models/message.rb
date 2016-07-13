class Message < ActiveRecord::Base
  include AASM

  has_one :payment
  has_one :replying_message, class_name: 'Message', foreign_key: :initial_message_id

  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id


  enum status: {
    initiated: 10,
    completed: 20,
    delivered: 30,
    replied: 40,
    wasted: 50,
    canceled: 60,
    retreated: 70
  }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :completed
    state :delivered, after_enter: [:mark_reply]
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

  def mark_reply
    initial_message.andand.reply!
  end

end

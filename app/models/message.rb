class Message < ActiveRecord::Base
  include AASM

  has_one :payment
  has_one :reply, class_name: 'Message', foreign_key: :initial_message_id

  belongs_to :sender, class_name: 'User', foreign_key: :sending_user_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiving_user_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id


  enum status: {
    initiated: 10,
    completed: 20,
    delivered: 30,
    read: 40,
    replied: 50,
    wasted: 60,
    canceled: 70
  }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :completed
    state :delivered
    state :read
    state :replied
    state :wasted
    state :canceled

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
      transitions from: :read, to: :replied
    end

    event :waste do
      transitions from: [:delivered, :read], to: :wasted
    end

    event :cancel do
      transitions from: [:initiated, :completed, :delivered], to: :canceled
    end
  end
end

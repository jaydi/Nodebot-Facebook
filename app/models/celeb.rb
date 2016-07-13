class Celeb < ActiveRecord::Base
  include AASM

  has_one :user

  enum status: {
    pending: 10,
    active: 20,
    inactive: 30
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :active
    state :inactive

    event :initiate do
      transitions from: :pending, to: :active
    end

    event :deactivate do
      transitions from: :active, to: :inactive
    end

    event :activate do
      transitions from: :inactive, to: :active
    end
  end


end

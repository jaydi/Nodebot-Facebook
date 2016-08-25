class Celeb < ActiveRecord::Base
  include AASM

  has_one :user

  attr_encrypted :password, :key => APP_CONFIG[:secret_key]

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

  def info_filled?
    !name.blank? and !profile_pic.blank?
  end

  def paired?
    !user.blank?
  end

end

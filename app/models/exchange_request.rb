class ExchangeRequest < ActiveRecord::Base
  include AASM

  belongs_to :celeb
  belongs_to :bank

  attr_encrypted :account_number, :key => APP_CONFIG[:encryption_key]

  validate :check_balance
  before_create :adjust_balance
  after_create :notify_admin

  scope :issued_by, ->(celeb_id) {
    where(celeb_id: celeb_id)
  }

  enum status: {
    requested: 10,
    succeeded: 20,
    failed: 30
  }

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :succeeded, after_enter: [:notify_exchange_result]
    state :failed, after_enter: [:notify_exchange_result]

    event :succeed do
      transitions from: :requested, to: :succeeded
    end

    event :fail do
      transitions from: :requested, to: :failed
    end
  end

  private

  def check_balance
    if amount > celeb.balance
      errors.add(:amount, "Exchange amount cannot be bigger than balance")
    end
  end

  def adjust_balance
    celeb.balance -= amount
    celeb.save!
  end

  def notify_admin
    1+1
    # TODO send email? sms?
  end

  def notify_exchange_result
    if succeeded?
      celeb.user.notify_exchange_success(self)
    elsif failed?
      celeb.user.notify_exchange_failure(self)
    end
  end

end
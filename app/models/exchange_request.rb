class ExchangeRequest < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :bank

  attr_encrypted :account_number, :key => APP_CONFIG[:encryption_key]

  validate :check_balance
  before_create :adjust_balance
  after_create :notify_admin

  scope :issued_by, ->(user_id) {
    where(user_id: user_id).order(id: :desc)
  }

  enum status: {
    requested: 10,
    succeeded: 20,
    failed: 30
  }

  aasm column: :status, enum: true do
    state :requested, initial: true
    state :succeeded, after_enter: [:notify_exchange_result]
    state :failed, after_enter: [:adjust_balance, :notify_exchange_result]

    event :succeed do
      transitions from: :requested, to: :succeeded
    end

    event :fail do
      transitions from: :requested, to: :failed
    end
  end

  private

  def check_balance
    if amount > user.balance
      errors.add("잔액부족", "환전요청금액이 잔액을 초과할 수 없습니다.")
    end
  end

  def adjust_balance
    if requested?
      user.balance -= amount
      user.save!
    elsif failed?
      user.balance += amount
      user.save!
    end
  end

  def notify_admin
    # TODO send email? sms? fb message?
  end

  def notify_exchange_result
    if succeeded?
      user.notify_exchange_success(self)
    elsif failed?
      user.notify_exchange_failure(self)
    end
  end

end
class Message < ActiveRecord::Base
  resourcify

  include AASM

  has_one :payment
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :initial_message, class_name: 'Message', foreign_key: :initial_message_id

  after_create :add_sender_role
  after_save :adjust_receiver_role

  scope :made_by, ->(user_id) {
    where(sender_id: user_id)
  }

  scope :sent_by, ->(user_id) {
    where(sender_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :received_by, ->(user_id) {
    where(receiver_id: user_id).where(status: [statuses[:delivered], statuses[:replied], statuses[:wasted]])
  }

  scope :in_progress, ->(user_id) {
    where(sender_id: user_id).where(status: [statuses[:initiated], statuses[:completed]])
  }

  enum kind: {
    fan_message: 10,
    partner_reply: 20
  }

  enum status: {
    initiated: 10,
    completed: 20,
    delivered: 30,
    replied: 50,
    wasted: 60,
    cancelled: 70
  }

  aasm column: :status, enum: true do
    state :initiated, initial: true
    state :completed
    state :delivered, after_enter: [:after_reply, :set_time_out]
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

  def in_progress?
    initiated? or completed?
  end

  def reply_message
    @reply_message ||= self.class.where(initial_message_id: self.id).last
  end

  def add_sender_role
    sender.add_role(:sender, self)
  end

  def adjust_receiver_role
    receiver.add_role(:receiver, self) if delivered?
  end

  def after_reply
    receiver.notify_reply(self) if partner_reply?
    initial_message.reply! if reply?
  end

  def set_time_out
    if fan_message?
      if Rails.env.production?
        MessageTimeOutWorker.perform_in(48.hours, id)
      else
        MessageTimeOutWorker.perform_in(15.minutes, id)
      end
    end
  end

  def time_out
    if reply_message.blank?
      waste!
    elsif reply_message.in_progress?
      MessageTimeOutWorker.perform_in(10.minutes, id)
    end
  end

  def settle_payment
    payment.settle if payment.present? and payment.pay_success?
  end

  def refund_payment
    payment.request_cancel! if payment.present? and payment.pay_success?
  end

end

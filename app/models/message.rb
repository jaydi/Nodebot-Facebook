class Message < ActiveRecord::Base

  def my_logger
    @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_#{self.class.name.underscore}.log")
  end

  include AASM

  has_one :payment
  has_one :replying_message, class_name: 'Message', foreign_key: :initial_message_id

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
    where(sending_user_id: user_id)
  }

  scope :received_by, ->(user_id) {
    where(receiving_user_id: user_id)
  }

  scope :on_progress, ->(user_id) {
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
    state :delivered, after_enter: [:send_if_reply]
    state :replied
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

  def is_reply?
    !initial_message.blank?
  end

  def send_if_reply
    if is_reply?
      initial_message.reply!
      Waikiki::MessageSender.send_text_message(receiver, "Reply arrived from #{sender.celeb.name}")
      begin
        Waikiki::MessageSender.send_attachment_message(receiver, Attachment.new({type: 'video', payload: video_url}))
      rescue HTTPClient::TimeoutError
        my_logger.error "Message with message id #{self.id} raised an error with http-timeout. However proceeded anyway."
      end
    end
  end

  def refund
    unless payment.blank?
      payment.request_refund!
    end
  end

end

class User < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable, :omniauthable, :validatable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable
  rolify

  include AASM
  include UserHelper
  include MessengerHelper
  include PaymentHelper

  # has_many :sent_messages
  # has_many :received_messages
  # has_many :sent_payments
  has_many :exchange_requests

  scope :partners, -> {
    where(is_partner: true)
  }

  enum status: {
    waiting: 10,
    nickname_setting: 20,
    nickname_set: 21,
    message_initiated: 110,
    messaging: 120,
    message_confirm: 130,
    message_completed: 140,
    message_cancelled: 150,
    payment_rejected: 201,
    payment_initiated: 200,
    payment_completed: 210,
    payment_cancelled: 220,
    reply_initiated: 300,
    replying: 310,
    reply_confirm: 320,
    reply_completed: 330,
    reply_cancelled: 340
  }

  aasm column: :status, enum: true do
    state :waiting, initial: true, after_enter: [:state_enter_action, :state_enter_message]
    state :nickname_setting, after_enter: [:state_enter_action, :state_enter_message]
    state :nickname_set, after_enter: [:state_enter_action, :state_enter_message, :start_messaging]

    state :message_initiated, after_enter: [:state_enter_action, :state_enter_message]
    state :messaging, after_enter: [:state_enter_action, :state_enter_message]
    state :message_confirm, after_enter: [:state_enter_action, :state_enter_message]
    state :message_completed, after_enter: [:state_enter_action, :state_enter_message]
    state :message_cancelled, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]

    state :payment_rejected, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]
    state :payment_initiated, after_enter: [:state_enter_action, :state_enter_message]
    state :payment_completed, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]
    state :payment_cancelled, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]

    state :reply_initiated, after_enter: [:state_enter_action, :state_enter_message]
    state :replying, after_enter: [:state_enter_action, :state_enter_message]
    state :reply_confirm, after_enter: [:state_enter_action, :state_enter_message]
    state :reply_completed, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]
    state :reply_cancelled, after_enter: [:state_enter_action, :state_enter_message, :end_conversation]

    event :start_setting_nickname do
      transitions from: :message_initiated, to: :nickname_setting
    end

    event :set_nickname do
      transitions from: :nickname_setting, to: :nickname_set
    end

    event :initiate_message do
      transitions from: :waiting, to: :message_initiated
    end

    event :start_messaging do
      transitions from: [:nickname_set, :message_initiated, :message_confirm], to: :messaging
    end

    event :confirm_message do
      transitions from: :messaging, to: :message_confirm
    end

    event :complete_message do
      transitions from: :message_confirm, to: :message_completed
    end

    event :cancel_message do
      transitions from: [:message_initiated, :message_confirm], to: :message_cancelled
    end

    event :reject_payment do
      transitions from: :message_completed, to: :payment_rejected
    end

    event :initiate_payment do
      transitions from: :message_completed, to: :payment_initiated
    end

    event :complete_payment do
      transitions from: :payment_initiated, to: :payment_completed
    end

    event :cancel_payment do
      transitions from: :payment_initiated, to: :payment_cancelled
    end

    event :initiate_reply do
      transitions from: :waiting, to: :reply_initiated
    end

    event :start_replying do
      transitions from: [:reply_initiated, :reply_confirm], to: :replying
    end

    event :confirm_reply do
      transitions from: :replying, to: :reply_confirm
    end

    event :complete_reply do
      transitions from: :reply_confirm, to: :reply_completed
    end

    event :cancel_reply do
      transitions from: [:reply_initiated, :reply_confirm], to: :reply_cancelled
    end

    event :end_conversation do
      transitions to: :waiting
    end
  end

  def profile_completed?
    name.present? and profile_pic.present?
  end

  def messenger_paired?
    messenger_id.present?
  end

  def is_newbie?
    Message.fan_message.made_by(id).count == 0
  end

  def current_message
    if @message
      @message.reload
      if @message.initiated? or @message.completed?
        @message
      else
        @message = nil
      end
    else
      @message = Message.in_progress(id).last
    end
  end

  def command(com)
    begin
      func, *args = com.to_s.split(':')
      if args.length > 0
        send(func, *args)
      else
        send(func)
      end
      save!
    rescue
      invalid_command_error
    end
  end

  def text_message(text)
    if messaging?
      msg = current_message
      msg.text = text
      msg.save!
      command(:confirm_message)
    elsif nickname_setting?
      update_attributes(name: text[0..9])
      command(:set_nickname)
    elsif waiting? and %w(hi hello hey 안녕 안녕하세요 야 ?).include?(text)
      initial_guide_message
    else
      state_enter_message
    end
  end

  def video_message(video_url)
    if replying?
      msg = current_message
      msg.video_url = video_url
      msg.save!
      command(:confirm_reply)
    end
  end

  def optin(target_type, target_id)
    case target_type.to_sym
      when :PTN
        user = User.find(target_id)
        user.update_attributes({messenger_id: messenger_id, is_partner: true})
        optin_partner_message
        self.destroy!

      when :MSG
        if current_message.blank?
          end_conversation! unless waiting?
          message = Message.create({
                           sender_id: id,
                           receiver_id: target_id,
                           kind: :fan_message
                         })
          add_role(:sender, message)
          command(:initiate_message)
        else
          optin_message_error
        end

      when :RPL
        if current_message.blank?
          end_conversation! unless waiting?
          initial_msg = Message.find(target_id)
          if initial_msg.video_repliable?
            Message.create({
                             initial_message_id: initial_msg.id,
                             sender_id: id,
                             receiver_id: initial_msg.sender_id,
                             kind: :partner_reply
                           })
            command(:initiate_reply)
          else
            cannot_be_replied_error
          end
        else
          optin_reply_error
        end

    end
  end

  def reply_to(target_id)
    if current_message.blank?
      end_conversation! unless waiting?
      initial_msg = Message.find(target_id)
      Message.create({
                       initial_message_id: initial_msg.id,
                       sender_id: initial_msg.receiver_id,
                       receiver_id: initial_msg.sender_id,
                       kind: :fan_message
                     })
      update_attribute(:status, :message_initiated)
      command(:start_messaging)
    else
      optin_message_error
    end
  end

  def add_revenue(revenue_amount)
    update_attributes({balance: balance + revenue_amount})
  end

end
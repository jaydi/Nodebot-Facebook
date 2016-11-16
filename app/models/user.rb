class User < ActiveRecord::Base

  def my_logger
    @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_#{self.class.name.underscore}.log")
  end

  include AASM
  include UserHelper

  belongs_to :celeb

  enum status: {
    waiting: 10,
    nickname_setting: 20,
    message_initiated: 110,
    messaging: 120,
    message_confirm: 130,
    message_completed: 140,
    payment_initiated: 200,
    payment_completed: 210,
    payment_cancelled: 220,
    reply_initiated: 300,
    replying: 310,
    reply_confirm: 320,
    reply_completed: 330,
  }

  aasm column: :status, enum: true do
    state :waiting, initial: true, after_enter: [:state_enter_action, :state_enter_guide]
    state :nickname_setting, after_enter: [:state_enter_action, :state_enter_guide], before_exit: [:state_exit_guide]

    state :message_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :messaging, after_enter: [:state_enter_action, :state_enter_guide]
    state :message_confirm, after_enter: [:state_enter_action, :state_enter_guide]
    state :message_completed, after_enter: [:state_enter_action, :state_enter_guide]

    state :payment_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :payment_completed, after_enter: [:state_enter_action, :state_enter_guide, :end_conversation, :save]
    state :payment_cancelled, after_enter: [:state_enter_action, :state_enter_guide, :end_conversation, :save]

    state :reply_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :replying, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_confirm, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_completed, after_enter: [:state_enter_action, :state_enter_guide, :end_conversation, :save]

    event :start_setting_nickname do
      transitions from: :message_initiated, to: :nickname_setting
    end

    event :initiate_message do
      transitions from: :waiting, to: :message_initiated
    end

    event :start_messaging do
      transitions from: [:nickname_setting, :message_initiated, :message_confirm], to: :messaging
    end

    event :confirm_message do
      transitions from: :messaging, to: :message_confirm
    end

    event :complete_message do
      transitions from: :message_confirm, to: :message_completed
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

    event :end_conversation do
      transitions to: :waiting
    end
  end

  def newbie?
    Message.sent_by(self).count == 0
  end

  def celeb?
    celeb.present?
  end

  def current_message
    unless @message.blank?
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
    rescue AASM::InvalidTransition
      state_transition_error
    end
  end

  def text_message(text)
    if messaging?
      msg = current_message
      msg.text = text
      msg.save!
      command(:confirm_message)
    elsif nickname_setting?
      self.name = text[0..9]
      save!
      command(:start_messaging)
    else
      state_enter_guide
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
      when :CLB
        celeb = Celeb.find(target_id)
        celeb.initiate!
        save!
        optin_celeb_guide

      when :MSG
        if current_message.blank?
          end_conversation! unless waiting?
          Message.create({
                           sending_user_id: id,
                           receiving_user_id: target_id
                         })
          command(:initiate_message)
        else
          optin_message_error
        end

      when :RPL
        if current_message.blank?
          end_conversation! unless waiting?
          initial_msg = Message.find(target_id)
          if initial_msg.delivered?
            Message.create({
                             initial_message_id: initial_msg.id,
                             sending_user_id: id,
                             receiving_user_id: initial_msg.sending_user_id
                           })
            command(:initiate_reply)
          elsif initial_msg.replied?
            already_replied_error
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
                       sending_user_id: id,
                       receiving_user_id: initial_msg.sending_user_id
                     })
      self.status = :message_initiated
      save!
      command(:start_messaging)
    else
      optin_message_error
    end
  end

  def read_stamp(watermark)
    delivered_messages = Message.received_by(id).delivered.before(Time.at(watermark / 1000))
    delivered_messages.each { |dm| dm.read! }
  end

end
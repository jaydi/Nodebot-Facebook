class User < ActiveRecord::Base

  def my_logger
    @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_#{self.class.name.underscore}.log")
  end

  include AASM
  include UserHelper

  belongs_to :celeb

  enum status: {
    waiting: 10,
    message_initiated: 20,
    reply_initiated: 21,
    messaging: 30,
    replying: 31,
    message_confirm: 40,
    reply_confirm: 41,
    message_completed: 50,
    reply_completed: 51,
    payment_initiated: 60,
    payment_completed: 70
  }

  aasm column: :status, enum: true do
    state :waiting, initial: true, after_enter: [:state_enter_action]
    state :message_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :messaging, after_enter: [:state_enter_action, :state_enter_guide]
    state :replying, after_enter: [:state_enter_action, :state_enter_guide]
    state :message_confirm, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_confirm, after_enter: [:state_enter_action, :state_enter_guide]
    state :message_completed, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_completed, after_enter: [:state_enter_action, :state_enter_guide, :end_conversation, :save]
    state :payment_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :payment_completed, after_enter: [:state_enter_action, :state_enter_guide, :end_conversation, :save]

    event :initiate_message do
      transitions from: :waiting, to: :message_initiated
    end

    event :initiate_reply do
      transitions from: :waiting, to: :reply_initiated
    end

    event :start_messaging do
      transitions from: :message_initiated, to: :messaging
    end

    event :start_replying do
      transitions from: :reply_initiated, to: :replying
    end

    event :confirm_message do
      transitions from: :messaging, to: :message_confirm
    end

    event :confirm_reply do
      transitions from: :replying, to: :reply_confirm
    end

    event :complete_message do
      transitions from: :message_confirm, to: :message_completed
    end

    event :complete_reply do
      transitions from: :reply_confirm, to: :reply_completed
    end

    event :initiate_payment do
      transitions from: :message_completed, to: :payment_initiated
    end

    event :complete_payment do
      transitions from: :payment_initiated, to: :payment_completed
    end

    event :end_conversation do
      transitions to: :waiting
    end
  end

  def celeb?
    !celeb.blank?
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
      self.send((com.to_s + '!').to_sym)
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
    else
      state_enter_guide
    end
  end

  def optin(target_type, target_id)
    case target_type.to_sym
      when :CLB
        self.celeb = Celeb.find(target_id)
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
          original_msg = Message.find(target_id)
          if original_msg.delivered?
            Message.create({
                             initial_message_id: original_msg.id,
                             sending_user_id: id,
                             receiving_user_id: original_msg.sending_user_id
                           })
            command(:initiate_reply)
          elsif original_msg.replied?
            already_replied_error
          else
            reply_error
          end
        else
          optin_reply_error
        end

    end
  end

end

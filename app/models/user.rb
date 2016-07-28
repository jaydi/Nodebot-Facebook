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
    @message ||= Message.on_progress(id).last
  end

  def optin(target_type, target_id)
    case target_type
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
          command(:INIT_MSG)
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
            command(:INIT_RPL)
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

  def command(com)
    begin
      case com
        when :INIT_MSG
          initiate_message!
        when :INIT_RPL
          initiate_reply!
        when :STRT_MSG
          start_messaging!
        when :STRT_RPL
          start_replying!
        when :CONF_MSG
          confirm_message!
        when :CONF_RPL
          confirm_reply!
        when :CMPT_MSG
          complete_message!
        when :CMPT_RPL
          complete_reply!
        when :INIT_PAY
          initiate_payment!
        when :CMPT_PAY
          complete_payment!
        when :END_CONV
          end_conversation!
      end
    rescue AASM::InvalidTransition
      state_transition_error
    end
  end

  def state_enter_action
    case status.to_sym
      when :waiting
        unless current_message.blank?
          if current_message.completed?
            current_message.deliver!
          else
            current_message.cancel!
          end
        end
      when :message_initiated
      when :reply_initiated
      when :messaging
      when :replying
      when :message_confirm
      when :reply_confirm
      when :message_completed
        current_message.complete!
      when :reply_completed
        current_message.complete!
        current_message.deliver!
      when :payment_initiated
        Payment.create({
                         message_id: current_message.id,
                         sending_user_id: current_message.sending_user_id,
                         receiving_user_id: current_message.receiving_user_id,
                         pay_amount: current_message.receiver.celeb.price
                       })
      when :payment_completed
        current_message.deliver!
    end
  end

  def text_message(text)
    if messaging?
      msg = current_message
      msg.text = text
      msg.save!
      command(:CONF_MSG)
    else
      state_enter_guide
    end
  end

  def video_message(video_url)
    if replying?
      msg = current_message
      msg.video_url = video_url
      msg.save!
      command(:CONF_RPL)
    else
      state_enter_guide
    end
  end

end

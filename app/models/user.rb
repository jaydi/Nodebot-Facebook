class User < ActiveRecord::Base
  include AASM

  has_many :sent_messages, class_name: 'Message', foreign_key: :sending_user_id
  has_many :received_messages, class_name: 'Message', foreign_key: :receiving_user_id

  belongs_to :celeb

  enum status: {
    waiting: 10,
    message_initiated: 20,
    reply_initiated: 21,
    messaging: 30,
    replying: 31,
    message_completed: 40,
    reply_completed: 41,
    payment_initiated: 50,
    payment_completed: 60
  }

  aasm column: :status, enum: true do
    state :waiting, initial: true
    state :message_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :reply_initiated, after_enter: [:state_enter_action, :state_enter_guide]
    state :messaging, after_enter: [:state_enter_action, :state_enter_guide]
    state :replying, after_enter: [:state_enter_action, :state_enter_guide]
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

    event :complete_message do
      transitions from: :messaging, to: :message_completed
    end

    event :complete_reply do
      transitions from: :replying, to: :reply_completed
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
    @msg ||= Message.where(sending_user_id: id).last
    if @msg.initiated? or @msg.completed?
      @msg
    else
      nil
    end
  end

  def command(com)
    case com
      when :INIT_MSG
        initiate_message!
      when :INIT_RPL
        initiate_reply!
      when :STRT_MSG
        start_messaging!
      when :STRT_RPL
        start_replying!
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
  end

  def state_enter_action
    case status.to_sym
      when :waiting
        if !current_message.blank?
          current_message.cancel!
        end
      when :message_initiated
      when :reply_initiated
      when :messaging
      when :replying
      when :message_completed
        current_message.complete!
      when :reply_completed
        current_message.complete!
        current_message.deliver!
      when :payment_initiated
        msg = current_message
        Payment.create({
                         message_id: msg.id,
                         sending_user_id: msg.sending_user_id,
                         receiving_user_id: msg.receiving_user_id,
                         pay_amount: msg.receiver.celeb.price
                       })
      when :payment_completed
        current_message.deliver!
    end
  end

  def state_enter_guide
    case status.to_sym
      when :message_initiated
        quick_reply_strt_msg = QuickReply.new({title: 'Yes', payload: 'STRT_MSG'})
        quick_reply_end_conv = QuickReply.new({title: 'No', payload: 'END_CONV'})
        quick_replies = [quick_reply_strt_msg, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "want to send message to #{current_message.receiver.name}?", quick_replies)

      when :reply_initiated
        quick_reply_strt_rpl = QuickReply.new({title: 'Yes', payload: 'STRT_RPL'})
        quick_reply_end_conv = QuickReply.new({title: 'No', payload: 'END_CONV'})
        quick_replies = [quick_reply_strt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "want to send reply to #{current_message.sender.name}?", quick_replies)

      when :messaging
        Waikiki::MessageSender.send_text_message(self, "input text")

      when :replying
        Waikiki::MessageSender.send_text_message(self, "input video")

      when :message_completed
        quick_reply_init_pay = QuickReply.new({title: 'Ok', payload: 'INIT_PAY'})
        quick_reply_end_conv = QuickReply.new({title: 'No', payload: 'END_CONV'})
        quick_replies = [quick_reply_init_pay, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "pay now to get replied", quick_replies)

      when :reply_completed
        Waikiki::MessageSender.send_text_message(self, "well done replying")

      when :payment_initiated
        button_pay = Button.new({type: 'web_url', url: "#{APP_CONFIG[:host_url]}/payments/#{current_message.payment.id}", title: 'PAY'})
        buttons = [button_pay]
        Waikiki::MessageSender.send_button_message(self, "click to pay", buttons)

      when :payment_completed
        Waikiki::MessageSender.send_text_message(self, "well done messaging")

    end
  end

  def optin(target_type, target_id)
    case target_type
      when :CLB
        self.celeb = Celeb.find(target_id)
        self.save!
        Waikiki::MessageSender.send_text_message(self, "welcome celeb!")

      when :MSG
        if waiting?
          Message.create({
                           sending_user_id: id,
                           receiving_user_id: target_id
                         })
          command(:INIT_MSG)
        end

      when :RPL
        if waiting?
          original_msg = Message.find(target_id)
          Message.create({
                           initial_message_id: original_msg.id,
                           sending_user_id: id,
                           receiving_user_id: original_msg.sending_user_id
                         })
          command(:INIT_RPL)
        end

    end
  end

  def text_message(text)
    if messaging?
      msg = current_message
      msg.text = text
      msg.save!
      command(:CMPT_MSG)
    end
  end

  def video_message(video_url)
    if replying?
      msg = current_message
      msg.video_url = video_url
      msg.save!
      command(:CMPT_RPL)
    end
  end

end

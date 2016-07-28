module UserHelper

  def optin_celeb_guide
    Waikiki::MessageSender.send_text_message(self, "welcome celeb!")
  end

  def optin_message_error
    Waikiki::MessageSender.send_text_message(self, "message on process")
    state_enter_guide
  end

  def optin_reply_error
    Waikiki::MessageSender.send_text_message(self, "reply on process")
    state_enter_guide
  end

  def already_replied_error
    Waikiki::MessageSender.send_text_message(self, "already replied")
  end

  def reply_error
    Waikiki::MessageSender.send_text_message(self, "reply error")
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

      when :message_confirm
        quick_reply_cmpt_msg = QuickReply.new({title: 'Confirm', payload: 'CMPT_MSG'})
        quick_reply_end_conv = QuickReply.new({title: 'Cancel', payload: 'END_CONV'})
        quick_replies = [quick_reply_cmpt_msg, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "confirm your message\n\n#{current_message.text}", quick_replies)

      when :reply_confirm
        quick_reply_cmpt_rpl = QuickReply.new({title: 'Confirm', payload: 'CMPT_RPL'})
        quick_reply_end_conv = QuickReply.new({title: 'Cancel', payload: 'END_CONV'})
        quick_replies = [quick_reply_cmpt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "confirm your video", quick_replies)

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

  def state_transition_error
    Waikiki::MessageSender.send_text_message(self, "invalid transition")
  end

  def notify_reply(reply_msg)
    begin
      Waikiki::MessageSender.send_attachment_message(self, Attachment.new({type: 'video', payload: reply_msg.video_url}))
    rescue HTTPClient::TimeoutError
      my_logger.error "reply message #{reply_msg.id} raised an error with http-timeout"
    end
    Waikiki::MessageSender.send_text_message(self, "Reply arrived from #{reply_msg.sender.celeb.name}")
  end

  def notify_refund(refund_payment)
    Waikiki::MessageSender.send_text_message(self, "#{refund_payment.message.text}\n\n above message wasted, #{refund_payment.pay_amount} refunded")
  end

end
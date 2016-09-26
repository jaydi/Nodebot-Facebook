module UserHelper

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

  def state_enter_guide
    case status.to_sym
      when :message_initiated
        quick_reply_strt_msg = QuickReply.new({title: '네', payload: 'start_messaging'})
        quick_reply_end_conv = QuickReply.new({title: '아니오', payload: 'end_conversation'})
        quick_replies = [quick_reply_strt_msg, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "#{current_message.receiver.celeb.name}님에게 메시지를 보내시겠어요?", quick_replies)

      when :reply_initiated
        quick_reply_strt_rpl = QuickReply.new({title: '네', payload: 'start_replying'})
        quick_reply_end_conv = QuickReply.new({title: '아니오', payload: 'end_conversation'})
        quick_replies = [quick_reply_strt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "#{current_message.receiver.name}에게 답장하시겠어요?", quick_replies)

      when :messaging
        Waikiki::MessageSender.send_text_message(self, "하고싶은 말을 입력해주세요.")

      when :replying
        Waikiki::MessageSender.send_text_message(self, "15초 이내의 동영상으로 답장해주세요.")

      when :message_confirm
        quick_reply_cmpt_msg = QuickReply.new({title: '확인', payload: 'complete_message'})
        quick_reply_end_conv = QuickReply.new({title: '취소', payload: 'end_conversation'})
        quick_replies = [quick_reply_cmpt_msg, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "입력한 메시지를 확인해주세요\n\n#{current_message.text}", quick_replies)

      when :reply_confirm
        quick_reply_cmpt_rpl = QuickReply.new({title: '확인', payload: 'complete_reply'})
        quick_reply_end_conv = QuickReply.new({title: '취소', payload: 'end_conversation'})
        quick_replies = [quick_reply_cmpt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "답장 동영상을 전달합니다.", quick_replies)

      when :message_completed
        quick_reply_init_pay = QuickReply.new({title: '그래요', payload: 'initiate_payment'})
        quick_reply_end_conv = QuickReply.new({title: '됐어요', payload: 'end_conversation'})
        quick_replies = [quick_reply_init_pay, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, "지금 결제하면 답장을 받을 수 있어요! 만약 내일 자정까지 답장이 없으면, 결제한 금액은 전액 환불됩니다. 결제하고 답장을 받아보시겠어요?", quick_replies)

      when :reply_completed
        Waikiki::MessageSender.send_text_message(self, "답장을 전달했습니다. :)")

      when :payment_initiated
        button_pay = Button.new({type: 'web_url', url: "#{APP_CONFIG[:host_url]}/payments/#{current_message.payment.id}", title: '결제'})
        buttons = [button_pay]
        Waikiki::MessageSender.send_button_message(self, "아래 링크에서 결제를 진행해주세요.", buttons)

      when :payment_completed
        Waikiki::MessageSender.send_text_message(self, "메시지를 전달했습니다. :)")

    end
  end

  def optin_celeb_guide
    Waikiki::MessageSender.send_text_message(self, "메신저와 연결되었습니다.")
  end

  def optin_message_error
    Waikiki::MessageSender.send_text_message(self, "작성중인 메시지가 있습니다.")
    state_enter_guide
  end

  def optin_reply_error
    Waikiki::MessageSender.send_text_message(self, "작성중인 답장이 있습니다.")
    state_enter_guide
  end

  def already_replied_error
    Waikiki::MessageSender.send_text_message(self, "이미 답장한 메시지입니다.")
  end

  def reply_error
    Waikiki::MessageSender.send_text_message(self, "답장 전달에 실패했습니다.")
  end

  def notify_reply(reply_msg)
    begin
      Waikiki::MessageSender.send_attachment_message(self, Attachment.new({type: 'video', payload: reply_msg.video_url}))
      button_reply = Button.new({type: 'postback', title: '답장하기', payload: "reply_to:#{reply_msg.id}"})
      buttons = [button_reply]
      Waikiki::MessageSender.send_button_message(self, '', buttons)
      Waikiki::MessageSender.send_text_message(self, "#{reply_msg.sender.celeb.name}에게서 답장을 받았습니다!")
    rescue HTTPClient::TimeoutError
      my_logger.error "reply message #{reply_msg.id} raised an error with http-timeout"
    end
  end

  def notify_refund(refund_payment)
    Waikiki::MessageSender.send_text_message(self, "#{refund_payment.message.text}\n\n#{refund_payment.message.receiver.celeb.name}에게 보낸 위 메시지에 대해 답장을 받지 못했습니다.. #{refund_payment.pay_amount}원 환불완료.")
  end

  def state_transition_error
    Waikiki::MessageSender.send_text_message(self, "수행할 수 없는 명령입니다.")
  end

end
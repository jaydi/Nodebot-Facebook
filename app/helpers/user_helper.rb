module UserHelper

  def state_enter_action
    case status.to_sym
      when :waiting
        current_message.cancel! if current_message.present? and (current_message.message_initiated? or current_message.message_confirm?)

      when :nickname_setting

      when :message_initiated

      when :reply_initiated

      when :messaging

      when :replying

      when :message_confirm

      when :reply_confirm

      when :message_completed
        current_message.complete!
        current_message.deliver!

      when :reply_completed
        current_message.complete!
        current_message.deliver!

      when :payment_initiated
        Payment.create({
                         message_id: current_message.id,
                         pay_amount: current_message.receiver.celeb.price,
                         status: Payment.statuses[:pay_request]
                       })

      when :payment_completed

      when :payment_cancelled
        current_message.payment.waste!

    end
  end

  def state_enter_guide
    case status.to_sym
      when :waiting
        if status_changed?
          if status_was == "message_completed"
            msg_str = "알겠습니다. 메시지는 잘 전달했어요. :)"
            Waikiki::MessageSender.send_text_message(self, msg_str)
          elsif status_was == "message_confirm" or status_was == "reply_confirm" or status_was == "message_initiated" or status_was == "reply_initiated"
            msg_str = "저는 그럼 이만.."
            Waikiki::MessageSender.send_text_message(self, msg_str)
          end
        end

      when :nickname_setting
        msg_str = "사용할 닉네임을 10자 이내로 입력해주세요."
        Waikiki::MessageSender.send_text_message(self, msg_str)

      when :message_initiated
        if newbie?
          msg_str = "안녕하세요, #{name}님. 키키봇입니다. 저를 통해 #{current_message.receiver.celeb.name}님과 메시지를 주고받을 수 있어요."
          msg_str += " 제게 메시지를 보내면, #{current_message.receiver.celeb.name}님에게 전달됩니다."
          msg_str += " #{current_message.receiver.celeb.name}님이 영상답장을 하면, #{name}님에게 바로 전달해드려요."
          Waikiki::MessageSender.send_text_message(self, msg_str)

          msg_str = "먼저, BJ와의 메시징에 사용할 닉네임을 설정하시겠어요? 지금 사용하고 계신 이름은 #{name} 입니다."
          quick_reply_set_nickname = QuickReply.new({title: '닉네임 설정', payload: 'start_setting_nickname'})
          quick_reply_use_current_name = QuickReply.new({title: '현재 이름 사용', payload: 'start_messaging'})
          quick_replies = [quick_reply_set_nickname, quick_reply_use_current_name]
          Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)
        else
          msg_str = "안녕하세요, #{name}님. #{current_message.receiver.celeb.name}님과 대화를 시작합니다. :)"
          quick_reply_strt_msg = QuickReply.new({title: '네', payload: 'start_messaging'})
          quick_reply_end_conv = QuickReply.new({title: '아니오', payload: 'end_conversation'})
          quick_replies = [quick_reply_strt_msg, quick_reply_end_conv]
          Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)
        end

      when :messaging
        msg_str = "메시지를 입력해주세요. 텍스트 메시지만 전달할 수 있어요."
        Waikiki::MessageSender.send_text_message(self, msg_str)

      when :message_confirm
        msg_str = "#{current_message.text}\n\n위 내용을 전달할게요."
        quick_reply_cmpt_msg = QuickReply.new({title: '네', payload: 'complete_message'})
        quick_reply_restrt_msg = QuickReply.new({title: '다시 쓸래요', payload: 'start_messaging'})
        quick_reply_end_conv = QuickReply.new({title: '관둘래요', payload: 'end_conversation'})
        quick_replies = [quick_reply_cmpt_msg, quick_reply_restrt_msg, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)

      when :message_completed
        msg_str = "#{current_message.receiver.celeb.name}님은 #{current_message.receiver.celeb.price}원을 결제하면, 10초 내외의 영상답장을 해드리고 있어요. 익일 자정까지 답장을 못 할 경우, 결제금액은 전액 환불됩니다. 결제하시겠어요?"
        quick_reply_init_pay = QuickReply.new({title: '좋아요!', payload: 'initiate_payment'})
        quick_reply_end_conv = QuickReply.new({title: '이걸로 됐어요', payload: 'end_conversation'})
        quick_replies = [quick_reply_init_pay, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)

      when :payment_initiated
        msg_str = "#{current_message.receiver.celeb.price}원을 결제합니다. 아래 링크에서 결제를 진행해주세요."
        button_kakao_pay = Button.new({type: 'web_url', url: "#{APP_CONFIG[:host_url]}/payments/#{current_message.payment.id}", title: '카카오페이'})
        button_cancel = Button.new({type: 'postback', title: '취소', payload: "cancel_payment"})
        buttons = [button_kakao_pay, button_cancel]
        Waikiki::MessageSender.send_button_message(self, msg_str, buttons)

      when :payment_completed
        msg_str = "메시지를 전달했습니다. 답장영상이 도착하면 바로 전달해드릴게요. :)"
        Waikiki::MessageSender.send_text_message(self, msg_str)

      when :payment_cancelled
        msg_str = "알겠습니다. 메시지는 잘 전달했어요. :)"
        Waikiki::MessageSender.send_text_message(self, msg_str)

      when :reply_initiated
        msg_str = "#{current_message.receiver.name}님에게 답장을 시작합니다."
        quick_reply_strt_rpl = QuickReply.new({title: '응', payload: 'start_replying'})
        quick_reply_end_conv = QuickReply.new({title: '아니야 됐어', payload: 'end_conversation'})
        quick_replies = [quick_reply_strt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)

      when :replying
        msg_str = "영상메시지를 보내주세요. 적어도 10초 이상의 셀카동영상으로 부탁드려요."
        Waikiki::MessageSender.send_text_message(self, msg_str)

      when :reply_confirm
        msg_str = "이 영상으로 전달할게요."
        quick_reply_cmpt_rpl = QuickReply.new({title: '응 이걸로 보내', payload: 'complete_reply'})
        quick_reply_restrt_rpl = QuickReply.new({title: '다시 할래', payload: 'start_replying'})
        quick_reply_end_conv = QuickReply.new({title: '관둘래', payload: 'end_conversation'})
        quick_replies = [quick_reply_cmpt_rpl, quick_reply_restrt_rpl, quick_reply_end_conv]
        Waikiki::MessageSender.send_quick_reply_message(self, msg_str, quick_replies)

      when :reply_completed
        msg_str = "답장을 전달했어요. #{self.celeb.price * 7 / 10}원의 수익을 얻으셨습니다. :)"
        Waikiki::MessageSender.send_text_message(self, msg_str)

    end
  end

  def state_exit_guide
    case status.to_sym
      when :nickname_setting
        msg_str = "#{name}님! 닉네임이 설정되었습니다. 이제 #{current_message.receiver.celeb.name}님과 대화를 시작합니다. :)"
        Waikiki::MessageSender.send_text_message(self, msg_str)
    end
  end

  def optin_celeb_guide
    Waikiki::MessageSender.send_text_message(self, "메신저와 연결되었습니다. 환영해요, #{celeb.name}님! :)")
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

  def notify_reply(reply_msg)
    begin
      Waikiki::MessageSender.send_attachment_message(self, Attachment.new({type: 'video', payload: reply_msg.video_url}))
    rescue HTTPClient::TimeoutError
      my_logger.error "reply message #{reply_msg.id} raised an error with http-timeout"
    end

    msg_str = "#{reply_msg.sender.celeb.name}에게서 답장을 받았어요!"
    Waikiki::MessageSender.send_text_message(self, msg_str)

    msg_str = "버튼을 눌러서 대화를 이어갈 수 있어요."
    button_reply = Button.new({type: 'postback', title: '답장하기', payload: "reply_to:#{reply_msg.id}"})
    buttons = [button_reply]
    Waikiki::MessageSender.send_button_message(self, msg_str, buttons)
  end

  def notify_pay_fail(failed_payment)
    Waikiki::MessageSender.send_text_message(self, "결제에 실패했습니다.\n에러메시지: #{failed_payment.pg_message}")
    state_enter_guide
  end

  def notify_cancel(canceled_payment)
    Waikiki::MessageSender.send_text_message(self, "#{canceled_payment.message.text}\n\n#{canceled_payment.message.receiver.celeb.name}님이 위 메시지에 대해 답장을 못하셨습니다.. :( #{canceled_payment.pay_amount}원 환불해드렸어요.")
  end

  def state_transition_error
    Waikiki::MessageSender.send_text_message(self, "지금은 수행할 수 없는 명령입니다.")
  end

end
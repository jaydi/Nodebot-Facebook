module UserHelper

  def state_enter_action
    case status.to_sym
      when :message_completed
        current_message.complete!

      when :message_cancelled
        current_message.cancel!

      when :payment_rejected
        current_message.deliver! if current_message.present? and current_message.completed?

      when :payment_initiated
        Payment.create({
                         message_id: current_message.id,
                         pay_amount: current_message.receiver.celeb.price,
                         status: Payment.statuses[:pay_request]
                       })

      when :payment_completed
        current_message.deliver!

      when :payment_cancelled
        current_message.payment.waste!
        current_message.deliver!

      when :reply_completed
        current_message.complete!
        current_message.deliver!

      when :reply_cancelled
        current_message.cancel!

    end
  end

  def state_enter_message
    case status.to_sym
      when :nickname_setting
        msg_str = "사용할 닉네임을 10자 이내로 입력해주세요."
        send_text(msg_str)

      when :nickname_set
        msg_str = "#{name}님! 닉네임이 설정되었습니다. 이제 #{current_message.receiver.celeb.name}님과 대화를 시작합니다. :)"
        send_text(msg_str)

      when :message_initiated
        if newbie?
          msg_str = "안녕하세요, #{name}님. 키키봇입니다. 저를 통해 #{current_message.receiver.celeb.name}님과 메시지를 주고받을 수 있어요."
          msg_str += " 제게 메시지를 보내면, #{current_message.receiver.celeb.name}님에게 전달됩니다."
          msg_str += " #{current_message.receiver.celeb.name}님이 영상답장을 하면, #{name}님에게 바로 전달해드려요."
          send_text(msg_str)

          msg_str = "먼저, BJ와의 메시징에 사용할 닉네임을 설정하시겠어요? 지금 사용하고 계신 이름은 #{name} 입니다."
          send_quick_replies(msg_str, quick_replies: [
            {title: '닉네임 설정', payload: 'start_setting_nickname'},
            {title: '현재 이름 사용', payload: 'start_messaging'}
          ])
        else
          msg_str = "안녕하세요, #{name}님. #{current_message.receiver.celeb.name}님과 대화를 시작합니다. :)"
          send_quick_replies(msg_str, quick_replies: [
            {title: '네', payload: 'start_messaging'},
            {title: '아니오', payload: 'cancel_message'}
          ])
        end

      when :messaging
        msg_str = "메시지를 입력해주세요. 텍스트 메시지만 전달할 수 있어요."
        send_text(msg_str)

      when :message_confirm
        msg_str = "#{current_message.text}\n\n위 내용을 전달할게요."
        send_quick_replies(msg_str, quick_replies: [
          {title: '네', payload: 'complete_message'},
          {title: '다시 쓸래요', payload: 'start_messaging'},
          {title: '관둘래요', payload: 'cancel_message'}
        ])

      when :message_completed
        msg_str = "#{current_message.receiver.celeb.name}님은 #{current_message.receiver.celeb.price}원을 결제하면, 10초 내외의 영상답장을 해드리고 있어요."
        msg_str += " 익일 자정까지 답장을 못 할 경우, 결제금액은 전액 환불됩니다. 결제하시겠어요?"
        send_quick_replies(msg_str, quick_replies: [
          {title: '좋아요!', payload: 'initiate_payment'},
          {title: '이걸로 됐어요', payload: 'end_conversation'}
        ])

      when :message_cancelled
        msg_str = "알겠습니다. 저는 그럼 이만.."
        send_text(msg_str)

      when :payment_rejected
        msg_str = "알겠습니다. 메시지는 잘 전달했어요. :)"
        send_text(msg_str)

      when :payment_initiated
        msg_str = "#{current_message.receiver.celeb.price}원을 결제합니다. 아래 링크에서 결제를 진행해주세요."
        send_buttons(msg_str, buttons: [
          {type: 'web_url', url: "#{APP_CONFIG[:host_url]}/payments/#{current_message.payment.id}", title: '카카오페이'},
          {type: 'postback', title: '취소', payload: "cancel_payment"}
        ])

      when :payment_completed
        msg_str = "메시지를 전달했습니다. 답장영상이 도착하면 바로 전달해드릴게요. :)"
        send_text(msg_str)

      when :payment_cancelled
        msg_str = "알겠습니다. 메시지는 잘 전달했어요. :)"
        send_text(msg_str)

      when :reply_initiated
        msg_str = "#{current_message.receiver.name}님에게 답장을 시작합니다."
        send_quick_replies(msg_str, quick_replies: [
          {title: '응', payload: 'start_replying'},
          {title: '아니야 됐어', payload: 'end_conversation'}
        ])

      when :replying
        msg_str = "영상메시지를 보내주세요. 적어도 10초 이상의 셀카동영상으로 부탁드려요."
        send_text(msg_str)

      when :reply_confirm
        msg_str = "이 영상으로 전달할게요."
        send_quick_replies(msg_str, quick_replies: [
          {title: '응 이걸로 보내', payload: 'complete_reply'},
          {title: '다시 할래', payload: 'start_replying'},
          {title: '관둘래', payload: 'end_conversation'}
        ])

      when :reply_completed
        msg_str = "답장을 전달했어요. #{self.celeb.price * 7 / 10}원의 수익을 얻으셨습니다. :)"
        send_text(msg_str)

      when :reply_cancelled
        msg_str = "알겠습니다. 저는 그럼 이만.."
        send_text(msg_str)

    end
  end

  def optin_celeb_guide
    send_text("메신저와 연결되었습니다. 환영해요, #{celeb.name}님! :)")
  end

  def optin_message_error
    send_text("작성중인 메시지가 있습니다.")
    state_enter_message
  end

  def optin_reply_error
    send_text("작성중인 답장이 있습니다.")
    state_enter_message
  end

  def already_replied_error
    send_text("이미 답장한 메시지입니다.")
  end

  def notify_reply(reply_msg)
    begin
      send_attachment({type: 'video', payload: reply_msg.video_url})
    rescue HTTPClient::TimeoutError
      my_logger.error "reply message #{reply_msg.id} raised an error with http-timeout"
    end

    msg_str = "#{reply_msg.sender.celeb.name}에게서 답장을 받았어요!"
    send_text(msg_str)

    msg_str = "버튼을 눌러서 대화를 이어갈 수 있어요."
    send_buttons(msg_str, buttons: [
      {type: 'postback', title: '답장하기', payload: "reply_to:#{reply_msg.id}"}
    ])
  end

  def notify_pay_fail(failed_payment)
    send_text("결제에 실패했습니다.\n에러메시지: #{failed_payment.pg_message}")
    state_enter_message
  end

  def notify_cancel(canceled_payment)
    send_text("#{canceled_payment.message.text}\n\n#{canceled_payment.message.receiver.celeb.name}님이 위 메시지에 대해 답장을 못하셨습니다.. :( #{canceled_payment.pay_amount}원 환불해드렸어요.")
  end

  def invalid_command_error
    send_text("수행할 수 없는 명령입니다.")
  end

end
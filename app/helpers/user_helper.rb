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
                         sender_id: current_message.sender_id,
                         receiver_id: current_message.receiver_id,
                         pay_amount: current_message.receiver.price,
                         commission_rate: current_message.receiver.commission_rate,
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
        msg_str = "#{name}님! 닉네임이 설정되었습니다. 이제 #{current_message.receiver_name}님과 대화를 시작합니다. :)"
        send_text(msg_str)

      when :message_initiated
        if is_newbie?
          msg_str = "안녕하세요, #{name}님. 키키봇입니다. 저를 통해 #{current_message.receiver_name}님과 메시지를 주고받을 수 있어요."
          msg_str += " 제게 메시지를 보내면, #{current_message.receiver_name}님에게 전달됩니다."
          msg_str += " #{current_message.receiver_name}님이 영상답장을 하면, #{name}님에게 바로 전달해드려요."
          send_text(msg_str)

          msg_str = "먼저, 메시징에 사용할 닉네임을 설정하시겠어요? 지금 사용하고 계신 이름은 #{name} 입니다."
          send_quick_replies(msg_str, quick_replies: [
            {title: '닉네임 설정', payload: 'start_setting_nickname'},
            {title: '현재 이름 사용', payload: 'start_messaging'}
          ])
        else
          msg_str = "안녕하세요, #{name}님. #{current_message.receiver_name}님과 대화를 시작합니다. :)"
          send_quick_replies(msg_str, quick_replies: [
            {title: '네', payload: 'start_messaging'},
            {title: '아니오', payload: 'cancel_message'}
          ])
        end

      when :messaging
        msg_str = "메시지를 입력해주세요. 텍스트 메시지만 전달할 수 있어요."
        send_text(msg_str)

      when :message_confirm
        msg_str = "위 내용을 전달할게요."
        send_quick_replies(msg_str, quick_replies: [
          {title: '네', payload: 'complete_message'},
          {title: '다시 쓸래요', payload: 'start_messaging'},
          {title: '관둘래요', payload: 'cancel_message'}
        ])

      when :message_completed
        msg_str = "#{current_message.receiver_name}님은 #{current_message.receiver.price}원을 후원하면, 영상으로 감사인사와 함께 답장을 드리고 있어요."
        msg_str += " 24시간 내에 답장을 못 받을 경우, 후원금은 전액 환불됩니다. 후원하시겠어요?"
        send_quick_replies(msg_str, quick_replies: [
          {title: '좋아요!', payload: 'initiate_payment'},
          {title: '이걸로 됐어요', payload: 'reject_payment'}
        ])

      when :message_cancelled
        msg_str = "알겠습니다. 저는 그럼 이만.."
        send_text(msg_str)

      when :payment_rejected
        msg_str = "알겠습니다. 메시지는 잘 전달했어요. :)"
        send_text(msg_str)

      when :payment_initiated
        msg_str = "#{current_message.receiver.price}원을 결제합니다. 아래 링크에서 진행해주세요."
        send_buttons(msg_str, buttons: [
          {type: 'web_url', url: pay_url(self, current_message.payment.id, :kakao), title: '카카오페이'},
          {type: 'postback', title: '취소', payload: "cancel_payment"}
        ])

      when :payment_completed
        msg_str = "메시지를 전달했습니다. 답장영상이 도착하면 바로 전달해드릴게요. :)"
        send_text(msg_str)

      when :payment_cancelled
        msg_str = "결제가 취소되었습니다. 메시지는 잘 전달했어요. :)"
        send_text(msg_str)

      when :reply_initiated
        msg_str = "#{current_message.receiver_name}님에게 답장을 시작합니다."
        send_quick_replies(msg_str, quick_replies: [
          {title: '응', payload: 'start_replying'},
          {title: '아니야 됐어', payload: 'cancel_reply'}
        ])

      when :replying
        msg_str = "영상메시지를 보내주세요."
        send_text(msg_str)

      when :reply_confirm
        msg_str = "이걸로 전달할게요."
        send_quick_replies(msg_str, quick_replies: [
          {title: '응 이걸로 보내', payload: 'complete_reply'},
          {title: '다시 할래', payload: 'start_replying'},
          {title: '관둘래', payload: 'cancel_reply'}
        ])

      when :reply_completed
        msg_str = "답장을 전달했어요."
        send_text(msg_str)

      when :reply_cancelled
        msg_str = "알겠습니다. 저는 그럼 이만.."
        send_text(msg_str)

    end
  end

  def initial_guide_message
    testable_user = User.with_role(:admin).first
    if testable_user
      msg_str = "아래 링크에서 키키봇 튜토리얼을 해보세요!"
      send_buttons(msg_str, buttons: [
        {type: "web_url", url: "#{APP_CONFIG[:host_url]}/#{testable_user.name}", title: '튜토리얼'}
      ])
    end
  end

  def optin_partner_message
    send_text("메신저와 연결되었습니다. 환영해요! :)")
  end

  def notify_pay_fail(failed_payment)
    send_text("결제에 실패했습니다.\n에러메시지: #{failed_payment.pg_message}")
    state_enter_message
  end

  def notify_cancel(canceled_payment)
    send_text("#{canceled_payment.message.text}\n\n#{canceled_payment.receiver_name}님이 위 메시지에 대해 답장을 못하셨습니다.. :( #{canceled_payment.pay_amount}원 환불해드렸어요.")
  end

  def notify_reply(reply_msg)
    if reply_msg.video_url.present?
      begin
        send_attachment({type: 'video', payload: reply_msg.video_url})
      rescue HTTPClient::TimeoutError
        Rails.logger.error "reply message #{reply_msg.id} raised an error with http-timeout"
      rescue Waikiki::SendMessageError => e
        send_text("메시지 전송 오류")
        raise Waikiki::SendMessageError.new(e.message)
      end
    else
      send_text("#{reply_msg.sender_name}: #{reply_msg.text}")
    end

    msg_str = "#{reply_msg.sender_name}에게서 답장을 받았어요!"
    send_text(msg_str)

    msg_str = "버튼을 눌러서 대화를 이어갈 수 있어요."
    send_buttons(msg_str, buttons: [
      {type: 'postback', title: '답장하기', payload: "reply_to:#{reply_msg.id}"}
    ])
  end

  def notify_profit(payment)
    send_text("(#{payment.partner_share}원 적립)")
  end

  def notify_exchange_success(exchange_request)
    send_text("#{exchange_request.bank.name}의 #{exchange_request.account_holder}님 계좌로 #{exchange_request.amount}원 환전입금되었습니다. :)")
  end

  def notify_exchange_failure(exchange_request)
    send_text("#{exchange_request.bank.name}의 #{exchange_request.account_holder}님 계좌로 #{exchange_request.amount}원 환전처리가 실패했습니다. :(\n실패사유: #{exchange_request.failure_reason}")
  end

  def optin_message_error
    send_text("작성중인 메시지가 있습니다.")
    state_enter_message
  end

  def optin_reply_error
    send_text("작성중인 답장이 있습니다.")
    state_enter_message
  end

  def cannot_be_replied_error
    send_text("답장할 수 없는 메시지입니다.")
  end

  def invalid_command_error
    send_text("오류가 발생했습니다. 관리자에게 연락이 갔으니 잠시 뒤에 다시 시도해주세요. 죄송합니다.")
  end

end
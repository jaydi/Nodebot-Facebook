class WebMessagesController < ApplicationController

  def my_logger
    @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_#{self.class.name.underscore}.log")
  end

  def verify_webhook
    if params['hub.verify_token'] == 'this__is__nodebot__'
      render text: params['hub.challenge']
    else
      render text: 'Error, wrong validation token'
    end
  end

  def webhook
    web_messages.each do |wm|
      if wm.save!
        WebMessageHandlingJob.perform_later(wm.id)
        my_logger.info "saved web message with id: #{wm.id}"
      else
        my_logger.info "web message save error with params: #{params}"
      end
    end
    render :nothing => true, :status => 200
  end

  private

  def web_messages
    msgs = []
    params['entry'].each do |entry|
      entry['messaging'].each do |messaging|
        if messaging['message']
          msg = WebMessage.new({
                                 message_type: WebMessage.message_types[:text],
                                 message_id: messaging['message']['mid'],
                                 sender_id: messaging['sender']['id'],
                                 sequence: messaging['message']['seq'],
                                 text: messaging['message']['text'],
                                 sent_timestamp: messaging['timestamp']
                               })
          if messaging['message']['quick_reply']
            msg.message_type = WebMessage.message_types[:quick_reply]
            msg.payload = messaging['message']['quick_reply']['payload']
          elsif messaging['message']['attachments']
            messaging['message']['attachments'].each do |att|
              case att['type']
                when 'image'
                  msg.message_type = WebMessage.message_types[:image]
                  # TODO
                when 'audio'
                  msg.message_type = WebMessage.message_types[:audio]
                  # TODO
                when 'video'
                  msg.message_type = WebMessage.message_types[:video]
                  # TODO
                when 'file'
                  msg.message_type = WebMessage.message_types[:file]
                  # TODO
                when 'location'
                  msg.message_type = WebMessage.message_types[:location]
                  # TODO
              end
            end
          end
        elsif messaging['postback']
          msg = WebMessage.new({
                                 message_type: WebMessage.message_types[:postback],
                                 sender_id: messaging['sender']['id'],
                                 payload: messaging['postback']['payload'],
                                 sent_timestamp: messaging['timestamp']
                               })
        elsif messaging['optin']
          # TODO
        elsif messaging['delivery']
          # TODO
        elsif messaging['read']
          # TODO
        end
        msgs.push msg unless msg.blank?
      end
    end
    msgs
  end

end
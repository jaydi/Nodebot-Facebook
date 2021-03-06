class WebMessagesController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!

  def verify_webhook
    if params['hub.verify_token'] == "#{APP_CONFIG[:fb_webhook_token]}"
      render text: params['hub.challenge'], status: 200
    else
      render text: 'error, wrong validation token', status: 200
    end
  end

  def webhook
    web_messages.each do |wm|
      if wm.save!
        WebMessageHandlingJob.perform_later(wm.id)
        my_logger.info "saved web message(#{wm.id}) with params: #{params}"
      else
        my_logger.info "web message save error with params: #{params}"
      end
    end
    render nothing: true, status: 200
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
                                 messenger_id: messaging['sender']['id'],
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
                  msg.payload = att['payload']['url']
                when 'audio'
                  msg.message_type = WebMessage.message_types[:audio]
                  msg.payload = att['payload']['url']
                when 'video'
                  msg.message_type = WebMessage.message_types[:video]
                  msg.payload = att['payload']['url']
                when 'file'
                  msg.message_type = WebMessage.message_types[:file]
                  msg.payload = att['payload']['url']
                when 'location'
                  msg.message_type = WebMessage.message_types[:location]
                  msg.payload = "#{att['payload']['coordinates.lat']},#{att['payload']['coordinates.long']}"
              end
            end
          end
        elsif messaging['postback']
          msg = WebMessage.new({
                                 message_type: WebMessage.message_types[:postback],
                                 messenger_id: messaging['sender']['id'],
                                 payload: messaging['postback']['payload'],
                                 sent_timestamp: messaging['timestamp']
                               })
        elsif messaging['optin']
          msg = WebMessage.new({
                                 message_type: WebMessage.message_types[:optin],
                                 messenger_id: messaging['sender']['id'],
                                 payload: messaging['optin']['ref'],
                                 sent_timestamp: messaging['timestamp']
                               })
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

  def my_logger
    @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_#{self.class.name.underscore}.log")
  end

end
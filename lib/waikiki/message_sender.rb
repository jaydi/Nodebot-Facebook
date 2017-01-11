module Waikiki
  class MessageSender
    ADMIN_USER_IDS = [1]

    class << self

      def my_logger
        @@my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_message_sender.log")
      end

      def header
        headers = {}
        headers.merge!(Waikiki::HTTPHeaders::JSON)
        headers
      end

      def body(user, msg_body)
        {
          recipient: {
            id: user.messenger_id
          },
          message: msg_body
        }.to_json
      end

      def send(user, msg_body)
        unless Rails.env.test?
          res = Waikiki::HttpPersistent.post("#{APP_CONFIG[:fb_graph_api_url]}/me/messages?access_token=#{APP_CONFIG[:fb_page_access_token]}", body(user, msg_body), header)
          json_res = JSON.parse(res.body)
          if json_res["error"]
            raise("send message failed with response: #{json_res}")
          else
            my_logger.info "sent message to user with sender id: #{user.messenger_id}"
          end
        end
      end

      def send_text_message(user, text)
        send(user, {text: text})
      end

      def send_quick_reply_message(user, text, quick_replies)
        send(user, {text: text, quick_replies: quick_replies})
      end

      def send_attachment_message(user, attachment)
        send(user, {attachment: attachment})
      end

      def send_button_message(user, text, buttons)
        send(user,
             attachment: {
               type: 'template',
               payload: {
                 template_type: 'button',
                 text: text,
                 buttons: buttons
               }
             }
        )
      end

      def send_generic_message(user, elements)
        send(user,
             attachment: {
               type: 'template',
               payload: {
                 template_type: 'generic',
                 elements: elements
               }
             }
        )
      end

      def send_to_admin(msg)
        if Rails.env.production?
          admin_users = User.where(id: ADMIN_USER_IDS)
          admin_users.each { |au| send_text_message(au, msg) }
        end
      end

    end

  end
end
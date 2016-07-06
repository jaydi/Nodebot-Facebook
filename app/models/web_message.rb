class WebMessage < ActiveRecord::Base

  enum message_types: {
    text: 10,
    quick_reply: 11,
    image: 12,
    audio: 13,
    video: 14,
    file: 15,
    location: 16,
    postback: 20
  }

  STARTERS = ['?', 'hi', 'hey', 'yo', 'hello', 'sup', 'knock knock']

  def process_message
    user = current_user
    case message_type
      when self.class.message_types[:text]
        if STARTERS.include? text.downcase
          help_message(user)
        else
          echo(user)
        end
      when self.class.message_types[:quick_reply]
        case payload
          when 'A'
            # TODO
        end
      when self.class.message_types[:postback]
        case payload
          when 'A'
            # TODO
          when 'B'
            # TODO
        end
    end
  end

  private

  def current_user
    current_user = User.find_by_sender_id(sender_id)
    if current_user.blank?
      # res = Waikiki::HttpPersistent.get("#{APP_CONFIG[:graph_api_url]}/#{sender_id}?fields=first_name,last_name,profile_pic,locale,timezone,gender&access_token=#{APP_CONFIG[:page_access_url]}")
      # json_res = JSON.parse(res.body)
      current_user = User.create({sender_id: sender_id})
    end
    current_user
  end

  def help_message(user)
    quick_reply_yes = QuickReply.new({content_type: 'text', title: 'Yes', payload: 'YES'})
    quick_reply_no = QuickReply.new({content_type: 'text', title: 'No', payload: 'NO'})
    quick_replies = [quick_reply_yes, quick_reply_no]
    Waikiki::MessageSender.send_quick_reply_message(user, "Hello World!", quick_replies)
  end

  def echo(user)
    Waikiki::MessageSender.send_text_message(user, text)
  end

end
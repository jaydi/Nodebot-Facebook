class WebMessage < ActiveRecord::Base

  enum message_types: {
    message: 10,
    postback: 20
  }

  STARTERS = ['?', 'hi', 'hey', 'yo', 'hello', 'sup', 'knock knock']

  def process_message
    user = current_user
    case message_type
      when self.class.message_types[:message]
        if STARTERS.include? text.downcase
          help_message(user)
        else
          echo(user)
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
    button_start = Waikiki::Button.new({type: 'web_url', url: 'https://www.google.com', title: 'Start'})
    buttons = [button_start]
    Waikiki::MessageSender.send_button_message(user, "Hello World!", buttons)
  end

  def echo(user)
    Waikiki::MessageSender.send_text_message(user, text)
  end

end
class WebMessage < ActiveRecord::Base

  enum message_types: {
    text: 10,
    quick_reply: 11,
    image: 12,
    audio: 13,
    video: 14,
    file: 15,
    location: 16,
    postback: 20,
    optin: 30,
    delivery: 40,
    read: 50
  }

  def process_message
    user = current_user
    case message_type
      when self.class.message_types[:quick_reply]
        user.command(payload)
      when self.class.message_types[:postback]
        user.command(payload)
      when self.class.message_types[:text]
        user.text_message(text)
      when self.class.message_types[:video]
        user.video_message(payload)
      when self.class.message_types[:optin]
        target_type, target_id = payload.split('_')
        user.optin(target_type, target_id)
      when self.class.message_types[:read]
        user.read_stamp(payload.to_i)
    end
  end

  private

  def current_user
    current_user = User.find_by_sender_id(sender_id)
    if current_user.blank?
      res = Waikiki::HttpPersistent.get("#{APP_CONFIG[:fb_graph_api_url]}/#{sender_id}?fields=first_name,last_name&access_token=#{APP_CONFIG[:fb_page_access_token]}")
      res_hash = JSON.parse(res.body)
      name = res_hash['last_name'] + res_hash['first_name']
      current_user = User.create({sender_id: sender_id, name: name})
    end
    current_user
  end

end
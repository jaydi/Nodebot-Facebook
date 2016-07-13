class QuickReply
  attr_accessor :content_type
  attr_accessor :title
  attr_accessor :payload

  def initialize(content_type: 'text', title: nil, payload: nil)
    @content_type = content_type
    @title = title
    @payload = payload
  end
end
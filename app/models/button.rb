class Button
  attr_accessor :type
  attr_accessor :url
  attr_accessor :title
  attr_accessor :payload

  def initialize(type: nil, url: nil, title: nil, payload: nil)
    @type = type
    @url = url
    @title = title
    @payload = payload
  end
end
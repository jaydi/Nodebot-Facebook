class Attachment
  attr_accessor :type
  attr_accessor :payload

  def initialize(type: nil, payload: nil)
    @type = type
    @payload = payload
  end
end
class Element
  attr_accessor :title
  attr_accessor :image_url
  attr_accessor :subtitle
  attr_accessor :buttons

  def initialize(title: nil, image_url: nil, subtitle: nil, buttons: nil)
    @title = title
    @image_url = image_url
    @subtitle = subtitle
    @buttons = buttons
  end
end
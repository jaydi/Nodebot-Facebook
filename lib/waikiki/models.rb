module Waikiki

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

    def self.type_web_url
      'web_url'
    end

    def self.type_postback
      'postback'
    end
  end

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

end
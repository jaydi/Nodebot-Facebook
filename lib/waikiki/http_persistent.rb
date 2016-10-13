require 'httpclient'

module Waikiki
  class HttpPersistent
    @@http = HTTPClient.new
    @@http.connect_timeout = 10
    @@http.receive_timeout = 10

    def self.get(url, headers = nil)
      response = nil
      begin
        response = @@http.get(url, header: headers)
      rescue HTTPClient::TimeoutError
        raise HTTPClient::TimeoutError.new("HTTP GET timed out. url=#{url}")
      end

      yield response if block_given?
      response
    end

    def self.post(url, params = nil, headers = nil)
      response = nil

      begin
        response = @@http.post(url, header: headers, body: params)
      rescue HTTPClient::TimeoutError
        raise HTTPClient::TimeoutError.new("HTTP POST timed out. url=#{url}, params=#{params}")
      end

      yield response if block_given?
      response
    end

    # def self.post_json(url, json)
    #   response = nil
    #
    #   begin
    #     response = @@http.post(url, header: HTTPHeaders::JSON, body: json)
    #   rescue HTTPClient::TimeoutError
    #     raise HTTPClient::TimeoutError.new("HTTP POST/json timed out. url=#{url}, body=#{json}")
    #   end
    #
    #   yield response if block_given?
    #   response
    # end

    def self.delete(url)
      response = nil

      begin
        response = @@http.delete(url)
      rescue HTTPClient::TimeoutError
        raise HTTPClient::TimeoutError.new("HTTP DELETE timed out. url=#{url}")
      end

      yield response if block_given?
      response
    end

    def self.put(url, params = nil, headers = nil)
      response = nil

      begin
        response = @@http.put(url, header: headers, body: params)
      rescue HTTPClient::TimeoutError
        raise HTTPClient::TimeoutError.new("HTTP PUT timed out. url=#{url}, params=#{params}")
      end

      yield response if block_given?
      response
    end

    def self.timeout(t)
      backup = @@http.receive_timeout
      @@http.receive_timeout = t
      yield
      @@http.receive_timeout = backup
    end
  end

  module HTTPHeaders
    JSON = {'Content-Type' => 'application/json'}
    AUTH = {'X-Access-Token' => "#{APP_CONFIG[:access_token]}"}
  end
end

module HTTP
  class Message
    def success?
      self.status == 200
    end

    def missing?
      self.status == 404
    end
  end
end

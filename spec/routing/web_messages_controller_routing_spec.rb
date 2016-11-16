require 'rails_helper'

describe WebMessagesController do
  it { expect(get: '/webhook').to route_to(controller: 'web_messages', action: 'verify_webhook') }
  it { expect(post: '/webhook').to route_to(controller: 'web_messages', action: 'webhook') }
end
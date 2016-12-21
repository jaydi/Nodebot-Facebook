require 'rails_helper'

describe ExchangeRequestsController do
  it { expect(get: '/celebs/exchange_requests/new').to route_to(controller: 'exchange_requests', action: 'new') }
  it { expect(post: '/celebs/exchange_requests').to route_to(controller: 'exchange_requests', action: 'create') }
end
require 'rails_helper'

describe ExchangeRequestsController do
  it { expect(get: '/exchange_requests').to route_to(controller: 'exchange_requests', action: 'index') }
  it { expect(get: '/exchange_requests/new').to route_to(controller: 'exchange_requests', action: 'new') }
  it { expect(post: '/exchange_requests').to route_to(controller: 'exchange_requests', action: 'create') }
end
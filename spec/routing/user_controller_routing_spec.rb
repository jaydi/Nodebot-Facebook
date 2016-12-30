require 'rails_helper'

describe UserSessionsController do
  it { expect(get: '/users/agreements').to route_to(controller: 'users', action: 'show_agreements') }
  it { expect(post: '/users/agreements').to route_to(controller: 'users', action: 'accept_agreements') }
end
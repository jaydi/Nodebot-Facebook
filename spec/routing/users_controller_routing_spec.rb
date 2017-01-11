require 'rails_helper'

describe UsersController do
  it { expect(get: '/users/pair').to route_to(controller: 'users', action: 'pair') }
  it { expect(get: '/users/agreements').to route_to(controller: 'users', action: 'show_agreements') }
  it { expect(post: '/users/agreements').to route_to(controller: 'users', action: 'accept_agreements') }
  it { expect(get: '/NAME').to route_to(controller: 'users', action: 'show_by_name', name: 'NAME') }
end
require 'rails_helper'

describe PaymentsController do
  it { expect(get: '/payments/1').to route_to(controller: 'payments', action: 'show', id: '1') }
  it { expect(post: '/payments/callback').to route_to(controller: 'payments', action: 'callback') }
end
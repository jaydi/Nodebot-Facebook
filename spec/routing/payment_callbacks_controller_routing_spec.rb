require 'rails_helper'

describe PaymentsController do
  it { expect(post: '/payments/callback').to route_to(controller: 'payment_callbacks', action: 'callback') }
end
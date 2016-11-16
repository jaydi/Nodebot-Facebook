require 'rails_helper'

describe WelcomeController do
  it { expect(get: '/').to route_to(controller: 'welcome', action: 'door') }
end
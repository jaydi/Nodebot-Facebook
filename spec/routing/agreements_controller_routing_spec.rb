require 'rails_helper'

RSpec.describe AgreementsController, type: :controller do
  it { expect(get: '/agreements/partner').to route_to(controller: 'agreements', action: 'show_partner') }
  it { expect(post: '/agreements/partner').to route_to(controller: 'agreements', action: 'create_partner') }
  it { expect(get: '/agreements/user').to route_to(controller: 'agreements', action: 'show_user') }
  it { expect(post: '/agreements/user').to route_to(controller: 'agreements', action: 'create_user') }
end

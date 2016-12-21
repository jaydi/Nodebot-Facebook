require 'rails_helper'

describe CelebsController do
  it { expect(get: '/Will').to route_to(controller: 'celebs', action: 'show_by_name', name: 'Will') }
  it { expect(get: '/celebs/new').to route_to(controller: 'celebs', action: 'new') }
  it { expect(post: '/celebs').to route_to(controller: 'celebs', action: 'create') }
  it { expect(get: '/celebs/edit').to route_to(controller: 'celebs', action: 'edit') }
  it { expect(put: '/celebs').to route_to(controller: 'celebs', action: 'update') }
  it { expect(patch: '/celebs').to route_to(controller: 'celebs', action: 'update') }
  it { expect(get: '/celebs/pair').to route_to(controller: 'celebs', action: 'pair') }
  it { expect(get: '/celebs/edit_password').to route_to(controller: 'celebs', action: 'edit_password') }
  it { expect(put: '/celebs/update_password').to route_to(controller: 'celebs', action: 'update_password') }
  it { expect(get: '/celebs/revenue_management').to route_to(controller: 'celebs', action: 'revenue_management') }
  it { expect(delete: '/celebs').to route_to(controller: 'celebs', action: 'destroy') }
end
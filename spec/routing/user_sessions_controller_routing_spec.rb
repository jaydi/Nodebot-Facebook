require 'rails_helper'

describe UserSessionsController do
  it { expect(get: '/user_sessions/new').to route_to(controller: 'user_sessions', action: 'new') }
  it { expect(post: '/user_sessions').to route_to(controller: 'user_sessions', action: 'create') }
  it { expect(get: '/user_sessions/request_new_password').to route_to(controller: 'user_sessions', action: 'request_new_password') }
  it { expect(post: '/user_sessions/send_new_password').to route_to(controller: 'user_sessions', action: 'send_new_password') }
  it { expect(delete: '/user_sessions/destroy').to route_to(controller: 'user_sessions', action: 'destroy') }
end
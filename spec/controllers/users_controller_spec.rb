require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  it 'should show agreements page' do
    get :show_agreements, {user_id: user.id}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show_agreements)
  end

  it 'should accept agreements' do
    payment_id = 1
    post :accept_agreements, {terms_accepted: true, privacy_accepted: true, user_id: user.id, pending_payment_id: payment_id}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(payment_path(id: payment_id))
  end
end

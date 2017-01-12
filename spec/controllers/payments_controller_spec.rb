require 'rails_helper'

RSpec.describe PaymentsController do
  let(:payment) { FactoryGirl.create(:payment) }

  it 'should show payment' do
    get :show, {id: payment.id, user_id: payment.sender_id}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show)
  end

  it 'should not show others payment' do
    get :show, {id: payment.id, user_id: payment.receiver_id}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(root_path)
  end

end
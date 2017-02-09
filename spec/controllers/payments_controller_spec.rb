require 'rails_helper'

RSpec.describe PaymentsController do
  let(:payment) { FactoryGirl.create(:payment) }

  it 'should redirect to agreements without agreements' do
    get :show, {id: payment.id, user_id: payment.sender_id, vendor: 'kakao'}
    expect(response.status).to eq(302)
    expect(response).to redirect_to agreements_user_path(user_id: payment.sender_id, pending_payment_id: payment.id, vendor: 'kakao')
  end

  it 'should not show others payment' do
    get :show, {id: payment.id, user_id: payment.receiver_id, vendor: 'kakao'}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(root_path)
  end

  it 'should show payment' do
    payment.sender.update_attributes({user_agreements_accepted: true})
    get :show, {id: payment.id, user_id: payment.sender_id, vendor: 'kakao'}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show)
  end

end
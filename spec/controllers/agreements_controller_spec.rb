require 'rails_helper'

RSpec.describe AgreementsController, type: :controller do

  it 'should show partner agreements' do
    get :show_partner
    expect(response.status).to eq(200)
    expect(response).to render_template(:show_partner)
  end

  it 'should proceed to sign up page' do
    post :create_partner, {terms_accepted: true, privacy_accepted: true}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_user_registration_path)
  end

  it 'should not proceed without agreement' do
    post :create_partner, {terms_accepted: true, privacy_accepted: false}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(agreements_partner_path)
  end

  it 'should show user agreements' do
    get :show_user, {user_id: 1, pending_payment_id: 1, vendor: 'naver'}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show_user)
  end

  it 'should proceed to payment page' do
    user = FactoryGirl.create(:user)
    post :create_user, {terms_accepted: true, privacy_accepted: true, user_id: user.id, pending_payment_id: 1, vendor: 'naver'}
    expect(user.reload.user_agreements_accepted).to be_truthy
    expect(response.status).to eq(302)
    expect(response).to redirect_to(payment_path(id: 1, user_id: 1, vendor: 'naver'))
  end

  it 'should not proceed without agreement' do
    post :create_user, {terms_accepted: true, privacy_accepted: false, user_id: 1, pending_payment_id: 1, vendor: 'naver'}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(agreements_user_path)
  end

end

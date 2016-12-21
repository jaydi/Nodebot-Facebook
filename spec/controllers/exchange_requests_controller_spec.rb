require 'rails_helper'

RSpec.describe ExchangeRequestsController, type: :controller do
  let(:celeb) { FactoryGirl.create(:celeb, balance: 20_000) }

  it 'should show new exchange request' do
    get :new, nil, {celeb_id: celeb.id}
    expect(response.status).to eq(200)
    expect(response).to render_template(:new)
  end

  it 'should create new exchange request' do
    post :create, { bank_id: 1, account_holder: 'will', account_number: 1234, amount: 10_000, password: celeb.password }, {celeb_id: celeb.id}
    expect(ExchangeRequest.count).to eq(1)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_revenue_management_path)
  end

  it 'should not create exchange request on false password' do
    post :create, { bank_id: 1, account_holder: 'will', account_number: 1234, amount: 10_000, password: 'false' }, {celeb_id: celeb.id}
    expect(ExchangeRequest.count).to eq(0)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_exchange_request_path)
  end

  it 'should not create exchange request on insufficient balance' do
    post :create, { bank_id: 1, account_holder: 'will', account_number: 1234, amount: 30_000, password: 'false' }, {celeb_id: celeb.id}
    expect(ExchangeRequest.count).to eq(0)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_exchange_request_path)
  end

end

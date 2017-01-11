require 'rails_helper'

RSpec.describe ExchangeRequestsController, type: :controller do
  let(:user) { FactoryGirl.create(:partner, balance: 10_000) }

  before(:each) do
    sign_in user
  end

  it 'should show index page' do
    get :index
    expect(response.status).to eq(200)
    expect(response).to render_template(:index)
  end

  it 'should show new exchange request' do
    get :new
    expect(response.status).to eq(200)
    expect(response).to render_template(:new)
  end

  it 'should create new exchange request' do
    post :create, {bank_id: 1, account_holder: 'will', account_number: 1234, amount: 10_000, password: user.password}
    expect(ExchangeRequest.count).to eq(1)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(exchange_requests_path)
  end

  it 'should not create exchange request on false password' do
    post :create, {bank_id: 1, account_holder: 'will', account_number: 1234, amount: 10_000, password: 'false'}
    expect(ExchangeRequest.count).to eq(0)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_exchange_request_path)
  end

  it 'should not create exchange request on insufficient balance' do
    post :create, {bank_id: 1, account_holder: 'will', account_number: 1234, amount: 20_000, password: user.password}
    expect(ExchangeRequest.count).to eq(0)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_exchange_request_path)
  end

end

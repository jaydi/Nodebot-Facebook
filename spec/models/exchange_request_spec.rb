require 'rails_helper'

describe ExchangeRequest do

  it 'should change associated values on creation' do
    user = FactoryGirl.create(:partner, balance: 10_000)
    balance_before = user.balance
    exchange_request = FactoryGirl.create(:exchange_request, user: user, amount: 5_000)
    balance_after = user.reload.balance
    expect(balance_before - balance_after).to eq(exchange_request.amount)
    expect(exchange_request.status).to eq('requested')
  end

  it 'should not be saved if balance is not enough' do
    user = FactoryGirl.create(:partner, balance: 5_000)
    bank = FactoryGirl.create(:bank)
    exchange_request = ExchangeRequest.new({
                                             user_id: user.id,
                                             bank_id: bank.id,
                                             account_holder: user.name,
                                             account_number: 1234,
                                             amount: 10_000
                                           })

    expect(exchange_request.save).to be_falsey
    expect(exchange_request.errors.messages.present?).to be_truthy
  end

  it 'can succeed' do
    exchange_request = FactoryGirl.create(:exchange_request)
    exchange_request.succeed!
    expect(exchange_request.status).to eq('succeeded')
  end

  it 'should change associated values on fail' do
    user = FactoryGirl.create(:partner, balance: 10_000)
    exchange_request = FactoryGirl.create(:exchange_request, user: user, amount: 5_000)
    balance_before = user.reload.balance
    exchange_request.fail!
    balance_after = user.reload.balance
    expect(exchange_request.status).to eq('failed')
    expect(balance_after - balance_before).to eq(exchange_request.amount)
  end

end
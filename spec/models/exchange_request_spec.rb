require 'rails_helper'

describe ExchangeRequest do

  it 'should change associated values on creation' do
    celeb = FactoryGirl.create(:celeb, balance: 10_000)
    balance_before = celeb.balance
    exchange_request = FactoryGirl.create(:exchange_request, celeb: celeb, amount: 5_000)
    balance_after = celeb.reload.balance
    expect(balance_before - balance_after).to eq(exchange_request.amount)
    expect(exchange_request.status).to eq('requested')
  end

  it 'should not be saved if balance is not enough' do
    celeb = FactoryGirl.create(:celeb, balance: 5_000)
    bank = FactoryGirl.create(:bank)
    exchange_request = ExchangeRequest.new({
                          celeb_id: celeb.id,
                          bank_id: bank.id,
                          account_holder: celeb.name,
                          account_number: 1234,
                          amount: 10_000
                        })

    expect(exchange_request.save).to be_falsey
    expect(exchange_request.errors).to include(:amount)
  end

  it 'can succeed' do
    exchange_request = FactoryGirl.create(:exchange_request)
    exchange_request.succeed!
    expect(exchange_request.status).to eq('succeeded')
  end

  it 'should change associated values on fail' do
    celeb = FactoryGirl.create(:celeb, balance: 10_000)
    exchange_request = FactoryGirl.create(:exchange_request, celeb: celeb, amount: 5_000)
    balance_before = celeb.reload.balance
    exchange_request.fail!
    balance_after = celeb.reload.balance
    expect(exchange_request.status).to eq('failed')
    expect(balance_after - balance_before).to eq(exchange_request.amount)
  end

end
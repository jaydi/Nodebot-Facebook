FactoryGirl.define do
  factory :exchange_request do
    user { FactoryGirl.create(:partner, balance: 20_000) }
    bank { FactoryGirl.create(:bank) }
    requester 'will'
    identity_string '123-45-100'
    account_holder 'will'
    account_number '1234'
    amount 10_000
  end
end

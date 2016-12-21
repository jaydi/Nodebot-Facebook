FactoryGirl.define do
  factory :exchange_request do
    celeb { FactoryGirl.create(:celeb, balance: 20_000) }
    bank { FactoryGirl.create(:bank) }
    account_holder 'will'
    account_number '1234'
    amount 10_000
  end
end

FactoryGirl.define do
  factory :payment do
    message { FactoryGirl.create(:message) }
    pay_amount 10000
  end
end

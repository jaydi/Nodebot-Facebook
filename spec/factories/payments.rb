FactoryGirl.define do
  factory :payment do
    message { FactoryGirl.create(:message, status: :delivered) }
    pay_amount 10000
  end
end

FactoryGirl.define do
  factory :payment do
    message { FactoryGirl.create(:message, status: :delivered) }
    pay_amount { message.receiver.celeb.price }
    commission_rate { message.receiver.celeb.commission_rate }
  end
end

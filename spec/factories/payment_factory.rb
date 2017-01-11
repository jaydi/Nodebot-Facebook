FactoryGirl.define do
  factory :payment do
    message { FactoryGirl.create(:message, status: :delivered) }
    sender_id { message.sender_id }
    receiver_id { message.receiver_id }
    pay_amount { message.receiver.price }
    commission_rate { message.receiver.commission_rate }
  end
end

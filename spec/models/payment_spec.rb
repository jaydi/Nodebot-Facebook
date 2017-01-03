require 'rails_helper'

describe Payment do

  it 'should change associated values after payment succeeded' do
    user = FactoryGirl.create(:user, status: :payment_initiated)
    message = FactoryGirl.create(:message, sender: user, status: :completed)
    payment = FactoryGirl.create(:payment, message: message)
    payment.succeed_pay!
    expect(message.reload.status).to eq('delivered')
    expect(user.reload.status).to eq('waiting')
  end

end
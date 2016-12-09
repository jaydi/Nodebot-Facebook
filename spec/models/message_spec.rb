require 'rails_helper'

describe Message do

  xit 'should get wasted after time out' do
    # TODO
  end

  it 'should mark initial message when replied' do
    message = FactoryGirl.create(:message, status: :delivered)
    reply_message = FactoryGirl.create(:reply_message, sender: message.receiver, receiver: message.sender, initial_message: message, status: :completed)
    reply_message.deliver!
    expect(message.reload.status).to eq('replied')
  end

  it 'should invoke refund if wasted' do
    payment = FactoryGirl.create(:payment, status: :pay_success)
    payment.message.waste!
    expect(payment.reload.status).to eq('cancel_success')
  end

end
require 'rails_helper'

describe Message do

  it 'should mark initial message when replied' do
    message = FactoryGirl.create(:message, status: :delivered)
    reply_message = FactoryGirl.create(:reply_message, sender: message.receiver, receiver: message.sender, initial_message: message, status: :completed)
    reply_message.deliver!
    expect(message.reload.status).to eq('replied')
  end

  it 'should invoke refund if wasted' do
    message = FactoryGirl.create(:message, status: :delivered)
    payment = FactoryGirl.create(:payment, message: message, status: :pay_success)
    message.time_out
    expect(payment.reload.status).to eq('cancel_success')
  end

  it 'should not be wasted if reply in progress' do
    reply_message = FactoryGirl.create(:reply_message)
    initial_message = reply_message.initial_message
    initial_message.time_out
    expect(initial_message.status).not_to eq('wasted')
  end

  it 'should not be wasted if replied' do
    reply_message = FactoryGirl.create(:reply_message, status: :completed)
    initial_message = reply_message.initial_message
    reply_message.deliver!
    initial_message.time_out
    expect(initial_message.status).not_to eq('wasted')
  end

  it 'should change associated values when replied' do
    partner = FactoryGirl.create(:partner)
    message = FactoryGirl.create(:message, receiver: partner, status: :delivered)
    payment = FactoryGirl.create(:payment, message: message, status: :pay_success)
    reply_message = FactoryGirl.create(:reply_message, initial_message: message, status: :completed)
    reply_message.deliver!
    expect(message.reload.status).to eq('replied')
    expect(payment.reload.status).to eq('settled')
    expect(partner.reload.balance).to eq(payment.partner_share)
  end

end
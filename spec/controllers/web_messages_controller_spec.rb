require 'rails_helper'

RSpec.describe WebMessagesController do

  it 'should return error on wrong webhook token' do
    get :verify_webhook, { 'hub.verify_token': 'wrong_token' }
    expect(response.status).to eq(200)
    expect(response.body).to start_with('error')
  end

  it 'should return challenge on verification' do
    challenge = 'some constant'
    get :verify_webhook, { 'hub.verify_token': "#{APP_CONFIG[:fb_webhook_token]}", 'hub.challenge': challenge }
    expect(response.status).to eq(200)
    expect(response.body).to eq(challenge)
  end

  xit 'should accept message' do
    # TODO
  end

  xit 'should accept quick reply' do
    # TODO
  end

  xit 'should accept postback' do
    # TODO
  end

  xit 'should accept plural messages' do
    # TODO
  end

end
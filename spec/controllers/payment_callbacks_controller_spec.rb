require 'rails_helper'

RSpec.describe PaymentCallbacksController do
  let(:payment) { FactoryGirl.create(:payment) }

  it 'should succeed payment' do
    post :callback, {merchant_uid: payment.merchant_uid, status: 'paid'}
    expect(response.status).to eq(200)
    expect(payment.reload.status).to eq('pay_success')
  end

end
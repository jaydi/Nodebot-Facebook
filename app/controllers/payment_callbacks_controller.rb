class PaymentCallbacksController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!

  def callback
    payment = Payment.find(id_from_merchant_uid)
    if payment.pay_request? and params[:status] == "paid"
      payment.succeed_pay!
    end
    render :nothing => true, :status => 200
  end

  private

  def id_from_merchant_uid
    params[:merchant_uid].split(':')[0]
  end

end

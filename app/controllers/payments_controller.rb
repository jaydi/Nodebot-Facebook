class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session, only: [:callback]

  def show
    @payment = Payment.find(params[:id])
    user = @payment.message.sender
    unless user.agreements_accepted?
      redirect_to users_agreements_path(user_id: user.id, pending_payment_id: @payment.id, vendor: :kakao)
      return
    end
  end

  def callback
    payment = Payment.find(params[:merchant_uid])
    if payment.pay_request? and params[:status] == "paid"
      payment.succeed_pay!
    end
    render :nothing => true, :status => 200
  end

end

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
    # TODO
    payment = Payment.find(params[:merchant_uid])
    if payment.pay_request?
      if params[:status] == "paid"
        payment.succeed_pay!
      else
        payment.fail_pay!
      end
    elsif payment.cancel_request?
      if params[:status] == "cancelled"
        payment.succeed_cancel!
      else
        payment.fail_cancel!
      end
    end
    render :nothing => true, :status => 200
  end

end

class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!
  before_action :load_and_authorize_payment, only: [:show]

  def show
    @payment = Payment.find(params[:id])
  end

  def callback
    payment = Payment.find(id_from_merchant_uid)
    if payment.pay_request? and params[:status] == "paid"
      payment.succeed_pay!
    end
    render :nothing => true, :status => 200
  end

  private

  def load_and_authorize_payment
    @payment = Payment.find(params[:id])
    user = User.find(params[:user_id])
    redirect_to root_path unless @payment.sender_id == user.id
    # unless user.user_agreements_accepted?
    #   redirect_to users_agreements_path(user_id: user.id, pending_payment_id: @payment.id, vendor: params[:vendor])
    #   return
    # end
  end

  def id_from_merchant_uid
    params[:merchant_uid].split(':')[0]
  end

end

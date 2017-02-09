class PaymentsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :authenticate_user!
  before_action :load_and_authorize_payment

  def show
  end

  private

  def load_and_authorize_payment
    @payment = Payment.find(params[:id])
    user = User.find(params[:user_id])
    unless @payment.sender_id == user.id
      redirect_to root_path
      return
    end
    unless user.user_agreements_accepted?
      redirect_to agreements_user_path(user_id: user.id, pending_payment_id: @payment.id, vendor: params[:vendor])
      return
    end
  end

end

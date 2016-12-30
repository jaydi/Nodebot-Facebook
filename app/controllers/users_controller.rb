class UsersController < ApplicationController

  def show_agreements
    @user_id = params[:user_id]
    @pending_payment_id = params[:pending_payment_id]
    @vendor = params[:vendor]
  end

  def accept_agreements
    if params[:terms_accepted] and params[:privacy_accepted]
      # TODO
      redirect_to payment_path(id: params[:pending_payment_id])
    else
      redirect_to users_agreements_path, flash: {error_message: "모든 항목에 동의해주셔야 합니다."}
    end
  end

end
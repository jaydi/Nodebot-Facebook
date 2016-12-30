class UsersController < ApplicationController

  def show_agreements
    @user = User.find(params[:id])
    if @user.agreements_accepted?
      redirect_to payment_path(id: params[:pending_payment_id], vendor: params[:vendor])
      return
    end

    @pending_payment_id = params[:pending_payment_id]
    @vendor = params[:vendor]
  end

  def accept_agreements
    @user = User.find(params[:id])
    if params[:terms_accepted] and params[:privacy_accepted]
      @user.update_attributes({agreements_accepted: true})
      redirect_to payment_path(id: params[:pending_payment_id])
    else
      redirect_to users_agreements_path, flash: {error_message: "모든 항목에 동의해주셔야 합니다."}
    end
  end

end
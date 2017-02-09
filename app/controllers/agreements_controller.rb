class AgreementsController < ApplicationController
  skip_before_action :authenticate_user!

  def show_partner
  end

  def create_partner
    if params[:terms_accepted] and params[:privacy_accepted]
      redirect_to new_user_registration_path
    else
      redirect_to agreements_partner_path, flash: {error: "모든 항목에 동의해주셔야 합니다."}
    end
  end

  def show_user
    @user_id = params[:user_id]
    @pending_payment_id = params[:pending_payment_id]
    @vendor = params[:vendor]
  end

  def create_user
    if params[:terms_accepted] and params[:privacy_accepted]
      user = User.find(params[:user_id])
      user.update_attributes({user_agreements_accepted: true})
      redirect_to payment_path(id: params[:pending_payment_id], user_id: params[:user_id], vendor: params[:vendor])
    else
      redirect_to agreements_user_path, flash: {error: "모든 항목에 동의해주셔야 합니다."}
    end
  end

end

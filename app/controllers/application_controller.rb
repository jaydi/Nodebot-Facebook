class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    render text: "#{exception}", status: 403, layout: false
  end

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def check_partner_agreements
    redirect_to partner_agreements_path unless session[:terms_accepted] and session[:privacy_accepted]
  end

  def check_user
    @user ||= current_user
    if not @user
      redirect_to new_user_session_path
    elsif not @user.profile_completed?
      redirect_to edit_user_registration_path
    elsif not @user.messenger_paired?
      redirect_to users_pair_path
    end
  end

  def set_minimal_layout_flag
    @minimal_layout = true
  end

  def set_door_layout_flag
    @door_layout = true
  end

end

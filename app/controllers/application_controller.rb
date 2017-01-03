class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_raven_context

  def current_celeb
    if !session[:celeb_id].blank?
      Celeb.find(session[:celeb_id])
    elsif !cookies[:celeb_auth_token].blank?
      celeb = Celeb.find_by_auth_token(cookies[:celeb_auth_token])
      raise ActiveRecord::RecordNotFound if celeb.auth_tokened_at.time < 24.hours.ago
      session[:celeb_id] = celeb.id
      celeb
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def get_celeb
    begin
      @celeb ||= current_celeb
    rescue ActiveRecord::RecordNotFound
      redirect_to new_user_session_path
    end
  end

  def check_celeb
    get_celeb
    if @celeb.present?
      if not @celeb.info_filled?
        redirect_to celebs_edit_path
      elsif not @celeb.paired?
        redirect_to celebs_pair_path
      end
    end
  end

  def check_celeb_agreements
    redirect_to celebs_agreements_path unless session[:terms_accepted] and session[:privacy_accepted]
  end

  def create_session(celeb)
    @celeb = celeb
    session[:celeb_id] = celeb.id
    cookies[:celeb_auth_token] = celeb.generate_auth_token
  end

  def destroy_session
    cookies[:celeb_auth_token] = nil
    session[:celeb_id] = nil
    @celeb = nil
  end

  def set_minimal_layout_flag
    @minimal_layout = true
  end

  def set_door_layout_flag
    @door_layout = true
  end

  private

  def set_raven_context
    Raven.user_context(celeb_id: session[:celeb_id])
  end

end

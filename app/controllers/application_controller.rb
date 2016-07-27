class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :current_celeb

  def current_celeb
    if !@celeb.blank?
      @celeb
    elsif session[:celeb_id]
      @celeb = Celeb.find(session[:celeb_id])
    elsif cookies[:celeb_token]
      # TODO
    else
      redirect_to new_user_session_path
    end
  end

  def destroy_session
    cookies[:celeb_token] = nil
    session[:celeb_id] = nil
    @celeb = nil
    redirect_to root_path
  end
end

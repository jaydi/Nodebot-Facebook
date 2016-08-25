class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def current_celeb
    if !session[:celeb_id].blank?
      Celeb.find(session[:celeb_id])
    elsif !cookies[:celeb_token].blank?
      # TODO celeb = Celeb.find_by_token(cookies[:celeb_token])
      # TODO session[:celeb_id] = celeb.id
      # TODO celeb
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def check_celeb
    begin
      @celeb ||= current_celeb
    rescue ActiveRecord::RecordNotFound
      redirect_to new_user_session_path if @celeb.blank?
    end
  end

  def check_celeb_status
    celeb = current_celeb
    if !celeb.info_filled?
      redirect_to celeb_edit_path
    elsif !celeb.paired?
      redirect_to celeb_pair_path
    end
  end

  def create_session(celeb)
    @celeb = celeb
    session[:celeb_id] = celeb.id
    # TODO cookies[:celeb_token] = celeb.auth_token
  end

  def destroy_session
    cookies[:celeb_token] = nil
    session[:celeb_id] = nil
    @celeb = nil
  end
end

class UserSessionsController < ApplicationController
  layout 'application'
  skip_before_action :current_celeb, except: [:destroy]

  def new
  end

  def create
    celeb = Celeb.where(email: params[:email]).first

    if celeb.blank?
      # TODO ERROR
      redirect_to new_user_session_path
      return
    end

    unless celeb.password == params[:password]
      # TODO ERROR
      redirect_to new_user_session_path
      return
    end

    session[:celeb_id] = celeb.id

    if celeb.user.blank?
      redirect_to celeb_pair_path
    else
      redirect_to messages_path
    end
  end

  def destroy
    destroy_session
  end

end

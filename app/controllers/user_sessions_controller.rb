class UserSessionsController < ApplicationController
  layout 'application_blank'
  skip_before_action :current_celeb, except: [:destroy]

  def new
  end

  def create
    celeb = Celeb.where(email: params[:email]).first

    unless celeb
      # TODO ERROR
      redirect_to new_user_session_path
    end

    unless celeb.password == params[:password]
      # TODO ERROR
      redirect_to new_user_session_path
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

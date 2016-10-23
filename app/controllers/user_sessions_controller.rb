class UserSessionsController < ApplicationController
  layout 'application'
  before_action :check_celeb, only: [:destroy]

  def new
  end

  def create
    celeb = Celeb.where(email: params[:email]).active.first

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

    create_session(celeb)
    redirect_to messages_path
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

end

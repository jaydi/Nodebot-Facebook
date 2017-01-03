class UserSessionsController < ApplicationController
  layout 'application'
  before_action :get_celeb, only: [:destroy]

  def new
  end

  def create
    celeb = Celeb.where(email: params[:email]).where.not(status: Celeb.statuses[:deactivated]).first

    if celeb.blank?
      redirect_to new_user_session_path, flash: {error_message: "등록되지 않은 이메일입니다."}
      return
    end

    unless celeb.password == params[:password]
      redirect_to new_user_session_path, flash: {error_message: "비밀번호가 일치하지 않습니다."}
      return
    end

    create_session(celeb)
    redirect_to messages_path
  end

  def request_new_password
  end

  def send_new_password
    celeb = Celeb.find_by_email(params[:email])
    if celeb.present?
      set_new_password_and_send(celeb)
      render :new_password_sent
    else
      redirect_to user_sessions_request_new_password_path, flash: {error_message: "등록되지 않은 이메일입니다."}
    end
  end

  def destroy
    destroy_session
    redirect_to root_path
  end

  private

  def set_new_password_and_send(celeb)
    return if Rails.env.test?
    new_password = (0...8).map { (65 + rand(26)).chr }.join
    celeb.password = new_password
    celeb.save!
    CelebMailer.send_new_password_email(celeb)
  end

end

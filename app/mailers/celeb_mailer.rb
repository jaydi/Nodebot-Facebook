class CelebMailer < ApplicationMailer
  default from: 'noreply@kicky.video'

  def new_password_email(celeb)
    @celeb = celeb
    mail(to: celeb.email, subject: "키키에서 새 비밀번호를 알려드립니다.")
  end
end

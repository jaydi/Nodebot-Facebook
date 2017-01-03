class CelebsController < ApplicationController
  before_action :get_celeb, except: [:show_by_name, :show_agreements, :accept_agreements, :new, :create]
  before_action :check_celeb_agreements, only: [:new]
  before_action :set_minimal_layout_flag, only: [:show_by_name]

  def show_by_name
    @celeb = Celeb.active.find_by_name(params[:name])
    redirect_to root_path unless @celeb
  end

  def show_agreements
  end

  def accept_agreements
    if params[:terms_accepted] and params[:privacy_accepted]
      session[:terms_accepted] = true
      session[:privacy_accepted] = true
      redirect_to new_celeb_path
    else
      redirect_to celebs_agreements_path, flash: {error_message: "모든 항목에 동의해주셔야 합니다."}
    end
  end

  def new
  end

  def create
    if Celeb.where(email: params[:email]).count != 0
      redirect_to new_celeb_path, flash: {error_message: "이미 존재하는 이메일 주소입니다."}
    elsif params[:password] != params[:password_confirm]
      redirect_to new_celeb_path, flash: {error_message: "비밀번호가 일치하지 않습니다."}
    else
      begin
        celeb = Celeb.new(celeb_params)
        celeb.save!
        create_session(celeb)
        redirect_to celebs_edit_path
      rescue ActiveRecord::RecordInvalids
        redirect_to new_celeb_path, flash: {error_message: celeb.errors.messages}
      end
    end
  end

  def edit
  end

  def update
    attrs_to_update = {}

    if @celeb.profile_pic.blank? and params[:profile].blank?
      redirect_to celebs_edit_path, flash: {error_message: '프로필 이미지를 입력해주세요.'}
      return
    end

    if params[:profile].present?
      attrs_to_update[:profile_pic] = upload_profile(params[:profile])
    end

    if @celeb.name.blank? and params[:name].blank?
      redirect_to celebs_edit_path, flash: {error_message: '닉네임을 입력해주세요.'}
      return
    end

    new_name = params[:name].gsub(' ', '')

    if new_name.present? and @celeb.name != new_name
      if Celeb.find_by_name(new_name).present?
        redirect_to celebs_edit_path, flash: {error_message: '이미 존재하는 닉네임입니다.'}
        return
      else
        attrs_to_update[:name] = new_name
      end
    end

    if @celeb.update_attributes(attrs_to_update)
      if @celeb.paired?
        redirect_to messages_path
      else
        redirect_to celebs_pair_path
      end
    else
      redirect_to celebs_edit_path, flash: {error_message: '계정 업데이트에 실패했습니다: ' + @celeb.errors.messages.to_s}
    end
  end

  def pair
  end

  def edit_password
  end

  def update_password
    if params[:current_password] == @celeb.password
      @celeb.password = params[:new_password]
      @celeb.save!
      redirect_to celebs_edit_path, flash: {info_message: '비밀번호가 변경되었습니다.'}
    else
      redirect_to celebs_edit_password_path, flash: {error_message: '현재 비밀번호가 일치하지 않습니다.'}
    end
  end

  def destroy
    destroy_session if @celeb.deactivate!
    redirect_to root_path
  end

  private

  def celeb_params
    params.permit(:email, :password)
  end

  def upload_profile(profile_dispatch)
    return 'test_url' if Rails.env.test?
    res = Cloudinary::Uploader.upload(profile_dispatch.tempfile.path, crop: :fill, width: 256, height: 256)
    res['secure_url']
  end

end
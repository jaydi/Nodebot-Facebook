class CelebsController < ApplicationController
  before_action :check_celeb, except: [:show_by_name, :new, :create]
  before_action :set_minimal_layout_flag, only: [:show_by_name]

  def show_by_name
    @celeb = Celeb.find_by_name(params[:name])
  end

  def new
    redirect_to messages_path unless @celeb.blank?
  end

  def create
    begin
      celeb = Celeb.new(celeb_params)
      celeb.save!
      create_session(celeb)
      redirect_to celebs_edit_path
    rescue ActiveRecord::RecordInvalids
      redirect_to new_celeb_path, flash: {error_message: celeb.errors.messages}
    end
  end

  def edit
  end

  def update
    @celeb.name = params[:name]
    @celeb.profile_pic = upload_profile(params[:profile])
    if Celeb.find_by_name(@celeb.name).present?
      redirect_to celebs_edit_path, flash: {error_message: '이미 존재하는 닉네임입니다.'}
    else
      begin
        @celeb.save!
        unless @celeb.paired?
          redirect_to celebs_pair_path
        else
          redirect_to messages_path, flash: {info_message: '계정 정보가 업데이트 되었습니다.'}
        end
      rescue
        redirect_to celebs_edit_path, flash: {error_message: '계정 업데이트에 실패했습니다.'}
      end
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
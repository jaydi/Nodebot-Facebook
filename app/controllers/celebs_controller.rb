class CelebsController < ApplicationController
  before_action :check_celeb, except: [:show, :show_by_name, :new, :create]
  before_action :set_minimal_layout_flag, only: [:show]

  def show
    @celeb = Celeb.find(params[:id])
  end

  def show_by_name
    @celeb = Celeb.find_by_name(params[:name])
    render :show
  end

  def new
    redirect_to messages_path unless @celeb.blank?
  end

  def create
    celeb = Celeb.new(celeb_params)
    if celeb.save!
      create_session(celeb)
      redirect_to celeb_edit_path
    else
      redirect_to new_celeb_path
    end
  end

  def edit
  end

  def update
    @celeb.name = params[:name]
    @celeb.profile_pic = upload_profile(params[:profile])
    if @celeb.save!
      unless @celeb.paired?
        redirect_to celeb_pair_path
      else
        redirect_to messages_path
      end
    else
      redirect_to celeb_edit_path
    end
  end

  def pair
  end

  def destroy
    if @celeb.deactivate!
      destroy_session
    end
  end

  private

  def celeb_params
    params.permit(:email, :password)
  end

  def upload_profile(profile_dispatch)
    res = Cloudinary::Uploader.upload(profile_dispatch.tempfile.path, crop: :fill, width: 256, height: 256)
    res['secure_url']
  end

end

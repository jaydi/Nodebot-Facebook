class CelebsController < ApplicationController
  layout 'application_blank', only: [:show]
  before_action :check_celeb, except: [:show, :new, :create]

  def show
    @model = Celeb.find(params[:id])
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
      redirect_to celeb_pair_path
    else
      redirect_to celeb_edit_path
    end
  end

  def pair
  end

  def destroy
    if @celeb.destroy!
      destroy_session
    end
  end

  private

  def celeb_params
    params.permit(:email, :password)
  end

  def upload_profile(profile_dispatch)
    # TODO
    'profile_pic_url'
  end

end

class CelebsController < ApplicationController
  layout 'application_blank', only: [:show]
  skip_before_action :current_celeb, only: [:show, :new, :create]

  def show
    @model = Celeb.find(params[:id])
  end

  def new
  end

  def create
    celeb = Celeb.new(celeb_params)
    if celeb.save!
      # TODO session and cookie
      session[:celeb_id] = celeb.id

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

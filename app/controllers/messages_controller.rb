class MessagesController < ApplicationController
  load_and_authorize_resource
  before_action :check_user

  def index
    @messages = @messages.fan_message.where(receiver_id: @user.id).order(id: :desc).page(params[:page])
  end

  def show
  end

end

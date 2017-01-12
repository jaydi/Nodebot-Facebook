class MessagesController < ApplicationController
  before_action :check_user
  load_and_authorize_resource

  def index
    @messages = @messages.fan_message.where(receiver_id: @user.id).order(id: :desc).page(params[:page])
  end

  def show
  end

end

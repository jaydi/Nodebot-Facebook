class MessagesController < ApplicationController
  before_action :check_user

  def index
    @messages = Message.fan_message.received_by(@user.id).order(id: :desc).page(params[:page])
  end

  def show
    @message = Message.find(params[:id])
  end

end

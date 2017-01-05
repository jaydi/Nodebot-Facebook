class MessagesController < ApplicationController
  before_action :check_celeb

  def index
    @messages = Message.fan_message.received_by(@celeb.user.id).order(id: :desc).page(params[:page])
  end

  def show
    @message = Message.find(params[:id])
    if @message.receiving_user_id != @celeb.user.id
      redirect_to messages_path
    end
  end

end

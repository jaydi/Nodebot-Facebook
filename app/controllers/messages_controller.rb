class MessagesController < ApplicationController
  before_action :check_celeb
  before_action :check_celeb_status

  def index
    @messages = Message.received_by(@celeb.user.id).delivered.initials
  end

  def show
    @message = Message.find(params[:id])
    if @message.receiving_user_id != @celeb.user.id
      redirect_to messages_path
    end
  end

end

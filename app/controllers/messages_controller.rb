class MessagesController < ApplicationController

  def index
    @messages = Message.initials_received_by(@celeb.user.id).delivered
  end

  def show
    @message = Message.find(params[:id])
    if @message.receiving_user_id != current_celeb.user.id
      redirect_to messages_path
    end
  end

end

class MessagesController < ApplicationController

  def index
    @messages = Message.received_by(@celeb.user.id).delivered.initials
  end

  def show
    @message = Message.find(params[:id])
    if @message.receiving_user_id != current_celeb.user.id
      redirect_to messages_path
    end
  end

end

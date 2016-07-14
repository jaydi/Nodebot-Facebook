class MessagesController < ApplicationController

  def index
    @messages = Message.initials_received_by(1)
  end

  def show
    @message = Message.find(params[:id])
  end

end

class MessagesController < ApplicationController
  before_action :check_user
  load_and_authorize_resource

  def index
    @messages = @messages.fan_message.received_by(@user.id).order(id: :desc).page(params[:page])
  end

  def show
  end

  def reply
    if @message.delivered? and not @message.video_repliable?
      reply_message = Message.create({
                       initial_message_id: @message.id,
                       sender_id: @user.id,
                       text: params['text'],
                       receiver_id: @message.sender_id,
                       kind: :partner_reply,
                     })
      reply_message.complete!
      reply_message.deliver!
    end
    redirect_to message_path(id: @message.id)
  end

end

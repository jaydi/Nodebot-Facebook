class MessagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  before_action :check_user, except: [:create]
  load_and_authorize_resource

  def index
    @messages = @messages.fan_message.received_by(@user.id).order(id: :desc).page(params[:page])
  end

  def show
  end

  def create
    message = Message.new(message_params)
    if message.save
      redirect_to "/#{message.receiver.name}"
    else
      redirect_to "/#{message.receiver.name}", flash: {error: message.errors}
    end
  end

  def reply
    if @message.delivered? and not @message.video_repliable?
      reply_message = Message.create({
                       initial_message_id: @message.id,
                       sender_id: @user.id,
                       sender_name: @user.name,
                       text: params['text'],
                       receiver_id: @message.sender_id,
                       receiver_name: @message.sender_name,
                       kind: :partner_reply,
                     })
      reply_message.complete!
      reply_message.deliver!
    end
    redirect_to message_path(id: @message.id)
  end

  private

  def message_params
    params.permit([:sender_name, :text, :receiver_id, :receiver_name]).merge({kind: :fan_message, status: :delivered})
  end

end

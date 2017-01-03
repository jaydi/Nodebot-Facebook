class MessageTimeOutWorker
  include Sidekiq::Worker

  def perform(id)
    message = Message.find(id)
    message.time_out
  end
end
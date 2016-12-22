class MessageTimeOutWorker
  include Sidekiq::Worker

  def perform(id)
    message = Message.find(id)
    message.waste! if message.delivered?
  end
end
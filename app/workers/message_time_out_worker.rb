class MessageTimeOutWorker
  include Sidekiq::Worker

  def perform(id)
    message = Message.find(id)
    if message.delivered? or message.read?
      reply_message = message.reply_message
      if reply_message.present? and reply_message.in_progress?
        self.class.perform_in(10.minutes, id)
      else
        message.waste!
      end
    end
  end
end
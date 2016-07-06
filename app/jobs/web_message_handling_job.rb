class WebMessageHandlingJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    web_message = WebMessage.find(id)
    web_message.process_message
  end
end

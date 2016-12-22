class CancelRequestJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    payment = Payment.find(id)
    return unless payment.cancel_request?

    # TODO send actual request

    payment.succeed_cancel!
  end
end
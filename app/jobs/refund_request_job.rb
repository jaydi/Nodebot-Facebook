class RefundRequestJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    payment = Payment.find(id)
    return unless payment.refund_request?

    # TODO
  end
end
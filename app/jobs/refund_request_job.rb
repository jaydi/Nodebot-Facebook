class RefundRequestJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    # TODO
    payment = Payment.find(id)
    if payment.refund_request?
      payment.succeed_refund!
    end
  end
end
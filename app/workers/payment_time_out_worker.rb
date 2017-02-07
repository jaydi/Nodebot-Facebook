class PaymentTimeOutWorker
  include Sidekiq::Worker

  def perform(id)
    payment = Payment.find(id)
    payment.time_out
  end
end
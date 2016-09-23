class PaymentsController < ApplicationController

  def show
    @payment = Payment.find(params[:id])
  end

  def callback
    # TODO
    payment = Payment.find(params[:id])
    if payment.pay_request?
      payment.succeed_pay!
    elsif payment.refund_request?
      payment.succeed_refund!
    end
    render :nothing => true, :status => 200
  end

end

class PaymentsController < ApplicationController

  def show
    @payment = Payment.find(params[:id])
  end

  def callback
    # TODO
    # payment = Payment.find(params[:merchant_uid])
    # if payment.pay_request?
    #   if params[:status] == "paid"
    #     payment.succeed_pay!
    #   else
    #     payment.fail_pay!
    #   end
    # elsif payment.cancel_request?
    #   if params[:status] == "cancelled"
    #     payment.succeed_cancel!
    #   else
    #     payment.fail_cancel!
    #   end
    # end
    render :nothing => true, :status => 200
  end

end

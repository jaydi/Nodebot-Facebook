class PaymentsController < ApplicationController
  layout 'application_blank'
  skip_before_action :current_celeb

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

    # case params[:result].to_sym
    #   when :pay_fail
    #   when :pay_success
    #     payment.succeed_pay!
    # end

    render :nothing => true, :status => 200
  end

end

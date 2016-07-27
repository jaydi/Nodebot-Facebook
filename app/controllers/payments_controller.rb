class PaymentsController < ApplicationController
  skip_before_action :current_celeb

  def show
    @payment = Payment.find(params[:id])
  end

  def callback
    payment = Payment.find(params[:id])
    payment.succeed_pay!
    # case params[:result].to_sym
    #   when :pay_fail
    #   when :pay_success
    #     payment.succeed_pay!
    # end
    render :nothing => true, :status => 200
  end

end

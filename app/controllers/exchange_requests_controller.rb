class ExchangeRequestsController < ApplicationController
  before_action :check_celeb

  def new
    # TODO view
  end

  def create
    if params[:password] == @celeb.password
      exchange_request = ExchangeRequest.new(exchange_request_params)
      if exchange_request.save
        redirect_to celebs_revenue_management_path
      else
        redirect_to new_exchange_request_path, flash: {error_message: exchange_request.errors}
      end
    else
      redirect_to new_exchange_request_path, flash: {error_message: '비밀번호가 일치하지 않습니다.'}
    end
  end

  private

  def exchange_request_params
    params.permit([:bank_id, :account_holder, :account_number, :amount]).merge(celeb_id: @celeb.id)
  end

end

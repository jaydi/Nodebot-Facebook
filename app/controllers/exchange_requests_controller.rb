class ExchangeRequestsController < ApplicationController
  before_action :check_user

  def index
    @exchange_requests = ExchangeRequest.issued_by(@user.id).order(id: :desc).page(params[:page]).per(10)
    @exchanged_sum = ExchangeRequest.succeeded.issued_by(@user.id).select("sum(#{:amount}) as sum").first.sum || 0
  end

  def new
    @banks = Bank.all
  end

  def create
    if @user.valid_password?(params[:password])
      exchange_request = ExchangeRequest.new(exchange_request_params)
      if exchange_request.save
        redirect_to exchange_requests_path
      else
        redirect_to new_exchange_request_path, flash: {error: exchange_request.errors}
      end
    else
      redirect_to new_exchange_request_path, flash: {error: '비밀번호가 일치하지 않습니다.'}
    end
  end

  private

  def exchange_request_params
    params.permit([:bank_id, :requester, :identity_string, :account_holder, :account_number, :amount]).merge({user_id: @user.id})
  end

end

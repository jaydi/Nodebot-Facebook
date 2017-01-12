Rails.application.routes.draw do

  root 'welcome#door'

  get 'webhook' => 'web_messages#verify_webhook'
  post 'webhook' => 'web_messages#webhook'

  get 'agreements/partner' => 'agreements#show_partner'
  post 'agreements/partner' => 'agreements#create_partner'
  get 'agreements/user' => 'agreements#show_user'
  post 'agreements/user' => 'agreements#create_user'

  resources :messages, only: [:index, :show]

  resources :payments, only: [:show]
  post 'payments/callback' => 'payment_callbacks#callback'

  resources :exchange_requests, only: [:index, :new, :create]

  devise_for :users, controllers: {registrations: 'users', sessions: 'user_sessions'}
  devise_scope :user do
    get 'users/pair' => 'users#pair'
    # this always has to be located at the LAST
    get ':name' => 'users#show_by_name'
  end
end

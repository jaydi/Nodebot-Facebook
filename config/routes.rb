Rails.application.routes.draw do

  root 'welcome#door'

  get 'webhook' => 'web_messages#verify_webhook'
  post 'webhook' => 'web_messages#webhook'

  resources :messages, only: [:index, :show]

  resources :payments, only: [:show] do
    collection do
      post 'callback'
    end
  end

  resources :exchange_requests, only: [:index, :new, :create]

  devise_for :users, controllers: {registrations: 'users'}
  devise_scope :user do
    get 'users/pair' => 'users#pair'
    get 'users/agreements' => 'users#show_agreements'
    post 'users/agreements' => 'users#accept_agreements'
    # this always has to be located at the LAST
    get ':name' => 'users#show_by_name'
  end
end

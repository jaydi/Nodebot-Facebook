Rails.application.routes.draw do

  root 'welcome#door'

  get 'webhook' => 'web_messages#verify_webhook'
  post 'webhook' => 'web_messages#webhook'

  resources :user_sessions, only: [:new, :create]
  get 'user_sessions/destroy' => 'user_sessions#destroy'
  get 'user_sessions/request_new_password' => 'user_sessions#request_new_password'
  post 'user_sessions/send_new_password' => 'user_sessions#send_new_password'

  resources :celebs, only: [:new, :create]
  get 'celebs/edit' => 'celebs#edit'
  put 'celebs' => 'celebs#update'
  patch 'celebs' => 'celebs#update'
  get 'celebs/pair' => 'celebs#pair'
  get 'celebs/edit_password' => 'celebs#edit_password'
  put 'celebs/update_password' => 'celebs#update_password'
  delete 'celebs' => 'celebs#destroy'

  resources :messages, only: [:index, :show]

  resources :payments, only: [:show] do
    member do
      post 'callback'
    end
  end

  # this always has to be located at the LAST
  get ':name' => 'celebs#show_by_name'
end

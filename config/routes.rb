Rails.application.routes.draw do

  root 'welcome#door'

  get 'webhook' => 'web_messages#verify_webhook'
  post 'webhook' => 'web_messages#webhook'

  resources :user_sessions, only: [:new, :create]
  get 'user_session/destroy' => 'user_sessions#destroy'

  resources :celebs, only: [:show, :new, :create]
  get 'celeb/edit' => 'celebs#edit'
  put 'celebs' => 'celebs#update'
  patch 'celebs' => 'celebs#update'
  get 'celeb/pair' => 'celebs#pair'
  delete 'celeb' => 'celebs#destroy'

  resources :messages, only: [:index, :show]

  resources :payments, only: [:show] do
    member do
      post 'callback'
    end
  end

  # this always has to be located at the LAST
  get ':name' => 'celebs#show_by_name'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

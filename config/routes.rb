Rit::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  match 'published/:layout_name/:instance_name/:plate_name' => 'plates#published', :as => :published_current
  match 'published/:layout_name/:plate_name' => 'plates#published', :as => :published_current
  match 'published_on/:layout_name/:instance_name/:plate_name/:date' => 'plates#published', :as => :published_on
  match 'published_on/:layout_name/:plate_name/:date' => 'plates#published', :as => :published_on
  match 'plate_editions/search' => 'plate_editions#search', :as => :search_plate_editions

  resources :plates do
    resources :plate_editions do
      member do
        get :preview
      end
    end
  end

  match 'plates/:id.:format' => 'plates#create_plate_edition', :as => :plate, :via => :post

  resources :events do
    member do
      get :show_row
    end
  end

  resources :plate_sets do
    resources :plate_set_plates
  end

  match 'plate_sets/:id.:format' => 'plate_sets#create_plate', :as => :plate_set, :via => :post

  resources :passwords
  resource :session
  resources :users do
    resource :password
    resource :confirmation
  end

  match 'sign_up' => 'users#new', :as => :sign_up
  match 'sign_in' => 'sessions#new', :as => :sign_in
  match 'sign_out' => 'sessions#destroy', :as => :sign_out, :method => :delete

  match '/' => 'plates#index'
end
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
    # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.published_current 'published/:layout_name/:instance_name/:plate_name',
                        :controller => 'plates',
                        :action => 'published'
  map.published_current 'published/:layout_name/:plate_name',
                        :controller => 'plates',
                        :action => 'published'                        
  map.published_on 'published_on/:layout_name/:instance_name/:plate_name/:date', 
                    :controller => 'plates',
                    :action => 'published'
  map.published_on 'published_on/:layout_name/:plate_name/:date',
                    :controller => 'plates',
                    :action => 'published'
  
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  map.resources :users, :except => [ :edit ]
  
  
  map.search_plate_editions 'plate_editions/search', :controller => 'plate_editions', :action => 'search'
  map.resources :plates, :member => { :show_row => :get }, :shallow => true do |plate|
    plate.resources :plate_editions, :member => { :preview => :get }
  end
  # Do edition creation :post to plate route so that errors show up at the correct URL
  map.plate 'plates/:id.:format', :controller => 'plates', :action => 'create_plate_edition', :conditions => { :method => :post }
  
  map.resources :events, :member => { :show_row => :get }
  
  map.resources :plate_sets, :shallow => true, :member => { :show_row => :get, :generate_plates => :put } do |plate_set|
    plate_set.resources :plate_set_plates
  end
  # Do plate set plate creation :post to plate route so that errors show up at the correct URL
  map.plate_set 'plate_sets/:id.:format', :controller => 'plate_sets', :action => 'create_plate', :conditions => { :method => :post }
  
  # override all clearance routes so that they will use sessions layout
  map.resource :session , :controller => 'sessions', :only => [ :new, :create, :destroy ]
  
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "plates"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

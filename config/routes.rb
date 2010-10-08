ActionController::Routing::Routes.draw do |map|
  map.resource :session, :controller => 'sessions', :only => [:new, :create, :destroy]
  
  map.resources :users, :controller => 'users' do |users|
    users.resource :password, :controller => 'clearance/passwords', :only => [:create, :edit, :update]
    users.resource :confirmation, :controller => 'clearance/confirmations', :only => [:new, :create]
  end
  Clearance::Routes.draw(map)

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

  map.search_plate_editions 'plate_editions/search', :controller => 'plate_editions', :action => 'search'

  map.resources :users, :except => [ :edit ]
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

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "plates"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end

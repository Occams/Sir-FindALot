Server::Application.routes.draw do
  
  resources :searches, :only => :create
  resources :pages, :only => [:index, :show]
  resources :parkingramps, :only => :show do
    member do
      match 'stats/year/:year/:hour' => 'stats#show', :year => /\d{4}/, :hour => /\d{1,2}/
      match 'stats/week/:year/:week/:hour' => 'stats#show', :year => /\d{4}/, :week => /\d{1,2}/, :hour => /\d{1,2}/
      match 'stats/day/:year/:month/:day' => 'stats#show', :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
    end
  end

  namespace :admin do
    resources :parkingramps, :except => [:show] do
      resources :parkingplanes, :except => [:index, :show] do
        resources :parkinglots
        resources :concretes
      end
      get 'sortplanes/:parkingplanes', :on => :member, :action => :sortplanes
    end
    
    match "/:id" => "pages#show"
  end
  
  namespace :api do
    resources :parkinglots, :only => [:show]
  end

  devise_for :operators
  
  # Catch all not intercepted routes till now and give that to the pages controller
  root :to => "pages#index"
  match "/:id" => "pages#show"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

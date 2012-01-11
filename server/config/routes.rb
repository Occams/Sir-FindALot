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
    resources :operators, :only => :show
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
end

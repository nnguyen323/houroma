Rails.application.routes.draw do
  get 'lounges/show'

  get 'my_time/index'

  root 'landing_pages#home'
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  get 'signup' => 'users#new'
  get 'userlist' => 'users#index'
  get 'help' => 'landing_pages#help'
  get 'mytime' => 'my_time#index'
  resources :nests, param: :title, only: [:index, :create, :show, :destroy]
  resources :users, param: :username, :path => "/", only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      get :tracking, :trackers
    end
  end
  
  resources :users, only: :index do
    collection do
      get :autocomplete
    end
  end
  resources :activities, only: :index do
    collection do
      get :autocomplete
    end
  end
  resources :landing_pages, only: :index do
    collection do
      get :search_all
    end
  end

  resources :comments, only: [:create]
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :activities,          only: [:create, :destroy, :update, :show]
  resources :relationships,       only: [:create, :destroy]
  resources :rates,               only: [:create, :destroy, :update]  
  resources :birds,               only: [:create, :destroy]
  get 'lounges/:action_name/' => 'lounges#show'
  get 'lounges/:action_name/top' => 'lounges#top'
  get 'lounges/:action_name/active' => 'lounges#active'
  get 'charts/active_users' => 'charts#active_users'
  #get 'charts/user_signup' => 'charts#user_signup'
  get 'charts/live_tracked' => 'charts#live_tracked'
  get 'charts/timeline_from_day' => 'charts#timeline_from_day'
  get 'charts/total_time' => 'charts#total_time'
  get 'charts/weekly_time' => 'charts#weekly_time'
  get 'charts/nest_time' => 'charts#nest_time'
  get 'charts/last_activities' => 'charts#last_activities'
end
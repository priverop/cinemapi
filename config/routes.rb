Rails.application.routes.draw do
  namespace :api do
    get "movies/search", to: "movies#search"
    resources :movies, only: [ :index, :show ]
    resources :theaters, only: [ :index, :show ]
  end

  scope "/backoffice" do
    get "/", to: "dashboard#index", as: :backoffice_root
    resource :session
    resources :passwords, param: :token
    resources :movies
    resources :theaters
    post "scraper", to: "scraper#run"
  end

  get "theater_search", to: "home#theater_search"
  get "image_proxy", to: "image_proxy#show", as: :image_proxy

  # Defines the root path route ("/")
  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end

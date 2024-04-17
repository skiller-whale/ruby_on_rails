Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "performances#index"

  devise_for :users
  resources :users, only: [:index, :show]

  resources :performances, except: [:show]

  resources :comedians do
    resources :comments, only: [:create]
  end

  resources :bands do
    resources :comments, only: [:create]
  end
end

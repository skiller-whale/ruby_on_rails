Rails.application.routes.draw do
  root to: "performances#index"

  devise_for :users
  resources :users, only: [:index, :show]

  resources :performances, except: [:show]

  resources :comedians
  resources :bands do
    resources :comments, only: [:create]
  end
end

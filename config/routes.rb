
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  Rails.application.routes.draw do
    root 'flights#index'
    resources :reservations
    resources :flights
    devise_for :users, controllers: { sessions: "users/sessions" }
  end


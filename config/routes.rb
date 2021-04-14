Rails.application.routes.draw do

  get '/authenticate-google', to: 'sessions#authenticate_google'
  get '/authenticate-facebook', to: 'sessions#authenticate_facebook'
  get 'auth/:provider/callback', to: 'users#create'

  get 'users/:id/recommended_users', to: 'users#get_recommended_users'
  resources :chatrooms
  resources :messages
  resources :posts
  resources :notifications
  resources :connections
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  
end

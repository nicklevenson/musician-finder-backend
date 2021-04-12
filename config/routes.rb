Rails.application.routes.draw do
  resources :chatrooms
  resources :messages
  resources :posts
  resources :notifications
  resources :connections
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

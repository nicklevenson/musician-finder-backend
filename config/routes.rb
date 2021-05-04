Rails.application.routes.draw do

  get '/authenticate-google', to: 'sessions#authenticate_google'
  get '/authenticate-facebook', to: 'sessions#authenticate_facebook'
  get '/authenticate-spotify', to: 'sessions#authenticate_spotify'
  get 'auth/:provider/callback', to: 'users#create'

  get 'users/:id/connected_users', to: 'users#get_connected_users'
  get 'users/:id/recommended_users', to: 'users#get_recommended_users'
  get '/users/:id/incoming_requests', to: 'users#get_incoming_requests'
  get 'users/:id/get_similar_tags/:other_user_id', to: 'users#get_similar_tags'
  get 'users/:id/get_user_chatrooms', to: 'users#get_user_chatrooms'
  get 'users/:id/get_user_notifications', to: 'users#get_user_notifications'
  post 'users/:id/request_connection', to: 'users#request_connection'
  post 'users/:id/accept_connection', to: 'users#accept_connection'
  post 'users/:id/reject_connection', to: 'users#reject_connection'
  post 'users/:id/reject_user', to: 'users#reject_user'

  post 'messages/make_read', to: 'messages#make_read'

  post 'notifications/make_read', to: 'notifications#make_read'

  
  resources :chatrooms
  resources :messages
  resources :posts
  resources :notifications
  resources :connections
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  
end

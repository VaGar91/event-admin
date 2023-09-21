# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    get '/login', to: 'devise/sessions#new', as: 'sign_in'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  root 'pages#home', as: 'home'
  # Show Events
  get '/events', to: 'event_admin#index'
  get '/public_events', to: 'event_admin#public_events'

  # Create Event
  get '/events/new', to: 'event_admin#new', as: 'new_event'
  post '/events', to: 'event_admin#create'

  # Importing to CSV
  get '/events/export', to: 'event_admin#export'

  # Edit Event
  get '/events/:id/edit', to: 'event_admin#edit', as: 'edit_event'
  patch '/events/:id', to: 'event_admin#update', as: 'update_event'

  # Delete Event
  get '/events/:id', to: 'event_admin#destroy'
  delete '/events/:id', to: 'event_admin#destroy', as: 'delete'

  # Delete Image
  get '/events/:id/delete_image', to: 'event_admin#delete_image', as: 'delete_image'
end

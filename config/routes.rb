# frozen_string_literal: true

Folio::Engine.routes.draw do
  get 'errors/not_found'

  get 'errors/internal_server_error'

  devise_for :accounts, class_name: 'Folio::Account', module: :devise

  root to: 'home#index', as: :home

  match '/400', to: 'errors#page400', via: :all
  match '/404', to: 'errors#page404', via: :all
  match '/422', to: 'errors#page422', via: :all
  match '/500', to: 'errors#page500', via: :all

  namespace :console, locale: :cs do
    root to: 'dashboard#index'
    resources :dashboard, only: :index
    resources :nodes, except: [:show] do
      post :set_positions, on: :collection
    end
    resources :menus do
      post :tree_sort, on: :member
    end
    resources :images, except: [:show, :new] do
      collection { post :tag }
    end
    resources :documents, except: [:show, :new] do
      collection { post :tag }
    end
    resources :leads, only: %i[index show update destroy] do
      collection do
        post :mass_handle
      end
      member do
        post :handle
        post :unhandle
      end
    end
    resources :newsletter_subscriptions, only: %i[index destroy]
    resources :accounts
    resources :visits, only: %i[index show]
    resource :site
  end

  resource :csrf, only: %i[show], controller: :csrf
  resources :leads, only: %i[create]
  resources :newsletter_subscriptions, only: %i[create]
end

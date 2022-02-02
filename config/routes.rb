Rails.application.routes.draw do
  devise_for :users
  namespace :site do
    get 'welcome/index'
    get 'search', to: 'search#questions'
    get 'subject/:subject_id/:subject', to: 'search#subject', as: 'search_subject'
    post 'answer', to: 'answer#question'
  end
  namespace :users_backoffice do
    get 'welcome/index'
    get 'profile', to: 'profile#edit'
    patch 'profile', to: 'profile#update'
  end
  namespace :admins_backoffice do
    get 'welcome/index' #dashboard
    resources :admins
    resources :subjects
    resources :questions
  end

  devise_for :admins, skip: [:registrations]

 
  get 'inicio', to: 'site/welcome#index'
  get 'admin', to: 'admins_backoffice/welcome#index'

  root to: 'site/welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
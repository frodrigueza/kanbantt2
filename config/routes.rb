######API#######
require 'api_constraints'

Rails.application.routes.draw do


  # API
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :projects do
        resources :tasks, only: [:index,:update,:show] do
          get 'all', on: :collection
          put 'update_gantt', on: :member, action:'update_gantt'
          delete 'update_gantt', on: :member, action:'destroy'
          post 'update_gantt', on: :collection, action:'create'
          resources :comments, only: [:create]
        end

        resources :indicators do
        end

        get 'all', on: :collection
      end

      #Métodos para usuarios
      post 'users/login', to: 'users#login'
      delete 'users/logout', to: 'users#logout'

      #Métodos de progresos
      get '/progress/estimated_in_resources_by_week' 
      get '/progress/real_in_resources_by_week' 
      get '/progress/estimated_in_days_by_week'
      get '/progress/real_in_days_by_week' 
      get '/progress/all_progress'

      get '/progress/performance_in_resources_by_week'
      get '/progress/performance_in_one_by_week'
      post '/push/send_token'

      
      get '/progress/performance_estimated_by_week'
      get '/progress/performance_real_by_week'

    end
  end

#######termino API#####
  
  # Página de errores
  get 'errors/file_not_found'
  get 'errors/unprocessable'
  get 'errors/internal_server_error'
  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all


  #usuarios con gema devise
  devise_for :users


  #Resources genera todas las rutas CRUD para cada uno de estos objetos
  resources :projects do
    get 'delete'
    get 'second_indicators'
    get 'tree_view'
    get 'root'
    get 'add_tree_view_column'
    get 'export'
    get 'kanban_board', to: 'kanban_board#index', as: :kanban_board_index
    get 'gantt', to: 'gantt#index'

    resources :indicators
    resources :users, only: [:index]
    resources :tasks do
      resources :reports
      resources :comments

    end
  end

  resources :tasks do
    get 'delete_confirmation'
    get 'fast_report'
    get 'toggle_urgent'
  end

  get 'gantt', to: 'gantt#index'
  get 'update_tree_view', to: 'tasks#update_tree_view'
  
  # get 'kanban_board_index', to: 'kanban_board#index'
  get 'gantt', to: 'gantt#index'

  resources :comments
  resources :reports
  resources :assignments
  resources :users

  resources :indicators

  resources :enterprises do
    resources :projects
    resources :users
  end

  namespace :kanban_board do
    get 'index'
    get 'update_item_partial'
  end




  root 'users#root_router'
end

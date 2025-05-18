Rails.application.routes.draw do
  # Montagens globais com constraints explícitos
  concern :storage_endpoints do
    mount ActiveStorage::Engine => '/rails/active_storage' if defined?(ActiveStorage)
    mount ActionCable.server => '/cable' if defined?(ActionCable)
  end
  
  # Domínio marketing (grady.com.br e www.grady.com.br)
  constraints host: /^(www\.)?grady\.com\.br$/ do
    concerns :storage_endpoints
    root to: 'marketing#home', as: :marketing_root
    # Adicionar outras rotas de marketing conforme necessário
  end
  
  # Domínio da aplicação (app.grady.com.br) - incluindo autenticação
  constraints host: 'app.grady.com.br' do
    concerns :storage_endpoints
    
    # Rotas de autenticação com Devise e caminhos customizados
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_up: 'register',
      password: 'forgot-password',
      confirmation: 'confirm',
      unlock: 'unlock',
      sign_out: 'logout'
    }
    
    # Rotas autenticadas
    authenticated :user do
      # Namespace para o painel da aplicação
      namespace :panel do
        resources :forms
        resources :booklets
        resources :results
      end
      
      # Rota raiz para usuários autenticados
      root to: 'dashboard#index', as: :authenticated_root
    end
    
    # Rota raiz para usuários não autenticados no subdomínio app
    root to: 'devise/sessions#new', as: :app_root
  end
  
  # Fallback APENAS para desenvolvimento
  unless Rails.env.production?
    root 'marketing#home'
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "posts#index"
end

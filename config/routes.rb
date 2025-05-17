Rails.application.routes.draw do
  # Rotas de autenticação com Devise e caminhos customizados
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_up: 'register',
    password: 'forgot-password',
    confirmation: 'confirm',
    unlock: 'unlock',
    sign_out: 'logout'
  }
  
  # Rota para o domínio principal
  root "home#index"
  
  # Rota para o subdomínio de autenticação - redireciona para login
  constraints host: 'auth.grady.com.br' do
    root to: 'devise/sessions#new'
  end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

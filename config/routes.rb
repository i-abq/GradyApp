Rails.application.routes.draw do
  constraints host: /localhost/ do
    root "marketing#home" # Adicionada rota raiz para localhost
    get "styleguide", to: "components#index"
  end

  # Domínio marketing (grady.com.br e www.grady.com.br)
  constraints host: /^(www\.)?grady\.com\.br$/ do
    root to: 'marketing#home', as: :marketing_root
    # Adicionar outras rotas de marketing conforme necessário
  end
  
  # Domínio da aplicação (app.grady.com.br)
  constraints host: 'app.grady.com.br' do
    # Rotas de autenticação com Devise e caminhos customizados
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_up: 'register',
      password: 'forgot-password',
      confirmation: 'confirm',
      unlock: 'unlock',
      sign_out: 'logout'
    }, controllers: {
      sessions: 'users/sessions'
    }
    
    # Namespace para o painel da aplicação
    namespace :panel do
      resources :forms
      resources :booklets
      resources :results
    end
    
    # Rota para o perfil do usuário
    get 'profile', to: 'profile#index'
    
    # Rota para a página de perguntas
    get 'questions', to: 'questions#index'

    # Rota para a página de booklets
    get 'booklets', to: 'booklets#index'

    scope :questions, as: :questions do
      resources :blueprints, except: [:destroy, :show] do
        post :publish, on: :member
      end
    end
    
    # Rota para a página de layouts
    get 'layouts', to: 'layouts#index'
    
    # Rota para o styleguide de componentes
    get 'styleguide', to: 'components#index'
    
    # Rota para a página de respostas
    get 'answers', to: 'answers#index'
    
    # Rota para a página de resultados
    get 'results', to: 'results#index'
    
    # Rota para a página de divulgação
    get 'publications', to: 'publications#index'
    
    # Rota raiz para usuários autenticados
    root to: 'dashboard#index', as: :app_root
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "posts#index"
end

class ApplicationController < ActionController::Base
  before_action :check_subdomain_routing
  
  private
  
  def check_subdomain_routing
    auth_domain = 'auth.grady.com.br'
    main_domain = 'www.grady.com.br'
    
    # Se estamos acessando o domínio principal mas tentando acessar recursos de autenticação
    if devise_controller? && request.host != auth_domain
      redirect_to(
        "https://#{auth_domain}#{request.fullpath}",
        allow_other_host: true
      ) and return
    end
    
    # Se estamos acessando o subdomínio de autenticação mas não é para um controller Devise
    if !devise_controller? && request.host == auth_domain && !request.path.start_with?('/assets')
      redirect_to(
        "https://#{main_domain}#{request.fullpath}",
        allow_other_host: true
      ) and return
    end
  end
end

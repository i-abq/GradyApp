class MarketingController < ApplicationController
  layout 'marketing'
  
  # As páginas de marketing não requerem autenticação
  skip_before_action :check_auth_subdomain
  
  def home
    # Renderiza a view de marketing/home
  end
end 
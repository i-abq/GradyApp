class MarketingController < ApplicationController
  layout 'marketing'
  
  # As páginas de marketing não requerem autenticação
  
  def home
    # Renderiza a view de marketing/home
  end
end 
class DashboardController < ApplicationController
  # Certifique-se de que o usuário esteja autenticado antes de acessar
  before_action :authenticate_user!
  
  def index
    # Lógica para a dashboard do usuário autenticado
  end
end 
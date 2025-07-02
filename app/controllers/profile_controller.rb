class ProfileController < ApplicationController
  before_action :authenticate_user!

  def index
    # Página de perfil do usuário - em branco por enquanto
  end
end 
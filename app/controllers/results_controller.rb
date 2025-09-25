class ResultsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Página de resultados - apenas título
  end
end

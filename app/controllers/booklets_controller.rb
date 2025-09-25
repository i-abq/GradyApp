class BookletsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Página de booklets - apenas título
  end
end

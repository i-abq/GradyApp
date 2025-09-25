class LayoutsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Página de layouts - apenas título
    render 'layouts_page/index'
  end
end

class ApplicationController < ActionController::Base
  protected
  
  def after_sign_out_path_for(resource_or_scope)
    "https://www.grady.com.br"
  end
end

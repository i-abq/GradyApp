class ApplicationController < ActionController::Base
  before_action :check_auth_subdomain
  
  protected
  
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  
  private
  
  def check_auth_subdomain
    return unless devise_controller?
    
    auth_domain = 'auth.grady.com.br'
    return if request.host == auth_domain
    
    redirect_to(
      "https://#{auth_domain}#{request.fullpath}",
      allow_other_host: true
    ) and return
  end
end

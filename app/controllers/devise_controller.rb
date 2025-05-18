class DeviseController < ActionController::Base
  include Devise::Controllers::Helpers
  
  layout 'application'
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token, if: :json_request?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || "https://app.grady.com.br"
  end
  
  def after_sign_out_path_for(resource_or_scope)
    "https://www.grady.com.br"
  end
  
  def json_request?
    request.format.json?
  end
end 
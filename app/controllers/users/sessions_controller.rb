# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # DELETE /resource/sign_out
  # Sobrescreve o método para garantir que o redirecionamento para outro host seja permitido.
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    yield if block_given?
    respond_to_on_destroy
  end

  protected

  def respond_to_on_destroy
    # Default is: redirect_to after_sign_out_path_for(resource_name)
    redirect_to after_sign_out_path_for(resource_name), allow_other_host: true, status: Devise.responder.redirect_status
  end
end 
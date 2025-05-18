# Plano de Rollback: Migração de auth.grady.com.br

Este documento descreve o plano de rollback caso surjam problemas críticos na migração da autenticação de `auth.grady.com.br` para `app.grady.com.br`.

## Passos para Rollback

1. **Restaurar o redirecionamento para auth.grady.com.br**:
   ```ruby
   # app/controllers/application_controller.rb
   before_action :check_auth_subdomain
   
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
   ```

2. **Reverter configurações de URL em ambientes**:
   ```ruby
   # config/environments/production.rb e development.rb
   config.action_controller.default_url_options = { host: "www.grady.com.br", protocol: "https" }
   config.action_mailer.default_url_options = { host: "auth.grady.com.br", protocol: "https" }
   ```

3. **Reverter redirecionamentos no CustomDeviseController**:
   ```ruby
   # app/controllers/custom_devise_controller.rb
   def after_sign_in_path_for(resource)
     stored_location_for(resource) || "https://app.grady.com.br"
   end
   
   def after_sign_out_path_for(resource_or_scope)
     "https://www.grady.com.br"
   end
   ```

4. **Reverter estrutura de rotas**:
   * Remover os concerns
   * Restaurar o formato original das rotas
   * Reverter a estrutura de authenticated

5. **Reconfigurar session_store**:
   ```ruby
   # config/initializers/session_store.rb
   Rails.application.config.session_store :cookie_store, 
     key: '_grady_app_session',
     domain: 'app.grady.com.br',
     same_site: :lax,
     secure: Rails.env.production?
   ```

6. **Verificar infraestrutura**:
   * Certificar-se de que auth.grady.com.br ainda resolve no DNS
   * Verificar que o certificado SSL para auth.grady.com.br ainda é válido
   * Restaurar configurações do servidor web (Nginx/Apache)

7. **Deploy da versão estável anterior**:
   ```bash
   git revert HEAD~n..HEAD  # onde n é o número de commits realizados nesta migração
   # ou
   git checkout [tag_ou_commit_anterior]
   git push --force heroku HEAD:main
   ```

## Checklist Pós-Rollback

- [ ] Verificar se login está funcionando em auth.grady.com.br
- [ ] Verificar redirecionamentos após login/logout
- [ ] Testar recuperação de senha e outros fluxos de autenticação
- [ ] Verificar se e-mails estão sendo enviados com URLs corretas

## Contatos

Em caso de emergência durante o rollback:
- **Desenvolvedor Responsável**: [Nome e contato]
- **DevOps/Infraestrutura**: [Nome e contato] 
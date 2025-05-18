# Configuração para garantir que a sessão não vaze para o domínio público
# Isolando a sessão ao subdomínio da aplicação

Rails.application.config.session_store :cookie_store, 
  key: '_grady_app_session',
  domain: 'app.grady.com.br',
  same_site: :lax,
  secure: Rails.env.production?

# Nota: Se no futuro for necessário compartilhar o cookie entre subdomínios,
# troque o domínio para:
# domain: '.grady.com.br' 
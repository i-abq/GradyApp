# Middleware para registrar acessos ao subdomínio auth.grady.com.br (obsoleto)
# Este middleware deve ser removido após um período de transição
# quando tivermos certeza de que não há mais requisições para esse subdomínio

class DeprecatedDomainLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    if request.host == 'auth.grady.com.br'
      Rails.logger.warn "Acesso ao domínio descontinuado: auth.grady.com.br - #{request.path}"
      # Opcionalmente, enviar para sistemas de monitoramento (NewRelic, Datadog, etc.)
    end
    @app.call(env)
  end
end

Rails.application.config.middleware.use DeprecatedDomainLogger if Rails.env.production? 
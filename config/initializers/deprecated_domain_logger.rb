# Middleware para registrar acessos ao subdomínio auth.grady.com.br (obsoleto)
# Este middleware deve ser removido após um período de transição
# quando tivermos certeza de que não há mais requisições para esse subdomínio

Rails.application.config.middleware.use(
  lambda do |app|
    lambda do |env|
      request = ActionDispatch::Request.new(env)
      if request.host == 'auth.grady.com.br'
        Rails.logger.warn "Acesso ao domínio descontinuado: auth.grady.com.br - #{request.path}"
        # Opcionalmente, enviar para sistemas de monitoramento (NewRelic, Datadog, etc.)
      end
      app.call(env)
    end
  end
) if Rails.env.production? 
# Checklist de Migração da Autenticação

Este documento contém o checklist de verificação para a migração da autenticação de `auth.grady.com.br` para `app.grady.com.br`.

## Pré-Deploy

### Código e Configuração
- [ ] Configurações de URL atualizadas em todos os ambientes
- [ ] Remoção do redirecionamento para auth.grady.com.br
- [ ] Configuração de variáveis de ambiente para URLs
- [ ] CSP configurada para novos domínios
- [ ] Estrutura de rotas atualizada
- [ ] Session store configurado com suporte a variáveis de ambiente
- [ ] Middleware de monitoramento de acessos ao domínio antigo
- [ ] Plano de rollback documentado

### Testes
- [ ] Fluxo completo de registro testado
- [ ] Processo de recuperação de senha testado
- [ ] Confirmação de conta testada
- [ ] Redirecionamentos após login/logout testados
- [ ] Funcionalidade de "lembrar-me" testada
- [ ] Testes em ambientes móveis

### Infraestrutura
- [ ] Variáveis de ambiente configuradas no servidor de produção
- [ ] Certificado SSL válido para app.grady.com.br
- [ ] DNS configurado corretamente
- [ ] Backup do banco de dados realizado
- [ ] Configuração de servidor web atualizada

## Pós-Deploy

### Verificações Funcionais
- [ ] Login funciona corretamente em app.grady.com.br
- [ ] Logout redireciona para www.grady.com.br
- [ ] Recuperação de senha envia e-mails com links corretos
- [ ] Confirmação de conta funciona
- [ ] Sessões persistem corretamente
- [ ] CSRF protection funciona nas requisições de formulário

### Monitoramento
- [ ] Logs verificados para erros relacionados à autenticação
- [ ] Monitoramento de acessos ao domínio antigo ativo
- [ ] Métricas de desempenho verificadas
- [ ] Alertas configurados para erros de autenticação

### Finais
- [ ] Comunicação para equipe sobre a conclusão da migração
- [ ] Documentação atualizada
- [ ] Tag de versão criada no repositório

## Cronograma

- Data planejada para deploy: ___/___/____
- Janela de manutenção: __:__ até __:__
- Responsável pelo deploy: _________________ 
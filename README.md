# GradyApp

Este é um aplicativo Rails.

## Configuração

Este projeto usa Ruby `3.3.0`.

### Dependências do Sistema

*   PostgreSQL
*   Ruby 3.3.0

### Primeiros Passos

Para começar, clone o repositório e instale as dependências:

```bash
git clone https://github.com/i-abq/GradyApp
cd GradyApp
bundle install
```

### Banco de Dados

Certifique-se de que o PostgreSQL esteja em execução. Em seguida, configure o banco de dados:

```bash
rails db:create
rails db:migrate
rails db:seed # Se houver seeds
```

## Como executar a aplicação

Você pode iniciar o servidor Rails com:

```bash
rails server
```

A aplicação estará disponível em `http://localhost:3000`.

## Como executar os testes

Para executar a suíte de testes, use:

```bash
rails test
```

## Serviços

*   **Servidor Web:** Puma
*   **Banco de Dados:** PostgreSQL

## Deploy com Docker

Este projeto inclui um `Dockerfile` para facilitar o deploy.

1.  **Construa a imagem Docker:**

    ```bash
    docker build -t gradyapp .
    ```

2.  **Execute o container:**

    ```bash
    docker run -p 3000:3000 -d gradyapp
    ```

    O `ENTRYPOINT` do Docker cuidará da preparação do banco de dados.

...

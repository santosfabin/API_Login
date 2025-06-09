# Projeto Backend - API de Gerenciamento de Usuários

Este é o repositório do backend para a API de gerenciamento de login e usuário. Ele foi desenvolvido com Node.js, TypeScript, Express e PostgreSQL, e é executado com comandos manuais do Docker.

## Sumário

*   [Pré-requisitos](#pré-requisitos)
*   [Configuração do Ambiente](#configuração-do-ambiente)
*   [Gerenciamento dos Containers](#gerenciamento-dos-containers)
*   [Rotas da API](#rotas-da-api)

---

## Pré-requisitos

*   **Docker Desktop:** Para criar e gerenciar os containers.
*   **Cliente HTTP:** Ferramenta como Postman, Insomnia ou Thunder Client.

---

## Configuração do Ambiente

Siga estes passos para configurar e executar o projeto.

### 1. Variáveis de Ambiente

Crie o arquivo `.env` a partir do exemplo. Este arquivo é crucial para a conexão com o banco de dados.

```bash
cp .env.example .env
```
**Importante:** Abra o arquivo `.env` e verifique se as variáveis, especialmente `DB_HOST`, correspondem à sua configuração. Para rodar com Docker, o `DB_HOST` será o nome do container do banco de dados na rede Docker.

### 2. Rede Docker

Crie uma rede para que os containers da API e do banco de dados possam se comunicar:
```bash
docker network create minha-rede-app
```

### 3. Container do Banco de Dados

Suba um container PostgreSQL na rede que você criou. Usaremos a imagem oficial do Postgres.

```bash
docker run -d \
  --name postgres-db-aula4 \
  --network minha-rede-app \
  --network-alias db-host \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=1234 \
  -e POSTGRES_DB=alpha \
  -v pgdata_aula4:/var/lib/postgresql/data \
  postgres:14-alpine
```
*   Usamos `--network-alias db-host` para que a API possa se conectar ao banco usando o nome `db-host`.

### 4. Schema do Banco de Dados

Com o container do banco rodando, crie a tabela `users`.

**A.** Acesse o terminal do container do banco:
```bash
docker exec -it postgres-db-aula4 psql -U postgres -d alpha
```

**B.** Execute o SQL para criar a tabela. **A coluna da senha é `password`**:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**C.** Saia do psql com `\q`.

### 5. Imagem Docker do Backend

Construa a imagem da sua aplicação a partir do `Dockerfile`:
```bash
docker build -t minha-api-aula4 .
```

### 6. Container do Backend

Finalmente, execute o container da sua API, conectando-o à rede e passando as variáveis de ambiente corretas.

```bash
docker run -d \
  --name api-server-aula4 \
  --network minha-rede-app \
  -p 7000:7000 \
  -v "$(pwd)/src:/usr/src/app/src" \
  -e PORT=7000 \
  -e DB_HOST=db-host \
  -e DB_USER=postgres \
  -e DB_PASSWORD=1234 \
  -e DB_NAME=alpha \
  -e DB_PORT=5432 \
  -e SECRET_KEY=SenhaForte \
  -e NODE_ENV=development \
  minha-api-aula4
```
Sua API estará rodando em `http://localhost:7000`.

---

## Gerenciamento dos Containers

*   **Ver Logs da API:** `docker logs -f api-server-aula4`
*   **Parar Containers:** `docker stop api-server-aula4 postgres-db-aula4`
*   **Remover Containers:** `docker rm api-server-aula4 postgres-db-aula4`
*   **Remover Volume de Dados (CUIDADO!):** `docker volume rm pgdata_aula4`
*   **Remover Rede:** `docker network rm minha-rede-app`

---

## Rotas da API

A API está acessível em `http://localhost:7000`. Todas as rotas são prefixadas com `/api`.

### `POST /api/users/` - Cadastro de Usuário
- **Descrição:** Registra um novo usuário no sistema.
- **Corpo (JSON):**
  ```json
  {
      "name": "Nome do Usuário",
      "email": "email@example.com",
      "password": "Senha_Segura123!"
  }
  ```

### `POST /api/login/` - Login de Usuário
- **Descrição:** Autentica um usuário e retorna um cookie de sessão.
- **Corpo (JSON):**
  ```json
  {
      "email": "email@example.com",
      "password": "Senha_Segura123!"
  }
  ```

### `DELETE /api/logout/` - Logout de Usuário
- **Descrição:** Invalida a sessão do usuário. Requer autenticação.

### `GET /api/users/` - Listar Todos os Usuários
- **Descrição:** Retorna uma lista de todos os usuários. Requer autenticação.

### `PATCH /api/users/` - Atualizar Usuário
- **Descrição:** Atualiza o próprio usuário (identificado pelo token). Requer autenticação.
- **Corpo (JSON, campos opcionais):**
  ```json
  {
      "name": "Novo Nome",
      "email": "novo.email@example.com"
  }
  ```

### `DELETE /api/users/` - Remover Usuário
- **Descrição:** Remove a conta do próprio usuário (identificado pelo token). Requer autenticação.
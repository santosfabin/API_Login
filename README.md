# Projeto Backend - API de Gerenciamento de Notas

Este é o repositório do backend para a API de gerenciamento de login e usuário. Ele foi desenvolvido com Node.js, TypeScript, Express e PostgreSQL, e é executado em containers Docker para facilitar o desenvolvimento e a implantação.

## Sumário

* [Pré-requisitos](#pré-requisitos)
* [Estrutura do Projeto](#estrutura-do-projeto)
* [Configuração do Ambiente](#configuração-do-ambiente)
    * [1. Criação da Rede Docker](#1-criação-da-rede-docker)
    * [2. Execução do Container PostgreSQL](#2-execução-do-container-postgresql)
    * [3. Configuração do Schema do Banco de Dados](#3-configuração-do-schema-do-banco-de-dados)
    * [4. Construção da Imagem Docker do Backend](#4-construção-da-imagem-docker-do-backend)
    * [5. Execução do Container do Backend](#5-execução-do-container-do-backend)
* [Verificando o Status do Backend](#verificando-o-status-do-backend)
    * [Acessando os Logs do Backend](#acessando-os-logs-do-backend)
    * [Verificando Usuários no Banco de Dados](#verificando-usuários-no-banco-de-dados)
* [Rotas da API](#rotas-da-api)
    * [Autenticação e Usuários](#autenticação-e-usuários)
        * [`POST /api/users/` - Cadastro de Usuário](#post-apiusers---cadastro-de-usuário)
        * [`POST /api/login/` - Login de Usuário](#post-apilogin---login-de-usuário)
        * [`DELETE /api/logout/` - Logout de Usuário](#delete-apilogout---logout-de-usuário)
        * [`GET /api/users/` - Listar Todos os Usuários (Autenticada)](#get-apiusers---listar-todos-os-usuários-autenticada)
        * [`PATCH /api/users/:id` - Atualizar Usuário (Autenticada)](#patch-apiusersid---atualizar-usuário-autenticada)
        * [`DELETE /api/users/:id` - Remover Usuário (Autenticada)](#delete-apiusersid---remover-usuário-autenticada)
    * [Notas (Exemplo - Adicione conforme seu projeto)](#notas-exemplo---adicione-conforme-seu-projeto)
        * [`POST /api/notes/` - Criar Nova Nota (Autenticada)](#post-apinotes---criar-nova-nota-autenticada)
        * [`GET /api/notes/` - Listar Todas as Notas (Autenticada)](#get-apinotes---listar-todas-as-notas-autenticada)
        * [`GET /api/notes/:id` - Obter Nota por ID (Autenticada)](#get-apinotesid---obter-nota-por-id-autenticada)
        * [`PATCH /api/notes/:id` - Atualizar Nota (Autenticada)](#patch-apinotesid---atualizar-nota-autenticada)
        * [`DELETE /api/notes/:id` - Remover Nota (Autenticada)](#delete-apinotesid---remover-nota-autenticada)
* [Testando a API](#testando-a-api)
* [Gerenciamento de Containers](#gerenciamento-de-containers)
    * [Parar Todos os Containers](#parar-todos-os-containers)
    * [Remover Todos os Containers, Imagens e Volumes](#remover-todos-os-containers-imagens-e-volumes)
* [Estrutura de Pastas](#estrutura-de-pastas)
* [Licença](#licença)

---

## Pré-requisitos

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

* **Docker Desktop:** Para criar e gerenciar containers Docker.
    * [Instalação do Docker](https://docs.docker.com/get-docker/)
* **Node.js e npm:** (Opcional, se você for rodar o projeto localmente sem Docker ou para depuração avançada).
    * Versão recomendada: Node.js 20.x
* **Um cliente HTTP:** (Postman, Insomnia, Thunder Client, etc.) para testar as rotas da API.

## Estrutura do Projeto
```text
├── src/
│   ├── app.ts                  # Ponto de entrada da aplicação Express
│   ├── routes/                 # Definição das rotas da API
│   │   ├── index.ts
│   │   ├── users.routes.ts
│   │   ├── login.routes.ts
│   │   ├── logout.routes.ts
│   │   └── notes.routes.ts     # Exemplo de rota de notas
│   ├── controllers/            # Lógica de negócio para cada rota
│   │   ├── usersController.ts
│   │   ├── authController.ts
│   │   └── notesController.ts
│   ├── services/               # Lógica de serviço (ex: interações com DB)
│   │   ├── userService.ts
│   │   ├── authService.ts
│   │   └── noteService.ts
│   ├── middleware/             # Funções de middleware (ex: autenticação)
│   │   └── authMiddleware.ts
│   └── database/               # Configuração do banco de dados (conexão)
│       └── db.ts
├── .env.example                # Exemplo das variáveis de ambiente
├── .dockerignore               # Arquivos a serem ignorados pelo Docker na build
├── Dockerfile                  # Define a imagem Docker do backend
├── package.json                # Dependências e scripts do projeto
├── tsconfig.json               # Configuração do TypeScript
├── README.md                   # Este arquivo
└── ... (outros arquivos de configuração)
```

## Configuração do Ambiente

Siga os passos abaixo para configurar e rodar o ambiente Docker para o backend e o banco de dados.

### 1. Criação da Rede Docker
Primeiro, crie uma rede Docker para permitir que os containers do PostgreSQL e do Backend se comuniquem.

```bash
docker network create minha-rede-backend
```

Explicação: O comando docker network create cria uma rede do tipo "bridge" personalizada. Isso é essencial para que os containers possam se encontrar e comunicar entre si usando seus nomes (aliases) em vez de IPs dinâmicos.

### 2. Execução do Container PostgreSQL
Execute um container PostgreSQL a partir da imagem bitnami/postgresql e conecte-o à rede que você acabou de criar.

```bash
docker run -d \
  --name meu-postgres \
  --network minha-rede-backend \
  --network-alias db-host \
  -v postgres_data:/bitnami/postgresql \
  -e POSTGRESQL_USERNAME=meuuser \
  -e POSTGRESQL_PASSWORD=minhasenha \
  -e POSTGRESQL_DATABASE=meubanco \
  bitnami/postgresql:latest
```

```text
-d: Roda o container em modo "detached" (em segundo plano).
--name meu-postgres: Atribui o nome meu-postgres ao container, facilitando o gerenciamento.
--network minha-rede-backend: Conecta o container à rede que criamos.
--network-alias db-host: Atribui o alias db-host ao container dentro da rede. Seu backend usará este nome para se conectar ao banco de dados.
-v postgres_data:/bitnami/postgresql: Cria um volume nomeado postgres_data para persistir os dados do banco de dados, garantindo que os dados não sejam perdidos ao parar ou remover o container.
-e POSTGRESQL_USERNAME=meuuser: Define o usuário do PostgreSQL.
-e POSTGRESQL_PASSWORD=minhasenha: Define a senha do PostgreSQL.
-e POSTGRESQL_DATABASE=meubanco: Define o nome do banco de dados inicial.
bitnami/postgresql:latest: A imagem Docker a ser utilizada.
```

### 3. Configuração do Schema do Banco de Dados
Após o container PostgreSQL estar rodando, você precisa criar a estrutura (schema) das tabelas que sua aplicação utiliza.

Acesse o shell do container PostgreSQL:

```bash
docker exec -it meu-postgres bash
```
Acesse o prompt do PostgreSQL:

```bash
psql -U meuuser -d meubanco
```
(Substitua meuuser e meubanco pelos seus valores.)

Crie a tabela de usuários (e outras tabelas conforme seu projeto):

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crie outras tabelas como 'notes' se sua aplicação tiver
CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```
Saia do prompt do PostgreSQL e do shell do container:

```sql
\q
```
```text
exit
```
### 4. Construção da Imagem Docker do Backend
Navegue até a pasta raiz do seu projeto backend (onde o Dockerfile e o package.json estão localizados).

Dockerfile:

```dockerfile
# Imagem base
FROM node:20-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de dependência e instala
COPY package*.json ./
RUN npm install

# Copia o tsconfig.json para que o ts-node funcione corretamente no container
COPY tsconfig.json ./

# Expõe a porta que sua API escuta
EXPOSE 7000

# Comando para iniciar a aplicação em modo de desenvolvimento com nodemon
# (Isso é o que vai executar seu script 'dev' do package.json)
CMD ["npm", "run", "dev"]
```
Comando para Construir a Imagem:

```bash
docker build -t meu-backend-api .
```

```text
-t meu-backend-api: Atribui a tag meu-backend-api à sua imagem.

.: Indica que o contexto da construção da imagem é o diretório atual.
```
.dockerignore: Certifique-se de que seu arquivo .dockerignore contenha as entradas necessárias para evitar copiar arquivos desnecessários (como node_modules e .env) para a imagem final, mantendo-a leve e segura.

Exemplo de .dockerignore:
```text
node_modules/
.env
npm-debug.log
dist/      # Se você não precisa da pasta dist na imagem para dev
.git/
*.log
```
### 5. Execução do Container do Backend
Execute o container do backend, conectando-o à rede Docker e passando as variáveis de ambiente necessárias. Este comando é otimizado para desenvolvimento, usando bind mounts e nodemon.

```bash
docker run -d \
  --name minha-api-dev \
  --network minha-rede-backend \
  -p 7000:7000 \
  -v "$(pwd)/src:/usr/src/app/src" \
  -v "$(pwd)/dist:/usr/src/app/dist" \
  -e DB_HOST=db-host \
  -e DB_USER=meuuser \
  -e DB_PASSWORD=minhasenha \
  -e DB_NAME=meubanco \
  -e DB_PORT=5432 \
  -e PORT=7000 \
  -e SECRET_KEY=sua_chave_secreta_para_desenvolvimento \
  -e NODE_ENV=development \
  meu-backend-api
```

```text
-d: Roda o container em modo "detached".
--name minha-api-dev: Nomeia o container do backend.
--network minha-rede-backend: Conecta o container à rede Docker.
-p 7000:7000: Mapeia a porta 7000 do container para a porta 7000 do seu host, permitindo acesso externo.
-v "$(pwd)/src:/usr/src/app/src": Bind mount do diretório src local para o container. Permite que você edite seus arquivos TypeScript localmente e o nodemon dentro do container detecte as mudanças e reinicie a aplicação.
-v "$(pwd)/dist:/usr/src/app/dist": Bind mount do diretório dist local para o container. Útil para depuração.
-e ...: Passa as variáveis de ambiente necessárias para a sua aplicação se conectar ao PostgreSQL e configurar sua porta e chave secreta. Lembre-se de usar db-host para DB_HOST e substituir os valores de credenciais e chave secreta.
-e NODE_ENV=development: Define a variável de ambiente NODE_ENV para "development", o que pode ativar funcionalidades específicas de desenvolvimento na sua aplicação.
meu-backend-api: O nome da imagem que você construiu.
```
Verificando o Status do Backend
Acessando os Logs do Backend
Para ver o que está acontecendo dentro do container do seu backend, incluindo mensagens de inicialização, erros e logs de requisições:

```bash
docker logs -f minha-api-dev
```


```text
docker logs: Comando para exibir os logs de um container.
-f: (Follow) Segue os logs em tempo real, exibindo novas linhas à medida que são geradas. Pressione Ctrl+C para sair.
minha-api-dev: O nome do seu container do backend.
```

Verificando Usuários no Banco de Dados
Para confirmar se os usuários cadastrados pela API estão sendo persistidos no banco de dados:

Acesse o shell do container PostgreSQL:

```bash
docker exec -it meu-postgres bash
```
Acesse o prompt do PostgreSQL:

```bash
psql -U meuuser -d meubanco
```
Liste os usuários:

```sql
SELECT id, name, email, created_at FROM users;
```
Saia do prompt do PostgreSQL e do shell do container:

```sql
\q
```
```text
exit
```
### Rotas da API
A API está acessível na porta 7000 em seu host (http://localhost:7000). Todas as rotas estão prefixadas com /api/.


```text
Autenticação e Usuários
POST /api/users/ - Cadastro de Usuário
Descrição: Registra um novo usuário no sistema.
Método: POST
URL: http://localhost:7000/api/users/
Headers:
Content-Type: application/json
Body (raw, JSON):
```

```json
{
    "name": "Nome do Usuário",
    "email": "email@example.com",
    "password": "Senha_Segura123!"
}
```
Retorno (Status: 201 Created ou 200 OK):
```json
{
    "id": "uuid-gerado-pelo-backend",
    "name": "Nome do Usuário",
    "email": "email@example.com"
}
```

```text
POST /api/login/ - Login de Usuário
Descrição: Autentica um usuário e retorna um cookie de sessão.
Método: POST
URL: http://localhost:7000/api/login/
Headers:
Content-Type: application/json
Body (raw, JSON):
```

```json
{
    "email": "email@example.com",
    "password": "Senha_Segura123!"
}
```
Retorno (Status: 200 OK):
```json
{
    "id": "uuid-do-usuario-logado"
}
```
Cookies: Um cookie token (ou sessionID) será retornado. Este cookie é necessário para acessar rotas autenticadas.

```text
DELETE /api/logout/ - Logout de Usuário
Descrição: Invalida a sessão do usuário.
Método: DELETE
URL: http://localhost:7000/api/logout/
Headers:
Cookies: Envie o cookie de sessão (token) recebido no login.
```

Retorno (Status: 200 OK ou 204 No Content):
```json
{
    "message": "Logout realizado com sucesso."
}
```

```text
GET /api/users/ - Listar Todos os Usuários (Autenticada)
Descrição: Retorna uma lista de todos os usuários cadastrados.
Método: GET
URL: http://localhost:7000/api/users/
Headers:
Cookies: Envie o cookie de sessão (token).
```

Retorno (Status: 200 OK):
```json
[
    {
        "id": "uuid-do-usuario-1",
        "name": "Usuário Um",
        "email": "user1@example.com"
    },
    {
        "id": "uuid-do-usuario-2",
        "name": "Usuário Dois",
        "email": "user2@example.com"
    }
]
```


```text
PATCH /api/users/:id - Atualizar Usuário (Autenticada)
Descrição: Atualiza as informações de um usuário específico.
Método: PATCH
URL: http://localhost:7000/api/users/UUID_DO_USUARIO (substitua UUID_DO_USUARIO pelo ID real)
Headers:
Content-Type: application/json
Cookies: Envie o cookie de sessão (token).
```

Body (raw, JSON - campos opcionais):

```json
{
    "name": "Novo Nome",
    "email": "novo.email@example.com",
    "password": "Nova_Senha_Forte123!"
}
```
Retorno (Status: 200 OK):
```json
{
    "id": "uuid-do-usuario",
    "name": "Novo Nome",
    "email": "novo.email@example.com"
}
```

```text
DELETE /api/users/:id - Remover Usuário (Autenticada)
Descrição: Remove um usuário específico do sistema.
Método: DELETE
URL: http://localhost:7000/api/users/UUID_DO_USUARIO (substitua UUID_DO_USUARIO pelo ID real)
Headers:
Cookies: Envie o cookie de sessão (token).
```text

Retorno (Status: 200 OK):
```json
{
    "message": "Usuário removido com sucesso."
}
```
Notas (Exemplo - Adicione conforme seu projeto)
(Se você tem rotas de notas, adicione-as aqui. Exemplo abaixo):

```text
POST /api/notes/ - Criar Nova Nota (Autenticada)
Descrição: Cria uma nova nota associada ao usuário autenticado.
Método: POST
URL: http://localhost:7000/api/notes/
Headers:
Content-Type: application/json
Cookies: Envie o cookie de sessão (token).
```

Body (raw, JSON):
```json
{
    "title": "Minha Primeira Nota",
    "content": "Conteúdo detalhado da minha nota."
}
```
Retorno (Status: 201 Created ou 200 OK):
```json
{
    "id": "uuid-da-nota-gerada",
    "user_id": "uuid-do-usuario-logado",
    "title": "Minha Primeira Nota",
    "content": "Conteúdo detalhado da minha nota.",
    "created_at": "2024-01-01T10:00:00.000Z"
}
```

```text
GET /api/notes/ - Listar Todas as Notas (Autenticada)
Descrição: Retorna todas as notas do usuário autenticado.
Método: GET
URL: http://localhost:7000/api/notes/
Headers:
Cookies: Envie o cookie de sessão (token).
```

Retorno (Status: 200 OK):
```json
[
    {
        "id": "uuid-da-nota-1",
        "user_id": "uuid-do-usuario",
        "title": "Nota 1",
        "content": "Conteúdo da nota 1."
    },
    {
        "id": "uuid-da-nota-2",
        "user_id": "uuid-do-usuario",
        "title": "Nota 2",
        "content": "Conteúdo da nota 2."
    }
]
```

```text
GET /api/notes/:id - Obter Nota por ID (Autenticada)
Descrição: Retorna uma nota específica pelo seu ID.
Método: GET
URL: http://localhost:7000/api/notes/UUID_DA_NOTA (substitua UUID_DA_NOTA pelo ID real)
Headers:
Cookies: Envie o cookie de sessão (token).
```

Retorno (Status: 200 OK):
```json
{
    "id": "uuid-da-nota",
    "user_id": "uuid-do-usuario",
    "title": "Título da Nota",
    "content": "Conteúdo da nota."
}
```

```text
PATCH /api/notes/:id - Atualizar Nota (Autenticada)
Descrição: Atualiza uma nota específica.
Método: PATCH
URL: http://localhost:7000/api/notes/UUID_DA_NOTA (substitua UUID_DA_NOTA pelo ID real)
Headers:
Content-Type: application/json
Cookies: Envie o cookie de sessão (token).
```

Body (raw, JSON - campos opcionais):
```json
{
    "title": "Novo Título da Nota",
    "content": "Conteúdo atualizado."
}
```
Retorno (Status: 200 OK):
```json
{
    "id": "uuid-da-nota",
    "user_id": "uuid-do-usuario",
    "title": "Novo Título da Nota",
    "content": "Conteúdo atualizado."
}
```

```text
DELETE /api/notes/:id - Remover Nota (Autenticada)
Descrição: Remove uma nota específica.
Método: DELETE
URL: http://localhost:7000/api/notes/UUID_DA_NOTA (substitua UUID_DA_NOTA pelo ID real)
Headers:
Cookies: Envie o cookie de sessão (token).
```

Retorno (Status: 200 OK):
```json
{
    "message": "Nota removida com sucesso."
}
```
Testando a API
Para testar as rotas da API, utilize um cliente HTTP como Postman ou Insomnia. Siga os passos de Configuração do Ambiente para garantir que seus containers estejam rodando, e então utilize as informações da seção Rotas da API para construir suas requisições.

Gerenciamento de Containers
Parar Todos os Containers
Para parar todos os containers Docker relacionados a este projeto (sem removê-los), permitindo que você os inicie novamente mais tarde com seus estados preservados:

Bash
```bash
docker stop meu-postgres minha-api-dev
```
docker stop: Envia um sinal de encerramento para o(s) container(es) especificado(s).
Remover Todos os Containers, Imagens e Volumes
Para limpar completamente o ambiente Docker do projeto, removendo containers, imagens e volumes de dados (isso apagará os dados do seu banco de dados PostgreSQL!):

Pare os containers (se estiverem rodando):

```bash
docker stop meu-postgres minha-api-dev
```
Remova os containers:

```bash
docker rm meu-postgres minha-api-dev
```
Remova a imagem do backend:

```bash
docker rmi meu-backend-api
```
Remova o volume de dados do PostgreSQL (ATENÇÃO: isso apaga seus dados!):

```bash
docker volume rm postgres_data
```
Remova a rede Docker:

```bash
docker network rm minha-rede-backend
```

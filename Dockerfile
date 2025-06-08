# Imagem base
FROM node:20-alpine

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de dependência e instala
COPY package*.json ./
# Para DEV, você provavelmente precisa de TODAS as dependências, então remova --omit=dev
RUN npm install

# Copia o tsconfig.json para que o ts-node funcione corretamente no container
COPY tsconfig.json ./

# Expõe a porta que sua API escuta
EXPOSE 7000

# Comando para iniciar a aplicação em modo de desenvolvimento com nodemon
# (Isso é o que vai executar seu script 'dev' do package.json)
CMD ["npm", "run", "dev"]


d: Roda o container em modo "detached". --name minha-api-dev: Nomeia o container do backend. --network minha-rede-backend: Conecta o container à rede Docker. -p 7000:7000: Mapeia a porta 7000 do container para a porta 7000 do seu host, permitindo acesso externo. -v "$(pwd)/src:/usr/src/app/src": Bind mount do diretório src local para o container. Permite que você edite seus arquivos TypeScript localmente e o nodemon dentro do container detecte as mudanças e reinicie a aplicação. -v "$(pwd)/dist:/usr/src/app/dist": Bind mount do diretório dist local para o container. Útil para depuração. -e ...: Passa as variáveis de ambiente necessárias para a sua aplicação se conectar ao PostgreSQL e configurar sua porta e c
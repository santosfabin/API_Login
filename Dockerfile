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

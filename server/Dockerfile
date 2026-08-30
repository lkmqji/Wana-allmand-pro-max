FROM node:20-alpine

WORKDIR /usr/src/app

# Copie des fichiers de dépendances
COPY package*.json ./

# Installation des dépendances de production
RUN npm ci --omit=dev

# Copie du code source
COPY . .

# Port exposé
EXPOSE 3001

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3001

# Commande de démarrage
CMD ["node", "index.js"]

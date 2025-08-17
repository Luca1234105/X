# Base image Node.js
FROM node:20-slim

# Setta la directory di lavoro
WORKDIR /usr/src/app

# Installa git, python3, pip e strumenti di compilazione in un solo layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-dev build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clona la repo direttamente nella cartella di lavoro
ARG GIT_REPO_URL="https://github.com/qwertyuiop8899/StreamViX.git"
ARG GIT_BRANCH="main"
RUN git -c http.sslVerify=false clone --branch ${GIT_BRANCH} --depth 1 ${GIT_REPO_URL} .

# Installa le dipendenze Python necessarie
RUN pip3 install --no-cache-dir --break-system-packages \
    requests beautifulsoup4 pycryptodome pyDes

# Installa pnpm in versione fissa
RUN npm install -g pnpm@8.15.5

# Assicura permessi corretti e passa all'utente non-root
RUN chown -R node:node /usr/src/app
USER node

# Installa le dipendenze Node.js e build dell'app in un unico layer
RUN pnpm install --prod=false \
    && pnpm add undici@6.19.8 \
    && pnpm run build \
    && pnpm prune --prod  # rimuove devDependencies per alleggerire

# Comando di avvio
CMD ["pnpm", "start"]

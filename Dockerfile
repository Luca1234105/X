# Base image Node.js slim
FROM node:20-slim

# Setta la directory di lavoro
WORKDIR /usr/src/app

# Installa git e Python minimo in un unico layer e pulisce cache apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-pip python3-dev build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clona la repo StreamViX direttamente nella directory di lavoro
ARG GIT_REPO_URL="https://github.com/qwertyuiop8899/StreamViX.git"
ARG GIT_BRANCH="main"
RUN git -c http.sslVerify=false clone --branch ${GIT_BRANCH} --depth 1 ${GIT_REPO_URL} .

# Installa dipendenze Python necessarie
RUN pip3 install --no-cache-dir --break-system-packages \
    requests beautifulsoup4 pycryptodome pyDes

# Installa pnpm in versione fissa
RUN npm install -g pnpm@8.15.5

# Passa all'utente non-root e setta permessi
RUN chown -R node:node /usr/src/app
USER node

# Installa dipendenze Node.js, build e rimuove devDependencies in un unico step
RUN pnpm install --prod=false \
    && pnpm add undici@6.19.8 \
    && pnpm run build \
    && pnpm prune --prod

# Espone la porta dell'applicazione (opzionale, HF la mappa automaticamente)
# EXPOSE 3000

# Comando di avvio con heap aumentato
CMD ["node", "--max-old-space-size=4096", "dist/addon.js"]

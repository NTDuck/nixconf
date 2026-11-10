# Adapted from upstream main's Dockerfile (base digest identical);
# see module header for the deltas (no apt git, no docker-start).
FROM node:24.14.0-slim@sha256:d8e448a56fc63242f70026718378bd4b00f8c82e78d20eefb199224a4d8e33d8

# Puppeteer is a QA-scripts-only devDep; skip its ~150MB Chromium.
ENV PUPPETEER_SKIP_DOWNLOAD=1

WORKDIR /app
USER node

COPY --chown=node:node package.json package-lock.json ./
RUN npm ci

COPY --chown=node:node . .

EXPOSE 4173
# Shell form so PORT stays operator-overridable via podman -e.
CMD ["sh", "-c", "exec node node_modules/vite/bin/vite.js --host 127.0.0.1 --port ${PORT:-4173} --strictPort"]

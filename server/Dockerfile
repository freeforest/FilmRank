FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

COPY src ./src
COPY .env.example ./.env.example

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "src/index.js"]

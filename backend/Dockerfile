# Stage 1: Build
FROM node:20-slim AS builder

WORKDIR /usr/src/app

# Install openssl so prisma generate can detect the version
RUN apt-get update -y && apt-get install -y openssl

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

# Generate Prisma Client
RUN npx prisma generate

COPY . .

RUN npm run build

# Stage 2: Runtime
FROM node:20-slim

WORKDIR /usr/src/app

# Install openssl for Prisma runtime
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies (required for npx prisma CLI during migration/deployment)
RUN npm install

# Copy generated Prisma Client and build output from builder
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /usr/src/app/node_modules/@prisma ./node_modules/@prisma
COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 8080

CMD ["npm", "start"]

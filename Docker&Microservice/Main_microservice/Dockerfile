# Stage 1: Builder stage
FROM node:16 AS builder
WORKDIR /build

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source files
COPY . .

# Stage 2: Production stage
FROM node:16-alpine
WORKDIR /app

# Copy production dependencies
COPY --from=builder /build/package.json /build/package-lock.json ./
RUN npm ci --only=production

# Copy built application
COPY --from=builder /build/src ./src

# Add this line to ensure ES modules work
ENV NODE_OPTIONS="--experimental-modules --es-module-specifier-resolution=node"

EXPOSE 3000
CMD ["node", "src/index.js"]
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

















# ////////////////////////////////////////////////////////////////////////////////////////////////////////////////







# # Stage 1: Builder (install & build)
# FROM node:20-alpine AS builder

# WORKDIR /app

# # Install only production dependencies first for better caching
# COPY package*.json ./
# RUN npm install --production

# # Copy app source code and build (if needed)
# COPY . .

# # If you have a build step (e.g., TypeScript or frontend build), uncomment:
# # RUN npm run build

# # Stage 2: Production (lightweight image)
# FROM node:20-alpine

# WORKDIR /app

# # Copy only required output
# COPY --from=builder /app ./

# EXPOSE 3000

# CMD ["node", "src/index.js"]  
# # or "dist/index.js" if compiled

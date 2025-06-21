# Stage 1: Builder - install dependencies and build
FROM node:16-alpine AS builder
WORKDIR /build

# Copy only what's needed for dependencies
COPY package.json package-lock.json ./

# Install exact versions and clean cache immediately
RUN npm ci --omit=dev && \
    npm cache clean --force

# Copy and build application
COPY . .
# RUN npm run build  # Uncomment if you have a build step

# Stage 2: Minimal runtime
FROM alpine:3.16
WORKDIR /app

# Install only Node.js runtime (no npm)
RUN apk add --no-cache nodejs

# Copy production files from builder
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/src ./src
# COPY --from=builder /build/dist ./dist  # For built applications

# Create non-root user
RUN adduser -D appuser && chown -R appuser /app
USER appuser

EXPOSE 3000
CMD ["node", "src/index.js"]
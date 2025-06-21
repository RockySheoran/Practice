# Docker README (Code-Centric)

Code-based guide for Docker with practical examples, commands, and interview questions answered through code. Ideal for developers and DevOps professionals.

## Table of Contents
1. [Setup Docker](#setup-docker)
2. [Core Docker Commands](#core-docker-commands)
3. [Dockerfile Example](#dockerfile-example)
4. [Docker Compose Example](#docker-compose-example)
5. [Docker Networking](#docker-networking)
6. [Docker Storage](#docker-storage)
7. [Interview Questions (Code-Based)](#interview-questions-code-based)
8. [Troubleshooting Commands](#troubleshooting-commands)

---

## Setup Docker

```bash
# Install Docker on Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
docker run hello-world
```

---

## Core Docker Commands

### Run and Manage Containers
```bash
# Run Nginx container (detached, port 8080:80, named)
docker run -d -p 8080:80 --name web-server nginx

# List running containers
docker ps

# List all containers
docker ps -a

# View container logs
docker logs web-server

# Access container shell
docker exec -it web-server /bin/bash

# Stop container
docker stop web-server

# Remove container
docker rm web-server
```

### Image Operations
```bash
# Pull Node.js image
docker pull node:16

# List images
docker images

# Build image from Dockerfile
docker build -t my-app:1.0 .

# Push image to Docker Hub
docker push my-username/my-app:1.0

# Remove image
docker rmi my-app:1.0
```

### System Cleanup
```bash
# Remove unused containers, images, networks
docker system prune

# Check system info
docker info --format '{{.ServerVersion}}'
```

---

## Dockerfile Example

```dockerfile
# Dockerfile for a Node.js app
FROM node:16

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

```bash
# Build the image
docker build -t my-app:1.0 .

# Run the container
docker run -d -p 3000:3000 my-app:1.0
```

---

## Docker Compose Example

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: my-secret-pw
    volumes:
      - db-data:/var/lib/mysql
volumes:
  db-data:
```

```bash
# Start services
docker-compose up -d

# View running services
docker-compose ps

# Check logs
docker-compose logs

# Stop and remove services
docker-compose down
```

---

## Docker Networking

```bash
# Create a custom bridge network
docker network create my-network

# Run container in custom network
docker run -d --name app1 --network my-network nginx

# List networks
docker network ls

# Inspect network
docker network inspect my-network

# Connect existing container to network
docker network connect my-network app2

# Remove network
docker network rm my-network
```

---

## Docker Storage

```bash
# Create a volume
docker volume create my-volume

# Run container with volume
docker run -d -v my-volume:/app --name app3 nginx

# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-volume

# Run container with bind mount
docker run -d -v /host/path:/app --name app4 nginx

# Remove volume
docker volume rm my-volume
```

---

## Interview Questions (Code-Based)

1. **How to run a container with environment variables?**
```bash
docker run -d -e MY_VAR=value -p 8080:80 --name env-test nginx
```

2. **How to reduce Docker image size?**
```dockerfile
# Multi-stage build
FROM node:16 AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM node:16-slim
WORKDIR /app
COPY --from=builder /app/dist .
CMD ["node", "index.js"]
```

3. **How to copy files from a container to the host?**
```bash
docker cp my-container:/app/file.txt ./file.txt
```

4. **How to limit container resources?**
```bash
docker run -d --memory="512m" --cpus="0.5" --name resource-limited nginx
```

5. **How to debug a container that won't start?**
```bash
docker logs my-container
docker inspect my-container
```

---

## Troubleshooting Commands

```bash
# Check why container failed
docker logs my-container

# Inspect container details
docker inspect my-container

# Check for port conflicts
netstat -tuln | grep 8080

# Rebuild image without cache
docker build --no-cache -t my-app:1.0 .

# Free up disk space
docker system prune -a
docker volume prune
```
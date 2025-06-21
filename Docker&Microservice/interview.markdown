# Docker README: Comprehensive Guide, Architecture, and Top 30 Interview Questions

This README is a complete guide to Docker, covering all key concepts, the Docker architecture, practical code examples, and the **top 30 interview questions** (including theory-based questions) for Docker-related roles. It is designed for beginners, developers, and DevOps professionals preparing for interviews.

## Table of Contents
1. [What is Docker?](#what-is-docker)
2. [Docker Architecture](#docker-architecture)
3. [Core Docker Concepts](#core-docker-concepts)
4. [Docker Installation](#docker-installation)
5. [Essential Docker Commands](#essential-docker-commands)
6. [Dockerfile Guide](#dockerfile-guide)
7. [Docker Compose](#docker-compose)
8. [Docker Networking](#docker-networking)
9. [Docker Storage](#docker-storage)
10. [Docker Best Practices](#docker-best-practices)
11. [Top 30 Docker Interview Questions](#top-30-docker-interview-questions)
12. [Troubleshooting Tips](#troubleshooting-tips)
13. [Resources](#resources)

---

## What is Docker?

Docker is an open-source platform that uses **containerization** to package applications and their dependencies into portable, lightweight containers. Containers run consistently across different environments (development, testing, production).

- **Key Features**: Portability, scalability, resource efficiency.
- **Use Cases**: Microservices, CI/CD pipelines, cloud-native applications.
- **Containers vs. VMs**: Containers share the host OS kernel, making them lighter than VMs, which include a full OS.

---

## Docker Architecture

Docker’s architecture is built around a client-server model, leveraging several components to manage containers efficiently.

### Components
1. **Docker Client**:
   - CLI tool (`docker`) that users interact with to send commands (e.g., `docker run`).
   - Communicates with the Docker daemon via REST API.
2. **Docker Daemon (dockerd)**:
   - Server process that manages images, containers, networks, and volumes.
   - Runs on the host OS and handles all container operations.
3. **Docker Images**:
   - Read-only templates built from Dockerfiles, stored in layers for efficiency.
   - Example: `nginx:latest` from Docker Hub.
4. **Docker Containers**:
   - Runnable instances of images, isolated using namespaces and cgroups.
5. **Docker Registry**:
   - Stores and distributes images (e.g., Docker Hub, private registries like AWS ECR).
6. **Containerd**:
   - A lightweight container runtime that manages container lifecycles (start, stop, etc.).
   - Interfaces between the Docker daemon and the OS.
7. **runc**:
   - Low-level runtime for creating and running containers, based on OCI standards.
8. **Docker Networking**:
   - Manages container communication using drivers (bridge, host, overlay).
9. **Docker Storage**:
   - Handles data persistence via volumes or bind mounts.

### How It Works
- The **Docker Client** sends commands to the **Docker Daemon**.
- The daemon pulls images from a **Registry** (e.g., Docker Hub).
- **Containerd** and **runc** create and manage containers using the host OS’s kernel features (namespaces for isolation, cgroups for resource limits).
- Containers share the host kernel but run in isolated environments with their own filesystems, processes, and networks.

### Architecture Diagram (Conceptual)
```
[User] --> [Docker Client] --> [Docker Daemon (dockerd)]
                                  |
                                  v
[Containerd] --> [runc] --> [Containers]
                                  |
                                  v
[Images] <--> [Registry (e.g., Docker Hub)]
                                  |
                                  v
[Host OS Kernel] --> [Namespaces, Cgroups]
```

---

## Core Docker Concepts

1. **Image**: Read-only template for containers, built from a Dockerfile.
2. **Container**: Running instance of an image, isolated from others.
3. **Dockerfile**: Script with instructions to build an image.
4. **Registry**: Repository for storing images (e.g., Docker Hub).
5. **Docker Compose**: Tool for multi-container apps using YAML.
6. **Docker Swarm**: Native orchestration for container clusters.
7. **Volumes**: Persistent storage for containers.

---

## Docker Installation

### Ubuntu
```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
docker run hello-world
```

### Windows/Mac
- Install Docker Desktop from [Docker’s website](https://www.docker.com/products/docker-desktop).
- Verify: `docker run hello-world`

---

## Essential Docker Commands

### Containers
```bash
# Run a container (detached, port mapping)
docker run -d -p 8080:80 --name my-web nginx

# List running containers
docker ps

# List all containers
docker ps -a

# Stop a container
docker stop my-web

# Remove a container
docker rm my-web

# View logs
docker logs my-web

# Access shell
docker exec -it my-web /bin/bash
```

### Images
```bash
# Pull an image
docker pull python:3.9

# Build an image
docker build -t my-app:1.0 .

# List images
docker images

# Push to registry
docker push my-username/my-app:1.0

# Remove an image
docker rmi my-app:1.0
```

### System
```bash
# Clean unused resources
docker system prune

# View system info
docker info --format '{{.ServerVersion}}'
```

---

## Dockerfile Guide

A `Dockerfile` defines image creation. Example for a Python app:

```dockerfile
# Use Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY . .

# Expose port
EXPOSE 5000

# Run app
CMD ["python", "app.py"]
```

### Build and Run
```bash
docker build -t my-app:1.0 .
docker run -d -p 5000:5000 my-app:1.0
```

---

## Docker Compose

Manages multi-container apps. Example `docker-compose.yml`:

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: mysecretpassword
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
```

### Commands
```bash
# Start services
docker-compose up -d

# List services
docker-compose ps

# View logs
docker-compose logs

# Stop and remove
docker-compose down
```

---

## Docker Networking

Docker supports:
- **Bridge**: Default, isolates containers on the same host.
- **Host**: Uses host’s network stack.
- **Overlay**: For multi-host communication (Swarm).
- **None**: No networking.

### Commands
```bash
# Create network
docker network create my-net

# Run container in network
docker run -d --name app1 --network my-net nginx

# List networks
docker network ls

# Inspect network
docker network inspect my-net

# Remove network
docker network rm my-net
```

---

## Docker Storage

### Volumes
```bash
# Create volume
docker volume create my-volume

# Run with volume
docker run -d -v my-volume:/app --name app2 nginx

# List volumes
docker volume ls

# Remove volume
docker volume rm my-volume
```

### Bind Mounts
```bash
# Mount host directory
docker run -d -v /host/path:/app/data --name app3 nginx
```

---

## Docker Best Practices

1. Use slim base images: `python:3.9-slim`.
2. Minimize layers: Combine `RUN` commands.
3. Multi-stage builds:
```dockerfile
FROM node:16 AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build
FROM node:16-slim
COPY --from=builder /app/dist .
CMD ["node", "index.js"]
```
4. Run as non-root: `USER appuser`.
5. Use specific tags: `nginx:1.21` vs. `latest`.
6. Clean up: `docker system prune`.

---

## Top 30 Docker Interview Questions

### Beginner-Level (15 Questions, Theory and Practical)

1. **What is Docker, and why is it used? (Theory)**
   - **Answer**: Docker is a containerization platform that packages apps and dependencies for consistency across environments. Used for portability, scalability, and efficient CI/CD.
   - **Code**:
     ```bash
     docker run hello-world
     ```

2. **What is the difference between a Docker image and a container? (Theory)**
   - **Answer**: Image is a read-only template; container is a running, writable instance.
   - **Code**:
     ```bash
     docker build -t my-image .
     docker run -d my-image
     ```

3. **What is a Dockerfile, and what is it used for? (Theory)**
   - **Answer**: Script with instructions to build a Docker image.
   - **Code**:
     ```dockerfile
     FROM alpine
     CMD ["echo", "Hello"]
     ```

4. **How does Docker differ from a virtual machine? (Theory)**
   - **Answer**: Containers share the host OS kernel, making them lightweight; VMs include a full OS, consuming more resources.

5. **What is Docker Hub? (Theory)**
   - **Answer**: Public registry for storing and sharing Docker images.
   - **Code**:
     ```bash
     docker pull nginx
     ```

6. **How do you run a container? (Practical)**
   - **Answer**: Use `docker run`.
   - **Code**:
     ```bash
     docker run -d -p 8080:80 nginx
     ```

7. **How do you list all containers? (Practical)**
   - **Answer**: Use `docker ps -a`.
   - **Code**:
     ```bash
     docker ps -a
     ```

8. **What are the main components of Docker architecture? (Theory)**
   - **Answer**: Client, daemon, containerd, runc, images, containers, registry.

9. **How do you build a Docker image? (Practical)**
   - **Answer**: Use `docker build`.
   - **Code**:
     ```bash
     docker build -t my-app:1.0 .
     ```

10. **What is the purpose of the `EXPOSE` instruction? (Theory)**
    - **Answer**: Documents ports the container listens on.
    - **Code**:
      ```dockerfile
      EXPOSE 8080
      ```

11. **How do you view container logs? (Practical)**
    - **Answer**: Use `docker logs`.
    - **Code**:
      ```bash
      docker logs my-container
      ```

12. **What is containerization? (Theory)**
    - **Answer**: Technology to package apps with dependencies in isolated, lightweight units.

13. **How do you remove a Docker image? (Practical)**
    - **Answer**: Use `docker rmi`.
    - **Code**:
      ```bash
      docker rmi my-app:1.0
      ```

14. **What is the role of namespaces in Docker? (Theory)**
    - **Answer**: Provide isolation for processes, network, filesystem, etc.

15. **How do you clean unused Docker resources? (Practical)**
    - **Answer**: Use `docker system prune`.
    - **Code**:
      ```bash
      docker system prune
      ```

### Intermediate-Level (10 Questions, Theory and Practical)

16. **What is the difference between `CMD` and `ENTRYPOINT`? (Theory)**
    - **Answer**: `CMD` provides default command/args, replaceable; `ENTRYPOINT` sets fixed command, with `CMD` as args.
    - **Code**:
      ```dockerfile
      ENTRYPOINT ["python", "app.py"]
      CMD ["--debug"]
      ```

17. **How does Docker ensure data persistence? (Theory)**
    - **Answer**: Uses volumes or bind mounts for data outside container lifecycle.
    - **Code**:
      ```bash
      docker volume create my-data
      docker run -v my-data:/app nginx
      ```

18. **What is Docker Compose, and when is it used? (Theory)**
    - **Answer**: Tool for defining and running multi-container apps using YAML, ideal for development and testing.
    - **Code**:
      ```yaml
      version: '3'
      services:
        web:
          image: nginx
      ```

19. **How do you limit container resources? (Practical)**
    - **Answer**: Use `--memory` and `--cpus`.
    - **Code**:
      ```bash
      docker run -d --memory="256m" --cpus="0.5" nginx
      ```

20. **What are Docker’s network types, and how do they work? (Theory)**
    - **Answer**: Bridge (default, single-host isolation), host (uses host’s network), overlay (multi-host), none (no networking).
    - **Code**:
      ```bash
      docker network create my-net
      docker run --network my-net nginx
      ```

21. **How do you copy files between host and container? (Practical)**
    - **Answer**: Use `docker cp`.
    - **Code**:
      ```bash
      docker cp my-container:/app/file.txt .
      ```

22. **What is the role of cgroups in Docker? (Theory)**
    - **Answer**: Control groups limit and manage resources (CPU, memory) for containers.

23. **How do you inspect a container’s details? (Practical)**
    - **Answer**: Use `docker inspect`.
    - **Code**:
      ```bash
      docker inspect my-container
      ```

24. **What is a multi-stage build, and why use it? (Theory)**
    - **Answer**: Separates build and runtime environments to reduce image size.
    - **Code**:
      ```dockerfile
      FROM node:16 AS builder
      RUN npm install
      FROM node:16-slim
      COPY --from=builder /app .
      ```

25. **How do you push an image to a registry? (Practical)**
    - **Answer**: Use `docker push`.
    - **Code**:
      ```bash
      docker push my-username/my-app:1.0
      ```

### Advanced-Level (5 Questions, Theory and Practical)

26. **How do you optimize a Docker image for production? (Theory)**
    - **Answer**: Use slim base images, multi-stage builds, `.dockerignore`, combine `RUN` commands.
    - **Code**:
      ```dockerfile
      FROM golang:1.17 AS builder
      RUN go build -o app
      FROM alpine
      COPY --from=builder /app .
      CMD ["./app"]
      ```

27. **What is Docker Swarm, and how does it compare to Kubernetes? (Theory)**
    - **Answer**: Swarm is Docker’s native orchestration; simpler but less feature-rich than Kubernetes.
    - **Code**:
      ```bash
      docker swarm init
      docker service create --name web --publish 8080:80 nginx
      ```

28. **How do you secure a Docker container? (Theory)**
    - **Answer**: Run as non-root, scan images, limit privileges, use trusted registries.
    - **Code**:
      ```dockerfile
      USER appuser
      ```
      ```bash
      docker scan my-app:1.0
      ```

29. **How does Docker handle container isolation? (Theory)**
    - **Answer**: Uses namespaces (PID, network, mount) and cgroups for resource limits.

30. **How do you debug a container that fails to start? (Practical)**
    - **Answer**: Check logs, inspect configuration, test commands.
    - **Code**:
      ```bash
      docker logs my-container
      docker inspect my-container
      docker exec -it my-container /bin/bash
      ```

---

## Troubleshooting Tips

```bash
# Container fails to start
docker logs my-container
docker inspect my-container

# Port conflict
netstat -tuln | grep 8080

# Build failure
docker build --no-cache -t my-app:1.0 .

# Disk space issues
docker system prune -a
docker volume prune
```

---

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
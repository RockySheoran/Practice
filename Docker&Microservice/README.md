
Docker README
This README provides a comprehensive guide to Docker, including its concepts, commands, best practices, and common interview questions. It is designed for beginners, developers, and DevOps professionals looking to understand or prepare for Docker-related roles.
Table of Contents

What is Docker?
Key Docker Concepts
Docker Installation
Docker Commands
Dockerfile Basics
Docker Compose
Docker Networking
Docker Storage
Docker Best Practices
Common Docker Interview Questions
Troubleshooting Docker
Resources


What is Docker?
Docker is an open-source platform that automates the deployment, scaling, and management of applications using containerization. Containers allow developers to package applications with their dependencies, ensuring consistency across development, testing, and production environments.

Containers vs. Virtual Machines: Containers are lightweight, sharing the host OS kernel, unlike VMs which include a full OS.
Use Cases: Microservices, CI/CD pipelines, cloud-native applications, and hybrid cloud deployments.


Key Docker Concepts

Image: A read-only template used to create containers. Images are built from a series of layers defined in a Dockerfile.
Container: A runnable instance of an image. Containers are isolated but share the host OS.
Dockerfile: A script containing instructions to build a Docker image.
Registry: A storage and distribution system for Docker images (e.g., Docker Hub, Amazon ECR).
Docker Hub: A public registry for sharing Docker images.
Docker Compose: A tool for defining and running multi-container Docker applications using YAML files.
Docker Swarm: Docker's native orchestration tool for managing a cluster of Docker nodes.
Volumes: Persistent storage for containers to retain data beyond their lifecycle.


Docker Installation
To install Docker on various platforms:

Ubuntu:
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker


Windows/Mac: Download and install Docker Desktop from Docker's official website.

Verify Installation:
docker --version
docker run hello-world




Docker Commands
Basic Commands

Run a container:
docker run -d -p 80:80 --name my-container nginx


-d: Run in detached mode.
-p: Map host port to container port.
--name: Assign a name to the container.


List running containers:
docker ps


List all containers:
docker ps -a


Stop a container:
docker stop my-container


Remove a container:
docker rm my-container


Remove an image:
docker rmi image-name



Image Commands

Pull an image:
docker pull nginx


Build an image:
docker build -t my-image:tag .


List images:
docker images


Push an image to a registry:
docker push my-username/my-image:tag



Container Management

Inspect a container:
docker inspect my-container


View container logs:
docker logs my-container


Execute a command in a container:
docker exec -it my-container /bin/bash



System Commands

Clean unused containers, images, networks:
docker system prune


View Docker info:
docker info




Dockerfile Basics
A Dockerfile is a script used to create Docker images. Below is an example:
# Use an official Node.js runtime as a base image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]

Common Dockerfile Instructions

FROM: Specifies the base image.
WORKDIR: Sets the working directory inside the container.
COPY: Copies files from the host to the container.
RUN: Executes commands during image building.
CMD: Specifies the default command to run when the container starts.
EXPOSE: Documents the port the container listens on.
ENV: Sets environment variables.


Docker Compose
Docker Compose is used to define and manage multi-container applications. Below is an example docker-compose.yml:
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
      MYSQL_ROOT_PASSWORD: example
    volumes:
      - db-data:/var/lib/mysql
volumes:
  db-data:

Common Docker Compose Commands

Start services:
docker-compose up -d


Stop services:
docker-compose down


View logs:
docker-compose logs


Build services:
docker-compose build




Docker Networking
Docker supports several network types:

Bridge: Default network for containers on a single host (isolated).
Host: Containers share the host's network stack.
Overlay: Used for communication between containers across multiple hosts (e.g., in Docker Swarm).
None: No networking.

Networking Commands

List networks:
docker network ls


Create a network:
docker network create my-network


Connect a container to a network:
docker network connect my-network my-container




Docker Storage
Docker provides two main storage options:

Volumes:

Managed by Docker, stored in /var/lib/docker/volumes/.

Command:
docker volume create my-volume
docker run -v my-volume:/app my-image




Bind Mounts:

Map a host directory to a container directory.

Command:
docker run -v /host/path:/container/path my-image





Storage Commands

List volumes:
docker volume ls


Remove a volume:
docker volume rm my-volume




Docker Best Practices

Use Official Images: Start with trusted images from Docker Hub.
Minimize Image Size: Use multi-stage builds and .dockerignore to exclude unnecessary files.
Avoid Running as Root: Use USER in Dockerfile to run as a non-root user.
Use Tags: Tag images with specific versions (e.g., nginx:1.21 instead of nginx:latest).
Clean Up Resources: Regularly prune unused containers, images, and volumes.
Leverage Caching: Order Dockerfile instructions to maximize layer caching.
Secure Containers: Scan images for vulnerabilities using tools like docker scan.


Common Docker Interview Questions
Beginner Level

What is the difference between a Docker image and a container?
An image is a read-only template, while a container is a running instance of an image.


What is a Dockerfile?
A script with instructions to build a Docker image.


How do you persist data in Docker?
Use volumes or bind mounts to store data outside the container's filesystem.



Intermediate Level

What is the difference between CMD and ENTRYPOINT in a Dockerfile?
CMD specifies the default command, which can be overridden. ENTRYPOINT defines a fixed command, with CMD providing arguments.


How does Docker networking work?
Docker uses bridge, host, overlay, or none networks to enable container communication.


What is Docker Compose used for?
To define and manage multi-container applications using YAML files.



Advanced Level

How would you optimize a Docker image?
Use multi-stage builds, minimize layers, and exclude unnecessary files with .dockerignore.


What is Docker Swarm, and how does it compare to Kubernetes?
Docker Swarm is Docker's native orchestration tool. Kubernetes is more complex but offers greater scalability and features.


How do you secure a Docker container?
Run as non-root, scan images, limit container privileges, and use trusted registries.


What happens when you run docker system prune?
It removes unused containers, images, networks, and volumes to free up space.




Troubleshooting Docker

Container fails to start:
Check logs: docker logs container-name.
Inspect configuration: docker inspect container-name.


Port already in use:
Identify the process: netstat -tuln | grep <port>.
Stop conflicting process or map a different host port.


Image build fails:
Verify Dockerfile syntax and ensure dependencies are available.
Use --no-cache to rebuild without cached layers.


Out of disk space:
Run docker system prune or docker volume prune to clean up.




Resources

Official Docker Documentation
Docker Hub
Docker Compose Reference
Docker Best Practices
Docker Interview Questions


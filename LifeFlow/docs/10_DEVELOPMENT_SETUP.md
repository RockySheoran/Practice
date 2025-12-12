# Local Development Setup for LifeFlow

## Prerequisites

```
Required Software:
├─ Git (version 2.40+)
├─ Docker Desktop (version 4.20+)
├─ Docker Compose (version 2.20+)
├─ Java 17 JDK (OpenJDK or Oracle)
├─ Maven 3.8+ (for building services)
├─ Node.js 18+ (for frontend)
├─ PostgreSQL CLI tools (psql)
└─ Postman or curl (for API testing)

System Requirements:
├─ CPU: 4 cores minimum
├─ RAM: 8GB minimum (12GB recommended)
├─ Storage: 50GB free space
├─ OS: Linux, macOS, or Windows (WSL2)
└─ Network: Stable internet connection
```

## Step 1: Clone Repository

```bash
git clone https://github.com/RockySheoran/LifeFlow.git
cd LifeFlow
```

## Step 2: Environment Configuration

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your local values
cat .env

# Important environment variables:
POSTGRES_USER=lifeflow
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=lifeflow_dev

RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest

SMTP_HOST=mailhog
SMTP_PORT=1025

JWT_SECRET=your_super_secret_jwt_key_for_dev_only
```

## Step 3: Start Docker Compose

```bash
# Start all services
docker-compose up -d

# Expected services:
# ✓ PostgreSQL (port 5432)
# ✓ RabbitMQ (port 5672, management: 15672)
# ✓ Redis (port 6379)
# ✓ Mailhog (port 1025, web: 8025)
# ✓ Keycloak (port 8080)
# ✓ API Gateway (port 8000)
# ✓ All 8 microservices

# Check status
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Example: View donor-service logs
docker-compose logs -f donor-service
```

## Step 4: Initialize Databases

```bash
# Connect to PostgreSQL
docker exec -it lifeflow-postgres psql -U lifeflow

# Or run initialization script
bash ./scripts/init-databases.sh

# This will:
# ├─ Create individual databases per service
# ├─ Create roles and permissions
# ├─ Initialize default data
# └─ Create indices

# Verify
psql -U lifeflow -h localhost -c "\l"  # List databases
```

## Step 5: Build & Run Services Locally

```bash
# Option A: Using Docker Compose (Easiest)
docker-compose up -d

# Option B: Build and run individually for development

# Build all services
mvn -DskipTests clean package -am

# Run Identity Service
cd services/identity-service
java -jar target/identity-service-1.0.0.jar
# Service starts on http://localhost:8001

# In another terminal, run Donor Service
cd services/donor-service
java -jar target/donor-service-1.0.0.jar
# Service starts on http://localhost:8002

# Repeat for other services...
```

## Step 6: Verify Setup

```bash
# Test API Gateway
curl -X GET http://localhost:8000/api/v1/health

# Test Identity Service
curl -X POST http://localhost:8001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@",
    "first_name": "Test",
    "last_name": "User"
  }'

# Access RabbitMQ Management Console
# Open browser: http://localhost:15672
# Username: guest
# Password: guest

# Access PostgreSQL
docker exec -it lifeflow-postgres psql -U lifeflow

# Access Mailhog (Email Testing)
# Open browser: http://localhost:8025
```

## Step 7: Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/blood-request-improvements

# 2. Make code changes
# ... edit files ...

# 3. Run tests
mvn test

# 4. Run integration tests
mvn verify

# 5. Build Docker image
docker build -t lifeflow/donor-service:latest ./services/donor-service

# 6. Update docker-compose.yml if needed
# Change image reference to your local build

# 7. Restart service
docker-compose up -d donor-service

# 8. View logs
docker-compose logs -f donor-service

# 9. Commit and push
git add .
git commit -m "feat: add blood request improvements"
git push origin feature/blood-request-improvements

# 10. Create Pull Request on GitHub
```

## Useful Docker Commands

```bash
# View all containers
docker-compose ps

# View logs
docker-compose logs -f                    # All services
docker-compose logs -f donor-service      # Specific service

# Execute command in container
docker exec -it lifeflow-postgres psql -U lifeflow

# Restart service
docker-compose restart donor-service

# Stop all services
docker-compose stop

# Remove all containers and volumes
docker-compose down -v

# Clean up docker images
docker image prune -a

# Check network
docker network ls
docker network inspect lifeflow_default
```

## API Testing with Postman

```bash
# Import Postman collection
1. Open Postman
2. File → Import → Select ./postman/LifeFlow.postman_collection.json
3. Import environment: ./postman/Dev.postman_environment.json

# Test endpoints:
├─ POST /api/v1/auth/register (Create account)
├─ POST /api/v1/auth/login (Login)
├─ GET /api/v1/donors/me (Get my profile)
├─ POST /api/v1/blood-requests (Create blood request)
└─ ... more endpoints

# Authentication flow:
1. Register new user
2. Login → Get JWT token
3. Add "Authorization: Bearer {token}" to subsequent requests
4. Use token in other authenticated endpoints
```

## Debugging

```bash
# Enable debug logging
export DEBUG=true
docker-compose up -d

# Remote debugging in IDE
# 1. Add debug flag to Java command
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
  -jar target/donor-service-1.0.0.jar

# 2. In IDE (IntelliJ IDEA), set up remote debugger:
# Run → Edit Configurations → Add "Remote JVM Debug"
# Host: localhost, Port: 5005

# 3. Set breakpoints in code
# 4. Click Debug button in IDE

# View database queries
psql -U lifeflow -h localhost -d lifeflow_donors -c "
  SELECT query, calls, mean_time
  FROM pg_stat_statements
  ORDER BY mean_time DESC
  LIMIT 10;
"

# Monitor RabbitMQ
# Open http://localhost:15672 → Queues tab
# View message counts, consumer status

# Monitor Redis
docker exec -it lifeflow-redis redis-cli
> INFO stats        # Show stats
> MONITOR           # Watch all commands
> FLUSHDB           # Clear database (dev only!)
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

### PostgreSQL Connection Issues
```bash
# Check if container is running
docker ps | grep postgres

# Restart container
docker-compose restart postgres

# Check logs
docker-compose logs postgres

# Verify connection string
# Should be: jdbc:postgresql://lifeflow-postgres:5432/lifeflow_donors
# Not: jdbc:postgresql://localhost:5432/...
# (inside Docker containers, use service names, not localhost)
```

### Out of Memory
```bash
# Increase Docker Desktop memory
# Docker Desktop → Preferences → Resources → Memory: 12GB+

# Or stop some services
docker-compose down
docker-compose up -d postgres rabbitmq redis

# Start only services you're working on
```

### Microservices Can't Connect to Database
```bash
# Check Docker network
docker network inspect lifeflow_default

# Ensure all services are on same network
# In docker-compose.yml:
services:
  postgres:
    networks:
      - lifeflow_network
  donor-service:
    networks:
      - lifeflow_network

networks:
  lifeflow_network:
    driver: bridge
```

## Next Steps

1. **Read the docs**:
   - `02_ARCHITECTURE.md`: Understand system design
   - `03_FUNCTIONAL_REQUIREMENTS.md`: Learn features
   - `04_ER_DIAGRAMS.md`: Study database schemas

2. **Explore code**:
   - Start with `DonorServiceApplication.java` in donor-service
   - Read entity classes in `com.lifeflow.entity`
   - Study REST controllers in `com.lifeflow.controller`

3. **Write code**:
   - Create a new branch
   - Implement a small feature
   - Write tests
   - Submit a PR

4. **Contribute**:
   - Follow code style guide
   - Write unit tests
   - Update documentation
   - Request code review

---

## Development Tools Recommendations

### IDE Setup (IntelliJ IDEA)
```
Plugins:
├─ Lombok
├─ Spring Boot Helper
├─ Docker
├─ Database Client
├─ REST Client
└─ GitToolBox

Code Style:
├─ Follow Google Java Style Guide
├─ Use 4-space indentation
├─ Max line length: 120 characters
└─ Auto-format before commit
```

### Git Workflow
```
Branch naming:
├─ feature/feature-name
├─ bugfix/bug-name
├─ docs/documentation-name
└─ hotfix/critical-fix

Commit messages:
feat: add blood request feature
fix: resolve notification delivery issue
docs: update API documentation
test: add unit tests for donor service
refactor: simplify inventory logic

Make commits atomic: One feature = one commit
```


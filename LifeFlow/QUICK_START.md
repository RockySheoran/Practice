# LifeFlow Quick Start Guide

Get LifeFlow running locally in 5 minutes!

## Prerequisites

```bash
# Check if installed
docker --version        # Should be 4.20+
docker-compose --version  # Should be 2.20+
git --version          # Any recent version

# Install if missing
# macOS: brew install docker docker-compose git
# Ubuntu: sudo apt-get install docker.io docker-compose git
# Windows: Use Docker Desktop installer
```

## 1. Clone Repository (1 minute)

```bash
git clone https://github.com/RockySheoran/LifeFlow.git
cd LifeFlow
```

## 2. Copy Environment File (1 minute)

```bash
cp .env.example .env

# Optional: Edit .env with your values
# Default values are fine for local development
```

## 3. Start Docker Containers (3 minutes)

```bash
docker-compose up -d

# Wait for services to start (check with: docker-compose ps)
# This will start:
# ✓ PostgreSQL database
# ✓ RabbitMQ message broker
# ✓ Redis cache
# ✓ Mailhog email server
# ✓ API Gateway
# ✓ All 8 microservices
```

## 4. Verify Setup (Takes ~30 seconds)

```bash
# Check all containers are running
docker-compose ps

# Test API Gateway
curl http://localhost:8000/health

# Expected response:
# {"status":"UP"}
```

## 5. Access Services

### API Gateway
```
Base URL: http://localhost:8000
Health: http://localhost:8000/health
```

### Microservices (Direct Access)
```
Identity Service:   http://localhost:8001
Donor Service:      http://localhost:8002
Inventory Service:  http://localhost:8003
Request Service:    http://localhost:8004
Geolocation Service: http://localhost:8005
Notification Service: http://localhost:8006
Camp Service:       http://localhost:8007
Analytics Service:  http://localhost:8008
```

### Infrastructure Dashboards
```
RabbitMQ Management: http://localhost:15672 (guest/guest)
Mailhog Web UI:     http://localhost:8025
PostgreSQL:         localhost:5432
Redis CLI:          redis-cli -h localhost
```

## 6. Test First API Call

```bash
# Register a new user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@",
    "first_name": "Test",
    "last_name": "User",
    "user_type": "DONOR"
  }'

# Expected response:
# {
#   "user_id": "uuid-xxx",
#   "email": "test@example.com",
#   "message": "Registration successful"
# }
```

## 7. Useful Commands

```bash
# View logs
docker-compose logs -f                    # All services
docker-compose logs -f donor-service      # Specific service

# Restart service
docker-compose restart donor-service

# Stop all services
docker-compose stop

# Remove all containers and data
docker-compose down -v

# Rebuild images
docker-compose build --no-cache

# Connect to database
docker exec -it lifeflow-postgres psql -U lifeflow

# Connect to Redis
docker exec -it lifeflow-redis redis-cli

# View RabbitMQ messages
# Open http://localhost:15672 → Queues tab
```

## Next Steps

1. **Read Documentation**:
   - `docs/02_ARCHITECTURE.md` - Understand system design
   - `docs/03_FUNCTIONAL_REQUIREMENTS.md` - Learn features

2. **Explore Code**:
   - Check `services/donor-management-service/` for example service
   - Read Spring Boot `@RestController` classes

3. **Test APIs**:
   - Use Postman collection: `postman/LifeFlow.postman_collection.json`
   - Or use curl commands in `TESTING_GUIDE.md`

4. **Contribute**:
   - Create a feature branch
   - Make changes
   - Submit pull request

## Troubleshooting

**Port already in use**:
```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>
```

**Out of memory**:
```bash
# Increase Docker memory limit
# Docker Desktop → Preferences → Resources → Memory: 12GB
```

**Containers won't start**:
```bash
# Check logs
docker-compose logs

# Try rebuilding
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

**Database connection issues**:
```bash
# Verify PostgreSQL is running
docker exec -it lifeflow-postgres pg_isready

# Check connection string in service logs
docker-compose logs postgres
```

## Need Help?

- Check `docs/10_DEVELOPMENT_SETUP.md` for detailed setup guide
- Review `README.md` in each service directory
- Check GitHub Issues for similar problems
- Read Docker Compose documentation: https://docs.docker.com/compose/

---

**Happy coding! 🚀**

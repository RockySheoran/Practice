#!/bin/bash

# LifeFlow Blood Donation System - Development Environment Startup Script
# This script starts the development environment with infrastructure services

set -e

echo "🚀 Starting LifeFlow Development Environment..."
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    cp .env.example .env
    print_status "Please edit .env file with your configuration before continuing."
    read -p "Press Enter to continue after editing .env file..."
fi

# Create network if it doesn't exist
print_status "Creating Docker network..."
docker network create lifeflow-network 2>/dev/null || print_warning "Network already exists"

# Start infrastructure services
print_status "Starting infrastructure services..."

# Start databases
print_status "Starting databases..."
docker-compose up -d identity-db donor-db hospital-db inventory-db request-db

# Wait for databases to be ready
print_status "Waiting for databases to be ready..."
sleep 30

# Check database health
print_status "Checking database health..."
for db in identity-db donor-db hospital-db inventory-db request-db; do
    if docker-compose ps $db | grep -q "Up"; then
        print_success "$db is running"
    else
        print_error "$db failed to start"
        exit 1
    fi
done

# Start Redis
print_status "Starting Redis..."
docker-compose up -d redis

# Start Kafka ecosystem
print_status "Starting Kafka ecosystem..."
docker-compose up -d zookeeper
sleep 10
docker-compose up -d kafka
sleep 20

# Start service discovery
print_status "Starting Eureka service discovery..."
docker-compose up -d eureka-server
sleep 15

# Start monitoring services
print_status "Starting monitoring services..."
docker-compose up -d zipkin prometheus grafana

# Wait for all services to be ready
print_status "Waiting for all infrastructure services to be ready..."
sleep 30

# Check service health
print_status "Checking service health..."
services_to_check=(
    "identity-db:5432"
    "donor-db:5433"
    "hospital-db:5434"
    "inventory-db:5435"
    "request-db:5436"
    "redis:6379"
    "kafka:9092"
    "eureka-server:8761"
    "zipkin:9411"
    "prometheus:9090"
    "grafana:3000"
)

for service in "${services_to_check[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if nc -z localhost $port 2>/dev/null; then
        print_success "$name is ready on port $port"
    else
        print_warning "$name is not ready on port $port"
    fi
done

# Display service URLs
echo ""
echo "🌐 Service URLs:"
echo "================"
echo "📊 Eureka Dashboard:     http://localhost:8761"
echo "📈 Grafana Dashboard:    http://localhost:3000 (admin/admin)"
echo "📊 Prometheus:           http://localhost:9090"
echo "🔍 Zipkin Tracing:       http://localhost:9411"
echo ""

# Display development instructions
echo "💻 Development Instructions:"
echo "============================"
echo "1. Infrastructure services are now running"
echo "2. You can now start individual microservices for development:"
echo ""
echo "   # Start Identity Service"
echo "   cd services/identity-service"
echo "   mvn spring-boot:run"
echo ""
echo "   # Start Donor Service (in another terminal)"
echo "   cd services/donor-service"
echo "   mvn spring-boot:run"
echo ""
echo "   # Continue with other services as needed..."
echo ""
echo "3. Or start all services with Docker:"
echo "   docker-compose up -d"
echo ""

# Display useful commands
echo "🛠️  Useful Commands:"
echo "==================="
echo "• View logs:           docker-compose logs -f [service-name]"
echo "• Stop all services:   docker-compose down"
echo "• Restart service:     docker-compose restart [service-name]"
echo "• Check status:        docker-compose ps"
echo "• Clean up:            docker-compose down -v --remove-orphans"
echo ""

print_success "Development environment started successfully! 🎉"
print_status "Happy coding! 💻"
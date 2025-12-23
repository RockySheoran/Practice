#!/bin/bash

# LifeFlow Blood Donation System - Build Script
# This script builds all microservices

set -e

echo "🏗️  Building LifeFlow Blood Donation System..."
echo "================================================"

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

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    print_error "Maven is not installed. Please install Maven first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Build parent POM first
print_status "Building parent POM..."
mvn clean install -N
if [ $? -eq 0 ]; then
    print_success "Parent POM built successfully"
else
    print_error "Failed to build parent POM"
    exit 1
fi

# Build shared libraries
print_status "Building shared libraries..."
cd shared
mvn clean install
if [ $? -eq 0 ]; then
    print_success "Shared libraries built successfully"
else
    print_error "Failed to build shared libraries"
    exit 1
fi
cd ..

# List of services to build
services=(
    "api-gateway"
    "identity-service"
    "donor-service"
    "hospital-service"
    "inventory-service"
    "request-service"
    "geolocation-service"
    "notification-service"
    "camp-service"
    "analytics-service"
    "gamification-service"
)

# Build each service
for service in "${services[@]}"; do
    print_status "Building $service..."
    
    if [ -d "services/$service" ]; then
        cd "services/$service"
        
        # Clean and compile
        mvn clean compile
        if [ $? -ne 0 ]; then
            print_error "Failed to compile $service"
            exit 1
        fi
        
        # Run tests
        print_status "Running tests for $service..."
        mvn test
        if [ $? -ne 0 ]; then
            print_warning "Tests failed for $service, but continuing build..."
        fi
        
        # Package
        mvn package -DskipTests
        if [ $? -ne 0 ]; then
            print_error "Failed to package $service"
            exit 1
        fi
        
        # Build Docker image
        print_status "Building Docker image for $service..."
        docker build -t lifeflow/$service:latest .
        if [ $? -eq 0 ]; then
            print_success "$service Docker image built successfully"
        else
            print_error "Failed to build Docker image for $service"
            exit 1
        fi
        
        cd ../..
    else
        print_warning "Service directory not found: services/$service"
    fi
done

# Build summary
echo ""
echo "🎉 Build Summary"
echo "================"
print_success "All services built successfully!"
echo ""
echo "📦 Built Docker Images:"
docker images | grep lifeflow

echo ""
echo "🚀 Next Steps:"
echo "1. Start infrastructure: docker-compose up -d identity-db donor-db redis kafka zookeeper eureka-server"
echo "2. Start all services: docker-compose up -d"
echo "3. Check health: curl http://localhost:8080/actuator/health"
echo ""
print_success "Build completed successfully! 🎉"
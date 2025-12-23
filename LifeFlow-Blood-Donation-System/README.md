# LifeFlow - Blood Donation Management System

## Overview

LifeFlow is a next-generation blood donation management system designed as a high-availability, mission-critical logistics platform. The system addresses emergency blood requests by connecting hospitals with nearby compatible donors through an intelligent microservices architecture.

## Key Features

- **Emergency Blood Request System**: Real-time matching of blood requests with compatible donors
- **Donor Management**: Complete donor profiles with eligibility tracking and gamification
- **Inventory Management**: Real-time blood bag tracking with expiry management
- **Geolocation Services**: Distance calculation and route optimization
- **Notification System**: Multi-channel communication (SMS, Email, Push notifications)
- **Predictive Analytics**: AI-powered shortage prediction and demand forecasting
- **Donation Drives**: Complete event management for blood collection campaigns
- **Real-time Tracking**: Live transportation monitoring with cold chain integrity

## System Architecture

### Microservices Architecture

The system is built using microservices architecture with the following core services:

1. **API Gateway Service** - Central entry point and request routing
2. **Identity & Profile Service** - User authentication and authorization
3. **Donor Management Service** - Donor profiles and eligibility management
4. **Hospital Management Service** - Hospital profiles and staff management
5. **Inventory & Blood Bank Service** - Blood bag tracking and stock management
6. **Request & Emergency Service** - Blood request processing and matching
7. **Geolocation & Logistics Service** - Distance calculation and route optimization
8. **Notification Service** - Multi-channel communication system
9. **Camp & Event Service** - Donation drive management
10. **Analytics & Reporting Service** - Data analytics and predictive modeling
11. **Gamification Service** - Donor rewards and engagement system

### Technology Stack

- **Backend**: Java 17+ with Spring Boot 3.x
- **Database**: PostgreSQL 15+
- **Message Queue**: Apache Kafka
- **Caching**: Redis
- **API Gateway**: Spring Cloud Gateway
- **Service Discovery**: Eureka Server
- **Configuration**: Spring Cloud Config
- **Monitoring**: Micrometer + Prometheus
- **Documentation**: OpenAPI 3.0 (Swagger)
- **Security**: Spring Security with OAuth2/JWT
- **Testing**: JUnit 5, Testcontainers, MockMvc

## Project Structure

```
LifeFlow-Blood-Donation-System/
├── api-gateway/
├── config-server/
├── eureka-server/
├── services/
│   ├── identity-service/
│   ├── donor-service/
│   ├── hospital-service/
│   ├── inventory-service/
│   ├── request-service/
│   ├── geolocation-service/
│   ├── notification-service/
│   ├── camp-service/
│   ├── analytics-service/
│   └── gamification-service/
├── shared/
│   ├── common-models/
│   ├── common-utils/
│   └── security-config/
├── database/
│   ├── migrations/
│   └── schemas/
├── docker/
├── docs/
└── scripts/
```

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.8+
- PostgreSQL 15+
- Redis 6+
- Apache Kafka 3.0+
- Docker & Docker Compose

### Quick Start

1. Clone the repository
2. Run `docker-compose up -d` to start infrastructure services
3. Run `mvn clean install` in the root directory
4. Start services in the following order:
   - Config Server
   - Eureka Server
   - Core Services
   - API Gateway

## Database Design

The system uses a microservices database pattern where each service has its own database schema. See the `database/schemas/` directory for detailed ER diagrams and table structures.

## API Documentation

Each service provides OpenAPI 3.0 documentation available at:
- `http://localhost:{port}/swagger-ui.html`
- `http://localhost:{port}/v3/api-docs`

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
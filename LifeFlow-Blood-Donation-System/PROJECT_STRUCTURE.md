# LifeFlow Blood Donation Management System - Project Structure

## Overview
LifeFlow is a comprehensive microservices-based blood donation management system built with Java Spring Boot, PostgreSQL, and modern cloud-native technologies.

## Root Directory Structure

```
LifeFlow-Blood-Donation-System/
├── README.md
├── docker-compose.yml
├── .env.example
├── pom.xml                          # Parent POM
├── .gitignore
│
├── services/                        # Microservices
│   ├── api-gateway/                 # Spring Cloud Gateway
│   ├── identity-service/            # User Authentication & Authorization
│   ├── donor-service/               # Donor Management
│   ├── hospital-service/            # Hospital Management
│   ├── inventory-service/           # Blood Inventory Management
│   ├── request-service/             # Blood Request Processing
│   ├── geolocation-service/         # Location & Route Management
│   ├── notification-service/        # Multi-channel Notifications
│   ├── camp-service/                # Donation Camp Management
│   ├── analytics-service/           # Analytics & Reporting
│   └── gamification-service/        # Rewards & Gamification
│
├── shared/                          # Shared Libraries
│   ├── common-models/               # Common DTOs and Entities
│   ├── security-config/             # Shared Security Configuration
│   ├── event-models/                # Event-driven Architecture Models
│   └── utils/                       # Common Utilities
│
├── infrastructure/                  # Infrastructure as Code
│   ├── kubernetes/                  # K8s Deployment Files
│   ├── terraform/                   # Infrastructure Provisioning
│   └── monitoring/                  # Monitoring & Observability
│       ├── prometheus/
│       ├── grafana/
│       └── elk/
│
├── database/                        # Database Scripts
│   ├── migrations/                  # Flyway Migration Scripts
│   ├── schemas/                     # Database Schema Definitions
│   └── seed-data/                   # Initial Data Scripts
│
├── docs/                           # Documentation
│   ├── api/                        # API Documentation
│   ├── architecture/               # Architecture Documentation
│   ├── database/                   # Database Documentation
│   └── deployment/                 # Deployment Guides
│
└── scripts/                        # Utility Scripts
    ├── build.sh                    # Build All Services
    ├── start-dev.sh                # Start Development Environment
    ├── run-tests.sh                # Run All Tests
    └── deploy.sh                   # Deployment Script
```

## Service-Specific Structure Details

### Each Microservice follows this standard structure:

```
service-name/
├── src/main/java/com/lifeflow/servicename/
│   ├── controller/                  # REST Controllers
│   │   ├── ServiceController.java
│   │   └── HealthController.java
│   ├── service/                     # Business Logic
│   │   ├── ServiceService.java
│   │   └── impl/
│   │       └── ServiceServiceImpl.java
│   ├── repository/                  # Data Access Layer
│   │   ├── ServiceRepository.java
│   │   └── custom/
│   ├── entity/                      # JPA Entities
│   │   ├── ServiceEntity.java
│   │   └── BaseEntity.java
│   ├── dto/                         # Data Transfer Objects
│   │   ├── request/
│   │   └── response/
│   ├── config/                      # Configuration Classes
│   │   ├── DatabaseConfig.java
│   │   ├── KafkaConfig.java
│   │   └── SecurityConfig.java
│   ├── exception/                   # Custom Exceptions
│   │   ├── ServiceException.java
│   │   └── GlobalExceptionHandler.java
│   ├── mapper/                      # Entity-DTO Mappers
│   │   └── ServiceMapper.java
│   ├── event/                       # Event Classes
│   │   ├── producer/
│   │   └── consumer/
│   └── ServiceApplication.java      # Main Application Class
├── src/main/resources/
│   ├── application.yml              # Service Configuration
│   ├── application-dev.yml          # Development Profile
│   ├── application-prod.yml         # Production Profile
│   └── db/migration/                # Flyway Migration Scripts
├── src/test/java/                   # Test Classes
│   ├── integration/                 # Integration Tests
│   ├── unit/                        # Unit Tests
│   └── testcontainers/              # Container Tests
├── Dockerfile
├── pom.xml
└── README.md
```

## Technology Stack

### Backend Technologies
- **Java 17** - Programming Language
- **Spring Boot 3.2** - Application Framework
- **Spring Cloud 2023** - Microservices Framework
- **Spring Security 6** - Security Framework
- **Spring Data JPA** - Data Access Layer
- **PostgreSQL 15** - Primary Database
- **Redis 7** - Caching & Session Storage
- **Apache Kafka** - Event Streaming Platform
- **Flyway** - Database Migration Tool

### Infrastructure & DevOps
- **Docker & Docker Compose** - Containerization
- **Kubernetes** - Container Orchestration
- **Spring Cloud Gateway** - API Gateway
- **Eureka** - Service Discovery
- **Zipkin** - Distributed Tracing
- **Prometheus & Grafana** - Monitoring
- **ELK Stack** - Logging & Analytics

### Testing Framework
- **JUnit 5** - Unit Testing
- **Testcontainers** - Integration Testing
- **MockMvc** - Web Layer Testing
- **WireMock** - API Mocking

## Service Descriptions

### 1. API Gateway Service
- **Port**: 8080
- **Purpose**: Single entry point for all client requests
- **Features**: 
  - Request routing and load balancing
  - Authentication and authorization
  - Rate limiting and throttling
  - Request/response transformation

### 2. Identity Service
- **Port**: 8081
- **Database**: `lifeflow_identity`
- **Purpose**: User authentication and authorization
- **Features**:
  - JWT token management
  - Role-based access control
  - OAuth2 integration
  - User profile management

### 3. Donor Service
- **Port**: 8082
- **Database**: `lifeflow_donor`
- **Purpose**: Donor management and eligibility tracking
- **Features**:
  - Donor registration and profile management
  - Eligibility checking and tracking
  - Donation history management
  - Health screening integration

### 4. Hospital Service
- **Port**: 8083
- **Database**: `lifeflow_hospital`
- **Purpose**: Hospital and medical facility management
- **Features**:
  - Hospital registration and verification
  - Staff management
  - Inventory tracking
  - Request management

### 5. Inventory Service
- **Port**: 8084
- **Database**: `lifeflow_inventory`
- **Purpose**: Blood inventory and stock management
- **Features**:
  - Blood bag tracking with RFID/Barcode
  - Expiry date management
  - Stock level monitoring
  - Automated alerts

### 6. Request Service
- **Port**: 8085
- **Database**: `lifeflow_request`
- **Purpose**: Blood request processing and matching
- **Features**:
  - Emergency request handling
  - Blood type matching algorithms
  - Priority queue management
  - Request fulfillment tracking

### 7. Geolocation Service
- **Port**: 8086
- **Database**: `lifeflow_geolocation`
- **Purpose**: Location services and route optimization
- **Features**:
  - GPS tracking and location services
  - Distance calculation
  - Route optimization
  - Delivery tracking

### 8. Notification Service
- **Port**: 8087
- **Database**: `lifeflow_notification`
- **Purpose**: Multi-channel notification system
- **Features**:
  - SMS, Email, Push notifications
  - WhatsApp integration
  - Notification preferences
  - Delivery confirmation

### 9. Camp Service
- **Port**: 8088
- **Database**: `lifeflow_camp`
- **Purpose**: Donation camp and event management
- **Features**:
  - Camp scheduling and management
  - Volunteer coordination
  - Registration management
  - Resource allocation

### 10. Analytics Service
- **Port**: 8089
- **Database**: `lifeflow_analytics`
- **Purpose**: Data analytics and reporting
- **Features**:
  - Real-time dashboards
  - Predictive analytics
  - Custom reports
  - Performance metrics

### 11. Gamification Service
- **Port**: 8090
- **Database**: `lifeflow_gamification`
- **Purpose**: Donor engagement and rewards
- **Features**:
  - Points and badge system
  - Leaderboards
  - Reward redemption
  - Achievement tracking

## Database Architecture

### Database Per Service Pattern
Each microservice has its own dedicated PostgreSQL database to ensure:
- **Data Isolation**: Services cannot directly access other services' data
- **Independent Scaling**: Each database can be scaled independently
- **Technology Diversity**: Different services can use different database technologies if needed
- **Fault Isolation**: Database issues in one service don't affect others

### Shared Data Handling
- **Event-Driven Architecture**: Services communicate through Kafka events
- **CQRS Pattern**: Separate read and write models where appropriate
- **Eventual Consistency**: Accept eventual consistency for better performance
- **Saga Pattern**: Manage distributed transactions across services

## Communication Patterns

### Synchronous Communication
- **REST APIs**: For direct service-to-service communication
- **OpenFeign**: For type-safe HTTP client communication
- **Circuit Breaker**: For fault tolerance (Resilience4j)

### Asynchronous Communication
- **Apache Kafka**: For event-driven communication
- **Event Sourcing**: For audit trails and state reconstruction
- **CQRS**: For separating command and query responsibilities

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Stateless authentication
- **OAuth2/OpenID Connect**: Third-party authentication
- **Role-Based Access Control (RBAC)**: Fine-grained permissions
- **API Key Management**: For external integrations

### Data Security
- **Encryption at Rest**: Database encryption
- **Encryption in Transit**: TLS/SSL for all communications
- **Data Masking**: Sensitive data protection
- **Audit Logging**: Complete audit trail

## Monitoring & Observability

### Application Monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and alerting
- **Micrometer**: Application metrics
- **Custom Dashboards**: Business-specific metrics

### Logging
- **ELK Stack**: Centralized logging
- **Structured Logging**: JSON format logs
- **Log Correlation**: Request tracing across services
- **Log Retention**: Configurable retention policies

### Distributed Tracing
- **Zipkin**: Request tracing
- **Spring Cloud Sleuth**: Automatic trace generation
- **Correlation IDs**: Request correlation across services

## Development Workflow

### Local Development
1. **Prerequisites**: Java 17, Docker, Maven
2. **Database Setup**: Docker Compose for local databases
3. **Service Startup**: Individual service development
4. **Integration Testing**: Testcontainers for integration tests

### CI/CD Pipeline
1. **Source Control**: Git with feature branch workflow
2. **Build**: Maven for compilation and packaging
3. **Testing**: Automated unit and integration tests
4. **Quality Gates**: SonarQube for code quality
5. **Deployment**: Docker containers to Kubernetes

## Configuration Management

### Environment-Specific Configuration
- **Spring Profiles**: Environment-specific configurations
- **ConfigMaps**: Kubernetes configuration management
- **Secrets**: Sensitive data management
- **External Configuration**: Spring Cloud Config Server

### Feature Flags
- **Toggle Features**: Enable/disable features without deployment
- **A/B Testing**: Gradual feature rollout
- **Circuit Breakers**: Automatic failure handling

This structure provides a solid foundation for building a production-ready, scalable blood donation management system with proper separation of concerns, fault tolerance, and observability.
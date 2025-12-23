# LifeFlow - Project Structure Documentation

## Complete Project Structure

```
LifeFlow-Blood-Donation-System/
├── README.md
├── PROJECT_STRUCTURE.md
├── MICROSERVICES_ARCHITECTURE.md
├── DATABASE_DESIGN.md
├── API_SPECIFICATIONS.md
├── DEPLOYMENT_GUIDE.md
├── pom.xml                          # Root Maven POM
├── docker-compose.yml               # Infrastructure services
├── .env.example                     # Environment variables template
├── .gitignore
│
├── api-gateway/                     # API Gateway Service
│   ├── src/main/java/com/lifeflow/gateway/
│   ├── src/main/resources/
│   ├── src/test/java/
│   └── pom.xml
│
├── config-server/                   # Spring Cloud Config Server
│   ├── src/main/java/com/lifeflow/config/
│   ├── src/main/resources/
│   └── pom.xml
│
├── eureka-server/                   # Service Discovery
│   ├── src/main/java/com/lifeflow/eureka/
│   ├── src/main/resources/
│   └── pom.xml
│
├── services/                        # Microservices
│   │
│   ├── identity-service/            # Authentication & Authorization
│   │   ├── src/main/java/com/lifeflow/identity/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── repository/
│   │   │   ├── entity/
│   │   │   ├── dto/
│   │   │   ├── config/
│   │   │   └── IdentityServiceApplication.java
│   │   ├── src/main/resources/
│   │   │   ├── application.yml
│   │   │   └── db/migration/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── donor-service/               # Donor Management
│   │   ├── src/main/java/com/lifeflow/donor/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── repository/
│   │   │   ├── entity/
│   │   │   ├── dto/
│   │   │   ├── config/
│   │   │   └── DonorServiceApplication.java
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── hospital-service/            # Hospital Management
│   │   ├── src/main/java/com/lifeflow/hospital/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── inventory-service/           # Blood Inventory Management
│   │   ├── src/main/java/com/lifeflow/inventory/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── request-service/             # Blood Request Processing
│   │   ├── src/main/java/com/lifeflow/request/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── geolocation-service/         # Location & Logistics
│   │   ├── src/main/java/com/lifeflow/geolocation/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── notification-service/        # Multi-channel Notifications
│   │   ├── src/main/java/com/lifeflow/notification/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── camp-service/                # Donation Drives Management
│   │   ├── src/main/java/com/lifeflow/camp/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   ├── analytics-service/           # Data Analytics & Reporting
│   │   ├── src/main/java/com/lifeflow/analytics/
│   │   ├── src/main/resources/
│   │   ├── src/test/java/
│   │   └── pom.xml
│   │
│   └── gamification-service/        # Donor Rewards & Engagement
│       ├── src/main/java/com/lifeflow/gamification/
│       ├── src/main/resources/
│       ├── src/test/java/
│       └── pom.xml
│
├── shared/                          # Shared Libraries
│   │
│   ├── common-models/               # Common DTOs and Entities
│   │   ├── src/main/java/com/lifeflow/common/model/
│   │   │   ├── dto/
│   │   │   ├── entity/
│   │   │   ├── enums/
│   │   │   └── constants/
│   │   └── pom.xml
│   │
│   ├── common-utils/                # Utility Classes
│   │   ├── src/main/java/com/lifeflow/common/util/
│   │   │   ├── DateUtils.java
│   │   │   ├── ValidationUtils.java
│   │   │   ├── EncryptionUtils.java
│   │   │   └── ResponseUtils.java
│   │   └── pom.xml
│   │
│   └── security-config/             # Security Configuration
│       ├── src/main/java/com/lifeflow/security/
│       │   ├── JwtTokenProvider.java
│       │   ├── SecurityConfig.java
│       │   └── AuthenticationFilter.java
│       └── pom.xml
│
├── database/                        # Database Scripts & Schemas
│   │
│   ├── migrations/                  # Flyway Migration Scripts
│   │   ├── identity/
│   │   │   ├── V1__Create_users_table.sql
│   │   │   ├── V2__Create_roles_table.sql
│   │   │   └── V3__Create_user_roles_table.sql
│   │   ├── donor/
│   │   │   ├── V1__Create_donors_table.sql
│   │   │   ├── V2__Create_donation_history_table.sql
│   │   │   └── V3__Create_eligibility_table.sql
│   │   ├── hospital/
│   │   ├── inventory/
│   │   ├── request/
│   │   ├── geolocation/
│   │   ├── notification/
│   │   ├── camp/
│   │   ├── analytics/
│   │   └── gamification/
│   │
│   └── schemas/                     # ER Diagrams & Documentation
│       ├── complete-er-diagram.md
│       ├── identity-schema.md
│       ├── donor-schema.md
│       ├── hospital-schema.md
│       ├── inventory-schema.md
│       ├── request-schema.md
│       ├── geolocation-schema.md
│       ├── notification-schema.md
│       ├── camp-schema.md
│       ├── analytics-schema.md
│       └── gamification-schema.md
│
├── docker/                          # Docker Configuration
│   ├── Dockerfile.base              # Base Java image
│   ├── docker-compose.dev.yml       # Development environment
│   ├── docker-compose.prod.yml      # Production environment
│   └── nginx/
│       └── nginx.conf
│
├── docs/                            # Documentation
│   ├── api/                         # API Documentation
│   │   ├── identity-api.md
│   │   ├── donor-api.md
│   │   ├── hospital-api.md
│   │   ├── inventory-api.md
│   │   ├── request-api.md
│   │   ├── geolocation-api.md
│   │   ├── notification-api.md
│   │   ├── camp-api.md
│   │   ├── analytics-api.md
│   │   └── gamification-api.md
│   │
│   ├── architecture/                # Architecture Documentation
│   │   ├── system-overview.md
│   │   ├── microservices-design.md
│   │   ├── event-driven-architecture.md
│   │   ├── security-architecture.md
│   │   └── deployment-architecture.md
│   │
│   └── user-guides/                 # User Documentation
│       ├── donor-guide.md
│       ├── hospital-guide.md
│       ├── admin-guide.md
│       └── api-integration-guide.md
│
├── scripts/                         # Utility Scripts
│   ├── build.sh                     # Build all services
│   ├── start-dev.sh                 # Start development environment
│   ├── stop-dev.sh                  # Stop development environment
│   ├── run-tests.sh                 # Run all tests
│   ├── deploy.sh                    # Deployment script
│   └── database/
│       ├── init-db.sh               # Initialize databases
│       ├── backup-db.sh             # Backup databases
│       └── restore-db.sh            # Restore databases
│
└── monitoring/                      # Monitoring & Observability
    ├── prometheus/
    │   └── prometheus.yml
    ├── grafana/
    │   └── dashboards/
    └── elk/
        ├── elasticsearch.yml
        ├── logstash.conf
        └── kibana.yml
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
│   └── db/migration/                # Flyway Migrations
├── src/test/java/                   # Test Classes
│   ├── integration/                 # Integration Tests
│   ├── unit/                        # Unit Tests
│   └── TestApplication.java
└── pom.xml                          # Maven Configuration
```

## Key Design Principles

1. **Microservices Architecture**: Each service is independently deployable and scalable
2. **Database per Service**: Each microservice has its own database schema
3. **Event-Driven Communication**: Services communicate via Kafka events
4. **API-First Design**: All services expose well-documented REST APIs
5. **Security by Design**: OAuth2/JWT authentication across all services
6. **Observability**: Comprehensive logging, metrics, and tracing
7. **Fault Tolerance**: Circuit breakers and retry mechanisms
8. **Configuration Management**: Externalized configuration via Config Server
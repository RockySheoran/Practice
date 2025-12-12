# LifeFlow Project Structure

## Directory Layout

```
LifeFlow/
│
├── docs/                                    # Documentation
│   ├── 01_README.md                        # Project overview
│   ├── 02_ARCHITECTURE.md                  # Microservices architecture
│   ├── 03_FUNCTIONAL_REQUIREMENTS.md       # Feature specifications
│   ├── 04_ER_DIAGRAMS.md                  # Database schemas
│   ├── 05_API_GATEWAY_DESIGN.md           # Gateway architecture
│   ├── 06_EVENT_DRIVEN_ARCHITECTURE.md    # Event system design
│   ├── 07_DATA_FLOW_SCENARIOS.md          # Workflow examples
│   ├── 08_COMPLIANCE_SECURITY.md          # Security & compliance
│   ├── 09_DEPLOYMENT_INFRASTRUCTURE.md    # Deployment guide
│   └── 10_DEVELOPMENT_SETUP.md            # Dev environment setup
│
├── services/                                # Microservices
│   ├── identity-auth-service/             # Authentication & Authorization
│   │   ├── src/
│   │   │   ├── main/
│   │   │   │   ├── java/com/lifeflow/
│   │   │   │   │   ├── controller/        # REST endpoints
│   │   │   │   │   ├── service/           # Business logic
│   │   │   │   │   ├── repository/        # Database access
│   │   │   │   │   ├── entity/            # JPA entities
│   │   │   │   │   ├── dto/               # Data transfer objects
│   │   │   │   │   ├── security/          # Security filters
│   │   │   │   │   ├── util/              # Utility classes
│   │   │   │   │   └── config/            # Configuration
│   │   │   │   └── resources/
│   │   │   │       ├── application.yml    # App configuration
│   │   │   │       └── application-prod.yml
│   │   │   └── test/java/com/lifeflow/   # Unit & integration tests
│   │   ├── Dockerfile                     # Container definition
│   │   ├── pom.xml                        # Maven dependencies
│   │   └── README.md                      # Service documentation
│   │
│   ├── donor-management-service/           # Donor operations
│   │   └── (same structure as above)
│   │
│   ├── inventory-blood-bank-service/       # Blood inventory
│   │   └── (same structure as above)
│   │
│   ├── request-emergency-service/          # Blood requests
│   │   └── (same structure as above)
│   │
│   ├── geolocation-logistics-service/      # Tracking & logistics
│   │   └── (same structure as above)
│   │
│   ├── notification-service/               # Notifications
│   │   └── (same structure as above)
│   │
│   ├── camp-event-service/                 # Donation camps
│   │   └── (same structure as above)
│   │
│   └── analytics-gamification-service/     # Analytics & rewards
│       └── (same structure as above)
│
├── api-gateway/                            # API Gateway (Spring Cloud)
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/lifeflow/gateway/
│   │   │   │   ├── filter/               # Custom filters
│   │   │   │   ├── config/               # Route & security config
│   │   │   │   ├── exception/            # Exception handlers
│   │   │   │   └── util/                 # Utility classes
│   │   │   └── resources/
│   │   │       └── application.yml
│   │   └── test/
│   └── Dockerfile
│
├── database-schemas/                       # Database definitions
│   ├── ER_DIAGRAMS.md                    # Entity relationships
│   ├── scripts/
│   │   ├── init-databases.sql            # Initial schema
│   │   ├── migrations/                   # Migration scripts
│   │   │   ├── V1.0__initial_schema.sql
│   │   │   ├── V1.1__add_audit_tables.sql
│   │   │   └── ...
│   │   └── seed-data.sql                 # Test data
│   └── README.md
│
├── postman/                                # API testing
│   ├── LifeFlow.postman_collection.json  # API endpoints
│   ├── Dev.postman_environment.json      # Dev variables
│   ├── Staging.postman_environment.json
│   └── Production.postman_environment.json
│
├── kubernetes/                             # K8s manifests
│   ├── namespaces.yaml                   # Namespaces
│   ├── configmaps.yaml                   # Configuration
│   ├── secrets.yaml                      # Secrets (encrypted)
│   ├── services/
│   │   ├── identity-service-deployment.yaml
│   │   ├── donor-service-deployment.yaml
│   │   └── ...
│   ├── ingress.yaml                      # Ingress controller
│   ├── monitoring/
│   │   ├── prometheus.yaml
│   │   ├── grafana.yaml
│   │   └── alertmanager.yaml
│   └── README.md
│
├── scripts/                                # Automation scripts
│   ├── dev/
│   │   ├── setup.sh                      # Local setup
│   │   ├── teardown.sh                   # Cleanup
│   │   └── reset-db.sh                   # Reset databases
│   ├── ci-cd/
│   │   ├── build.sh                      # Build all services
│   │   ├── test.sh                       # Run all tests
│   │   └── deploy.sh                     # Deploy pipeline
│   └── monitoring/
│       ├── health-check.sh
│       └── backup.sh
│
├── config/                                 # Configuration files
│   ├── docker/
│   │   └── Dockerfile.base               # Base image
│   ├── nginx/
│   │   └── nginx.conf                    # Web server config
│   └── logging/
│       └── logback.xml                   # Logging config
│
├── docs-assets/                            # Documentation media
│   ├── diagrams/
│   │   ├── architecture.png
│   │   ├── data-flow.png
│   │   └── er-diagram.png
│   ├── screenshots/
│   └── videos/
│
├── docker-compose.yml                      # Local environment
├── .dockerignore                           # Docker build ignore
├── .gitignore                              # Git ignore
├── .env.example                            # Environment template
├── .github/                                # GitHub workflows
│   └── workflows/
│       ├── ci.yml                         # CI pipeline
│       ├── cd.yml                         # CD pipeline
│       └── security-scan.yml              # Security checks
├── QUICK_START.md                          # 5-minute start
├── PROJECT_STRUCTURE.md                    # This file
├── CONTRIBUTING.md                         # Contribution guide
├── LICENSE                                 # MIT License
└── README.md                               # Main readme

```

## Key Files Explained

### Configuration Files

**docker-compose.yml**:
- Defines all services for local development
- Includes database, cache, broker, gateway, and all microservices
- Uses `.env` for environment variables

**.env.example**:
- Template for environment variables
- Copy to `.env` and customize for your environment
- Never commit actual `.env` file (add to .gitignore)

### Documentation Files

**docs/01_README.md**:
- Project overview
- Key features
- Getting started guide

**docs/02_ARCHITECTURE.md**:
- Microservices design
- Component responsibilities
- Communication patterns

**docs/04_ER_DIAGRAMS.md**:
- Database schemas for each service
- Relationships and constraints
- Sample queries

### Service Structure (Each Microservice)

```
service-name/
├── src/
│   ├── main/java/com/lifeflow/
│   │   ├── controller/         # REST endpoints (@RestController)
│   │   ├── service/            # Business logic (@Service)
│   │   ├── repository/         # Data access (@Repository)
│   │   ├── entity/             # JPA entities (@Entity)
│   │   ├── dto/                # Request/Response DTOs
│   │   ├── exception/          # Custom exceptions
│   │   ├── config/             # Spring configuration
│   │   ├── util/               # Helper utilities
│   │   └── event/              # Event publishing
│   ├── main/resources/
│   │   ├── application.yml     # Default config
│   │   └── db/migration/       # Flyway migrations
│   └── test/java/              # Unit & integration tests
├── pom.xml                      # Maven dependencies
├── Dockerfile                   # Container image
└── README.md                    # Service documentation
```

### Standard Java Package Structure

```
com.lifeflow.{service-name}
├── controller              # REST API endpoints
│   ├── DonorController.java
│   ├── HealthController.java
│   └── ...
├── service                 # Business logic layer
│   ├── DonorService.java
│   ├── EligibilityService.java
│   └── ...
├── repository              # Data access layer (JPA)
│   ├── DonorRepository.java
│   ├── MedicalHistoryRepository.java
│   └── ...
├── entity                  # JPA entities
│   ├── Donor.java
│   ├── MedicalHistory.java
│   └── ...
├── dto                     # Data transfer objects
│   ├── DonorRequestDTO.java
│   ├── DonorResponseDTO.java
│   └── ...
├── config                  # Configuration classes
│   ├── SecurityConfig.java
│   ├── RabbitMQConfig.java
│   └── ...
├── event                   # Event handling
│   ├── DonorEventPublisher.java
│   ├── DonorEventListener.java
│   └── ...
├── exception               # Custom exceptions
│   ├── DonorNotFoundException.java
│   ├── InvalidEligibilityException.java
│   └── ...
└── util                    # Utility classes
    ├── DateUtils.java
    ├── ValidationUtils.java
    └── ...
```

## Dependencies Between Services

```
API Gateway
    ↓
┌───┬───┬───┬───┬────┬───┬───┬──────┐
↓   ↓   ↓   ↓   ↓    ↓   ↓   ↓      ↓
IS  DS  INV RS  GLS  NS  CS  AS  (Legend)
                ↓
            Message Broker    IS = Identity Service
            (RabbitMQ)        DS = Donor Service
                ↓             INV= Inventory Service
        Database (PostgreSQL) RS = Request Service
        Redis (Cache)         GLS= Geolocation Service
                              NS = Notification Service
                              CS = Camp Service
                              AS = Analytics Service
```

## Build & Deployment Artifacts

```
Artifacts produced per service:
├── JAR file               # target/service-name-version.jar
├── Docker image           # lifeflow/service-name:version
└── Kubernetes manifest    # kubernetes/service-name-deployment.yaml

Production deployment:
├── Docker images pushed to ECR
├── Kubernetes manifests applied
├── Services auto-scale based on load
└── Zero-downtime rolling updates
```

---

**Last Updated**: 2024  
**Maintained by**: LifeFlow Development Team

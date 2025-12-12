# LifeFlow Project Structure (Java/Spring Boot)

```
lifeflow/
├── docs/
│   ├── LIFEFLOW_ARCHITECTURE.md
│   ├── EMERGENCY_WORKFLOW_SEQUENCE.md
│   ├── API_REFERENCE.md
│   ├── DEPLOYMENT_GUIDE.md
│   └── DISASTER_RECOVERY.md
│
├── database/
│   ├── schemas/
│   │   ├── 01_identity_service.sql
│   │   ├── 02_donor_service.sql
│   │   ├── 03_inventory_service.sql
│   │   ├── 04_request_service.sql
│   │   ├── 05_notification_service.sql
│   │   ├── 06_geolocation_service.sql
│   │   ├── 07_analytics_service.sql
│   │   └── init_all.sql
│   └── migrations/
│       ├── V1__initial_schema.sql
│       └── V2__add_indexes.sql
│
├── pom.xml                               # Parent POM
│
├── lifeflow-api-gateway/                 # Spring Cloud Gateway
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/gateway/
│   │       │   ├── config/
│   │       │   ├── filter/
│   │       │   └── LifeflowGatewayApp.java
│   │       └── resources/
│   │           ├── application.yml
│   │           └── application-prod.yml
│   └── Dockerfile
│
├── lifeflow-identity-service/            # Auth & User Management
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/identity/
│   │       │   ├── controller/
│   │       │   │   ├── AuthController.java
│   │       │   │   └── UserController.java
│   │       │   ├── service/
│   │       │   │   ├── AuthService.java
│   │       │   │   ├── UserService.java
│   │       │   │   └── JwtTokenProvider.java
│   │       │   ├── entity/
│   │       │   │   ├── User.java
│   │       │   │   └── Role.java
│   │       │   ├── repository/
│   │       │   │   ├── UserRepository.java
│   │       │   │   └── RoleRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── LoginRequest.java
│   │       │   │   ├── LoginResponse.java
│   │       │   │   └── RegisterRequest.java
│   │       │   ├── config/
│   │       │   │   ├── SecurityConfig.java
│   │       │   │   └── JwtConfig.java
│   │       │   └── IdentityServiceApp.java
│   │       └── resources/
│   │           ├── application.yml
│   │           └── data.sql
│   ├── Dockerfile
│   └── .dockerignore
│
├── lifeflow-donor-service/               # Donor Management
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/donor/
│   │       │   ├── controller/
│   │       │   │   ├── DonorController.java
│   │       │   │   └── EligibilityController.java
│   │       │   ├── service/
│   │       │   │   ├── DonorService.java
│   │       │   │   ├── EligibilityService.java
│   │       │   │   └── GamificationService.java
│   │       │   ├── entity/
│   │       │   │   ├── DonorProfile.java
│   │       │   │   ├── DonationHistory.java
│   │       │   │   ├── EligibilityCheck.java
│   │       │   │   └── DonorGamification.java
│   │       │   ├── repository/
│   │       │   │   ├── DonorRepository.java
│   │       │   │   ├── DonationHistoryRepository.java
│   │       │   │   └── GamificationRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── DonorProfileDTO.java
│   │       │   │   ├── EligibilityCheckDTO.java
│   │       │   │   └── GamificationDTO.java
│   │       │   ├── event/
│   │       │   │   └── DonationCompleteEvent.java
│   │       │   └── DonorServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-inventory-service/           # Blood Inventory
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/inventory/
│   │       │   ├── controller/
│   │       │   │   ├── InventoryController.java
│   │       │   │   └── StockController.java
│   │       │   ├── service/
│   │       │   │   ├── InventoryService.java
│   │       │   │   ├── StockService.java
│   │       │   │   └── ExpiryManagementService.java
│   │       │   ├── entity/
│   │       │   │   ├── BloodInventory.java
│   │       │   │   ├── StockSummary.java
│   │       │   │   └── ExpiryAlert.java
│   │       │   ├── repository/
│   │       │   │   ├── BloodInventoryRepository.java
│   │       │   │   └── StockSummaryRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── BloodBagDTO.java
│   │       │   │   └── StockLevelDTO.java
│   │       │   └── InventoryServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-request-service/             # Request & Emergency
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/request/
│   │       │   ├── controller/
│   │       │   │   ├── RequestController.java
│   │       │   │   └── ResponseController.java
│   │       │   ├── service/
│   │       │   │   ├── RequestService.java
│   │       │   │   ├── MatchingEngine.java
│   │       │   │   └── SagaOrchestrator.java
│   │       │   ├── entity/
│   │       │   │   ├── BloodRequest.java
│   │       │   │   ├── RequestResponse.java
│   │       │   │   └── DonorMatch.java
│   │       │   ├── repository/
│   │       │   │   ├── BloodRequestRepository.java
│   │       │   │   ├── RequestResponseRepository.java
│   │       │   │   └── DonorMatchRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── CreateRequestDTO.java
│   │       │   │   ├── AcceptResponseDTO.java
│   │       │   │   └── MatchedDonorDTO.java
│   │       │   ├── event/
│   │       │   │   ├── BloodNeededEvent.java
│   │       │   │   ├── DonorMatchedEvent.java
│   │       │   │   └── DonorAcceptedEvent.java
│   │       │   └── RequestServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-geolocation-service/         # Geolocation & Logistics
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/geolocation/
│   │       │   ├── controller/
│   │       │   │   ├── GeoController.java
│   │       │   │   └── TrackingController.java
│   │       │   ├── service/
│   │       │   │   ├── GeoService.java
│   │       │   │   ├── TrackingService.java
│   │       │   │   └── DistanceCalculator.java
│   │       │   ├── entity/
│   │       │   │   ├── DonorLocation.java
│   │       │   │   ├── HospitalLocation.java
│   │       │   │   ├── DeliveryRide.java
│   │       │   │   └── RideTrackingPoint.java
│   │       │   ├── repository/
│   │       │   │   ├── DonorLocationRepository.java
│   │       │   │   └── DeliveryRideRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── LocationDTO.java
│   │       │   │   └── NearbyDonorsDTO.java
│   │       │   └── GeolocationServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-notification-service/        # Notifications
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/notification/
│   │       │   ├── controller/
│   │       │   │   └── NotificationController.java
│   │       │   ├── service/
│   │       │   │   ├── NotificationService.java
│   │       │   │   ├── SmsProvider.java
│   │       │   │   ├── EmailProvider.java
│   │       │   │   ├── PushNotificationProvider.java
│   │       │   │   └── CircuitBreakerManager.java
│   │       │   ├── entity/
│   │       │   │   └── NotificationLog.java
│   │       │   ├── repository/
│   │       │   │   └── NotificationLogRepository.java
│   │       │   ├── event/
│   │       │   │   └── NotificationEventListener.java
│   │       │   ├── dto/
│   │       │   │   └── NotificationDTO.java
│   │       │   └── NotificationServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-analytics-service/           # Analytics & Dashboard
│   ├── pom.xml
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lifeflow/analytics/
│   │       │   ├── controller/
│   │       │   │   ├── DashboardController.java
│   │       │   │   ├── ForecastController.java
│   │       │   │   └── ReportController.java
│   │       │   ├── service/
│   │       │   │   ├── DashboardService.java
│   │       │   │   ├── ForecastService.java
│   │       │   │   ├── PredictionEngine.java
│   │       │   │   └── AnalyticsService.java
│   │       │   ├── entity/
│   │       │   │   ├── DashboardMetric.java
│   │       │   │   ├── DailyStats.java
│   │       │   │   └── BloodDemandForecast.java
│   │       │   ├── repository/
│   │       │   │   ├── DashboardMetricRepository.java
│   │       │   │   └── ForecastRepository.java
│   │       │   ├── dto/
│   │       │   │   ├── DashboardDTO.java
│   │       │   │   └── ForecastDTO.java
│   │       │   └── AnalyticsServiceApp.java
│   │       └── resources/
│   │           └── application.yml
│   └── Dockerfile
│
├── lifeflow-common/                      # Shared Libraries
│   ├── pom.xml
│   └── src/main/java/com/lifeflow/common/
│       ├── entity/
│       │   ├── BaseEntity.java
│       │   └── AuditEntity.java
│       ├── dto/
│       │   ├── ApiResponse.java
│       │   └── ErrorResponse.java
│       ├── exception/
│       │   ├── LifeflowException.java
│       │   ├── ResourceNotFoundException.java
│       │   └── ValidationException.java
│       ├── event/
│       │   ├── DomainEvent.java
│       │   ├── EventPublisher.java
│       │   └── EventConsumer.java
│       ├── utils/
│       │   ├── JwtUtil.java
│       │   ├── DateUtil.java
│       │   └── ValidationUtil.java
│       └── constant/
│           ├── BloodType.java
│           ├── UrgencyLevel.java
│           └── Constants.java
│
├── infrastructure/
│   ├── docker-compose.yml
│   ├── Dockerfile.base                   # Base Java 17 image
│   ├── kubernetes/
│   │   ├── namespace.yaml
│   │   ├── configmaps/
│   │   │   ├── app-config.yaml
│   │   │   └── logging-config.yaml
│   │   ├── secrets/
│   │   │   ├── db-secret.yaml
│   │   │   └── jwt-secret.yaml
│   │   ├── deployments/
│   │   │   ├── api-gateway-deployment.yaml
│   │   │   ├── identity-service-deployment.yaml
│   │   │   ├── donor-service-deployment.yaml
│   │   │   ├── inventory-service-deployment.yaml
│   │   │   ├── request-service-deployment.yaml
│   │   │   ├── geolocation-service-deployment.yaml
│   │   │   ├── notification-service-deployment.yaml
│   │   │   └── analytics-service-deployment.yaml
│   │   ├── services/
│   │   │   ├── api-gateway-service.yaml
│   │   │   └── ... (other services)
│   │   └── monitoring/
│   │       ├── prometheus-deployment.yaml
│   │       ├── grafana-deployment.yaml
│   │       └── alert-rules.yaml
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/
│       ├── prometheus.yml
│       ├── grafana-dashboards/
│       └── log-stack.yml
│
├── tests/
│   ├── unit/
│   │   ├── java/com/lifeflow/.../
│   │   │   ├── service/
│   │   │   │   ├── RequestServiceTest.java
│   │   │   │   ├── DonorServiceTest.java
│   │   │   │   └── InventoryServiceTest.java
│   │   │   └── controller/
│   │   │       └── RequestControllerTest.java
│   │   └── resources/
│   │       └── application-test.yml
│   ├── integration/
│   │   └── java/com/lifeflow/.../
│   │       └── EmergencyWorkflowIT.java
│   └── performance/
│       └── LoadTestSuite.java
│
├── scripts/
│   ├── setup-databases.sh
│   ├── build-all.sh
│   ├── deploy.sh
│   └── seed-test-data.sql
│
├── .env.example
├── docker-compose.yml
├── docker-compose-prod.yml
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── test.yml
│       └── deploy.yml
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Maven Module Structure

**Parent POM:** `pom.xml`
```xml
<modules>
    <module>lifeflow-common</module>
    <module>lifeflow-api-gateway</module>
    <module>lifeflow-identity-service</module>
    <module>lifeflow-donor-service</module>
    <module>lifeflow-inventory-service</module>
    <module>lifeflow-request-service</module>
    <module>lifeflow-geolocation-service</module>
    <module>lifeflow-notification-service</module>
    <module>lifeflow-analytics-service</module>
</modules>
```

## Service Port Mapping

| Service | Port | JVM | Database |
|---------|------|-----|----------|
| API Gateway | 8080 | 256MB | - |
| Identity | 3001 | 512MB | lifeflow_identity |
| Donor | 3002 | 512MB | lifeflow_donor |
| Inventory | 3003 | 512MB | lifeflow_inventory |
| Request | 3004 | 768MB | lifeflow_request |
| Geolocation | 3005 | 512MB | lifeflow_geolocation |
| Notification | 3006 | 512MB | lifeflow_notifications |
| Analytics | 3007 | 768MB | lifeflow_analytics |

## Build & Run Commands

```bash
# Build all modules
mvn clean install

# Build specific service
mvn clean install -pl lifeflow-donor-service

# Run tests
mvn test

# Package for Docker
mvn clean package -DskipTests -P docker

# Build Docker images
docker-compose build

# Run services
docker-compose up -d
```

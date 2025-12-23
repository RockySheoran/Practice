# LifeFlow - Microservices Architecture

## Architecture Overview

LifeFlow implements a microservices architecture designed for high availability, scalability, and fault tolerance. The system is built around the principle that in a blood donation system, downtime can cost lives, so each service is designed to operate independently.

## Core Architectural Principles

### 1. Service Independence
- Each microservice owns its data and business logic
- Services can be developed, deployed, and scaled independently
- Failure of one service doesn't bring down the entire system

### 2. Event-Driven Communication
- Services communicate through asynchronous events via Apache Kafka
- Reduces coupling between services
- Enables better scalability and resilience

### 3. Database per Service
- Each service has its own PostgreSQL database schema
- Ensures data isolation and service autonomy
- Prevents database-level coupling

## Service Catalog

### 1. API Gateway Service
**Port**: 8080  
**Purpose**: Central entry point for all client requests

**Responsibilities**:
- Request routing to appropriate microservices
- Authentication and authorization
- Rate limiting and throttling
- Request/response transformation
- Load balancing
- API versioning

**Key Features**:
- Spring Cloud Gateway
- JWT token validation
- Circuit breaker integration
- Request logging and monitoring

### 2. Identity & Profile Service
**Port**: 8081  
**Purpose**: User authentication and profile management

**Responsibilities**:
- User registration and authentication
- Role-based access control (RBAC)
- OAuth2/JWT token management
- User profile management
- Password management and security

**Database Tables**:
- users, roles, user_roles, user_profiles, audit_logs

**Events Published**:
- USER_REGISTERED, USER_AUTHENTICATED, PROFILE_UPDATED

### 3. Donor Management Service
**Port**: 8082  
**Purpose**: Complete donor lifecycle management

**Responsibilities**:
- Donor registration and profile management
- Medical history and eligibility tracking
- Donation history management
- Eligibility calculations (3-month blocking)
- Health screening and pre-donation checks

**Database Tables**:
- donors, donation_history, medical_history, eligibility_status, health_screenings

**Events Published**:
- DONOR_REGISTERED, DONATION_COMPLETED, ELIGIBILITY_UPDATED

**Events Consumed**:
- USER_REGISTERED, BLOOD_REQUEST_CREATED

### 4. Hospital Management Service
**Port**: 8083  
**Purpose**: Hospital and medical facility management

**Responsibilities**:
- Hospital registration and profile management
- Staff management and permissions
- Hospital inventory tracking
- Emergency contact management
- Hospital certification and compliance

**Database Tables**:
- hospitals, hospital_staff, hospital_inventory, certifications, emergency_contacts

**Events Published**:
- HOSPITAL_REGISTERED, STAFF_UPDATED, INVENTORY_UPDATED

### 5. Inventory & Blood Bank Service
**Port**: 8084  
**Purpose**: Blood inventory and stock management

**Responsibilities**:
- Blood bag tracking with RFID/barcode
- Inventory management by blood type
- Expiry date monitoring and alerts
- Stock level management
- Blood bag lifecycle tracking
- Cold chain monitoring

**Database Tables**:
- blood_bags, inventory_levels, blood_banks, storage_locations, expiry_alerts

**Events Published**:
- BLOOD_COLLECTED, BLOOD_EXPIRED, STOCK_LOW, INVENTORY_UPDATED

**Events Consumed**:
- DONATION_COMPLETED, BLOOD_REQUEST_FULFILLED

### 6. Request & Emergency Service
**Port**: 8085  
**Purpose**: Blood request processing and emergency management

**Responsibilities**:
- Blood request creation and management
- Emergency request prioritization
- Blood type compatibility matching
- Request status tracking
- SLA monitoring for emergency requests

**Database Tables**:
- blood_requests, emergency_requests, request_status, compatibility_matrix, sla_tracking

**Events Published**:
- BLOOD_REQUEST_CREATED, EMERGENCY_ALERT, REQUEST_FULFILLED, REQUEST_EXPIRED

**Events Consumed**:
- DONOR_AVAILABLE, INVENTORY_UPDATED, HOSPITAL_REQUEST

### 7. Geolocation & Logistics Service
**Port**: 8086  
**Purpose**: Location services and logistics management

**Responsibilities**:
- Distance calculation between donors and hospitals
- Route optimization for blood transportation
- Real-time tracking of blood deliveries
- Geographic search and filtering
- Traffic and weather integration

**Database Tables**:
- locations, routes, deliveries, tracking_data, geographic_zones

**Events Published**:
- DELIVERY_STARTED, DELIVERY_COMPLETED, ROUTE_OPTIMIZED, LOCATION_UPDATED

**Events Consumed**:
- BLOOD_REQUEST_CREATED, DONOR_MATCHED

### 8. Notification Service
**Port**: 8087  
**Purpose**: Multi-channel communication system

**Responsibilities**:
- SMS notifications via Twilio/AWS SNS
- Email notifications via SendGrid/AWS SES
- Push notifications for mobile apps
- WhatsApp messaging integration
- Notification preferences management
- Delivery status tracking

**Database Tables**:
- notifications, notification_preferences, delivery_status, templates, channels

**Events Published**:
- NOTIFICATION_SENT, NOTIFICATION_FAILED, DELIVERY_CONFIRMED

**Events Consumed**:
- All service events that require notifications

### 9. Camp & Event Service
**Port**: 8088  
**Purpose**: Donation drive and event management

**Responsibilities**:
- Donation drive planning and scheduling
- Venue management and booking
- Volunteer coordination and scheduling
- Resource allocation and inventory
- Event marketing and promotion
- Performance analytics

**Database Tables**:
- camps, events, venues, volunteers, resources, registrations, performance_metrics

**Events Published**:
- CAMP_SCHEDULED, EVENT_CREATED, VOLUNTEER_ASSIGNED, CAMP_COMPLETED

**Events Consumed**:
- DONOR_REGISTERED, DONATION_COMPLETED

### 10. Analytics & Reporting Service
**Port**: 8089  
**Purpose**: Data analytics and business intelligence

**Responsibilities**:
- Predictive analytics for blood demand
- Seasonal trend analysis
- Performance metrics and KPIs
- Custom report generation
- Machine learning model training
- Data visualization and dashboards

**Database Tables**:
- analytics_data, predictions, reports, ml_models, dashboards, metrics

**Events Published**:
- PREDICTION_GENERATED, REPORT_CREATED, ALERT_TRIGGERED

**Events Consumed**:
- All service events for analytics processing

### 11. Gamification Service
**Port**: 8090  
**Purpose**: Donor engagement and reward system

**Responsibilities**:
- Points and badge management
- Reward tier calculations
- Achievement tracking
- Leaderboards and competitions
- Reward redemption processing
- Social features and sharing

**Database Tables**:
- user_points, badges, achievements, rewards, leaderboards, redemptions

**Events Published**:
- POINTS_AWARDED, BADGE_EARNED, REWARD_REDEEMED, ACHIEVEMENT_UNLOCKED

**Events Consumed**:
- DONATION_COMPLETED, EMERGENCY_RESPONSE, CAMP_PARTICIPATION

## Event-Driven Architecture

### Event Flow Examples

#### Emergency Blood Request Workflow
```
1. Hospital → Request Service: Creates emergency request
2. Request Service → Event Bus: BLOOD_REQUEST_CREATED (EMERGENCY)
3. Inventory Service ← Event Bus: Checks stock availability
4. Geolocation Service ← Event Bus: Finds nearby donors
5. Notification Service ← Event Bus: Alerts compatible donors
6. Donor Service ← Event Bus: Updates donor availability
7. Analytics Service ← Event Bus: Records emergency metrics
```

#### Donation Completion Workflow
```
1. Donor Service → Event Bus: DONATION_COMPLETED
2. Inventory Service ← Event Bus: Updates stock levels
3. Gamification Service ← Event Bus: Awards points and badges
4. Analytics Service ← Event Bus: Updates donation statistics
5. Notification Service ← Event Bus: Sends thank you message
```

### Event Categories

#### Domain Events
- DONOR_REGISTERED, DONATION_COMPLETED, BLOOD_REQUEST_CREATED
- HOSPITAL_REGISTERED, INVENTORY_UPDATED, CAMP_SCHEDULED

#### Integration Events
- NOTIFICATION_SENT, PAYMENT_PROCESSED, EXTERNAL_API_CALLED

#### System Events
- SERVICE_STARTED, SERVICE_STOPPED, HEALTH_CHECK_FAILED

## Service Communication Patterns

### 1. Synchronous Communication (REST APIs)
- Used for real-time queries and immediate responses
- API Gateway to service communication
- Service-to-service calls for critical operations

### 2. Asynchronous Communication (Events)
- Used for eventual consistency scenarios
- Non-blocking operations
- Event sourcing for audit trails

### 3. Circuit Breaker Pattern
- Prevents cascade failures
- Automatic fallback mechanisms
- Health monitoring and recovery

## Data Consistency Strategies

### 1. SAGA Pattern
- Distributed transaction management
- Compensating actions for rollbacks
- Choreography-based coordination

### 2. Event Sourcing
- Complete audit trail of all changes
- Replay capability for debugging
- Temporal queries and analytics

### 3. CQRS (Command Query Responsibility Segregation)
- Separate read and write models
- Optimized query performance
- Scalable read replicas

## Security Architecture

### 1. Authentication & Authorization
- OAuth2 with JWT tokens
- Role-based access control (RBAC)
- Service-to-service authentication

### 2. Data Protection
- Encryption at rest (AES-256)
- Encryption in transit (TLS 1.3)
- PII data anonymization

### 3. Compliance
- HIPAA compliance for medical data
- GDPR compliance for personal data
- Audit logging for all operations

## Monitoring & Observability

### 1. Distributed Tracing
- Request correlation across services
- Performance bottleneck identification
- Error propagation tracking

### 2. Metrics Collection
- Business metrics (donations, requests)
- Technical metrics (latency, throughput)
- Infrastructure metrics (CPU, memory)

### 3. Centralized Logging
- Structured logging with correlation IDs
- Log aggregation via ELK stack
- Real-time log analysis and alerting

## Deployment Strategy

### 1. Containerization
- Docker containers for all services
- Kubernetes orchestration
- Blue-green deployments

### 2. Service Mesh
- Istio for service communication
- Traffic management and security
- Observability and monitoring

### 3. Infrastructure as Code
- Terraform for infrastructure provisioning
- Helm charts for Kubernetes deployments
- GitOps workflow with ArgoCD
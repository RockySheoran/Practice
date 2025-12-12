# LifeFlow Microservices Architecture

## Architecture Overview

LifeFlow follows a **microservices architecture** with an event-driven communication model. Each service is independently deployable, scalable, and maintains its own database.

```
┌─────────────────────────────────────────────────────────────────┐
│                      Mobile & Web Clients                        │
│                  (Donor App, Hospital Portal, Admin Dashboard)  │
└────────────────────────┬──────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    API Gateway (Kong/Spring Cloud)              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ - Request Routing & Load Balancing                        │  │
│  │ - Rate Limiting & Authentication                         │  │
│  │ - Request/Response Transformation                        │  │
│  │ - Monitoring & Metrics Collection                        │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────┬──────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┬─────────────────┬──────────────┐
        │                │                │                 │              │
        ▼                ▼                ▼                 ▼              ▼
  ┌──────────┐    ┌──────────┐     ┌──────────┐     ┌──────────┐   ┌──────────┐
  │ Identity │    │  Donor   │     │Inventory │     │ Request  │   │Geoloc &  │
  │  Auth    │    │Management│     │Blood Bank│     │Emergency │   │Logistics │
  │ Service  │    │ Service  │     │ Service  │     │ Service  │   │ Service  │
  │          │    │          │     │          │     │          │   │          │
  │ Port:   │    │ Port:    │     │ Port:    │     │ Port:    │   │ Port:    │
  │  8001   │    │  8002    │     │  8003    │     │  8004    │   │  8005    │
  └─────┬────┘    └────┬─────┘     └────┬─────┘     └────┬─────┘   └─────┬────┘
        │              │                │                │              │
        └──────────────┼────────────────┼────────────────┼──────────────┘
                       │
        ┌──────────────┼────────────────┐
        │              │                │
        ▼              ▼                ▼
  ┌──────────┐   ┌──────────┐    ┌──────────┐
  │Notificat.│   │   Camp   │    │Analytics &│
  │ Service  │   │  Event   │    │Gamification
  │          │   │ Service  │    │ Service  │
  │ Port:   │   │ Port:    │    │ Port:    │
  │  8006   │   │  8007    │    │  8008    │
  └─────┬────┘   └────┬─────┘    └────┬─────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │    Event Bus (RabbitMQ/Kafka)
        │    - MESSAGE BROKER          │
        │    - Event Publisher/Subscriber
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
   ┌──────────┐              ┌──────────────┐
   │PostgreSQL│              │    Redis     │
   │Databases │              │  (Caching)   │
   │per Service
   └──────────┘              └──────────────┘
```

## Microservices Overview

### 1. Identity & Authentication Service (Port: 8001)
**Responsibility**: User registration, authentication, authorization, role management

**Key Features**:
- OAuth2 & JWT-based authentication
- Biometric login support (fingerprint, face recognition)
- Role-based access control (RBAC): Donor, Hospital, Blood Bank, Admin
- Two-factor authentication (2FA)
- KYC document management
- Password reset and account recovery
- Session management
- Audit logging for security events

**Database**: PostgreSQL
**Key Entities**:
- Users (Donors, Hospital Staff, Blood Banks, Admins)
- Roles & Permissions
- OAuth Clients
- Sessions
- Audit Logs

---

### 2. Donor Management Service (Port: 8002)
**Responsibility**: Donor profiles, medical history, donation history, eligibility status

**Key Features**:
- Donor registration and profile management
- Medical history tracking
- Blood type and physical attributes (weight, hemoglobin level)
- Donation eligibility checker (AI-based)
- Donation blocking/cooldown period management (3 months after donation)
- Eligibility criteria validation (recent travel, tattoos, medications)
- Donation history with timestamps
- Reward points and badge management
- Emergency contact information
- Pagination and search filters

**Database**: PostgreSQL
**Key Entities**:
- Donor Profiles
- Medical History
- Donation Records
- Eligibility Status
- Rewards & Badges

---

### 3. Inventory & Blood Bank Service (Port: 8003)
**Responsibility**: Blood bag tracking, stock management, expiry tracking, location management

**Key Features**:
- Individual blood bag tracking (barcode/RFID)
- Batch ID management
- Stock count by blood type (A+, A-, B+, B-, O+, O-, AB+, AB-)
- Expiry date tracking (35-42 days for most blood types)
- Automated expiry alerts
- Fridge/location management
- Stock reservation during requests
- Stock reconciliation
- Inventory analytics and reports
- Predictive stocking using ML

**Database**: PostgreSQL
**Key Entities**:
- Blood Inventory
- Batch Records
- Expiry Tracking
- Storage Locations (Refrigerators)
- Stock Movement History

---

### 4. Request & Emergency Service (Port: 8004)
**Responsibility**: Blood requests, urgency handling, matching logic

**Key Features**:
- Emergency blood request creation
- Urgency levels (Critical, High, Normal, Elective)
- Blood type matching logic (e.g., A+ accepts O+ compatible types)
- Request status tracking (Pending, Matched, In Transit, Delivered, Cancelled)
- Priority queue management
- Request history and analytics
- Elective scheduling for non-emergency requests
- Pagination and filtering

**Database**: PostgreSQL
**Key Entities**:
- Blood Requests
- Request Status History
- Urgency Levels
- Matching Records

---

### 5. Geolocation & Logistics Service (Port: 8005)
**Responsibility**: Distance calculation, route optimization, live tracking

**Key Features**:
- Real-time GPS tracking of blood transport
- Distance calculation (donor to hospital, hospital to fridge location)
- Geo-fenced alerts (notify donors within 5km radius)
- Route optimization using Google Maps API
- Delivery vehicle/rider tracking
- Estimated arrival time (ETA) calculation
- Route history and analytics
- Traffic integration for delay predictions

**Database**: PostgreSQL + Redis (for live locations)
**Key Entities**:
- Location Records
- Route History
- Live Tracking Sessions
- Geo-fences

---

### 6. Notification Service (Port: 8006)
**Responsibility**: Multi-channel notifications (Email, SMS, Push, WhatsApp)

**Key Features**:
- Email notifications (SendGrid)
- SMS notifications (Twilio)
- Push notifications (Firebase)
- WhatsApp notifications (optional)
- Notification templates
- Do-not-disturb scheduling (respect silent hours)
- Notification history and read status
- Delivery confirmation
- Retry logic for failed notifications
- High-priority alerts (bypass silent mode if permission granted)

**Database**: PostgreSQL
**Key Entities**:
- Notification Records
- Templates
- Delivery Status
- User Preferences

---

### 7. Camp & Event Service (Port: 8007)
**Responsibility**: Donation drive management, volunteer coordination, event scheduling

**Key Features**:
- Donation drive creation and scheduling
- Venue and capacity management
- Volunteer rostering
- Digital marketing assets generation
- Registration and sign-ups
- Event calendar
- Post-event analytics
- NGO management
- Donation target tracking

**Database**: PostgreSQL
**Key Entities**:
- Camps/Drives
- Venues
- Volunteers
- Registrations
- Events
- Analytics

---

### 8. Analytics & Gamification Service (Port: 8008)
**Responsibility**: Rewards, badges, dashboards, analytics

**Key Features**:
- Donor gamification (points, badges, leaderboards)
- Reward calculation and redemption
- "Life-Saver" badge system
- Monthly/yearly rankings
- System dashboards (real-time stats)
- Blood shortage predictions
- Donor retention analytics
- Hospital request patterns
- Campaign effectiveness tracking

**Database**: PostgreSQL
**Key Entities**:
- Rewards
- Badges & Achievements
- Leaderboards
- Analytics Records
- Dashboards

---

## API Gateway Design

The **API Gateway** serves as the single entry point for all client requests. It handles:

```
┌─────────────────────────────────────────────────────────┐
│          API Gateway (Kong / Spring Cloud)              │
├─────────────────────────────────────────────────────────┤
│ ✓ Request Routing to Services                           │
│ ✓ Load Balancing across service instances               │
│ ✓ Rate Limiting (API throttling)                        │
│ ✓ Authentication & Authorization (JWT validation)       │
│ ✓ Request/Response Transformation                       │
│ ✓ CORS handling                                         │
│ ✓ API Versioning (v1/, v2/)                            │
│ ✓ Logging & Audit Trails                               │
│ ✓ Metrics Collection & Monitoring                       │
│ ✓ Circuit Breaker integration                          │
│ ✓ Request validation                                    │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow & Communication Pattern

### Synchronous Communication (Direct API Calls)
Used for immediate operations:
- Login/Authentication
- Real-time data fetch (donor profile, inventory status)
- Payment processing (if applicable)

### Asynchronous Communication (Event-Driven)
Used for decoupled operations:
- Blood request workflow
- Notifications
- Inventory updates
- Gamification rewards

---

## Service Independence

Each service is independent in terms of:
- **Database**: No shared databases; each service has its own PostgreSQL instance
- **Deployment**: Can be deployed/updated independently
- **Scaling**: Can be scaled horizontally based on load
- **Failure**: Failure in one service should not cascade to others

---

## Cross-Cutting Concerns

### Distributed Tracing
- Use OpenTelemetry for request tracing across services
- Correlation IDs for tracking requests

### Monitoring & Logging
- Centralized logging via ELK Stack
- Prometheus for metrics
- Grafana for dashboards

### Security
- JWT tokens with short expiry
- Service-to-service authentication (mTLS or API keys)
- Data encryption at rest and in transit
- PII masking in logs

---

## Deployment Architecture

### Development
- Docker Compose with all services running locally

### Staging
- Kubernetes cluster with limited replicas

### Production
- Kubernetes cluster with auto-scaling
- Multiple availability zones
- Load balancing
- CDN for static content
- Backup and disaster recovery setup


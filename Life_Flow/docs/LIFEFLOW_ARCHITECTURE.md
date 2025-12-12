# LifeFlow: Next-Generation Blood Donation Management System

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Entity-Relationship Diagram](#entity-relationship-diagram)
4. [Database Schemas](#database-schemas)
5. [Emergency Request Workflow](#emergency-request-workflow)
6. [Microservices Detail](#microservices-detail)
7. [API Endpoints](#api-endpoints)

---

## System Overview

**LifeFlow** is a mission-critical, high-availability blood donation management system designed to:
- Connect hospitals with donors in emergencies
- Manage blood inventory with predictive stocking
- Track blood units from donation to usage
- Gamify donor engagement
- Ensure 99.9% uptime with microservices architecture

### Core Problem Statement
When a hospital has an emergency blood requirement for a critical patient:
1. Hospital submits an urgent request
2. System identifies compatible donors nearby
3. Donors receive notifications
4. Upon acceptance, hospital is notified
5. Scheduling coordination happens
6. Blood unit is tracked until usage

---

## Architecture

### Microservices Components

```
┌─────────────────────────────────────────────────────────────┐
│                      API GATEWAY                             │
│              (Request Routing, Rate Limiting)                │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐  ┌────────▼────────┐  ┌────────▼────────┐
│  DONOR MGMT    │  │  REQUEST &      │  │  INVENTORY &    │
│  SERVICE       │  │  EMERGENCY      │  │  BLOOD BANK     │
│                │  │  SERVICE        │  │  SERVICE        │
├────────────────┤  ├─────────────────┤  ├─────────────────┤
│ • Profile      │  │ • Blood Request │  │ • Stock Ledger  │
│ • History      │  │ • Urgency Level │  │ • Batch Track   │
│ • Eligibility  │  │ • Matching      │  │ • Expiry Track  │
└────────┬───────┘  └────────┬────────┘  └────────┬────────┘
         │                   │                   │
         └─────────────────────────────────────────┘
                          │
              ┌───────────┼───────────┐
              │           │           │
        ┌─────▼─┐  ┌─────▼──┐  ┌────▼────┐
        │NOTIF. │  │GEOLOC. │  │ANALYTICS│
        │SERVICE│  │SERVICE │  │SERVICE  │
        └───────┘  └────────┘  └─────────┘
              │           │           │
              └───────────┼───────────┘
                          │
                  ┌───────▼────────┐
                  │  EVENT BUS     │
                  │  (RabbitMQ/    │
                  │   Kafka)       │
                  └────────────────┘
```

---

## Entity-Relationship Diagram

### Core Entities

```
┌──────────────────┐
│      USERS       │
├──────────────────┤
│ user_id (PK)     │
│ email            │
│ phone            │
│ role (Enum)      │◄─┐
│ password_hash    │  │
│ created_at       │  │
└──────────────────┘  │
        │             │
        ├─────────────┤
        │             │
┌───────▼──────────┐  │  ┌─────────────────┐
│ DONOR_PROFILE    │  │  │    HOSPITAL     │
├──────────────────┤  │  ├─────────────────┤
│ donor_id (FK)    │  │  │ hospital_id(FK) │
│ blood_type       │  │  │ name            │
│ weight           │  │  │ location        │
│ hemoglobin       │  │  │ address         │
│ last_donation    │  │  │ contact_person  │
│ eligibility_flag │  │  │ emergency_line  │
│ verified_at      │  │  └─────────────────┘
└──────────────────┘  │
                      │
                      └─→ (user_id foreign key)

┌──────────────────────────┐
│    BLOOD_REQUEST         │
├──────────────────────────┤
│ request_id (PK)          │
│ hospital_id (FK)         │
│ blood_type_needed        │
│ units_required           │
│ urgency_level (CRITICAL/ │
│   HIGH/MEDIUM/LOW)       │
│ patient_condition        │
│ created_at               │
│ deadline                 │
│ status (PENDING/MATCHED/ │
│   ACCEPTED/FULFILLED)    │
└──────────────────────────┘
        │
        │ (1:N relationship)
        │
┌───────▼──────────────────────┐
│   REQUEST_RESPONSE           │
├──────────────────────────────┤
│ response_id (PK)             │
│ request_id (FK)              │
│ donor_id (FK)                │
│ response_status (ACCEPTED/   │
│   REJECTED/PENDING)          │
│ response_time                │
│ scheduled_pickup_time        │
│ confirmed_by_donor_at        │
│ confirmation_code            │
└──────────────────────────────┘
        │
        │ (1:1 relationship)
        │
┌───────▼──────────────────────┐
│   BLOOD_INVENTORY            │
├──────────────────────────────┤
│ bag_id (PK)                  │
│ blood_type                   │
│ batch_number                 │
│ donation_date                │
│ expiry_date                  │
│ storage_location             │
│ status (AVAILABLE/RESERVED/  │
│   USED/EXPIRED)              │
│ current_temperature          │
│ barcode/RFID                 │
│ donor_id (FK) [anonymized]   │
└──────────────────────────────┘

┌───────────────────────┐
│   DONATION_HISTORY    │
├───────────────────────┤
│ donation_id (PK)      │
│ donor_id (FK)         │
│ donation_date         │
│ blood_type_collected  │
│ units_collected       │
│ health_score          │
│ staff_notes           │
│ center_id (FK)        │
└───────────────────────┘

┌──────────────────────┐
│  DONOR_GAMIFICATION  │
├──────────────────────┤
│ gamification_id(PK)  │
│ donor_id (FK)        │
│ total_points         │
│ badge_level (BRONZE/ │
│  SILVER/GOLD)        │
│ donations_count      │
│ lives_saved_estimate │
│ last_updated         │
└──────────────────────┘

┌──────────────────────────┐
│   BLOOD_FULFILLMENT      │
├──────────────────────────┤
│ fulfillment_id (PK)      │
│ request_id (FK)          │
│ bag_id (FK)              │
│ request_response_id(FK)  │
│ pickup_timestamp         │
│ delivery_timestamp       │
│ used_timestamp           │
│ delivered_to_hospital    │
│ rider_id                 │
└──────────────────────────┘

┌──────────────────────────┐
│  NOTIFICATIONS_LOG       │
├──────────────────────────┤
│ notification_id (PK)     │
│ user_id (FK)             │
│ notification_type (SMS/  │
│  EMAIL/PUSH/WHATSAPP)    │
│ content                  │
│ request_id (FK)          │
│ sent_at                  │
│ delivery_status          │
│ read_at                  │
└──────────────────────────┘
```

---

## Database Schemas

### Database 1: Identity & Profile Service DB
```sql
-- Service: Identity & Profile Service
-- Handles authentication and user management
```

### Database 2: Donor Management Service DB
```sql
-- Service: Donor Management Service
-- Manages donor profiles and eligibility
```

### Database 3: Inventory & Blood Bank Service DB
```sql
-- Service: Inventory & Blood Bank Service
-- Manages blood stock and tracking
```

### Database 4: Request & Emergency Service DB
```sql
-- Service: Request & Emergency Service
-- Manages blood requests and matching
```

### Database 5: Notification Service DB
```sql
-- Service: Notification Service
-- Logs all notifications (stateless but auditable)
```

---

## Emergency Request Workflow

### Scenario: Hospital in Emergency

**Timeline: 0 to 10 Minutes**

```
T=0:00s
┌─────────────────────────────────────────┐
│ STEP 1: Hospital Submits Request        │
│                                         │
│ Hospital Admin submits:                 │
│ - Patient: Critical accident            │
│ - Blood Type: O+ (or O-)               │
│ - Units: 4 units URGENTLY               │
│ - Deadline: 30 mins                     │
└────────────────┬────────────────────────┘
                 │
                 │ REQUEST_SERVICE
                 │ validates & stores
                 │
                 ▼
        ┌────────────────────┐
        │ EVENT_BLOOD_NEEDED │
        │ published to bus   │
        └────────┬───────────┘
                 │
                 │ (consumed by 3 services)
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼

T=0:05s
┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│ INVENTORY   │ │ GEOLOCATION  │ │ NOTIFICATION │
│ SERVICE     │ │ SERVICE      │ │ SERVICE      │
│             │ │              │ │              │
│ Check stock │ │ Find donors  │ │ Queue alerts │
│ for O+/O-   │ │ within 5km   │ │              │
└──────┬──────┘ └──────┬───────┘ └──────┬───────┘
       │               │               │
       │ SCENARIO A    │ SCENARIO B    │
       │ Stock Found   │ No Stock      │
       │               │ In Bank       │
       ▼               ▼               ▼

T=0:10s
┌──────────────────────────────────────────┐
│ SCENARIO A: STOCK AVAILABLE              │
│                                          │
│ 1. Reserve 4 units of O+                │
│ 2. Emit: EVENT_BLOOD_FOUND              │
│ 3. Send: "Matched from bank inventory"  │
│ 4. Hospital: Arrange pickup             │
│ 5. Estimated delivery: 15 mins          │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│ SCENARIO B: URGENT DONOR MOBILIZATION    │
│                                          │
│ 1. Geolocation finds 8 O+ donors nearby │
│ 2. Notification Service sends HIGH-      │
│    PRIORITY alerts (sound, bypass silent)│
│ 3. Alerts: "Emergency request! Earn     │
│    100 points. Can you donate in 30mins?"│
│ 4. Donor 1: ACCEPTS in 2 mins           │
│ 5. Donor 2: ACCEPTS in 4 mins           │
│ 6. Donor 3: No response (offline)       │
│ 7. Geolocation tracks ride to center    │
│ 8. Collection starts                    │
└──────────────────────────────────────────┘

T=0:15s - CRITICAL: First Acceptance
┌─────────────────────────────────────────┐
│ STEP 2: Donor Accepts (Scenario B)      │
│                                         │
│ Donor 1 receives alert                  │
│ "EMERGENCY - O+ needed in 30 mins"      │
│                                         │
│ Donor Action: TAP "ACCEPT"              │
└────────────┬────────────────────────────┘
             │
             │ REQUEST_RESPONSE_SERVICE
             │ records response
             │
             ▼
    ┌────────────────────────┐
    │ EVENT_DONOR_ACCEPTED   │
    │ published to bus       │
    └────────┬───────────────┘
             │
        ┌────┴────┬────────────┐
        │          │            │
        ▼          ▼            ▼
   ┌────────┐ ┌──────┐  ┌────────────┐
   │HOSPITAL│ │DONOR │  │ANALYTICS   │
   │NOTIFIED│ │NOTIF.│  │SERVICE     │
   │        │ │      │  │            │
   │"1 donor│ │"Your │  │Logs: Donor │
   │accepted"│ │loc   │  │responded   │
   │        │ │sent" │  │in 2 mins   │
   └────────┘ └──────┘  └────────────┘

T=0:20s - Donor En Route
┌─────────────────────────────────────────┐
│ STEP 3: Pickup Scheduling               │
│                                         │
│ 1. Hospital: Gets live pickup ETA      │
│ 2. Donor: "Report to Center in 15 mins"│
│ 3. Geolocation Service tracks ride     │
│ 4. Confirmation: Donor arrived at      │
│    collection center                    │
└─────────────────────────────────────────┘

T=0:25s - Collection Complete
┌─────────────────────────────────────────┐
│ STEP 4: Blood Collection & Fulfillment  │
│                                         │
│ 1. Medical staff collects 1 unit from  │
│    Donor 1                              │
│ 2. Barcode assigned: BAG-001-URGENT    │
│ 3. Inventory Service: +1 unit O+ added │
│ 4. Gamification: +100 points to Donor  │
│ 5. NOTIFICATION: "Your blood unit in   │
│    transport to [Hospital Name]"        │
└─────────────────────────────────────────┘

T=0:30s - BLOOD IN TRANSIT
┌─────────────────────────────────────────┐
│ STEP 5: Live Tracking                   │
│                                         │
│ Hospital sees:                          │
│ "Blood en route, ETA 10 mins"          │
│                                         │
│ Donor sees:                             │
│ "Your blood unit helping a patient     │
│  at [Hospital]. Status: In Transit"    │
└─────────────────────────────────────────┘

T=0:35s - DELIVERY & USAGE
┌─────────────────────────────────────────┐
│ STEP 6: Delivery Confirmation           │
│                                         │
│ 1. Blood arrives at hospital            │
│ 2. Inventory Service: status = READY    │
│ 3. Doctor approves usage                │
│ 4. Inventory Service: status = USED     │
│ 5. NOTIFICATION to Donor:               │
│    "✓ Your donation saved a life!       │
│     Patient: Stable"                    │
│ 6. Gamification: "Hero Badge Unlocked"  │
└─────────────────────────────────────────┘
```

---

## Microservices Detail

### 1. Identity & Profile Service
**Ports:** 3001  
**Database:** PostgreSQL (users_db)  
**Responsibility:**
- User registration (Donor/Hospital/Admin)
- OAuth2 + Biometric authentication
- Role-based access control
- KYC document verification

**Key APIs:**
```
POST /auth/register
POST /auth/login
POST /auth/refresh-token
GET /profile/{user_id}
POST /profile/update
POST /profile/verify-kyc
```

---

### 2. Donor Management Service
**Ports:** 3002  
**Database:** PostgreSQL (donor_db)  
**Responsibility:**
- Donor profile management
- Medical history and eligibility checking
- Donation history tracking
- Real-time eligibility status

**Key APIs:**
```
GET /donor/{donor_id}
POST /donor/profile/create
PUT /donor/profile/update
GET /donor/eligibility/{donor_id}
POST /donor/donation-history
GET /donor/gamification/{donor_id}
```

---

### 3. Inventory & Blood Bank Service
**Ports:** 3003  
**Database:** PostgreSQL (inventory_db)  
**Responsibility:**
- Blood bag tracking (barcode/RFID)
- Stock ledger management
- Expiry date monitoring
- Storage temperature tracking
- Batch management

**Key APIs:**
```
POST /inventory/add-bag
GET /inventory/stock/{blood_type}
GET /inventory/bag/{bag_id}
PUT /inventory/bag/{bag_id}/reserve
PUT /inventory/bag/{bag_id}/release
GET /inventory/expiry-alerts
POST /inventory/batch-create
```

---

### 4. Request & Emergency Service
**Ports:** 3004  
**Database:** PostgreSQL (request_db)  
**Responsibility:**
- Blood request creation
- Donor matching algorithm
- Urgency level management
- Request status tracking
- SAGA pattern for consistency

**Key APIs:**
```
POST /request/create
GET /request/{request_id}
GET /request/active
POST /request/{request_id}/match-donors
POST /response/{response_id}/accept
POST /response/{response_id}/reject
PUT /request/{request_id}/status
```

---

### 5. Geolocation & Logistics Service
**Ports:** 3005  
**Database:** Redis (caching) + PostgreSQL  
**Responsibility:**
- Distance calculation (donor to hospital)
- Geo-fencing logic (5km radius)
- Ride/delivery tracking
- Route optimization

**Key APIs:**
```
GET /geo/nearby-donors/{hospital_id}?radius=5
POST /geo/track-delivery/{fulfillment_id}
GET /geo/delivery-status/{fulfillment_id}
PUT /geo/location/{rider_id}
```

---

### 6. Notification Service
**Ports:** 3006  
**Database:** MongoDB (notifications_log)  
**Responsibility:**
- Stateless notification dispatcher
- SMS, Email, Push, WhatsApp integration
- Circuit breaker for provider failures
- Notification history logging

**Key APIs:**
```
POST /notify/send-sms
POST /notify/send-email
POST /notify/send-push
POST /notify/send-batch
GET /notify/history/{user_id}
```

---

### 7. Analytics & Dashboard Service
**Ports:** 3007  
**Database:** PostgreSQL + Elasticsearch  
**Responsibility:**
- Real-time dashboard metrics
- Predictive stocking ML model
- Donor engagement analytics
- System health monitoring

**Key APIs:**
```
GET /analytics/dashboard
GET /analytics/predictions/shortages
GET /analytics/donor-stats
GET /analytics/response-times
```

---

## API Endpoints Summary

### Blood Request Endpoint (Primary)
```http
POST /request/create
Content-Type: application/json

{
  "hospital_id": "hosp-001",
  "blood_type": "O+",
  "units_required": 4,
  "urgency_level": "CRITICAL",
  "patient_condition": "Multiple trauma, ICU admission",
  "deadline_minutes": 30
}

Response:
{
  "request_id": "req-12345",
  "status": "PENDING",
  "matched_donors": 8,
  "created_at": "2024-01-15T14:23:45Z"
}
```

### Donor Response Endpoint
```http
POST /response/{request_id}/accept
Content-Type: application/json

{
  "donor_id": "donor-99",
  "can_arrive_in_minutes": 25,
  "confirmation_code": "APPROVED"
}

Response:
{
  "response_id": "resp-456",
  "request_id": "req-12345",
  "status": "ACCEPTED",
  "scheduled_pickup_time": "2024-01-15T14:45:00Z",
  "points_earned": 100
}
```

---

## Data Flow in Event-Driven Architecture

```
REQUEST_SERVICE
  ├─ EVENT_BLOOD_NEEDED
  │  ├─→ INVENTORY_SERVICE: Check stock
  │  ├─→ GEOLOCATION_SERVICE: Find donors
  │  └─→ NOTIFICATION_SERVICE: Queue alerts
  │
  └─ EVENT_BLOOD_FOUND (if stock available)
     └─→ HOSPITAL: "Blood available, please arrange pickup"

DONOR_SERVICE
  └─ EVENT_DONATION_COMPLETE
     ├─→ INVENTORY_SERVICE: +1 unit
     ├─→ GAMIFICATION_SERVICE: +50 points
     ├─→ ANALYTICS_SERVICE: Update stats
     └─→ NOTIFICATION_SERVICE: Thank you note

REQUEST_RESPONSE_SERVICE
  └─ EVENT_DONOR_ACCEPTED
     ├─→ HOSPITAL: Notify acceptance
     ├─→ GEOLOCATION_SERVICE: Track pickup
     ├─→ INVENTORY_SERVICE: Reserve unit
     └─→ GAMIFICATION_SERVICE: +100 bonus points
```

---

## Compliance & Security Checklist

- [ ] HIPAA compliance for medical data
- [ ] GDPR privacy for donor information
- [ ] Encryption in transit (TLS 1.3)
- [ ] Encryption at rest (AES-256)
- [ ] Field-level access control
- [ ] Audit logs for sensitive operations
- [ ] PII anonymization in non-medical flows
- [ ] Two-factor authentication for admins
- [ ] Circuit breakers for external APIs
- [ ] Database backups (hourly)
- [ ] Disaster recovery plan (RTO: 1 hour)

---

## Deployment Architecture

```
LOAD BALANCER (NGINX)
        ↓
API GATEWAY (Kong/AWS API Gateway)
        ↓
┌───────┴───────┬───────────┬──────────┬──────────┐
│               │           │          │          │
DONOR_MGMT   REQUEST_SVC  INVENTORY  GEOLOCATION NOTIFY
(3 replicas)  (3 replicas) (2 rep)   (2 replicas)(2 rep)
        │               │           │          │
        └───────────────┼───────────┴──────────┘
                        ↓
                 RabbitMQ/Kafka
                 (Event Bus)
                        ↓
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
    PostgreSQL      MongoDB         Redis Cache
    (Primary)     (Notifications)  (Geolocation)
        ↓
    Backup Server
    (Daily full backup)
```

---

## Success Metrics (SLAs)

| Metric | Target | Actual |
|--------|--------|--------|
| System Uptime | 99.9% | - |
| Emergency Request Response Time | <10s | - |
| Donor Acceptance Notification Latency | <5s | - |
| Blood Delivery Completion Time | <45 mins | - |
| API Latency (p95) | <200ms | - |
| Error Rate | <0.1% | - |

---

**This document is version 1.0 and will be updated as development progresses.**

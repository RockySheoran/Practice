# API Gateway Design for LifeFlow

## Overview
The API Gateway serves as the single entry point for all client requests (mobile apps, web portals, admin dashboards). It handles routing, load balancing, rate limiting, and authentication before forwarding requests to microservices.

## Gateway Architecture

```
┌─────────────────────────────────────────────────────────┐
│        Client (Mobile, Web, Admin Dashboard)             │
└─────────────────────────┬───────────────────────────────┘
                          │ HTTPS
                          ▼
┌─────────────────────────────────────────────────────────┐
│            API Gateway (Kong / Spring Cloud)             │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 1. Request Reception & CORS Handling                │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 2. Authentication (JWT Validation)                  │ │
│  │    - Extract JWT from Authorization header         │ │
│  │    - Validate signature, expiry                     │ │
│  │    - Reject if invalid                             │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 3. Rate Limiting                                    │ │
│  │    - 1000 requests/hour per user                    │ │
│  │    - 10,000 requests/hour per API key               │ │
│  │    - 100 requests/minute for emergency API          │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 4. Request Routing                                  │ │
│  │    - Route to appropriate microservice              │ │
│  │    - Load balance across service instances          │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 5. Transformation & Validation                      │ │
│  │    - Validate request payload                       │ │
│  │    - Transform request/response format              │ │
│  │    - Encrypt/decrypt sensitive data                 │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 6. Monitoring & Logging                             │ │
│  │    - Log all requests and responses                 │ │
│  │    - Collect metrics for monitoring                 │ │
│  │    - Trace request across services                  │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 7. Response Aggregation (if needed)                 │ │
│  │    - Combine responses from multiple services       │ │
│  │    - Format response                                │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────┬───────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┬──────────────┐
        │                 │                 │              │
        ▼                 ▼                 ▼              ▼
   ┌────────┐        ┌────────┐       ┌────────┐    ┌────────┐
   │Service1│        │Service2│       │Service3│    │Service4│
   │(Port   │        │(Port   │       │(Port   │    │(Port   │
   │ 8001)  │        │ 8002)  │       │ 8003)  │    │ 8004)  │
   └────────┘        └────────┘       └────────┘    └────────┘
```

## API Gateway Implementation Options

### Option 1: Kong (Recommended for Production)
**Advantages**:
- Enterprise-grade API gateway
- Excellent plugin ecosystem
- High performance and scalability
- Built-in rate limiting, authentication, logging
- Admin dashboard
- Supports Lua scripting for custom logic

**Setup**:
```yaml
Kong Configuration:
- Upstream Services: Point to each microservice
- Routes: /api/v1/donors → Service_2, /api/v1/hospitals → Service_4
- Plugins: JWT Auth, Rate Limiting, CORS, Logging, Request Transformer
- Load Balancing: Round-robin across service instances
```

### Option 2: Spring Cloud Gateway (Better for Microservices Stack)
**Advantages**:
- Native Spring Boot integration
- Lightweight and fast
- Reactive (Netty-based)
- Easy to customize with Java code
- Good for Java-heavy teams

**Setup**:
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: identity-service
          uri: http://localhost:8001
          predicates:
            - Path=/api/v1/auth/**
          filters:
            - JwtAuthenticationFilter
        - id: donor-service
          uri: http://localhost:8002
          predicates:
            - Path=/api/v1/donors/**
        # ... more routes
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods: GET, POST, PUT, DELETE
            allowedHeaders: "*"
```

---

## API Gateway Routes

### Identity & Authentication Routes
```
POST   /api/v1/auth/register              → Create account
POST   /api/v1/auth/login                 → Login with credentials
POST   /api/v1/auth/refresh-token         → Refresh JWT token
POST   /api/v1/auth/logout                → Logout
POST   /api/v1/auth/forgot-password       → Initiate password reset
POST   /api/v1/auth/reset-password        → Complete password reset
POST   /api/v1/auth/enable-2fa            → Enable 2FA
POST   /api/v1/auth/verify-2fa            → Verify 2FA code
GET    /api/v1/auth/kyc-status            → Check KYC verification status
POST   /api/v1/auth/upload-kyc            → Upload KYC documents
GET    /api/v1/users/{id}                 → Get user profile
PUT    /api/v1/users/{id}                 → Update user profile
```

### Donor Routes
```
GET    /api/v1/donors/me                  → Get my donor profile
PUT    /api/v1/donors/me                  → Update my profile
GET    /api/v1/donors/eligibility         → Check my eligibility
GET    /api/v1/donors/donations           → Get my donation history
GET    /api/v1/donors/rewards             → Get my rewards and points
GET    /api/v1/donors/badges              → Get my badges
GET    /api/v1/donors/emergency-requests  → Get nearby emergency requests
POST   /api/v1/donors/requests/{id}/accept → Accept emergency request
POST   /api/v1/donors/requests/{id}/decline → Decline emergency request
GET    /api/v1/donors/leaderboards        → Get leaderboards
GET    /api/v1/donors/impact              → Get vein-to-vein tracking
POST   /api/v1/donors/preferences         → Update notification preferences
```

### Hospital Routes
```
GET    /api/v1/hospitals/me               → Get hospital profile
PUT    /api/v1/hospitals/me               → Update hospital profile
POST   /api/v1/blood-requests             → Create blood request
GET    /api/v1/blood-requests             → Get my requests
GET    /api/v1/blood-requests/{id}        → Get request details
GET    /api/v1/blood-requests/{id}/track  → Real-time tracking
GET    /api/v1/inventory                  → Get blood inventory
GET    /api/v1/donor-search               → Search donors
POST   /api/v1/donor-booking              → Schedule donor pickup
GET    /api/v1/analytics                  → Get hospital analytics
GET    /api/v1/invoices                   → Get billing invoices
```

### Blood Bank Routes
```
GET    /api/v1/blood-banks/me             → Get blood bank profile
GET    /api/v1/inventory/status           → Get inventory status
POST   /api/v1/blood-bags/checkin         → Add new donation
GET    /api/v1/blood-bags                 → List blood bags
GET    /api/v1/blood-bags/{id}            → Get bag details
PUT    /api/v1/blood-bags/{id}/status     → Update bag status
GET    /api/v1/inventory/reports          → Get inventory reports
POST   /api/v1/stock-forecasts            → Request demand forecast
GET    /api/v1/expiry-alerts              → Get expiring bags
```

### Request & Emergency Routes
```
POST   /api/v1/requests                   → Create request
GET    /api/v1/requests/{id}              → Get request details
GET    /api/v1/requests/{id}/status       → Poll for status updates
GET    /api/v1/requests/{id}/alternatives → Get compatible blood types
POST   /api/v1/requests/{id}/match        → Trigger manual matching
PUT    /api/v1/requests/{id}/cancel       → Cancel request
```

### Geolocation Routes
```
POST   /api/v1/locations/report           → Report current location
GET    /api/v1/donors/nearby              → Get nearby donors
GET    /api/v1/distance                   → Calculate distance
GET    /api/v1/tracking/{request_id}      → Get real-time tracking
GET    /api/v1/geofences/{id}             → Get geofence details
```

### Notification Routes
```
GET    /api/v1/notifications              → Get my notifications
PUT    /api/v1/notifications/{id}         → Mark as read
DELETE /api/v1/notifications/{id}         → Delete notification
PUT    /api/v1/notification-preferences   → Update preferences
GET    /api/v1/notification-preferences   → Get my preferences
```

### Camp & Event Routes
```
GET    /api/v1/camps                      → List upcoming camps
GET    /api/v1/camps/{id}                 → Get camp details
POST   /api/v1/camps/{id}/register        → Register for camp
GET    /api/v1/camps/{id}/schedule        → Get available slots
POST   /api/v1/volunteers                 → Register as volunteer
GET    /api/v1/camps/{id}/analytics       → Get camp analytics
```

### Analytics & Gamification Routes
```
GET    /api/v1/analytics/system           → Get system-wide stats
GET    /api/v1/leaderboards               → Get leaderboards
GET    /api/v1/rewards/catalog            → Get reward catalog
POST   /api/v1/rewards/redeem             → Redeem points
GET    /api/v1/donations/impact           → Get donation impact
GET    /api/v1/engagement                 → Get engagement metrics
```

### Admin Routes
```
GET    /api/v1/admin/users                → List all users
PUT    /api/v1/admin/users/{id}           → Update user
DELETE /api/v1/admin/users/{id}           → Delete/suspend user
GET    /api/v1/admin/system-health        → Get system health
GET    /api/v1/admin/audit-logs           → Get audit logs
GET    /api/v1/admin/settings             → Get system settings
PUT    /api/v1/admin/settings             → Update settings
```

---

## Request/Response Format

### Standard Request Format
```json
{
  "apiVersion": "v1",
  "requestId": "uuid-string",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    // Request payload
  }
}
```

### Standard Response Format
```json
{
  "apiVersion": "v1",
  "requestId": "uuid-string",
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 200,
  "success": true,
  "data": {
    // Response payload
  },
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "totalPages": 5,
      "totalRecords": 100
    }
  }
}
```

### Error Response Format
```json
{
  "apiVersion": "v1",
  "requestId": "uuid-string",
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 400,
  "success": false,
  "error": {
    "code": "INVALID_BLOOD_TYPE",
    "message": "Blood type must be one of: A+, A-, B+, B-, O+, O-, AB+, AB-",
    "details": [
      {
        "field": "blood_type",
        "message": "Invalid value provided"
      }
    ]
  }
}
```

---

## Authentication & Authorization

### JWT Token Structure
```
Header: {
  "alg": "HS256",
  "typ": "JWT"
}

Payload: {
  "sub": "user_id",
  "email": "user@example.com",
  "roles": ["DONOR", "VOLUNTEER"],
  "permissions": ["DONATE", "VIEW_REQUESTS"],
  "iat": 1642252800,
  "exp": 1642339200,
  "iss": "LifeFlow"
}
```

### Authorization Levels
```
1. Anonymous: No token required
   - List camps
   - Public information

2. Authenticated: Valid JWT required
   - Donor: View own donations, accept requests
   - Hospital: Create blood requests
   - Blood Bank: Manage inventory

3. Role-Based: Specific roles required
   - ROLE_DONOR: Donation endpoints
   - ROLE_HOSPITAL: Hospital endpoints
   - ROLE_BLOOD_BANK_MANAGER: Inventory endpoints
   - ROLE_ADMIN: Administrative endpoints

4. Scope-Based: Specific permissions required
   - blood_requests:create
   - blood_requests:read
   - donors:search
   - inventory:write
```

---

## Rate Limiting Strategy

### Tier 1: Public APIs
- **Limit**: 100 requests/minute
- **Apply to**: Camp list, general information

### Tier 2: Authenticated Users (Donors)
- **Limit**: 1000 requests/hour
- **Apply to**: Donor profile, donation history

### Tier 3: Authenticated Users (Hospitals)
- **Limit**: 5000 requests/hour
- **Apply to**: Blood requests, inventory checks

### Tier 4: Emergency APIs
- **Limit**: No limit (bypass rate limiting)
- **Apply to**: Emergency request creation, tracking

### Tier 5: Admin APIs
- **Limit**: 10,000 requests/hour
- **Apply to**: Administrative operations

---

## Monitoring & Logging

### Metrics to Collect
- Request count per endpoint
- Response time (p50, p95, p99)
- Error rate (5xx, 4xx)
- Requests per user
- Service availability

### Logging Strategy
- **INFO**: Successful requests
- **WARN**: Rate limit exceeded, retry attempts
- **ERROR**: Failed requests, exceptions
- **DEBUG**: Full request/response body (for development only)

### Log Format
```
[timestamp] [correlation_id] [service] [level] [message]
2024-01-15T10:30:00.123Z uuid-123 donor-service INFO GET /api/v1/donors/me - 200 - 45ms
```

---

## Circuit Breaker Pattern

### Implementation
```
Service State Transitions:
CLOSED (Normal) → OPEN (Failing) → HALF_OPEN (Recovery) → CLOSED

Trigger Open: 5 consecutive failures or 50% failure rate
Duration: 30 seconds
Half-Open: Allow 1 request to test if service recovered
```

### Fallback Strategies
```
- Identity Service down: Reject new requests, allow cached sessions
- Inventory Service down: Suggest alternative blood types manually
- Notification Service down: Queue for retry, log for manual follow-up
- Geolocation Service down: Disable distance filtering, show all donors
```


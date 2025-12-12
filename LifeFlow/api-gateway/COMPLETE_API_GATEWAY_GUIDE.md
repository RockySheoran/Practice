# API Gateway - Complete Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [How API Gateway Works](#how-api-gateway-works)
4. [Routing Configuration](#routing-configuration)
5. [Inter-Service Communication](#inter-service-communication)
6. [Shared Entities & DTOs](#shared-entities--dtos)
7. [Event-Driven Architecture](#event-driven-architecture)
8. [Circuit Breaker Pattern](#circuit-breaker-pattern)
9. [Authentication & Authorization](#authentication--authorization)
10. [Rate Limiting](#rate-limiting)
11. [Code Examples](#code-examples)
12. [Troubleshooting](#troubleshooting)

---

## Overview

The API Gateway is the **single entry point** for all client requests in the LifeFlow system. It acts as:

- **Router**: Directs requests to appropriate microservices
- **Authenticator**: Validates JWT tokens before allowing access
- **Rate Limiter**: Prevents abuse with request throttling
- **Circuit Breaker**: Protects against cascading failures
- **Transformer**: Modifies requests/responses as needed
- **Aggregator**: Can combine responses from multiple services

### Key Technologies
- **Framework**: Spring Cloud Gateway
- **Resilience**: Resilience4j (Circuit Breaker, Retry, Time Limiter)
- **Caching**: Redis
- **Messaging**: RabbitMQ
- **Authentication**: JWT (JSON Web Tokens)

---

## Architecture

```
┌─────────────┐
│   Clients   │ (Mobile, Web, Desktop)
└──────┬──────┘
       │ (HTTP/REST)
       ▼
┌──────────────────────────────────────┐
│    API Gateway (Port 8000)           │
│                                      │
│  ┌───────────────────────────────┐  │
│  │ Authentication Filter (JWT)   │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌───────────────────────────────┐  │
│  │ Rate Limiter (Redis)          │  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌───────────────────────────────┐  │
│  │ Circuit Breaker (Resilience4j)│  │
│  └───────────────────────────────┘  │
│                                      │
│  ┌───────────────────────────────┐  │
│  │ Request Router                │  │
│  └───────────────────────────────┘  │
└────────┬─────┬─────┬──────┬──────┬──────────┘
         │     │     │      │      │
    ┌────▼──┐ ┌─▼────┐ ┌──▼─┐ ┌──▼──┐ ┌───▼────┐
    │ Auth  │ │Donor │ │Inv │ │Req  │ │Geoloc  │
    │ 8001  │ │8002  │ │8003│ │8004 │ │8005    │
    └───────┘ └──────┘ └────┘ └─────┘ └────────┘
    ┌───────────────┬─────────────────┬────────────┐
    │ Notification  │ Camp Service    │ Analytics  │
    │ 8006          │ 8007            │ 8008       │
    └───────────────┴─────────────────┴────────────┘
         │
         ▼
    ┌──────────────┐
    │  RabbitMQ    │ (Event Bus)
    │  (Events)    │
    └──────────────┘
         │
         ▼
    ┌──────────────┐
    │   Redis      │ (Cache)
    │  (Live Data) │
    └──────────────┘
```

---

## How API Gateway Works

### Request Flow (Step-by-Step)

1. **Client sends request**
   ```
   POST /api/v1/blood-requests
   Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
   ```

2. **Gateway receives request at Port 8000**
   - Identifies the request path

3. **JWT Authentication Filter**
   - Extracts token from `Authorization: Bearer <token>`
   - Validates token signature and expiration
   - Extracts user information (ID, role, type)
   - Adds headers to request:
     ```
     X-User-Id: user-123
     X-User-Role: donor
     X-User-Type: donor
     X-Forwarded-Token: <original-token>
     ```

4. **Rate Limiter (Redis)**
   - Checks if user has exceeded request limit
   - Returns 429 (Too Many Requests) if limit exceeded
   - Otherwise, allows request to proceed

5. **Request Router**
   - Matches route based on path and method
   - Applies route-specific filters
   - Example: `/api/v1/blood-requests` → `request-service:8004`

6. **Circuit Breaker Check**
   - Checks if destination service is healthy
   - If circuit is OPEN (service down), return cached response or fallback
   - If HALF-OPEN, allow limited requests to test recovery
   - If CLOSED (healthy), forward request

7. **Forward to Microservice**
   - HTTP call to: `http://request-service:8004/blood-requests`
   - Passes all headers including user info

8. **Microservice processes request**
   - Uses X-User-Id, X-User-Role for authorization
   - Executes business logic
   - Returns response

9. **Response returned to Gateway**
   - Gateway receives response from microservice

10. **Response sent to Client**
    - Gateway sends response to client with status code

### Failure Handling

If microservice fails:

```
Circuit Breaker in OPEN state
    ↓
Return fallback response (cached data)
    ↓
Try again after 30 seconds
    ↓
If service recovers: Circuit closes, normal operation resumes
If service still down: Stay open, use fallback data
```

---

## Routing Configuration

### Route Definition Example

```java
.route("donor-service", r -> r
    .path("/api/v1/donors/**")                          // Match path
    .filters(f -> f
        .stripPrefix(2)                                 // Remove /api/v1
        .filter(new JwtAuthenticationFilter())          // Validate JWT
        .requestRateLimiter(config -> config
            .setRateLimiter(new RedisRateLimiter(100, 200))))
    .uri("http://donor-service:8002"))                  // Destination
```

### All Routes

| Client Path | Destination Service | Port | Auth Required |
|-------------|-------------------|------|----------------|
| `/api/v1/auth/register` | Identity Service | 8001 | No |
| `/api/v1/auth/login` | Identity Service | 8001 | No |
| `/api/v1/users/**` | Identity Service | 8001 | Yes |
| `/api/v1/donors/**` | Donor Service | 8002 | Yes |
| `/api/v1/eligibility/**` | Donor Service | 8002 | Yes |
| `/api/v1/inventory/**` | Inventory Service | 8003 | Yes |
| `/api/v1/blood-bags/**` | Inventory Service | 8003 | Yes |
| `/api/v1/blood-requests` | Request Service | 8004 | Yes |
| `/api/v1/tracking/**` | Geolocation Service | 8005 | Yes |
| `/api/v1/distance/**` | Geolocation Service | 8005 | Yes |
| `/api/v1/notifications/**` | Notification Service | 8006 | Yes |
| `/api/v1/camps/**` | Camp Service | 8007 | Yes |
| `/api/v1/analytics/**` | Analytics Service | 8008 | Yes |
| `/api/v1/rewards/**` | Analytics Service | 8008 | Yes |

---

## Inter-Service Communication

### Two Types of Communication

#### 1. Synchronous (REST) - Real-time data needed

**When to use:**
- Check blood inventory before fulfilling request
- Get donor eligibility status
- Calculate distance between locations
- Validate user role/permissions

**Example: Request Service checks Inventory**

```java
// In Request Service
@Service
public class BloodRequestService {
    
    @Autowired
    private ServiceToServiceClient client;
    
    public void createBloodRequest(BloodRequestDTO request) {
        // SYNC CALL: Check if blood is available RIGHT NOW
        BloodStockResponse stock = client.checkBloodStock(request.getBloodType());
        
        if (!stock.getAvailable()) {
            throw new BloodNotAvailableException("Blood type " + request.getBloodType() + " out of stock");
        }
        
        // Reserve the blood
        ReservationResponse reserved = client.reserveBlood(
            requestId,
            request.getBloodType(),
            request.getQuantity()
        );
        
        // Continue processing...
    }
}
```

**Implementation:**
```java
// ServiceToServiceClient (in api-gateway or any service)
public BloodStockResponse checkBloodStock(String bloodType) {
    String url = INVENTORY_SERVICE_URL + "/api/internal/inventory/check-stock?bloodType=" + bloodType;
    ResponseEntity<BloodStockResponse> response = restTemplate.exchange(
        url,
        HttpMethod.GET,
        createServiceHeaders(),
        BloodStockResponse.class
    );
    return response.getBody();
}
```

#### 2. Asynchronous (RabbitMQ) - State changes/notifications

**When to use:**
- Blood has been donated (notify analytics, notification service)
- Donation completed (send confirmation)
- Request fulfilled (notify hospital, donor)
- Stock running low (alert blood bank)

**Example: Donor Service publishes donation event**

```java
// In Donor Service when donation is recorded
@Service
public class DonationService {
    
    @Autowired
    private EventPublisher eventPublisher;
    
    public void recordDonation(String donorId, String bloodType, Integer units) {
        // ... save donation to database ...
        
        // ASYNC: Publish event
        eventPublisher.publishBloodDonated(
            donorId,
            bloodType,
            units,
            bloodBankId
        );
        
        // Return immediately - don't wait for other services to react
        return;
    }
}
```

**Other services listen:**
```java
// In Analytics Service - listens for blood.donated events
@Component
@RabbitListener(queues = "analytics.blood-donated")
public class DonationEventListener {
    
    public void onBloodDonated(EventPublisher.BloodDonatedEvent event) {
        // Update donor statistics
        updateDonorDonationCount(event.getDonorId());
        // Update inventory projections
        updateInventoryForecasts(event.getBloodType());
        // Award reward points
        awardRewardPoints(event.getDonorId(), 50);
    }
}
```

### Service-to-Service Communication Flow

```
Request Service (Port 8004)
    ├─ Sync Call (REST)
    │  └─ GET http://inventory-service:8003/api/internal/inventory/check-stock
    │     └─ Response: { availableUnits: 50, available: true }
    │
    └─ Async Call (RabbitMQ)
       └─ Publish: event.blood.requested
          ├─ Consumed by: Inventory Service
          ├─ Consumed by: Notification Service  
          ├─ Consumed by: Analytics Service
          └─ Consumed by: Geolocation Service
```

---

## Shared Entities & DTOs

### Critical Entities Shared Between Services

#### 1. **User Entity** (shared across ALL services)

```java
@Data
public class UserDTO {
    private String userId;           // UUID
    private String email;
    private String username;
    private String role;             // admin, donor, hospital, bank
    private String userType;
    private LocalDateTime createdAt;
    private LocalDateTime lastLogin;
    private Boolean active;
}
```

**Shared by:**
- Identity Service (owns)
- Donor Service (references user_id)
- Notification Service (sends to user)
- Analytics Service (tracks user activity)

#### 2. **Donor Entity** (Donor Service)

```java
@Data
public class DonorDTO {
    private String donorId;
    private String userId;           // ← Shared reference
    private String firstName;
    private String lastName;
    private String bloodType;
    private LocalDate dateOfBirth;
    private String gender;
    private String phone;
    private String email;
    private Double weight;
    private Boolean eligible;
    private LocalDateTime lastDonationDate;
}
```

**Referenced by:**
- Request Service (to match donors)
- Camp Service (register donors)
- Analytics Service (track donors)

#### 3. **Blood Inventory Entity** (Inventory Service)

```java
@Data
public class BloodBagDTO {
    private String bagId;
    private String bloodType;       // A+, B-, O+, AB-
    private String bloodBankId;     // ← Which bank has it
    private LocalDateTime collectedDate;
    private LocalDateTime expiryDate;
    private String status;          // AVAILABLE, RESERVED, IN_USE, EXPIRED
    private Integer quantity;
    private String location;        // Which fridge/location
}
```

**Referenced by:**
- Request Service (to reserve bags)
- Geolocation Service (calculate transport)
- Notification Service (alert about expiry)
- Analytics Service (track inventory)

#### 4. **Blood Request Entity** (Request Service)

```java
@Data
public class BloodRequestDTO {
    private String requestId;
    private String bloodType;
    private Integer unitsNeeded;
    private String hospitalId;
    private String patientName;
    private LocalDateTime requestDate;
    private String urgency;         // ROUTINE, URGENT, EMERGENCY
    private String status;          // PENDING, MATCHED, FULFILLED, CANCELLED
    private LocalDateTime targetDeliveryTime;
}
```

**Referenced by:**
- Inventory Service (to reserve stock)
- Geolocation Service (calculate routes)
- Notification Service (notify about status)
- Analytics Service (track requests)

#### 5. **Transport/Logistics Entity** (Geolocation Service)

```java
@Data
public class TransportDTO {
    private String transportId;
    private String requestId;       // ← From Request Service
    private String vehicleId;
    private String driverName;
    private Double currentLat;
    private Double currentLon;
    private String destination;
    private LocalDateTime startTime;
    private LocalDateTime estimatedArrival;
    private String status;          // IN_TRANSIT, DELIVERED
}
```

**Referenced by:**
- Request Service (link transport to request)
- Notification Service (send location updates)

#### 6. **Notification Template Entity** (Notification Service)

```java
@Data
public class NotificationDTO {
    private String notificationId;
    private String userId;          // ← From Identity Service
    private String type;            // SMS, EMAIL, PUSH, WHATSAPP
    private String subject;
    private String message;
    private String status;          // PENDING, SENT, FAILED
    private LocalDateTime sentAt;
}
```

### Entity Reference Diagram

```
Identity Service (USER)
    ↑
    ├─ Donor Service (DONOR → USER_ID)
    ├─ Notification Service (NOTIFICATION → USER_ID)
    └─ Analytics Service (ANALYTICS → USER_ID)

Donor Service (DONOR)
    ↑
    ├─ Request Service (REQUEST → DONOR_ID for matching)
    ├─ Camp Service (CAMP_REGISTRATION → DONOR_ID)
    └─ Analytics Service (REWARDS → DONOR_ID)

Inventory Service (BLOOD_BAG)
    ↑
    ├─ Request Service (RESERVATION → BLOOD_BAG_ID)
    └─ Geolocation Service (TRANSPORT → BLOOD_BAG_ID)

Request Service (BLOOD_REQUEST)
    ↑
    ├─ Geolocation Service (ROUTE → REQUEST_ID)
    └─ Notification Service (ALERTS → REQUEST_ID)
```

---

## Event-Driven Architecture

### Event Types

#### User Events
```
USER_REGISTERED
├─ Published by: Identity Service
├─ Consumed by: Donor Service, Notification Service
└─ Payload:
    {
      "eventId": "uuid",
      "userId": "user-123",
      "email": "john@example.com",
      "userType": "donor",
      "timestamp": "2024-01-15T10:30:00"
    }
```

#### Donation Events
```
BLOOD_DONATED
├─ Published by: Donor Service
├─ Consumed by: Inventory Service, Analytics Service, Notification Service
└─ Payload:
    {
      "eventId": "uuid",
      "donorId": "donor-456",
      "bloodType": "O+",
      "units": 450,
      "bloodBankId": "bank-789",
      "donationDate": "2024-01-15",
      "timestamp": "2024-01-15T10:30:00"
    }
```

#### Request Events
```
BLOOD_REQUESTED
├─ Published by: Request Service
├─ Consumed by: Inventory Service, Geolocation Service, Notification Service
└─ Payload:
    {
      "eventId": "uuid",
      "requestId": "req-111",
      "bloodType": "AB-",
      "units": 2,
      "hospitalId": "hosp-222",
      "isEmergency": false,
      "timestamp": "2024-01-15T14:00:00"
    }

EMERGENCY_REQUEST (HIGH PRIORITY)
├─ Published by: Request Service
├─ Consumed by: ALL SERVICES - requires immediate action
└─ Payload:
    {
      "eventId": "uuid",
      "requestId": "req-222",
      "bloodType": "O+",
      "units": 5,
      "hospitalId": "hosp-333",
      "patientName": "John Doe",
      "isEmergency": true,
      "priority": "CRITICAL",
      "timestamp": "2024-01-15T14:05:00"
    }
```

#### Inventory Events
```
BLOOD_RESERVED / BLOOD_RELEASED
├─ Published by: Inventory Service or Request Service
├─ Consumed by: Inventory Service (to update counters)
└─ Payload: { bloodBagId, requestId, reservedAt/releasedAt }

STOCK_LOW
├─ Published by: Inventory Service
├─ Consumed by: Notification Service, Analytics Service
└─ Payload: { bloodType, remainingUnits, bloodBankId }

BLOOD_EXPIRED
├─ Published by: Inventory Service
├─ Consumed by: Notification Service
└─ Payload: { bloodBagId, bloodType, bloodBankId }
```

### RabbitMQ Topic Exchange Setup

```yaml
spring:
  rabbitmq:
    host: rabbitmq
    port: 5672

# Topics (Routing Keys)
event.user.registered
event.blood.donated
event.blood.requested
event.emergency.request        # ← HIGH PRIORITY
event.blood.reserved
event.stock.low
event.transport.started
event.camp.completed
...
```

---

## Circuit Breaker Pattern

### Why We Need Circuit Breakers

**Problem:** If Inventory Service is down, Request Service keeps sending requests to it

```
Request Service
    ├─ Call 1: Inventory Service DOWN → Timeout (5 sec)
    ├─ Call 2: Inventory Service DOWN → Timeout (5 sec)
    ├─ Call 3: Inventory Service DOWN → Timeout (5 sec)
    └─ User waits 15+ seconds for failure
```

**Solution:** Circuit Breaker

```
Request Service
    ├─ Call 1-3: Inventory Service DOWN → Opens circuit
    └─ Call 4+: Fast Fail! (immediately return error)
       
After 30 seconds:
    ├─ Test call: Does Inventory Service work now?
    └─ If YES: Circuit closes, normal operation
    └─ If NO: Circuit stays open
```

### Circuit Breaker States

```
CLOSED (Normal Operation)
    ├─ Requests pass through
    ├─ Track failures
    └─ If 5+ failures in 100 calls → Open

OPEN (Service Down)
    ├─ Fast fail - don't send requests
    ├─ Return fallback response
    ├─ After 30 seconds → Half-Open

HALF_OPEN (Testing Recovery)
    ├─ Allow 3 test calls
    ├─ If all succeed → CLOSED
    └─ If any fails → OPEN
```

### Configuration Example

```java
CircuitBreaker inventoryServiceCB = CircuitBreaker.of("inventory-service", 
    CircuitBreakerConfig.custom()
        .failureRateThreshold(50.0f)              // Open if 50%+ calls fail
        .slowCallRateThreshold(50.0f)             // Open if 50%+ calls are slow
        .slowCallDurationThreshold(Duration.ofSeconds(2))  // Calls > 2sec = slow
        .waitDurationInOpenState(Duration.ofSeconds(30))   // Try again after 30sec
        .permittedNumberOfCallsInHalfOpenState(3)          // Test with 3 calls
        .slidingWindowSize(100)                   // Track last 100 calls
        .build());
```

### Usage in Code

```java
// In ServiceToServiceClient
public BloodStockResponse checkBloodStock(String bloodType) {
    try {
        // Circuit breaker will either:
        // 1. Allow request to go through (CLOSED)
        // 2. Fast fail immediately (OPEN)
        // 3. Test request (HALF_OPEN)
        
        ResponseEntity<BloodStockResponse> response = Decorators.ofSupplier(
            () -> restTemplate.exchange(url, HttpMethod.GET, headers, BloodStockResponse.class)
        )
        .withCircuitBreaker(inventoryServiceCB)
        .withFallback(fallbackStock)
        .execute();
        
        return response.getBody();
    } catch (CircuitBreakerOpenException e) {
        // Service is down - return cached/fallback data
        log.warn("Inventory Service circuit open, using fallback");
        return getCachedStock(bloodType);
    }
}

// Fallback function
private BloodStockResponse getCachedStock(String bloodType) {
    // Return last known good value from Redis cache
    return redisCache.getBloodStock(bloodType);
}
```

---

## Authentication & Authorization

### JWT Token Flow

1. **User Login**
```
Client
    ├─ POST /api/v1/auth/login
    ├─ Body: { email, password }
    └─ API Gateway
        └─ Forward to Identity Service (8001)
            ├─ Validate credentials
            ├─ Create JWT token
            └─ Return token

Response:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "user-123",
  "role": "donor",
  "userType": "donor",
  "expiresIn": 86400
}
```

2. **Include Token in Requests**
```
Client stores token in localStorage/sessionStorage

Subsequent requests:
GET /api/v1/donors/profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

3. **Gateway Validates Token**
```java
@Component
public class JwtAuthenticationFilter {
    
    public GatewayFilter apply(Config config) {
        return ((exchange, chain) -> {
            // Extract token from "Bearer <token>"
            String token = exchange.getRequest()
                .getHeaders()
                .getFirst(HttpHeaders.AUTHORIZATION)
                .substring(7);
            
            // Validate token
            Claims claims = jwtUtil.validateToken(token);
            
            // Extract user info
            String userId = claims.getSubject();
            String role = claims.get("role", String.class);
            
            // Add to request headers for downstream service
            exchange.getRequest().mutate()
                .header("X-User-Id", userId)
                .header("X-User-Role", role)
                .build();
            
            return chain.filter(exchange);
        });
    }
}
```

4. **Microservice Checks Headers**
```java
@RestController
@RequestMapping("/api/v1/donors")
public class DonorController {
    
    @GetMapping("/profile")
    public DonorDTO getProfile(
        @RequestHeader("X-User-Id") String userId,
        @RequestHeader("X-User-Role") String role
    ) {
        // Authorization: Only donors can see their own profile
        if (!"donor".equals(role)) {
            throw new UnauthorizedException("Only donors can access this endpoint");
        }
        
        return donorService.getProfile(userId);
    }
}
```

### Token Structure

```
JWT = Header.Payload.Signature

Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "sub": "user-123",           // Subject (userId)
  "email": "john@example.com",
  "role": "donor",
  "userType": "donor",
  "iat": 1674817800,           // Issued at
  "exp": 1674904200            // Expires at (24 hours later)
}

Signature: HMAC(Base64(Header) + "." + Base64(Payload), SECRET_KEY)
```

---

## Rate Limiting

### Using Redis Rate Limiter

**Why:**
- Prevent abuse
- Ensure fair resource usage
- Protect against DDoS attacks

**Configuration:**

```yaml
# Per service in application.yml
- id: donor-service
  filters:
    - name: RequestRateLimiter
      args:
        redis-rate-limiter.replenish-rate: 100    # 100 requests per second
        redis-rate-limiter.burst-capacity: 200    # Allow burst up to 200
```

**How it works:**
```
Bucket: [200 tokens]

Request comes in:
    ├─ Use 1 token
    ├─ Tokens left: 199
    └─ Request allowed

After 1 second:
    ├─ Replenish 100 tokens
    ├─ Tokens now: 199 + 100 = 299
    └─ Cap at 200 (burst capacity)
    └─ Tokens: 200

If tokens run out:
    ├─ Request rejected
    └─ Return: 429 Too Many Requests
```

**Different limits per service:**

| Service | Rate | Reason |
|---------|------|--------|
| Donor Service | 100 req/sec | Normal usage |
| Inventory Service | 100 req/sec | Critical path |
| Geolocation | 100 req/sec | Maps API calls are expensive |
| Notification | 1000 req/sec | Batch operations |
| Leaderboards | 1000 req/sec | Public read-heavy endpoint |
| Blood Requests | 50 req/sec | Emergency requests - no limit |

---

## Code Examples

### Example 1: Create Blood Request (Sync + Async)

```java
// API Gateway receives request
POST /api/v1/blood-requests
Authorization: Bearer <token>
{
  "bloodType": "O+",
  "unitsNeeded": 3,
  "hospitalId": "hosp-123",
  "patientName": "John Doe",
  "urgency": "EMERGENCY"
}

// Request Service handles it
@Service
public class BloodRequestService {
    
    @Autowired
    private ServiceToServiceClient client;
    @Autowired
    private EventPublisher eventPublisher;
    
    public BloodRequestDTO createRequest(BloodRequestDTO request) {
        String requestId = UUID.randomUUID().toString();
        
        // 1. SYNC: Check inventory in real-time
        BloodStockResponse stock = client.checkBloodStock(request.getBloodType());
        
        if (stock.getAvailableUnits() < request.getUnitsNeeded()) {
            // 2. ASYNC: Publish event that blood needed
            eventPublisher.publishBloodRequested(
                requestId,
                request.getBloodType(),
                request.getUnitsNeeded(),
                request.getHospitalId()
            );
            
            // Store request in database with PENDING status
            BloodRequest saved = repository.save(new BloodRequest(requestId, request));
            return saved.toDTO();
        }
        
        // 3. SYNC: Reserve blood
        ReservationResponse reserved = client.reserveBlood(
            requestId,
            request.getBloodType(),
            request.getUnitsNeeded()
        );
        
        // 4. SYNC: Find nearby blood banks and transport
        DistanceResponse distance = client.calculateDistance(
            request.getHospitalId(),
            reserved.getBloodBankId()
        );
        
        // 5. ASYNC: Publish request fulfilled event
        eventPublisher.publishBloodRequestFulfilled(
            requestId,
            reserved.getReservationId(),
            request.getUnitsNeeded()
        );
        
        // 6. ASYNC: Publish transport started event
        eventPublisher.publishTransportStarted(
            transportId,
            requestId,
            vehicleId
        );
        
        BloodRequest saved = repository.save(new BloodRequest(requestId, request));
        return saved.toDTO();
    }
}
```

### Example 2: Event Listener (Async)

```java
// Notification Service listens for all events
@Component
public class EventListeners {
    
    @Autowired
    private NotificationService notificationService;
    
    // Listen for blood requests
    @RabbitListener(queues = "notification.blood-requested")
    public void onBloodRequested(EventPublisher.BloodRequestedEvent event) {
        // Send notification to nearby donors
        notificationService.notifyNearbyDonors(
            event.getBloodType(),
            "Blood needed at hospital: " + event.getHospitalId()
        );
    }
    
    // Listen for emergency requests (highest priority)
    @RabbitListener(queues = "notification.emergency-request")
    public void onEmergencyRequest(EventPublisher.EmergencyRequestEvent event) {
        // Send SMS to available donors
        notificationService.sendSMSAlert(
            event.getBloodType(),
            "EMERGENCY: Blood needed for " + event.getPatientName()
        );
        
        // Send push notification
        notificationService.sendPushNotification(
            event.getBloodType(),
            "Critical blood request"
        );
    }
    
    // Listen for donations
    @RabbitListener(queues = "notification.blood-donated")
    public void onBloodDonated(EventPublisher.BloodDonatedEvent event) {
        // Thank you email to donor
        notificationService.sendThankYouEmail(event.getDonorId());
    }
}
```

### Example 3: Fallback/Caching

```java
@Component
public class ServiceToServiceClient {
    
    @Autowired
    private RedisTemplate<String, Object> redis;
    
    public DonorEligibilityResponse checkDonorEligibility(String donorId) {
        try {
            // Try to get from service
            ResponseEntity<DonorEligibilityResponse> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                DonorEligibilityResponse.class
            );
            
            // Cache the response for 1 hour
            redis.opsForValue().set(
                "donor-eligibility:" + donorId,
                response.getBody(),
                Duration.ofHours(1)
            );
            
            return response.getBody();
            
        } catch (Exception e) {
            log.warn("Donor Service unavailable, using cached data");
            
            // Return cached data if service is down
            Object cached = redis.opsForValue().get("donor-eligibility:" + donorId);
            if (cached != null) {
                return (DonorEligibilityResponse) cached;
            }
            
            // If no cache, return safe default
            return new DonorEligibilityResponse(donorId, false, "Service unavailable");
        }
    }
}
```

---

## Troubleshooting

### Issue 1: 401 Unauthorized

**Problem:** "Invalid or expired token"

**Solution:**
1. Check token is in format: `Authorization: Bearer <token>`
2. Verify token is not expired: `exp` claim should be in future
3. Regenerate token by logging in again
4. Check `jwt.secret` in `application.yml` matches Identity Service

### Issue 2: 429 Too Many Requests

**Problem:** "Rate limit exceeded"

**Solution:**
1. Wait a few seconds before retrying
2. Check if you're in a loop making too many requests
3. Increase rate limit in `application.yml` if needed
4. Use exponential backoff with retries

### Issue 3: Service Connection Failed

**Problem:** "Connection refused to http://inventory-service:8003"

**Solution:**
1. Check if all services are running: `docker-compose ps`
2. Check service name matches docker-compose: `inventory-service` or `inventory`?
3. Check network: services must be on same Docker network
4. Check port: default is 8003 for inventory

### Issue 4: Circuit Breaker Open

**Problem:** "Circuit breaker for inventory-service is open"

**Solution:**
1. Check logs for why service failed
2. Wait 30 seconds for circuit to half-open
3. Fix underlying service issue
4. Once fixed, circuit will close automatically
5. Monitoring dashboard: `http://localhost:8000/actuator/circuitbreakers`

### Issue 5: Request Timeout

**Problem:** "Request took more than 5 seconds"

**Solution:**
1. Check if service is slow (check logs)
2. Increase timeout in `ResilienceConfig` (default 5 seconds)
3. Optimize database queries
4. Scale service horizontally

---

## Summary

### Key Takeaways

✅ **API Gateway is the single entry point**
- All requests go through port 8000
- Routes to appropriate microservice
- Validates authentication

✅ **Two types of inter-service communication**
- **Sync (REST):** Use when you need immediate answer
- **Async (RabbitMQ):** Use for state changes/notifications

✅ **Services share entities via DTOs**
- Define shared structure
- Use strong typing (not strings)
- Version your DTOs

✅ **Resilience is critical**
- Circuit breakers prevent cascading failures
- Retries with exponential backoff
- Fallback to cached data

✅ **Security at every level**
- JWT tokens validate all requests
- Headers contain user info
- Microservices verify authorization

### Next Steps

1. **Deploy services:** `docker-compose up`
2. **Test endpoints:** Use Postman/Curl
3. **Monitor health:** Check `/actuator/health`
4. **View logs:** `docker logs api-gateway`
5. **Scale if needed:** Add more instances behind load balancer

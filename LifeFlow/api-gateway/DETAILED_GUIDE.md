# LifeFlow API Gateway - Complete Architecture & Implementation Guide

## Table of Contents
1. [API Gateway Overview](#api-gateway-overview)
2. [How API Gateway Works](#how-api-gateway-works)
3. [Important Entities Shared Between Services](#important-entities-shared-between-services)
4. [Inter-Service Communication Patterns](#inter-service-communication-patterns)
5. [Implementation Best Practices](#implementation-best-practices)
6. [Code Examples](#code-examples)

---

## API Gateway Overview

### What is an API Gateway?

An API Gateway is a server that acts as a **single entry point** for all client requests. It sits between clients (mobile apps, web apps, admin dashboards) and the backend microservices.

```
┌─────────────────────────────────────────────────────┐
│           Client Applications                        │
│  ├─ Donor Mobile App                                │
│  ├─ Hospital Web Portal                             │
│  ├─ Blood Bank Dashboard                            │
│  └─ Admin Management System                         │
└──────────────────────┬──────────────────────────────┘
                       │ HTTPS
                       ▼
        ┌──────────────────────────────┐
        │     API GATEWAY (Port 8000)   │
        ├──────────────────────────────┤
        │ ✓ Request Routing            │
        │ ✓ Authentication             │
        │ ✓ Rate Limiting              │
        │ ✓ Transformation             │
        │ ✓ Logging & Monitoring       │
        │ ✓ Load Balancing             │
        └──────────────┬───────────────┘
                       │
        ┌──────────────┴──────────────┬──────────────┬──────────────┐
        │                             │              │              │
        ▼                             ▼              ▼              ▼
    ┌────────────┐            ┌────────────┐  ┌────────────┐  ┌────────────┐
    │ Identity   │            │   Donor    │  │ Inventory  │  │  Request   │
    │ Service    │            │  Service   │  │  Service   │  │  Service   │
    │ (8001)     │            │  (8002)    │  │  (8003)    │  │  (8004)    │
    └────────────┘            └────────────┘  └────────────┘  └────────────┘
        ▼                             ▼              ▼              ▼
    ┌────────────┐            ┌────────────┐  ┌────────────┐  ┌────────────┐
    │  Database  │            │  Database  │  │  Database  │  │  Database  │
    └────────────┘            └────────────┘  └────────────┘  └────────────┘
```

### Why Do We Need an API Gateway?

| Problem | Solution |
|---------|----------|
| Multiple services with different ports | Single entry point (8000) |
| Client doesn't know service locations | Gateway handles routing |
| No authentication on each service | Centralized JWT validation |
| Inconsistent rate limiting | Gateway enforces limits |
| No visibility into requests | Centralized logging |
| Services overloaded | Load balancing |
| Service down = error | Graceful fallback (circuit breaker) |

---

## How API Gateway Works

### Request Flow (Step by Step)

```
STEP 1: CLIENT REQUEST
┌─────────────────────────────────────────┐
│ POST /api/v1/auth/login                 │
│ Body: {email, password}                 │
│ Header: Content-Type: application/json  │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 2: API GATEWAY RECEIVES REQUEST
┌─────────────────────────────────────────┐
│ 1. Extract request headers              │
│ 2. Generate correlation ID              │
│ 3. Log incoming request                 │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 3: VALIDATION FILTERS
┌─────────────────────────────────────────┐
│ ✓ CORS Check: Origin allowed?           │
│ ✓ Content-Type: Valid format?           │
│ ✓ Payload: Not too large?               │
│ ✓ Rate Limit: Under limit?              │
└─────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
    VALID                INVALID
        │                   │
        ▼                   ▼
   CONTINUE          Return 429/400
                     (rate limited/error)
                  │
                  ▼
STEP 4: AUTHENTICATION (if required)
┌─────────────────────────────────────────┐
│ Check Authorization header:             │
│ "Authorization: Bearer {JWT}"           │
│                                         │
│ Verify JWT:                             │
│ ✓ Signature valid?                      │
│ ✓ Token not expired?                    │
│ ✓ User not blocked?                     │
│ Extract: user_id, roles, permissions    │
└─────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
      VALID              INVALID
        │                   │
        ▼                   ▼
   CONTINUE          Return 401/403
                     (unauthorized)
                  │
                  ▼
STEP 5: REQUEST ROUTING
┌─────────────────────────────────────────┐
│ Path: /api/v1/auth/login                │
│ → Route to: identity-service (8001)     │
│                                         │
│ Path: /api/v1/donors/me                 │
│ → Route to: donor-service (8002)        │
│                                         │
│ Path: /api/v1/blood-requests            │
│ → Route to: request-service (8004)      │
│                                         │
│ Load balance across instances           │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 6: REQUEST TRANSFORMATION
┌─────────────────────────────────────────┐
│ Add headers:                            │
│ ├─ X-User-Id: extracted from JWT       │
│ ├─ X-Correlation-Id: unique ID         │
│ ├─ X-Service-Name: api-gateway         │
│ └─ X-Request-Time: timestamp           │
│                                         │
│ Optionally modify body                  │
│ (e.g., inject user context)             │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 7: FORWARD TO MICROSERVICE
┌─────────────────────────────────────────┐
│ Forward request to:                     │
│ http://identity-service:8001/api/v1/auth/login
│                                         │
│ Measure response time                   │
│ Handle timeouts (< 30 seconds)          │
│ Catch service unavailable errors        │
└─────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
    SUCCESS              FAILURE
        │                   │
        ▼                   ▼
   Got Response      Check Circuit Breaker
                     │
                ┌────┴────┐
                │         │
            OPEN      CLOSED
            (fail)   (retry)
                  │
                  ▼
STEP 8: RESPONSE PROCESSING
┌─────────────────────────────────────────┐
│ 1. Receive response from service        │
│ 2. Extract response headers             │
│ 3. Mask sensitive data (passwords, etc) │
│ 4. Add gateway headers                  │
│ 5. Measure total time                   │
│ 6. Log response metrics                 │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 9: RESPONSE SENT TO CLIENT
┌─────────────────────────────────────────┐
│ HTTP/1.1 200 OK                         │
│ Content-Type: application/json          │
│ X-Correlation-Id: uuid-123              │
│ X-Response-Time: 145ms                  │
│                                         │
│ Body: {token, user_id, roles}           │
└─────────────────────────────────────────┘
                  │
                  ▼
STEP 10: LOGGING & MONITORING
┌─────────────────────────────────────────┐
│ Record:                                 │
│ ├─ Endpoint: /api/v1/auth/login        │
│ ├─ Method: POST                         │
│ ├─ Status: 200                          │
│ ├─ Response Time: 145ms                 │
│ ├─ User Id: donor_123                   │
│ ├─ Request Size: 256 bytes              │
│ ├─ Response Size: 512 bytes             │
│ └─ Timestamp: 2024-01-15T10:30:00Z      │
│                                         │
│ Update metrics:                         │
│ ├─ request_count{endpoint="/auth"}      │
│ ├─ response_time_ms{endpoint="/auth"}   │
│ └─ error_rate{endpoint="/auth"}         │
└─────────────────────────────────────────┘
```

---

## Important Entities Shared Between Services

### Core Shared Entities (Referenced by All Services)

#### 1. **USER_ID** (UUID)
Most important shared identifier across all services.

**Who shares it:**
- Identity Service: Owns and manages users
- All other services: Reference it for operations

```
Identity Service Database:
┌─ users table
│  └─ user_id: UUID (PK)
│  └─ email: String
│  └─ roles: Array[Role]

Donor Service Database:
┌─ donors table
│  └─ donor_id: UUID (PK)
│  └─ user_id: UUID (FK - reference to Identity Service)

Request Service Database:
┌─ blood_requests table
│  └─ request_id: UUID (PK)
│  └─ hospital_id: VARCHAR (actually user_id)
│  └─ created_by: VARCHAR (actually user_id)

Notification Service Database:
┌─ notifications table
│  └─ recipient_id: VARCHAR (actually user_id)
```

**Event synchronization:**
```
Identity Service publishes:
EVENT_USER_REGISTERED {
  user_id: UUID,
  email: String,
  user_type: ENUM (DONOR, HOSPITAL, BLOOD_BANK, ADMIN),
  roles: Array[String],
  created_at: Timestamp
}

All services listen and cache/store:
├─ user_id → user_type mapping
├─ user_id → roles mapping
└─ user_id → basic profile
```

#### 2. **BLOOD_TYPE** (ENUM)
```
Shared in all services:
A_PLUS, A_MINUS, B_PLUS, B_MINUS, O_PLUS, O_MINUS, AB_PLUS, AB_MINUS

Donor Service:
├─ donor profile: blood_type
└─ donation_records: blood_type_verified

Inventory Service:
├─ blood_bags: blood_type
├─ inventory: blood_type → stock count
└─ compatibility matrix: (donor_type → recipient_type)

Request Service:
├─ blood_requests: patient_blood_type
└─ request_alternatives: compatible types

Analytics Service:
├─ leaderboards: by blood_type
└─ predictions: demand by blood_type
```

#### 3. **REQUEST_ID** (UUID)
Ties multiple services together for a single blood request.

```
Request Service (Owner):
┌─ blood_requests
│  └─ request_id: UUID (PK)
│  └─ hospital_id: UUID
│  └─ status: ENUM (PENDING, MATCHING, MATCHED, etc)

Inventory Service (Listens):
┌─ When EVENT_BLOOD_REQUEST_CREATED received
│  └─ Reserves blood bags for request_id
│  └─ Publishes EVENT_BLOOD_RESERVED {request_id, bag_ids}

Geolocation Service (Listens):
┌─ When EVENT_BLOOD_MATCHED received
│  └─ Creates tracking session for request_id
│  └─ Monitors delivery progress

Notification Service (Listens):
┌─ Sends notifications for request_id status changes
│  ├─ To hospital: "Blood found"
│  ├─ To donor: "Request matched"
│  └─ To driver: "Pickup ready"

Analytics Service (Listens):
┌─ Records metrics for request_id
│  ├─ Fulfillment time
│  ├─ Donor response time
│  └─ Hospital satisfaction
```

#### 4. **BLOOD_BAG_ID** (UUID)
Physical blood unit tracked across services.

```
Inventory Service (Owner):
┌─ blood_bags
│  ├─ bag_id: UUID
│  ├─ barcode_number: String (for scanning)
│  ├─ blood_type: ENUM
│  ├─ expiry_date: Date
│  ├─ status: ENUM
│  └─ donor_id: UUID (reference to Donor Service)

Request Service (Listens):
┌─ request_fulfillment
│  └─ blood_bag_id: UUID
│  └─ request_id: UUID (links bags to requests)

Geolocation Service (Listens):
┌─ live_tracking_sessions
│  └─ blood_bag_id: UUID (tracks delivery)

Notification Service (Listens):
┌─ Notifies when bag_id is:
│  ├─ Picked up
│  ├─ In transit
│  └─ Delivered

Analytics Service (Listens):
┌─ donation_impact_tracking
│  └─ bag_id → final patient outcome
```

#### 5. **DONOR_ID** (UUID)
All donor-specific operations.

```
Donor Service (Owner):
┌─ donors
│  ├─ donor_id: UUID (PK)
│  ├─ user_id: UUID (from Identity Service)
│  ├─ blood_type: ENUM
│  ├─ eligibility_status: ENUM
│  └─ total_donations: Integer

Inventory Service (Listens):
┌─ blood_bags
│  └─ donor_id: UUID (tracks which donor gave blood)

Request Service (Listens):
┌─ matching_records
│  ├─ request_id: UUID
│  └─ donor_id: UUID (matched donor for request)

Geolocation Service (Listens):
┌─ donor_locations
│  └─ donor_id: UUID (real-time GPS location)

Notification Service (Listens):
┌─ Sends notifications to donor_id

Analytics Service (Listens):
┌─ donor_rewards: donor_id
├─ donor_badges: donor_id
├─ engagement_metrics: donor_id
└─ leaderboards: donor_id
```

#### 6. **HOSPITAL_ID** (UUID)
Hospital-specific operations.

```
Request Service (Primary User):
┌─ blood_requests
│  ├─ request_id: UUID
│  └─ hospital_id: UUID (who made request)

Geolocation Service (Listens):
┌─ geo_fences
│  ├─ geofence_id: UUID
│  └─ entity_id: hospital_id (5km radius)

Inventory Service (Listens):
┌─ hospitals can check stock levels

Analytics Service (Listens):
┌─ hospital_metrics
│  └─ hospital_id: UUID
│  └─ request_fulfillment_rate
│  └─ average_fulfillment_time
```

---

## Inter-Service Communication Patterns

### Pattern 1: Synchronous REST Call (Service-to-Service)

Used when you need immediate response.

**When to use:**
- Authentication validation
- Real-time data fetch
- Critical operations requiring immediate confirmation

**Example: Request Service needs Donor eligibility**

```
Request Service Code:
─────────────────────

@Service
public class RequestService {
    
    private final RestTemplate restTemplate;
    
    public boolean isDonorEligible(String donorId) {
        try {
            // Call Donor Service synchronously
            ResponseEntity<DonorResponse> response = restTemplate.exchange(
                "http://donor-service:8002/api/v1/donors/{id}/eligibility",
                HttpMethod.GET,
                new HttpEntity<>(createHeaders()),
                DonorResponse.class,
                donorId
            );
            
            return response.getBody().isEligible();
        } catch (RestClientException e) {
            // Service unavailable - use fallback or circuit breaker
            log.error("Donor service unavailable", e);
            throw new ServiceUnavailableException("Cannot verify donor eligibility");
        }
    }
    
    private HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + getServiceToken());
        headers.set("X-Service-Name", "request-service");
        headers.set("X-Correlation-Id", UUID.randomUUID().toString());
        return headers;
    }
}
```

**Pros:**
- Immediate response
- Simple to understand
- Good for critical operations

**Cons:**
- Tight coupling between services
- Service down = caller fails
- Slower than async

### Pattern 2: Asynchronous Event Publishing (Event-Driven)

Most important pattern for LifeFlow microservices.

**When to use:**
- Notifications
- Analytics updates
- Non-critical background tasks
- When services don't need immediate response

**Example: Donation completed**

```
DONOR SERVICE - Blood donation completed
────────────────────────────────────────

@Service
public class DonationService {
    
    private final DonationRepository donationRepo;
    private final RabbitTemplate rabbitTemplate;
    private final EventPublisher eventPublisher;
    
    @Transactional
    public void recordDonation(Donation donation) {
        // 1. Save to local database
        Donation saved = donationRepo.save(donation);
        
        // 2. Publish event to message broker
        DonationEvent event = DonationEvent.builder()
            .donationId(saved.getId())
            .donorId(saved.getDonorId())
            .bloodType(saved.getBloodType())
            .unitsCollected(saved.getUnitsCollected())
            .donationDate(saved.getDonationDate())
            .eventTimestamp(Instant.now())
            .build();
        
        eventPublisher.publish("donation-events", event);
    }
}


INVENTORY SERVICE - Listening for donations
──────────────────────────────────────────

@Component
public class DonationEventListener {
    
    private final InventoryService inventoryService;
    
    @RabbitListener(queues = "donation-events-queue")
    public void onDonationCompleted(DonationEvent event) {
        try {
            log.info("Received donation event: {}", event.getDonationId());
            
            // Add blood to inventory
            inventoryService.addBloodToInventory(
                event.getBloodType(),
                event.getUnitsCollected(),
                event.getDonationId()
            );
            
            log.info("Inventory updated for donation: {}", event.getDonationId());
        } catch (Exception e) {
            log.error("Error processing donation event", e);
            // Send to dead letter queue for manual review
            throw new AmqpRejectAndDontRequeueException("Processing failed", e);
        }
    }
}


ANALYTICS SERVICE - Listening for donations
───────────────────────────────────────────

@Component
public class AnalyticsEventListener {
    
    private final AnalyticsRepository analyticsRepo;
    
    @RabbitListener(queues = "donation-analytics-queue")
    public void recordDonationMetrics(DonationEvent event) {
        // Record metrics asynchronously
        AnalyticsRecord record = AnalyticsRecord.builder()
            .donorId(event.getDonorId())
            .donationDate(event.getDonationDate())
            .unitsCollected(event.getUnitsCollected())
            .build();
        
        analyticsRepo.save(record);
        
        // Trigger badge checks asynchronously
        awardBadgesIfEarned(event.getDonorId());
    }
}


NOTIFICATION SERVICE - Listening for donations
──────────────────────────────────────────────

@Component
public class DonationNotificationListener {
    
    private final NotificationService notificationService;
    
    @RabbitListener(queues = "donation-notification-queue")
    public void sendDonationThankYou(DonationEvent event) {
        // Send SMS to donor
        notificationService.sendSMS(
            event.getDonorId(),
            "Thank you for donating " + event.getUnitsCollected() + 
            " units of " + event.getBloodType() + " blood!"
        );
        
        // Send email with impact tracking link
        notificationService.sendEmail(
            event.getDonorId(),
            "donation-thank-you",
            Map.of(
                "units", event.getUnitsCollected(),
                "bloodType", event.getBloodType(),
                "trackingUrl", generateTrackingUrl(event.getDonationId())
            )
        );
    }
}


COMPLETE FLOW:
──────────────

Donor Service     Inventory Service    Analytics Service    Notification Service
      │                 │                     │                    │
      │                 │                     │                    │
   Donation             │                     │                    │
   recorded         Queue Message        Queue Message         Queue Message
      │                 │                     │                    │
      └─ Publishes EVENT_DONATION_COMPLETED
           │             │                     │                    │
           ├────────────→│ Updates stock      │                    │
           │             │ Stores in DB       │                    │
           │             │                    │                    │
           ├────────────────────────────────→│ Records stats      │
           │                                  │ Awards points     │
           │                                  │ Updates metrics    │
           │                                  │                    │
           ├────────────────────────────────────────────────────→│
           │                                                       │ Sends SMS
           │                                                       │ Sends Email
           │                                                       │ Updates DB
           │                                                       │
           │←──────────────────────────────────────────────────────│
           │
      Process Complete
     (Donor sees thank you)
```

**Pros:**
- Loose coupling
- Service failure doesn't cascade
- Highly scalable
- Asynchronous performance

**Cons:**
- Slightly delayed updates
- Harder to debug
- Need message broker

### Pattern 3: Event Sourcing with Saga Pattern

For distributed transactions.

**Example: Blood Request Fulfillment (Multi-step process)**

```
Emergency blood request requires multiple services to coordinate:

REQUEST SERVICE          INVENTORY SERVICE       GEOLOCATION SERVICE
      │                        │                        │
      │ 1. Create Request      │                        │
      │────────────────────────→ Receive EVENT          │
      │                         │ Check if stock exists │
      │                         │                       │
      │ 2. Stock Available?     │                       │
      │←────────────────────────│ Publish EVENT         │
      │                        
      │ 3. Match Donor          │                       │
      │────────────────────────→ Reserve Blood Bag      │
      │                         │ Publish EVENT         │
      │
      │ 4. Assign Transport     │                       │
      │─────────────────────────────────────────────────→ Create Tracking
      │                         │                       │
      │                         │                       │ Publish EVENT
      │                         │                       │
      │ 5. Delivery Confirmed   │←──────────────────────│
      │←────────────────────────────────────────────────│


SAGA PATTERN (Choreography):
──────────────────────────

Each service listens and acts independently:

Step 1: Request Service creates request
        Publishes: EVENT_BLOOD_REQUEST_CREATED
        
Step 2: Inventory Service listens
        If stock exists:
            Reserves blood bag
            Publishes: EVENT_BLOOD_RESERVED
        Else:
            Publishes: EVENT_STOCK_NOT_AVAILABLE
            
Step 3: Request Service listens
        If EVENT_BLOOD_RESERVED:
            Publishes: EVENT_READY_TO_MATCH_DONOR
        If EVENT_STOCK_NOT_AVAILABLE:
            Publishes: EVENT_TRIGGERING_EMERGENCY_DONOR_CALL
            
Step 4: Geolocation Service listens
        If EVENT_READY_TO_MATCH_DONOR:
            Finds nearby eligible donors
            Publishes: EVENT_DONORS_IDENTIFIED
        If EVENT_TRIGGERING_EMERGENCY_DONOR_CALL:
            Triggers geo-fenced emergency alert
            
Step 5: Notification Service listens
        Sends notifications to identified donors
        
Step 6: Request Service listens
        When donor accepts:
            Publishes: EVENT_DONOR_ACCEPTED
            
Step 7: Geolocation Service listens
        Arranges transport
        Starts real-time tracking
        
Step 8: Inventory Service listens
        Updates bag status to IN_TRANSIT
        
Step 9: Geolocation Service publishes
        EVENT_BLOOD_DELIVERED
        
Step 10: Request Service listens
         Updates request status to DELIVERED
         Publishes: EVENT_REQUEST_FULFILLED


COMPENSATION (If something fails):
─────────────────────────────────

If blood delivery fails:

Geolocation Service publishes:
  EVENT_DELIVERY_FAILED
  
Inventory Service listens:
  Unreserves blood bag
  Makes it available again
  
Request Service listens:
  Resets to PENDING
  Triggers retry or alternative
```

---

## Implementation Best Practices

### 1. Use Correlation IDs for Tracing

Every request gets a unique ID to track across services.

```java
@Component
public class CorrelationIdFilter extends OncePerRequestFilter {
    
    private static final String CORRELATION_ID_HEADER = "X-Correlation-Id";
    private static final String CORRELATION_ID_LOG_VAR_NAME = "correlationId";
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain) {
        
        // Extract or create correlation ID
        String correlationId = request.getHeader(CORRELATION_ID_HEADER);
        if (correlationId == null) {
            correlationId = UUID.randomUUID().toString();
        }
        
        // Store in MDC for logging
        MDC.put(CORRELATION_ID_LOG_VAR_NAME, correlationId);
        
        // Add to response header
        response.addHeader(CORRELATION_ID_HEADER, correlationId);
        
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove(CORRELATION_ID_LOG_VAR_NAME);
        }
    }
}

// Logging output will include correlationId in all logs
2024-01-15 10:30:00 [uuid-123] DonorService: Processing donation
2024-01-15 10:30:01 [uuid-123] InventoryService: Adding to stock
2024-01-15 10:30:02 [uuid-123] NotificationService: Sending SMS
// All have same correlation ID!
```

### 2. Service-to-Service Authentication

Services should authenticate to each other.

```java
@Component
public class ServiceAuthConfig {
    
    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
            .interceptors((request, body, execution) -> {
                // Add service-level auth
                request.getHeaders().set("X-Service-Auth", 
                    generateServiceToken());
                request.getHeaders().set("X-Service-Name", 
                    "donor-service");
                return execution.execute(request, body);
            })
            .build();
    }
    
    private String generateServiceToken() {
        // Create service-to-service JWT
        return Jwts.builder()
            .setSubject("donor-service")
            .setIssuedAt(new Date())
            .setExpiration(addMinutes(new Date(), 5))
            .signWith(SignatureAlgorithm.HS256, serviceSecret)
            .compact();
    }
}
```

### 3. Circuit Breaker Pattern

Prevent cascading failures.

```java
@Service
public class DonorServiceClient {
    
    @CircuitBreaker(
        name = "donor-service",
        fallbackMethod = "getDonorFallback"
    )
    public Donor getDonor(String donorId) {
        return restTemplate.getForObject(
            "http://donor-service:8002/api/v1/donors/{id}",
            Donor.class,
            donorId
        );
    }
    
    // Called when service fails
    public Donor getDonorFallback(String donorId, Exception e) {
        log.warn("Donor service unavailable, using cached data", e);
        
        // Return cached version
        return donorCache.getIfPresent(donorId)
            .orElse(createDummyDonor(donorId));
    }
}

// Configuration
@Bean
public CircuitBreakerRegistry circuitBreakerRegistry() {
    CircuitBreakerConfig config = CircuitBreakerConfig.custom()
        .failureRateThreshold(50)  // Fail if 50% of requests fail
        .waitDurationInOpenState(Duration.ofSeconds(30))  // Wait 30s before retry
        .slowCallRateThreshold(60)  // Fail if 60% are slow (> 2s)
        .build();
    
    return CircuitBreakerRegistry.of(config);
}
```

### 4. Request/Response Wrapping

Standardize all API responses.

```java
// Standard Response Wrapper
@Data
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private ErrorDetails error;
    private long timestamp;
    private String correlationId;
    
    // Constructors
    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.success = true;
        response.data = data;
        response.timestamp = System.currentTimeMillis();
        return response;
    }
    
    public static <T> ApiResponse<T> error(String message, ErrorDetails error) {
        ApiResponse<T> response = new ApiResponse<>();
        response.success = false;
        response.message = message;
        response.error = error;
        response.timestamp = System.currentTimeMillis();
        return response;
    }
}

// Service returns standard response
@RestController
public class DonorController {
    
    @GetMapping("/api/v1/donors/{id}")
    public ResponseEntity<ApiResponse<DonorDto>> getDonor(@PathVariable String id) {
        Donor donor = donorService.getDonor(id);
        return ResponseEntity.ok(
            ApiResponse.success(DonorDto.from(donor))
        );
    }
}
```

### 5. Data Validation & Transformation

Always validate before storing.

```java
// DTOs (Data Transfer Objects)
@Data
@Valid
public class CreateDonationRequest {
    @NotNull(message = "Donor ID required")
    private String donorId;
    
    @NotNull(message = "Blood type required")
    @Pattern(regexp = "^(A|B|O|AB)_[+-]$")
    private String bloodType;
    
    @Min(value = 1, message = "Units must be > 0")
    @Max(value = 2, message = "Units must be <= 2")
    private BigDecimal unitsCollected;
    
    @NotNull(message = "Blood bank required")
    private String bloodBankId;
}

// Service validates
@Service
public class DonationService {
    
    public Donation recordDonation(@Valid CreateDonationRequest request) {
        // 1. Validate request (annotation handles it)
        // 2. Validate business rules
        validateDonorEligible(request.getDonorId());
        validateBloodBankExists(request.getBloodBankId());
        
        // 3. Map DTO to entity
        Donation donation = Donation.builder()
            .donorId(request.getDonorId())
            .bloodType(BloodType.valueOf(request.getBloodType()))
            .unitsCollected(request.getUnitsCollected())
            .donationDate(LocalDate.now())
            .build();
        
        // 4. Save and publish event
        Donation saved = donationRepository.save(donation);
        eventPublisher.publish(new DonationEvent(saved));
        
        return saved;
    }
}
```

---

## Code Examples

### Complete Service-to-Service Communication Example

```java
// ===== SCENARIO: Hospital requests blood =====

// 1. HOSPITAL creates request via API Gateway
POST /api/v1/blood-requests
{
  "blood_type": "O_POSITIVE",
  "quantity": 2,
  "urgency_level": "CRITICAL"
}

// API Gateway routes to Request Service
// Request Service receives and processes:

@Service
public class BloodRequestService {
    
    private final BloodRequestRepository requestRepo;
    private final EventPublisher eventPublisher;
    private final InventoryClient inventoryClient;
    
    @Transactional
    public BloodRequestDto createRequest(CreateRequestDto dto) {
        // 1. Create request in DB
        BloodRequest request = BloodRequest.builder()
            .hospitalId(getCurrentHospitalId())
            .bloodType(BloodType.valueOf(dto.getBloodType()))
            .quantity(dto.getQuantity())
            .urgencyLevel(UrgencyLevel.valueOf(dto.getUrgencyLevel()))
            .status(RequestStatus.PENDING)
            .createdAt(Instant.now())
            .build();
        
        BloodRequest saved = requestRepo.save(request);
        
        // 2. Check inventory synchronously
        try {
            InventoryDto inventory = inventoryClient.checkStock(
                saved.getBloodType()
            );
            
            if (inventory.getAvailableUnits() >= saved.getQuantity()) {
                // Stock available - move to matching phase
                saved.setStatus(RequestStatus.MATCHING);
                requestRepo.save(saved);
                
                // Publish event for async processing
                eventPublisher.publish(
                    new BloodRequestCreatedEvent(saved)
                );
            } else {
                // Insufficient stock - trigger emergency
                saved.setStatus(RequestStatus.EMERGENCY_MODE);
                requestRepo.save(saved);
                
                eventPublisher.publish(
                    new EmergencyBloodNeededEvent(saved)
                );
            }
        } catch (Exception e) {
            log.error("Error checking inventory", e);
            // Continue anyway - use event-driven fallback
            eventPublisher.publish(
                new BloodRequestCreatedEvent(saved)
            );
        }
        
        return BloodRequestDto.from(saved);
    }
}

// 3. INVENTORY SERVICE listens
@Component
public class BloodRequestListener {
    
    private final InventoryService inventoryService;
    private final EventPublisher eventPublisher;
    
    @RabbitListener(queues = "blood-request-queue")
    public void onBloodRequested(BloodRequestCreatedEvent event) {
        BloodRequest request = event.getRequest();
        
        // Try to reserve blood
        try {
            List<BloodBag> reserved = inventoryService.reserveBlood(
                request.getBloodType(),
                request.getQuantity(),
                request.getId()
            );
            
            // Publish success event
            eventPublisher.publish(
                new BloodReservedEvent(request.getId(), reserved)
            );
        } catch (InsufficientStockException e) {
            // Publish failure event
            eventPublisher.publish(
                new BloodReservationFailedEvent(
                    request.getId(),
                    e.getMessage()
                )
            );
        }
    }
}

// 4. REQUEST SERVICE listens to inventory response
@Component
public class InventoryResponseListener {
    
    private final BloodRequestRepository requestRepo;
    private final DonorMatchingService matchingService;
    private final EventPublisher eventPublisher;
    
    @RabbitListener(queues = "inventory-response-queue")
    public void onBloodReserved(BloodReservedEvent event) {
        BloodRequest request = requestRepo.findById(
            event.getRequestId()
        ).orElseThrow();
        
        // Update status
        request.setStatus(RequestStatus.MATCHED);
        request.setMatchedBloodBags(event.getReservedBags());
        requestRepo.save(request);
        
        // Publish event for next step
        eventPublisher.publish(
            new BloodMatchedEvent(request)
        );
    }
    
    @RabbitListener(queues = "inventory-failure-queue")
    public void onBloodReservationFailed(BloodReservationFailedEvent event) {
        BloodRequest request = requestRepo.findById(
            event.getRequestId()
        ).orElseThrow();
        
        // Trigger donor search
        List<EligibleDonor> donors = matchingService.findNearbyDonors(
            request.getBloodType(),
            request.getHospitalId()
        );
        
        request.setStatus(RequestStatus.SEEKING_DONORS);
        requestRepo.save(request);
        
        // Notify donors
        eventPublisher.publish(
            new DonorSearchEvent(request, donors)
        );
    }
}

// 5. GEOLOCATION SERVICE listens
@Component
public class DonorSearchListener {
    
    private final GeolocationService geoService;
    private final NotificationClient notificationClient;
    
    @RabbitListener(queues = "donor-search-queue")
    public void onDonorSearch(DonorSearchEvent event) {
        List<EligibleDonor> donors = event.getDonors();
        
        // Create geofence around hospital
        geoService.createEmergencyGeofence(
            event.getRequest().getHospitalId(),
            donors
        );
        
        // Trigger notifications (async)
        notificationClient.notifyDonors(
            donors,
            "Emergency blood needed in your area!"
        );
    }
}

// 6. NOTIFICATION SERVICE sends alerts
@Service
public class EmergencyNotificationService {
    
    private final SmsService smsService;
    private final PushService pushService;
    
    public void notifyDonors(List<Donor> donors, String message) {
        donors.forEach(donor -> {
            // Send SMS (high priority)
            smsService.sendSMS(
                donor.getPhoneNumber(),
                message + " Reply YES to help. Tap here for more info."
            );
            
            // Send push notification
            pushService.sendPush(
                donor.getDeviceToken(),
                "🔴 EMERGENCY BLOOD NEEDED",
                message,
                createEmergencyDeepLink(donor)
            );
        });
    }
}

// 7. DONOR accepts request via app
// Sends event through API Gateway

// 8. REQUEST SERVICE listens to donor acceptance
// Updates status to DONOR_ACCEPTED
// Publishes event

// 9. GEOLOCATION SERVICE arranges transport
// Publishes event

// 10. INVENTORY SERVICE updates bag status
// Publishes event

// 11. All services listen and update their records
```

---

## Summary: Best Communication Practices

| Need | Pattern | Example |
|------|---------|---------|
| Real-time auth | REST call | Validating JWT token |
| Check availability | REST call | Check blood stock |
| Update related data | Event Published | Donation recorded → update inventory |
| Non-critical notifications | Event queue | Send SMS/Email |
| Complex workflows | Saga pattern | Multi-step blood request |
| Cross-service queries | Cache + REST | Donor profile lookup |
| Failure handling | Circuit breaker | Service down → cached data |

---

**This architecture ensures:**
✅ **Scalability**: Services scale independently
✅ **Reliability**: Failure isolation via events
✅ **Maintainability**: Clear service boundaries
✅ **Observability**: Correlation IDs trace requests
✅ **Performance**: Async operations don't block
✅ **Decoupling**: Services don't depend on each other

# API Gateway - Visual Diagrams & Flows

## 1. Complete System Architecture

```
                           ┌─────────────────────┐
                           │   Client Apps       │
                           │  (Mobile/Web/Desktop)
                           └──────────┬──────────┘
                                      │
                          HTTP/REST (Port 8000)
                                      │
                      ┌───────────────▼───────────────┐
                      │     API GATEWAY               │
                      │   (Spring Cloud Gateway)      │
                      │                               │
                      │  ┌─────────────────────────┐  │
                      │  │ Request Processing      │  │
                      │  │ 1. JWT Validation       │  │
                      │  │ 2. Rate Limiting        │  │
                      │  │ 3. Circuit Breaker      │  │
                      │  │ 4. Route Matching       │  │
                      │  └─────────────────────────┘  │
                      └──────────┬──────────────────┬──┘
                                 │                  │
        ┌────────────────────────┼──────────────────┼────────────────┐
        │                        │                  │                │
    ┌───▼────┐  ┌──────┐  ┌─────▼──┐  ┌──────┐  ┌──▼──┐  ┌───┐  ┌───▼──┐
    │Identity │  │Donor │  │Inventor│  │Request│ │Geol │  │Notif│ │Camp  │
    │Service  │  │8002  │  │Service │  │Service│ │8005 │  │8006 │ │8007  │
    │8001     │  │      │  │8003    │  │8004   │ │     │  │     │ │      │
    └────────┘  └──────┘  └────────┘  └──────┘ └─────┘  └───┘  └──────┘
    
    ┌──────────────────────────────────────────────────────────────────┐
    │ Supporting Infrastructure                                        │
    │                                                                  │
    │ ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────────┐  │
    │ │  Redis   │   │RabbitMQ  │   │PostgreSQL│   │  Analytics  │  │
    │ │  Cache   │   │  Events  │   │  (8 DBs) │   │   Service   │  │
    │ │          │   │          │   │          │   │   8008      │  │
    │ └──────────┘   └──────────┘   └──────────┘   └─────────────┘  │
    │                                                                  │
    └──────────────────────────────────────────────────────────────────┘
```

---

## 2. Request Flow - Step by Step

```
┌─────────────────────────────────────────────────────────────────────┐
│ REQUEST ARRIVES AT GATEWAY (Port 8000)                              │
│ POST /api/v1/blood-requests                                         │
│ Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...      │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 1: JWT AUTHENTICATION FILTER                                   │
│ ├─ Extract token from Authorization header                          │
│ ├─ Validate signature using JWT secret                             │
│ ├─ Check token expiration                                          │
│ ├─ Extract claims: { userId, role, userType }                     │
│ ├─ ADD HEADERS:                                                    │
│ │  ├─ X-User-Id: user-123                                         │
│ │  ├─ X-User-Role: hospital                                       │
│ │  └─ X-User-Type: hospital                                       │
│ └─ If invalid token → RETURN 401 UNAUTHORIZED                      │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 2: RATE LIMITER (Redis)                                        │
│ ├─ Check rate limit for user                                        │
│ ├─ Default: 50 req/sec (blood requests endpoint)                   │
│ ├─ Use token bucket algorithm                                       │
│ └─ If exceeded → RETURN 429 TOO MANY REQUESTS                       │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 3: ROUTE MATCHING                                              │
│ ├─ Match path: /api/v1/blood-requests                              │
│ ├─ Match method: POST                                               │
│ ├─ Find route: request-service                                     │
│ ├─ Check filter: EmergencyPriorityFilter (for emergencies)        │
│ └─ Destination: http://request-service:8004                        │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 4: CIRCUIT BREAKER CHECK (Resilience4j)                        │
│ ├─ Check status of request-service circuit breaker                 │
│ │  ├─ CLOSED: Normal, forward request                              │
│ │  ├─ OPEN: Service down, return fallback                          │
│ │  └─ HALF_OPEN: Test with limited requests                       │
│ └─ If OPEN → Return cached response or error                       │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 5: FORWARD REQUEST WITH TIMEOUT                                │
│ ├─ Add correlation ID header                                        │
│ ├─ Add user info headers (from step 1)                             │
│ ├─ HTTP POST to: http://request-service:8004/blood-requests       │
│ ├─ Set timeout: 5 seconds                                           │
│ └─ Wait for response                                                │
│                                                                     │
│  request-service receives request                                   │
│  ├─ Reads X-User-Id header                                         │
│  ├─ Verifies user is authorized                                    │
│  ├─ Makes SYNC calls to other services:                           │
│  │  ├─ GET /api/internal/inventory/check-stock (wait for response) │
│  │  ├─ GET /api/internal/distance (wait for response)             │
│  │  └─ POST /api/internal/notifications/send (wait for response)  │
│  ├─ Publishes ASYNC events:                                       │
│  │  ├─ event.blood.requested (to RabbitMQ)                        │
│  │  ├─ event.blood.reserved (to RabbitMQ)                         │
│  │  └─ event.transport.started (to RabbitMQ)                      │
│  └─ Returns response                                                │
│                                                                     │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 6: RECEIVE RESPONSE                                            │
│ ├─ Status: 200 OK                                                   │
│ ├─ Body: { requestId, status: "FULFILLED", ... }                  │
│ └─ Headers: X-Correlation-Id, etc.                                │
└────────────┬────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│ STEP 7: RESPONSE TO CLIENT                                          │
│ ├─ Status: 200 OK                                                   │
│ └─ Body: { requestId, status, eta, ... }                           │
│                                                                     │
│ Meanwhile (Async):                                                  │
│ ├─ Inventory Service receives BLOOD_RESERVED event                 │
│ │  └─ Updates stock count in its database                          │
│ ├─ Analytics Service receives multiple events                      │
│ │  └─ Updates dashboards, leaderboards                             │
│ └─ Notification Service receives events                            │
│    └─ Sends SMS/Email to donors and hospital                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Authentication Flow

```
┌──────────────────────────────────────────────────────────────────┐
│ CLIENT APPLICATION                                               │
│                                                                  │
│ PHASE 1: Registration                                            │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ POST /api/v1/auth/register                                 │  │
│ │ {                                                           │  │
│ │   "email": "john@example.com",                            │  │
│ │   "password": "securePass123",                            │  │
│ │   "userType": "donor"                                      │  │
│ │ }                                                           │  │
│ └────────────┬─────────────────────────────────────────────┘  │
└──────────────┼─────────────────────────────────────────────────┘
               │
               │ No JWT needed (public endpoint)
               ▼
        ┌─────────────────────────────────────────┐
        │ API GATEWAY (Port 8000)                 │
        │ ├─ No JWT filter for /auth/register    │
        │ └─ Forward to Identity Service         │
        └─────────────┬───────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────────────┐
        │ Identity Service (Port 8001)            │
        │ ├─ Hash password                        │
        │ ├─ Save user to database                │
        │ ├─ Publish USER_REGISTERED event       │
        │ └─ Return userId                        │
        └─────────────┬───────────────────────────┘
                      │
               ┌──────┴───────┐
               │              │
            Response    Async Events
               │         ┌────┴────┐
               │         │          │
               ▼         ▼          ▼
            Client   Donor Svc  Notification
            {              Service
             "userId": "user-123"
            }
               │
               │ Stores in localStorage
               │

┌──────────────────────────────────────────────────────────────────┐
│ PHASE 2: Login                                                   │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ POST /api/v1/auth/login                                    │  │
│ │ {                                                           │  │
│ │   "email": "john@example.com",                            │  │
│ │   "password": "securePass123"                             │  │
│ │ }                                                           │  │
│ └────────────┬─────────────────────────────────────────────┘  │
└──────────────┼─────────────────────────────────────────────────┘
               │
               │ No JWT needed (public endpoint)
               ▼
        ┌─────────────────────────────────────────┐
        │ API GATEWAY                             │
        │ └─ Forward to Identity Service          │
        └─────────────┬───────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────────────────────┐
        │ Identity Service                                │
        │ ├─ Verify email                                 │
        │ ├─ Hash provided password                       │
        │ ├─ Compare with stored hash                     │
        │ ├─ CREATE JWT TOKEN                             │
        │ │  ├─ Header: { alg: "HS256" }                 │
        │ │  ├─ Payload: {                                │
        │ │  │   sub: "user-123",                         │
        │ │  │   email: "john@...",                       │
        │ │  │   role: "donor",                           │
        │ │  │   iat: 1674817800,                         │
        │ │  │   exp: 1674904200  (24h from now)          │
        │ │  ├─ Signature: HMAC(header.payload, secret)   │
        │ │  └─ Result: eyJhbGciOi...                     │
        │ └─ Return { token, userId, role, ... }          │
        └─────────────┬───────────────────────────────────┘
                      │
               ┌──────┴──────────────────┐
               │                         │
            Response              Publish
               │              LOGIN_SUCCESS
               ▼                  event
            Client
            {
             "token": "eyJhbGciOi...",
             "userId": "user-123",
             "role": "donor",
             "expiresIn": 86400000
            }
            │
            │ Stores token in localStorage
            │

┌──────────────────────────────────────────────────────────────────┐
│ PHASE 3: Subsequent Requests (With JWT)                          │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ GET /api/v1/donors/profile                                │  │
│ │ Authorization: Bearer eyJhbGciOi...                        │  │
│ │                                                            │  │
│ │ (Token from localStorage)                                 │  │
│ └────────────┬───────────────────────────────────────────────┘  │
└──────────────┼───────────────────────────────────────────────────┘
               │
               ▼
        ┌──────────────────────────────────────────────┐
        │ API GATEWAY - JWT Authentication Filter      │
        │                                              │
        │ ┌──────────────────────────────────────────┐ │
        │ │ Extract Token                            │ │
        │ │ "Bearer eyJhbGciOi..." → "eyJhbGciOi..."│ │
        │ └────────────┬─────────────────────────────┘ │
        │              ▼                                 │
        │ ┌──────────────────────────────────────────┐ │
        │ │ Validate Signature                       │ │
        │ │ ├─ Split: header.payload.signature       │ │
        │ │ ├─ Compute HMAC(header.payload, secret)  │ │
        │ │ ├─ Compare with provided signature       │ │
        │ │ └─ If mismatch: 401 UNAUTHORIZED         │ │
        │ └────────────┬─────────────────────────────┘ │
        │              ▼                                 │
        │ ┌──────────────────────────────────────────┐ │
        │ │ Check Expiration                         │ │
        │ │ ├─ Extract "exp" from payload            │ │
        │ │ ├─ Compare with current time             │ │
        │ │ └─ If past: 401 UNAUTHORIZED             │ │
        │ └────────────┬─────────────────────────────┘ │
        │              ▼                                 │
        │ ┌──────────────────────────────────────────┐ │
        │ │ Extract Claims                           │ │
        │ │ sub (userId): "user-123"                 │ │
        │ │ role: "donor"                            │ │
        │ │ email: "john@..."                        │ │
        │ └────────────┬─────────────────────────────┘ │
        │              ▼                                 │
        │ ┌──────────────────────────────────────────┐ │
        │ │ Add Headers to Request                   │ │
        │ │ X-User-Id: user-123                      │ │
        │ │ X-User-Role: donor                       │ │
        │ │ X-User-Type: donor                       │ │
        │ │ X-Forwarded-Token: eyJhbGciOi...       │ │
        │ └────────────┬─────────────────────────────┘ │
        │              ▼                                 │
        │ Forward to Donor Service (Port 8002)          │
        └──────────────┬───────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────────────────────┐
        │ Donor Service (Port 8002)                            │
        │ ├─ Read X-User-Id header: "user-123"               │
        │ ├─ Read X-User-Role header: "donor"                │
        │ ├─ Verify user is authorized to access this data   │
        │ │  └─ Only donors can view their own profile       │
        │ ├─ Query profile from database for user-123        │
        │ └─ Return profile with status 200                  │
        └──────────────┬───────────────────────────────────┘
                       │
                       ▼
        ┌─────────────────────────────────────────┐
        │ API GATEWAY                             │
        │ └─ Return response to client            │
        └─────────────┬───────────────────────────┘
                      │
        ┌─────────────┴──────────────────┐
        │                                │
        ▼                                ▼
    Response                         Token expires in
    { "donorId", "name",            24 hours
      "bloodType", ... }
    
    Client stores in state
    ├─ Display profile
    └─ Token valid until 24h later
```

---

## 4. Circuit Breaker State Diagram

```
                         ┌──────────────────┐
                         │    REQUEST 1-3   │
                         │  All succeed ✓   │
                         └────────┬─────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │                           │
                ┌───┴────────────────────────┐  │
                │      SERVICE HEALTHY       │  │
                │       (CLOSED STATE)       │  │
                │                            │  │
                │ ├─ Requests pass through  │  │
                │ ├─ Failures tracked       │  │
                │ └─ < 50% fail rate        │  │
                │                            │  │
                └───────┬────────────────────┘  │
                        │                       │
                    ┌───▼─────────────────────┐ │
                    │  REQUEST 4-5            │ │
                    │  Both fail ✗            │ │
                    │  + 3 slow calls ⏱       │ │
                    │  = 50%+ failure rate    │ │
                    └────────┬────────────────┘ │
                             │                  │
                ┌────────────▼────────────────┐ │
                │                             │ │
                │      SERVICE FAILING       │ │
                │      (OPEN STATE)          │ │
                │                            │ │
                │ ├─ Fast fail ✓             │ │
                │ ├─ Return cached data      │ │
                │ ├─ Don't bother service    │ │
                │ └─ Wait 30 seconds...      │ │
                │                            │ │
                └────────┬───────────────────┘ │
                         │                     │
          ┌──────────────▼──────────────────┐  │
          │   30 SECOND WAIT               │  │
          │   ========████████░░░░░░ 50%   │  │
          └──────────────┬──────────────────┘  │
                         │                     │
                ┌────────▼───────────────────┐ │
                │                            │ │
                │  RECOVERY TEST             │ │
                │  (HALF-OPEN STATE)         │ │
                │                            │ │
                │ ├─ Allow 3 test requests  │ │
                │ ├─ Observe responses      │ │
                │ └─ What happens next?     │ │
                │                            │ │
                └────┬──────────────┬────────┘ │
                     │              │          │
          ┌──────────▼──┐      ┌────▼────────┐│
          │ All succeed ✓│      │ Any fail ✗  ││
          │             │      │             ││
          │ Back to     │      │ Stay open   ││
          │ CLOSED ✓    │      │ Try again   ││
          │             │      │ in 30 sec   ││
          └─────────────┘      └─────────────┘│
                     │                        │
                     └────────────┬───────────┘
                                  │
                                  │ Continuous cycle
                                  │
                                  ▼
```

---

## 5. Event Flow - Multiple Consumers

```
Donor Service                        Request Service
(Records Donation)                   (Publishes Events)
    │                                    │
    ├─ Save to DB                        │
    │   Donation {                       │
    │     donorId: "donor-123",         │
    │     bloodType: "O+",              │
    │     units: 450,                   │
    │     date: "2024-01-15"            │
    │   }                                │
    │                                    │
    ├─ PUBLISH EVENT ──────────────────────────────┐
    │   event.blood.donated              │        │
    │   {                                │        │
    │     eventId: "evt-123",            │        │
    │     donorId: "donor-123",          │        │
    │     bloodType: "O+",               │        │
    │     units: 450,                    │        │
    │     timestamp: "2024-01-15T10:30"  │        │
    │   }                                │        │
    │                                    │        │
    └────────────────────────────────────▼        │
                                                  │
              ┌───────────────────────────────────┘
              │
              │ RabbitMQ Topic Exchange
              │ routing-key: "event.blood.donated"
              │
              ├──────────┬─────────────┬────────────┐
              │          │             │            │
              ▼          ▼             ▼            ▼
         
         Inventory      Analytics      Notification    Camp
         Queue          Queue          Queue           Queue
         inventory.    analytics.      notification.   camp.
         blood-donated blood-donated   blood-donated   blood-donated
              │            │              │             │
              ▼            ▼              ▼             ▼
         
         @RabbitListener  @RabbitListener @RabbitListener (Optional)
         public void     public void     public void
         onBloodDonated  onBloodDonated  onBloodDonated
         
         Inventory       Analytics       Notification
         Service         Service         Service
              │              │              │
              ├─ Add          ├─ Award       ├─ Send
              │ +450 units    │ 50 points    │ thank you
              │ O+ to         │ to donor     │ email
              │ stock         │              │
              ├─ Update       ├─ Update      ├─ Record
              │ forecasts     │ leaderboards │ delivery
              └─ Publish      └─ Publish     └─ Log
                stock         updated       acknowledgement
                updated       statistics
```

---

## 6. Sync vs Async Comparison

```
┌──────────────────────────────────────┬──────────────────────────────────────┐
│      SYNCHRONOUS (REST)              │    ASYNCHRONOUS (RabbitMQ)          │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ Request Service                      │ Request Service                      │
│ ├─ Call Inventory Service            │ ├─ Publish BLOOD_REQUESTED event    │
│ ├─ Wait for response (blocking)      │ ├─ Return immediately               │
│ ├─ 5 second timeout                  │ └─ Don't wait for response           │
│ │   │                                │                                      │
│ │   ├─ If response: Use data         │ Event published to RabbitMQ        │
│ │   ├─ If timeout: Circuit opens     │ ├─ Inventory Service receives      │
│ │   └─ If error: Fallback            │ │  └─ Updates stock count          │
│ │                                    │ ├─ Notification Service receives    │
│ │ Total time: ~100-500ms             │ │  └─ Sends SMS alerts             │
│ │                                    │ ├─ Analytics Service receives       │
│ │ User waiting: YES (blocks)          │ │  └─ Updates dashboard            │
│ │                                    │ │                                   │
│ │                                    │ Total time: 0ms (fire & forget)     │
│ │                                    │ User waiting: NO (async)            │
│                                      │                                      │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ PROS:                                │ PROS:                                │
│ ✓ Get immediate response             │ ✓ Fast response to user             │
│ ✓ Caller knows if succeeded          │ ✓ Loose coupling                    │
│ ✓ Simple implementation              │ ✓ Easy to scale                     │
│                                      │ ✓ Eventual consistency              │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ CONS:                                │ CONS:                                │
│ ✗ Slower response (wait for answer)  │ ✗ No immediate confirmation         │
│ ✗ Tightly coupled (both must work)   │ ✗ Harder to debug                  │
│ ✗ Cascade failures (if service down) │ ✗ Event ordering issues             │
│                                      │ ✗ Duplicate handling needed         │
├──────────────────────────────────────┼──────────────────────────────────────┤
│ USE WHEN:                            │ USE WHEN:                            │
│ • Need real-time answer              │ • State change notification         │
│ • Caller depends on result           │ • Multiple services affected        │
│ • Data validation needed             │ • Can tolerate delay (seconds)      │
│ • User needs feedback                │ • Fire-and-forget acceptable        │
│                                      │ • Loose coupling preferred          │
└──────────────────────────────────────┴──────────────────────────────────────┘

Example Flow:

Request Service creates blood request

SYNC part:
    ├─ Inventory: Check stock ────────────┐
    │                                     ├─ Wait for answer (sync)
    ├─ Geolocation: Calculate distance ──┤
    │                                     └─ Total: ~200ms
    └─ Notification: Send SMS ───────────┘

ASYNC part (happens later):
    ├─ Event: "blood.requested" published
    └─ Multiple services react independently
       ├─ Inventory: Update forecasts
       ├─ Analytics: Track metrics
       ├─ Camp: Alert nearby camps
       └─ Notification: Send push notifications
```

---

## 7. Rate Limiting - Token Bucket Algorithm

```
BEFORE Request:                   DURING Request:                 AFTER Request:
Bucket capacity: 200              Use 1 token                      Replenish happens
Tokens: 200                       ├─ Request allowed              every 1 second
│░░░░░░░░░░░░░░░░░░│             │░░░░░░░░░░░░░░░░░░│              │
├─ 100 tokens/sec                ├─ Tokens left: 199              ├─ Add 100 tokens
├─ Replenish rate                │                                ├─ Cap at 200
│                                └─ Return 200 OK                │
│                                                                 │░░░░░░░░░░░░░░░░░░│
│                                                                 
1 second later:                    Request 2:                      Request 101:
Tokens: 299 → capped at 200       │░░░░░░░░░░░░░░░░░░│            │░░░░░░░░░░░░░░░░░░│
│░░░░░░░░░░░░░░░░░░│              ├─ Request allowed              ├─ Tokens: 99
├─ Still 200 (max)                └─ 200 OK                        ├─ Need: 1
│                                                                 ├─ Allowed ✓
│                                                                 
Request 200:                       Request 300:
│░░░░░░░░░░░░░░░░░░│              Empty bucket!
├─ Tokens: 1                       ├─ Tokens: 0
├─ Request allowed                ├─ Request blocked!
└─ 200 OK                          └─ 429 Too Many Requests

Wait 30 seconds:
After ~3 seconds of waiting:
│░░░░░░░░░░░░░░░░░░│
├─ Tokens: 300
├─ Capped at: 200
│░░░░░░░░░░░░░░░░░░│
```

---

## 8. Complete Microservice Network

```
                        EXTERNAL WORLD
                             │
                    ┌────────▼────────┐
                    │  Client Apps    │
                    │ (Web/Mobile)    │
                    └────────┬────────┘
                             │ Port 8000
                    ┌────────▼─────────────────────────────────┐
                    │    API GATEWAY (Spring Cloud Gateway)    │
                    │                                          │
                    │  ┌──────────────────────────────────┐   │
                    │  │ Routes & Filters                 │   │
                    │  │ ├─ JWT Authentication          │   │
                    │  │ ├─ Rate Limiting (Redis)       │   │
                    │  │ ├─ Circuit Breaker             │   │
                    │  │ └─ Request Routing             │   │
                    │  └──────────────────────────────────┘   │
                    └────────────────────┬────────────────────┘
        
    INTERNAL DOCKER NETWORK (docker-compose)
        
    ┌──────┬──────┬──────┬───────┬──────┬─────┬──────┬─────┐
    │      │      │      │       │      │     │      │     │
    ▼      ▼      ▼      ▼       ▼      ▼     ▼      ▼     ▼
  
  Auth   Donor   Inv    Req    Geol   Notif Camp  Analy  Shared
  8001   8002   8003   8004   8005   8006  8007  8008   DTOs
  
  All services connected to:
    ├─ PostgreSQL (own database)
    ├─ Redis (cache)
    └─ RabbitMQ (event bus)

   ┌──────────────┬──────────────┬──────────────────┐
   │              │              │                  │
   ▼              ▼              ▼                  ▼
Redis          PostgreSQL    RabbitMQ          External APIs
(Cache)        (8 databases) (Events)          └─ Google Maps
                                               └─ Twilio
                                               └─ SendGrid
                                               └─ Firebase
```

---

## 9. Data Flow - Complete Blood Request

```
TIMELINE: Blood Request Creation to Delivery

T=0.0s: User (Hospital Admin) creates emergency blood request
        POST /api/v1/blood-requests
        Authorization: Bearer <token>
        {
          "bloodType": "AB-",
          "unitsNeeded": 3,
          "urgency": "EMERGENCY",
          "patientName": "John Smith"
        }

T=0.1s: API Gateway
        ├─ [1] Validates JWT token ✓
        ├─ [2] Bypasses rate limiting (emergency)
        ├─ [3] Checks circuit breaker (CLOSED) ✓
        └─ [4] Routes to Request Service:8004

T=0.2s: Request Service receives
        ├─ Creates request record in database
        │  request_id = "req-12345"
        │  status = "PENDING"
        │
        └─ Makes SYNC calls:
           │
           ├─ [5] Sync→ Inventory: Check AB- stock
           │       Response: 5 units available
           │
           ├─ [6] Sync→ Inventory: Reserve 3 units
           │       Response: reservation_id = "res-789"
           │
           ├─ [7] Sync→ Geolocation: Find nearest blood bank
           │       Response: bank-456, distance: 12km, time: 20min
           │
           └─ [8] Sync→ Geolocation: Calculate transport route
                   Response: optimal_route, ETA: 20:45

T=0.5s: Updates request in database
        status = "FULFILLED"

T=0.6s: Publishes ASYNC events to RabbitMQ
        ├─ [9]  event.blood.requested
        ├─ [10] event.blood.reserved
        ├─ [11] event.transport.started
        ├─ [12] event.emergency.request (HIGH PRIORITY)
        └─ [13] Returns 200 OK to user with ETA

        Response: {
          "requestId": "req-12345",
          "status": "FULFILLED",
          "estimatedDelivery": "2024-01-15T20:45:00",
          "transportId": "trans-999"
        }

T=0.7s: [9] Inventory Service receives event
        ├─ Updates blood_inventory
        │  AB- count: 5 → 2
        │  reserved: 3
        ├─ Publishes: stock.updated
        └─ Publishes: transport.started

T=0.8s: [10] Analytics Service receives event
        ├─ Increments emergency request count
        ├─ Records request timestamp
        ├─ Updates request fulfillment time metrics
        └─ Publishes: analytics.updated

T=0.9s: [11] Notification Service receives multiple events
        ├─ For event.blood.requested:
        │  ├─ Send SMS to 100+ nearby donors: "O+ blood needed"
        │  ├─ Send WhatsApp: "Emergency donation request"
        │  └─ Send push notifications
        │
        ├─ For event.emergency.request:
        │  ├─ Alert hospital: "Transport dispatched"
        │  ├─ Alert blood bank: "Prepare AB- for transport"
        │  └─ Alert drivers: "Route ready"
        │
        └─ For event.transport.started:
           ├─ Send SMS to hospital: "ETA 20:45"
           └─ Send app notification: "Blood en route"

T=1.0s: Camp Service (Optional) receives events
        ├─ Check if any camps nearby need AB-
        └─ Alert camp coordinators

T=5.0s: Geolocation Service
        ├─ Publishes: transport.location_update
        │  Lat: 28.5355, Lon: 77.3910
        │  ETA remaining: 18 min
        │
        └─ Notification receives location_update
           └─ Sends live location to hospital app

T=15.0s: Transport arrives 5 minutes early
         ├─ Geolocation publishes: transport.completed
         ├─ Request Service receives
         │  └─ Updates status = "DELIVERED"
         ├─ Inventory publishes: blood.released (from transport)
         ├─ Notification publishes confirmations
         ├─ Analytics records delivery time: 14 min
         └─ All stakeholders notified

FINAL STATE:
├─ Request: DELIVERED
├─ Blood: In hospital (being transfused)
├─ Inventory: 2 units remaining
├─ Hospital: Received blood on time
├─ Blood bank: Replenishment scheduled
└─ All services synchronized via events
```

---

**These diagrams visualize the complete architecture and data flows of the API Gateway system.**

# Inter-Service Communication Guide

## Quick Reference

### When to Use What?

| Scenario | Method | Response Time | Resilience |
|----------|--------|----------------|-----------|
| Check inventory before fulfilling request | **REST (Sync)** | Immediate | Circuit Breaker + Fallback |
| Notify other services of state change | **RabbitMQ (Async)** | Eventual | Event replay from queue |
| Get donor eligibility | **REST (Sync)** | Immediate | Cache fallback |
| Send email/SMS notification | **RabbitMQ (Async)** | Can wait | Retry + DLQ |
| Calculate distance | **REST (Sync)** | Immediate | Use cached/approximate |
| Record analytics data | **RabbitMQ (Async)** | Can wait | Event accumulation |

---

## Pattern 1: Synchronous REST Calls

### Use Case: Real-Time Data Needed Immediately

**Example: Blood Request → Check Inventory**

```
Blood Request Service               Inventory Service
    ├─ Receive request
    ├─ Need to know: Is blood available?
    └─ Call REST API → [  ]
                          │
                          └─ GET /api/internal/inventory/check-stock?bloodType=O+
                             
                             ├─ Query database
                             ├─ Check availability
                             └─ Return { availableUnits: 50, available: true }
                          
                       ← Response back
    
    ├─ If available: Reserve immediately
    ├─ If not: Add to queue or notify
    └─ Continue processing
```

### Implementation

**Step 1: Define the internal API endpoint (Inventory Service)**

```java
@RestController
@RequestMapping("/api/internal/inventory")
public class InventoryInternalController {
    
    /**
     * Internal endpoint - called by other services
     * NOT exposed to clients through API Gateway
     * Uses internal authentication
     */
    @GetMapping("/check-stock")
    public ResponseEntity<BloodStockDTO> checkStock(
        @RequestParam String bloodType
    ) {
        BloodStockDTO stock = inventoryService.getAvailableStock(bloodType);
        
        if (stock == null || stock.getAvailableUnits() <= 0) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new BloodStockDTO(bloodType, 0, null));
        }
        
        return ResponseEntity.ok(stock);
    }
}
```

**Step 2: Call from another service using RestTemplate**

```java
@Service
public class BloodRequestService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Autowired
    private CircuitBreaker inventoryServiceCB;
    
    public void createRequest(BloodRequestDTO request) {
        // Use circuit breaker for resilience
        BloodStockDTO stock = Decorators.ofSupplier(() -> {
            String url = "http://inventory-service:8003/api/internal/inventory/check-stock?bloodType=" + request.getBloodType();
            
            ResponseEntity<BloodStockDTO> response = restTemplate.exchange(
                url,
                HttpMethod.GET,
                createServiceHeaders(),
                BloodStockDTO.class
            );
            
            return response.getBody();
        })
        .withCircuitBreaker(inventoryServiceCB)
        .withFallback(throwable -> getCachedStock(request.getBloodType()))
        .get();
        
        if (stock != null && stock.getAvailableUnits() > 0) {
            // Reserve the blood
            reserveBlood(stock);
        } else {
            // Queue for later fulfillment
            addToWaitlist(request);
        }
    }
    
    private BloodStockDTO getCachedStock(String bloodType) {
        // Return last known value from Redis
        return redisTemplate.opsForValue()
            .get("blood-stock:" + bloodType);
    }
}
```

### Best Practices

✅ **DO:**
- Use timeouts (default 5 seconds)
- Implement circuit breakers
- Cache responses when possible
- Provide fallback values
- Use internal API paths (e.g., `/api/internal/*`)
- Log all external calls with correlation ID

❌ **DON'T:**
- Make synchronous calls in loops
- Call without timeout (can hang forever)
- Ignore failures (always have fallback)
- Call external services synchronously
- Expose internal endpoints through API Gateway

---

## Pattern 2: Asynchronous Event-Driven Communication

### Use Case: State Change That Other Services Should Know About

**Example: Blood Donated → Notify Multiple Services**

```
Donor Service (Donation recorded)
    ├─ Save donation to database
    ├─ Publish "BLOOD_DONATED" event
    └─ Return immediately
    
    Event: {
      eventId: "evt-123",
      donorId: "donor-456",
      bloodType: "O+",
      units: 450,
      timestamp: "2024-01-15T10:30:00"
    }
                │
                └─ Publish to RabbitMQ topic: "event.blood.donated"
                
                ├─ Inventory Service receives
                │  ├─ Update stock count: +450 units O+
                │  └─ Update forecasting model
                
                ├─ Analytics Service receives
                │  ├─ Increment donor's donation count
                │  ├─ Award 50 reward points
                │  └─ Update leaderboards
                
                └─ Notification Service receives
                   ├─ Send thank you email
                   └─ Send SMS confirmation
```

### Implementation

**Step 1: Publish Event (Donor Service)**

```java
@Service
public class DonationService {
    
    @Autowired
    private EventPublisher eventPublisher;
    
    @Transactional
    public void recordDonation(String donorId, String bloodType, Integer units) {
        // 1. Save donation to database
        Donation donation = new Donation();
        donation.setDonorId(donorId);
        donation.setBloodType(bloodType);
        donation.setUnits(units);
        donation.setDonationDate(LocalDateTime.now());
        
        Donation saved = donationRepository.save(donation);
        
        // 2. Publish event (fire and forget)
        eventPublisher.publishBloodDonated(
            donorId,
            bloodType,
            units,
            "blood-bank-123"
        );
        
        // 3. Return to user immediately
        return saved;
    }
}
```

**Step 2: Subscribe to Event (Inventory Service)**

```java
@Component
public class BloodDonatedEventListener {
    
    @Autowired
    private InventoryService inventoryService;
    
    /**
     * Listen on queue that receives blood.donated events
     * Automatically created queue if doesn't exist
     */
    @RabbitListener(queues = "inventory.blood-donated")
    public void onBloodDonated(EventPublisher.BloodDonatedEvent event) {
        try {
            // Add blood to inventory
            inventoryService.addBloodToInventory(
                event.getBloodBankId(),
                event.getBloodType(),
                event.getUnits(),
                event.getDonationDate()
            );
            
            log.info("Inventory updated with {} units of {}", event.getUnits(), event.getBloodType());
        } catch (Exception e) {
            log.error("Error updating inventory from donation event", e);
            // Throw exception to trigger retry
            throw new RuntimeException("Failed to update inventory", e);
        }
    }
}
```

**Step 3: Subscribe to Same Event (Analytics Service)**

```java
@Component
public class DonationAnalyticsListener {
    
    @Autowired
    private AnalyticsService analyticsService;
    
    /**
     * Different service, different queue
     * Both services get the same event
     */
    @RabbitListener(queues = "analytics.blood-donated")
    public void onBloodDonated(EventPublisher.BloodDonatedEvent event) {
        // Update donor stats
        analyticsService.incrementDonationCount(event.getDonorId());
        
        // Award reward points
        analyticsService.awardPoints(event.getDonorId(), 50);
        
        // Update analytics dashboard
        analyticsService.updateDashboard(event.getBloodType(), event.getUnits());
    }
}
```

### Event Queue Configuration

```yaml
# RabbitMQ Configuration
spring:
  rabbitmq:
    host: rabbitmq
    port: 5672
    username: guest
    password: guest

# Define all events/topics
rabbitmq:
  exchange: lifeflow-exchange
  exchange-type: topic
  
  # Events that get published
  events:
    - name: event.user.registered
      durable: true
      ttl: 3600000  # 1 hour
    
    - name: event.blood.donated
      durable: true
      ttl: 86400000  # 24 hours
    
    - name: event.blood.requested
      durable: true
      ttl: 86400000
    
    - name: event.emergency.request
      durable: true
      ttl: 604800000  # 7 days (keep for audit)
  
  # Queues for each service
  queues:
    - name: inventory.blood-donated
      routing-key: event.blood.donated
      durable: true
      dead-letter-exchange: lifeflow-dlx
    
    - name: analytics.blood-donated
      routing-key: event.blood.donated
      durable: true
    
    - name: notification.blood-donated
      routing-key: event.blood.donated
      durable: true
    
    - name: notification.blood-requested
      routing-key: event.blood.requested
      durable: true
```

### Best Practices

✅ **DO:**
- Publish events after database transaction succeeds (use Outbox pattern)
- Have unique queue per service consuming the event
- Use durable queues (survives broker restart)
- Implement idempotent event handlers (handle duplicate events)
- Use correlation IDs to trace events through system
- Set message TTL (Time To Live) appropriately

❌ **DON'T:**
- Publish event before saving to database
- Expect immediate delivery (events are async)
- Have critical business logic depend on event processing
- Forget to handle failures (set up dead-letter queues)
- Create queue per consumer (multiple consumers share queue)

---

## Pattern 3: Request-Reply (Async with Response)

### Use Case: Need Response Eventually, But Async

```
Service A                          Service B
    ├─ Post message to queue       
    └─ Return immediately          
                                   ├─ Consume message
                                   ├─ Process (takes time)
                                   ├─ Post response to callback queue
                                   └─ Done
    
    ├─ Poll callback queue periodically
    ├─ Get response
    └─ Update result
```

**Example: Geolocation Service calculating complex routes**

```java
// Request Service sends route calculation request
@Service
public class BloodRequestService {
    
    @Autowired
    private RabbitTemplate rabbitTemplate;
    
    public void createRequest(BloodRequestDTO request) {
        // 1. Send route calculation request
        RouteRequest routeRequest = new RouteRequest();
        routeRequest.setRequestId(request.getRequestId());
        routeRequest.setFromLocation(request.getDeliveryAddress());
        routeRequest.setToLocation(bloodBank.getAddress());
        routeRequest.setCallbackQueue("request-service.route-response");
        
        rabbitTemplate.convertAndSend(
            "lifeflow-exchange",
            "request.calculate-route",
            routeRequest
        );
        
        // 2. Return immediately (don't wait for result)
        return request.getRequestId();
    }
}

// Geolocation Service processes route request
@Component
public class RouteRequestListener {
    
    @RabbitListener(queues = "geolocation.calculate-route")
    public void onRouteRequest(RouteRequest request) {
        // Calculate complex route (might take 30+ seconds)
        RouteResponse response = calculateOptimalRoute(
            request.getFromLocation(),
            request.getToLocation()
        );
        
        // Send response back to callback queue
        rabbitTemplate.convertAndSend(
            request.getCallbackQueue(),
            response
        );
    }
}

// Request Service receives response later
@Component
public class RouteResponseListener {
    
    @RabbitListener(queues = "request-service.route-response")
    public void onRouteResponse(RouteResponse response) {
        // Update request with route information
        BloodRequest request = requestRepository.findById(response.getRequestId()).orElseThrow();
        request.setOptimalRoute(response.getRoute());
        request.setEstimatedTime(response.getDurationMinutes());
        requestRepository.save(request);
        
        // Publish event that route is ready
        eventPublisher.publishTransportStarted(response.getRequestId());
    }
}
```

---

## Pattern 4: Saga Pattern (Distributed Transactions)

### Use Case: Multi-step process across services

**Example: Fulfill Blood Request**

```
Request Service (Initiator)
    ├─ Step 1: Reserve blood in Inventory Service
    ├─ Step 2: Get route from Geolocation Service  
    ├─ Step 3: Send SMS to hospital via Notification Service
    └─ If ANY step fails: Rollback
```

**Implementation:**

```java
@Service
public class BloodRequestSaga {
    
    @Autowired
    private ServiceToServiceClient client;
    @Autowired
    private EventPublisher eventPublisher;
    
    /**
     * Execute multi-step blood request fulfillment
     * Coordinates across multiple services
     */
    public boolean fulfillBloodRequest(String requestId) {
        BloodRequest request = requestRepository.findById(requestId).orElseThrow();
        
        // Step 1: Reserve blood
        ReservationResponse reservation = client.reserveBlood(
            requestId,
            request.getBloodType(),
            request.getUnitsNeeded()
        );
        
        if (reservation == null || !reservation.getSuccess()) {
            log.warn("Failed to reserve blood for request {}", requestId);
            publishBloodRequestCancelled(requestId, "Blood not available");
            return false;
        }
        
        // Step 2: Calculate route
        try {
            DistanceResponse distance = client.calculateDistance(
                request.getDeliveryAddress(),
                reservation.getBloodBankAddress()
            );
            
            if (distance == null || distance.getDistanceKm() > 500) {
                // Rollback: Release reservation
                client.releaseBlood(reservation.getReservationId());
                publishBloodRequestCancelled(requestId, "Distance too far");
                return false;
            }
        } catch (Exception e) {
            // Rollback: Release reservation
            client.releaseBlood(reservation.getReservationId());
            throw e;
        }
        
        // Step 3: Send notification
        try {
            client.sendNotification(
                request.getRequestingUserId(),
                new NotificationRequest("Blood request confirmed and in transit")
            );
        } catch (Exception e) {
            log.warn("Notification failed but request will proceed", e);
            // Don't rollback for notification failures
        }
        
        // All steps succeeded!
        eventPublisher.publishBloodRequestFulfilled(
            requestId,
            reservation.getReservationId(),
            request.getUnitsNeeded()
        );
        
        return true;
    }
}
```

### Compensation (Rollback)

```java
// If Step 1 fails: Release reservation
client.releaseBlood(reservationId);

// If Step 2 fails: Release reservation + cancel notification
client.releaseBlood(reservationId);
client.sendNotification(userId, "Request cancelled");

// If Step 3 fails: Release reservation + try again later
client.releaseBlood(reservationId);
queueForRetry(requestId);
```

---

## Common Mistakes & How to Avoid Them

### ❌ Mistake 1: Calling Service Without Timeout

```java
// BAD - Can hang forever if service is slow/down
ResponseEntity<BloodStockDTO> response = restTemplate.exchange(url, ...);

// GOOD - Has timeout
RestTemplate restTemplate = new RestTemplate(
    new BufferingClientHttpRequestFactory(
        new HttpComponentsClientHttpRequestFactory()
            .setConnectTimeout(5000)
            .setReadTimeout(5000)
    )
);
```

### ❌ Mistake 2: No Error Handling

```java
// BAD - Will crash if inventory service is down
BloodStockDTO stock = client.checkBloodStock(bloodType);
int available = stock.getAvailableUnits();  // NPE if client returns null

// GOOD - Has fallback
BloodStockDTO stock = client.checkBloodStock(bloodType);
if (stock == null) {
    stock = getCachedStock(bloodType);
}
if (stock == null || stock.getAvailableUnits() <= 0) {
    throw new BloodNotAvailableException();
}
```

### ❌ Mistake 3: Publishing Event Before DB Commit

```java
// BAD - Event published but DB not committed
donationRepository.save(donation);  // Not committed yet
eventPublisher.publishBloodDonated(...);  // Event sent
// If DB rollback happens, event already published

// GOOD - Use Outbox pattern or transaction listener
@TransactionEventListener(phase = TransactionPhase.AFTER_COMMIT)
public void onDonationSaved(DonationSavedEvent event) {
    eventPublisher.publishBloodDonated(...);
}
```

### ❌ Mistake 4: Non-Idempotent Event Handlers

```java
// BAD - If event delivered twice, inventory updated twice
@RabbitListener(queues = "inventory.blood-donated")
public void onBloodDonated(BloodDonatedEvent event) {
    inventory.addUnits(event.getBloodType(), event.getUnits());
    // If this runs twice: +450, then +450 = +900 (wrong!)
}

// GOOD - Idempotent (same operation, same result)
@RabbitListener(queues = "inventory.blood-donated")
public void onBloodDonated(BloodDonatedEvent event) {
    // Check if already processed
    if (processedEventIds.contains(event.getEventId())) {
        return;
    }
    
    inventory.addUnits(event.getBloodType(), event.getUnits());
    processedEventIds.add(event.getEventId());
    
    // Or use database unique constraint
    inventoryRepository.addUnitsIdempotent(
        event.getBloodType(),
        event.getUnits(),
        event.getEventId()  // Unique key
    );
}
```

### ❌ Mistake 5: Synchronous Call in Loop

```java
// BAD - Calls inventory service 10 times in a row
List<String> bloodTypes = Arrays.asList("A+", "B+", "O+", ...);
for (String bloodType : bloodTypes) {
    BloodStockDTO stock = client.checkBloodStock(bloodType);  // 5 sec timeout * 10 = 50 sec!
}

// GOOD - Batch call or use async
@GetMapping("/check-all-stock")
public ResponseEntity<Map<String, BloodStockDTO>> checkAllStock() {
    String url = "http://inventory-service:8003/api/internal/inventory/check-all-stock";
    ResponseEntity<Map<String, BloodStockDTO>> response = restTemplate.exchange(url, ...);
    return response;
}
```

---

## Monitoring & Debugging

### Correlation ID - Trace requests across services

```java
// API Gateway adds correlation ID
exchange.getRequest().mutate()
    .header("X-Correlation-Id", UUID.randomUUID().toString())
    .build();

// Forward to all downstream services
client.checkBloodStock(bloodType, correlationId);

// Each service logs with correlation ID
log.info("[{}] Checking blood stock for {}", correlationId, bloodType);

// View all logs for one request
logs | grep "X-Correlation-Id: abc-123-def"
```

### Circuit Breaker Monitoring

```
GET /actuator/circuitbreakers

{
  "circuitBreakers": [
    {
      "name": "inventory-service",
      "status": "CLOSED",
      "numberOfFailedCalls": 3,
      "numberOfSuccessfulCalls": 97,
      "failureRate": 3.0,
      "slowCallRate": 0.0
    }
  ]
}
```

### Event Monitoring

```
# View queue depths (how many messages waiting)
rabbitmqctl list_queues

# View dead letter queue (failed messages)
docker logs rabbitmq

# Replay failed events
rabbitmqctl purge_queue inventory.blood-donated  # Clear queue
# Manually send events again for reprocessing
```

---

## Summary Checklist

- [ ] REST calls have timeout
- [ ] REST calls have fallback
- [ ] REST calls use circuit breaker
- [ ] Events use routing keys appropriately  
- [ ] Event handlers are idempotent
- [ ] Events published after DB commit
- [ ] Correlation IDs used for tracing
- [ ] Error messages are logged
- [ ] Failed events go to dead letter queue
- [ ] All queue/exchange configuration documented
- [ ] Multiple consumers can listen same event
- [ ] Saga compensation logic implemented for distributed transactions

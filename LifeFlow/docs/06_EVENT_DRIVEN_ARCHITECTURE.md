# Event-Driven Architecture for LifeFlow

## Message Broker Options

### RabbitMQ (Recommended)
- **Reliability**: Persistent queues, acknowledgments
- **Throughput**: ~1 million messages/second
- **Use case**: Most LifeFlow events

### Apache Kafka (Alternative)
- **Throughput**: ~10 million messages/second
- **Data Retention**: Long-term event history
- **Use case**: Analytics, audit trails

---

## Event Categories

### 1. **Authentication Events**
```
EVENT_USER_REGISTERED
├── user_id
├── user_type (DONOR, HOSPITAL, BLOOD_BANK, ADMIN)
├── email
└── timestamp

EVENT_USER_LOGGED_IN
├── user_id
├── login_timestamp
├── ip_address
└── location

EVENT_2FA_ENABLED
├── user_id
├── method
└── timestamp

EVENT_PASSWORD_CHANGED
├── user_id
└── timestamp
```

### 2. **Donor Events**
```
EVENT_DONOR_PROFILE_CREATED
├── donor_id
├── blood_type
├── email
├── phone_number
└── timestamp

EVENT_DONOR_ELIGIBILITY_CHANGED
├── donor_id
├── new_status (ELIGIBLE, INELIGIBLE, BLOCKED)
├── reason
├── next_eligible_date
└── timestamp

EVENT_DONATION_COMPLETED
├── donor_id
├── donation_date
├── blood_type
├── units_donated
├── blood_bank_id
├── blood_bag_ids (array)
├── next_eligible_date
└── timestamp

EVENT_DONOR_BLOCKED
├── donor_id
├── reason
├── unblock_date
└── timestamp
```

### 3. **Inventory Events**
```
EVENT_BLOOD_BAG_ADDED
├── bag_id
├── blood_bank_id
├── blood_type
├── donor_id
├── donation_date
├── expiry_date
└── timestamp

EVENT_BLOOD_BAG_EXPIRED
├── bag_id
├── blood_type
├── expiry_date
└── timestamp

EVENT_BLOOD_BAG_USED
├── bag_id
├── hospital_id
├── request_id
├── transfusion_timestamp
└── timestamp

EVENT_BLOOD_BAG_DISCARDED
├── bag_id
├── reason
└── timestamp

EVENT_STOCK_LOW
├── blood_bank_id
├── blood_type
├── current_units
├── threshold
└── timestamp

EVENT_STOCK_UPDATED
├── blood_bank_id
├── blood_type
├── previous_count
├── new_count
├── change_reason
└── timestamp
```

### 4. **Request Events**
```
EVENT_BLOOD_REQUEST_CREATED
├── request_id
├── hospital_id
├── blood_type
├── urgency_level
├── quantity_needed
├── created_at
└── timestamp

EVENT_BLOOD_FOUND
├── request_id
├── blood_bag_id
├── location
├── eta
└── timestamp

EVENT_BLOOD_NOT_FOUND
├── request_id
├── reason (NO_INVENTORY, ALL_RESERVED, URGENT_ONLY)
└── timestamp

EVENT_DONOR_MATCHED
├── request_id
├── donor_id
├── distance_km
├── matching_score
└── timestamp

EVENT_DONOR_NOTIFIED
├── request_id
├── donor_id
├── notification_channels (SMS, PUSH, EMAIL)
├── sent_at
└── timestamp

EVENT_DONOR_ACCEPTED
├── request_id
├── donor_id
├── acceptance_timestamp
├── scheduled_time
└── timestamp

EVENT_DONOR_DECLINED
├── request_id
├── donor_id
├── reason
└── timestamp

EVENT_REQUEST_CANCELLED
├── request_id
├── reason
├── cancelled_by
└── timestamp

EVENT_REQUEST_FULFILLED
├── request_id
├── blood_bag_id
├── delivered_at
├── fulfillment_time_minutes
└── timestamp
```

### 5. **Geolocation Events**
```
EVENT_DONOR_LOCATION_UPDATED
├── donor_id
├── latitude
├── longitude
├── timestamp

EVENT_GEOFENCE_ENTERED
├── donor_id
├── geofence_id
├── hospital_id
├── timestamp

EVENT_GEOFENCE_EXITED
├── donor_id
├── geofence_id
└── timestamp

EVENT_DELIVERY_STARTED
├── request_id
├── transport_vehicle_id
├── pickup_location
├── delivery_location
├── estimated_arrival
└── timestamp

EVENT_DELIVERY_COMPLETED
├── request_id
├── delivery_time_minutes
├── actual_arrival
└── timestamp

EVENT_DELIVERY_DELAYED
├── request_id
├── delay_minutes
├── reason
└── timestamp
```

### 6. **Notification Events**
```
EVENT_NOTIFICATION_QUEUED
├── notification_id
├── recipient_id
├── notification_type
├── channels
├── queued_at
└── timestamp

EVENT_NOTIFICATION_SENT
├── notification_id
├── channel
├── recipient_identifier
├── sent_at
└── timestamp

EVENT_NOTIFICATION_DELIVERED
├── notification_id
├── channel
├── delivered_at
└── timestamp

EVENT_NOTIFICATION_CLICKED
├── notification_id
├── clicked_at
└── timestamp

EVENT_SMS_BOUNCED
├── notification_id
├── phone_number
├── reason
└── timestamp

EVENT_EMAIL_BOUNCED
├── notification_id
├── email
├── reason
└── timestamp
```

### 7. **Camp Events**
```
EVENT_CAMP_CREATED
├── camp_id
├── camp_name
├── start_date
├── location
└── timestamp

EVENT_DONOR_REGISTERED_FOR_CAMP
├── camp_id
├── donor_id
├── registration_date
└── timestamp

EVENT_CAMP_STARTED
├── camp_id
├── actual_start_time
└── timestamp

EVENT_CAMP_COMPLETED
├── camp_id
├── total_donors
├── total_units
├── actual_end_time
└── timestamp

EVENT_VOLUNTEER_ASSIGNED
├── camp_id
├── volunteer_id
├── role
└── timestamp
```

### 8. **Gamification & Analytics Events**
```
EVENT_POINTS_EARNED
├── donor_id
├── points
├── reason (DONATION, REFERRAL, EMERGENCY, etc.)
├── previous_balance
├── new_balance
└── timestamp

EVENT_BADGE_EARNED
├── donor_id
├── badge_id
├── badge_name
├── earned_at
└── timestamp

EVENT_REWARD_REDEEMED
├── donor_id
├── reward_id
├── points_spent
├── new_balance
└── timestamp

EVENT_IMPACT_NOTIFICATION_SENT
├── donor_id
├── bag_id
├── patient_info (anonymized)
├── sent_at
└── timestamp

EVENT_LEADERBOARD_UPDATED
├── leaderboard_type
├── period
├── updated_at
└── timestamp

EVENT_CHURN_RISK_DETECTED
├── donor_id
├── churn_score
├── risk_level
└── timestamp
```

---

## Event Flow Architecture

```
┌─────────────────────────────┐
│    Microservice A            │
│  (e.g., Donor Service)       │
│  ┌─────────────────────────┐ │
│  │ Business Logic          │ │
│  │ (Process Donation)      │ │
│  └────────────┬────────────┘ │
│               │               │
│               ▼               │
│  ┌─────────────────────────┐ │
│  │ Event Publisher         │ │
│  │ (Emit EVENT_XXXX)       │ │
│  └────────────┬────────────┘ │
└───────────────┼────────────────┘
                │
                │ EVENT_DONATION_COMPLETED
                │ {donor_id, blood_type, ...}
                │
                ▼
        ┌──────────────────┐
        │  Message Broker  │
        │  (RabbitMQ/Kafka)│
        └──────────────────┘
                │
        ┌───────┼───────┬──────────┐
        │       │       │          │
        ▼       ▼       ▼          ▼
    ┌────┐ ┌────┐ ┌────┐      ┌────────┐
    │ S1 │ │ S2 │ │ S3 │ ...  │ Service│
    │    │ │    │ │    │      │Queue   │
    └────┘ └────┘ └────┘      └────────┘
    (Event listeners/subscribers)

Each subscribes to EVENT_DONATION_COMPLETED
and performs its own action independently.
```

---

## Guaranteed Delivery Pattern

### 1. **Outbox Pattern** (Preferred for Saga transactions)
```
┌─────────────────────────────────────┐
│ Donor Service                        │
│ ┌────────────────────────────────┐  │
│ │ BEGIN TRANSACTION               │  │
│ │ 1. Update DONATIONS table       │  │
│ │ 2. Insert into OUTBOX table     │  │
│ │ COMMIT                          │  │
│ └────────────────────────────────┘  │
│ ┌────────────────────────────────┐  │
│ │ Outbox Poller                   │  │
│ │ (polls every 1 second)          │  │
│ │ - Read unpublished events       │  │
│ │ - Publish to broker             │  │
│ │ - Mark as published             │  │
│ └────────────────────────────────┘  │
└─────────────────────────────────────┘
```

### 2. **Dead Letter Queue (DLQ)**
```
Service tries to process event 3 times
│
├─ Attempt 1: FAIL → Retry after 1s
├─ Attempt 2: FAIL → Retry after 5s
├─ Attempt 3: FAIL → Send to DLQ
└─ DLQ: Manual investigation by admin
```

---

## Event Ordering & Consistency

### Challenges
- Multiple consumers process same event asynchronously
- Database updates may take time to propagate
- Network latency causes inconsistencies

### Solutions

**1. Event Versioning**
```json
{
  "eventVersion": "1.0",
  "eventId": "uuid-unique",
  "eventType": "EVENT_DONATION_COMPLETED",
  "aggregateId": "donor_123",
  "aggregateType": "DONOR",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": { ... }
}
```

**2. Idempotency Keys**
```
Header: Idempotency-Key: "uuid-unique"
Service tracks processed IDs to prevent duplicates
If event replayed, same ID detected, skipped
```

**3. Eventual Consistency**
```
- Donor Service: Immediately records donation
- Inventory Service: Eventually adds blood bag (+5 seconds)
- Gamification Service: Eventually awards points (+10 seconds)
- Notification Service: Eventually sends thank you (+15 seconds)

Client sees full state after ~15 seconds
Before that, may see partial updates
```

---

## Error Handling & Compensation

### SAGA Pattern for Distributed Transactions

**Scenario: Blood Request Fulfillment**
```
1. Request Service: Create request (PENDING)
   ✓ Success → Emit EVENT_REQUEST_CREATED

2. Inventory Service: Reserve blood bag
   ✗ FAIL → Emit EVENT_RESERVATION_FAILED
   
3. Request Service: Receive failure event
   → Update request to CANCELLED
   → Emit EVENT_REQUEST_CANCELLED
   → Notify hospital
   
Compensation: Rollback previous steps
```

### Timeout Handling
```
Event published: 14:00:00
Scheduled completion: 14:05:00 (5-minute timeout)

If no completion event by 14:05:00:
├─ Send reminder notification
├─ Escalate to admin
├─ Auto-cancel if > 10 minutes
└─ Generate incident report
```

---

## Event Store (Event Sourcing)

### Use Case: Complete Audit Trail
```
Store ALL events chronologically:

2024-01-15 10:00:00 EVENT_DONOR_REGISTERED {donor_id: 123}
2024-01-15 10:05:00 EVENT_ELIGIBILITY_VERIFIED {donor_id: 123}
2024-01-15 14:30:00 EVENT_DONATION_SCHEDULED {donor_id: 123}
2024-01-15 15:00:00 EVENT_DONATION_COMPLETED {donor_id: 123}
2024-01-15 15:05:00 EVENT_BLOOD_BAG_ADDED {bag_id: ABC}
2024-01-15 15:30:00 EVENT_BLOOD_BAG_RESERVED {bag_id: ABC, request_id: 789}
2024-01-15 16:00:00 EVENT_BLOOD_DELIVERED {bag_id: ABC}

Replay events to reconstruct state at any point in time
```

### Implementation
```java
class EventStore {
  store(event);           // Append event
  getEvents(aggregateId); // Get all events for entity
  getEventsSince(time);   // Get events after time
  replay(events);         // Reconstruct state
}
```

---

## Monitoring Event Flow

### Metrics
- Events published/minute
- Events processed/minute
- Processing latency (p50, p95, p99)
- Failed events count
- DLQ events count

### Alerting
```
Alert if:
- Event processing latency > 30 seconds
- Failed events > 10 in 5 minutes
- DLQ size > 100
- Message broker CPU > 80%
```

---

## Event Retention Policy

```
Real-time events: 7 days (fast access)
Archived events: 1 year (compliance)
Audit events: 7 years (legal requirement)

Strategy:
- Hot storage: Recent 7 days in Kafka/RabbitMQ
- Warm storage: 7 days - 1 year in archive database
- Cold storage: 1-7 years in S3/Glacier
```


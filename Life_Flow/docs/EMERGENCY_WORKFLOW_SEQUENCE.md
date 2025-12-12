# Emergency Blood Request Workflow (Detailed Sequence)

## Actors
- **Hospital Admin** (creates request)
- **Request Service** (processes request)
- **Inventory Service** (checks stock)
- **Geolocation Service** (finds donors)
- **Notification Service** (sends alerts)
- **Donor** (responds to alert)
- **Rider/Logistics** (delivers blood)

## Sequence Diagram (ASCII)

```
┌──────────┐  ┌─────────────┐  ┌──────────────┐  ┌──────────┐  ┌──────────────┐  ┌──────────┐
│ Hospital │  │Request Svc  │  │Inventory Svc │  │Geo Svc   │  │Notification  │  │  Donor   │
│  Admin   │  │             │  │              │  │          │  │  Service     │  │          │
└─────┬────┘  └──────┬──────┘  └──────┬───────┘  └─────┬────┘  └──────┬───────┘  └─────┬────┘
      │              │                │                │               │               │
      │ POST /request/create           │                │               │               │
      │──────────────────────────────>│                │               │               │
      │                              │                │               │               │
      │                              │ Validate Request               │               │
      │                              │ Store in DB                    │               │
      │                              │                │               │               │
      │                              │ Check Inventory Stock          │               │
      │                              │────────────────────────────>│               │
      │                              │                │                               │
      │                              │                │ Query: SELECT * FROM         │
      │                              │                │ blood_inventory               │
      │                              │                │ WHERE blood_type = 'O+'      │
      │                              │                │ AND status = 'AVAILABLE'     │
      │                              │                │                               │
      │                              │  ✗ Stock Not Found             │               │
      │                              │<────────────────────────────│                │
      │                              │                │               │               │
      │                              │ Find Eligible Donors           │               │
      │                              │────────────────────────────>│               │
      │                              │                │                               │
      │                              │                │ SELECT donor_id, latitude,   │
      │                              │                │ longitude FROM donor_locations
      │                              │                │ WHERE distance < 5km AND      │
      │                              │                │ blood_type = 'O+'            │
      │                              │                │                               │
      │                              │  8 Donors Found (rank by score)                │
      │                              │<────────────────────────────│                │
      │                              │                │               │               │
      │                              │ Send Notifications             │               │
      │                              │───────────────────────────────────────────>│
      │                              │                │               │               │
      │                              │                │               │ SMS: "Emergency!"
      │                              │                │               │ Push notification
      │                              │                │               │ WhatsApp alert
      │                              │                │               │
      │                              │                │               │<──────────────┤
      │                              │                │               │ DONOR OPENS APP
      │                              │                │               │
      │                              │                │               │  POST /response
      │                              │                │               │  {accepted: true}
      │                              │                │               │────────────────>│
      │                              │                │               │                 │
      │                              │ *** ACCEPTANCE RECORDED ***    │                 │
      │                              │                │               │                 │
      │ ✓ Donor Matched!            │                │               │                 │
      │<──────────────────────────────────────────────────────────────────────────────│
      │                              │                │               │                 │
      │ "Donor accepted! ETA 25 mins"│                │               │                 │
      │                              │                │               │                 │
      │ Prepare patient              │                │               │                 │
      │ Inform O.T.                  │                │               │                 │
      │                              │                │               │                 │
      │                              │                │               │ Donor arrives at│
      │                              │                │               │ collection center
      │                              │                │               │────────────────>│
      │                              │                │               │                 │
      │                              │  Reserve Blood Unit            │                 │
      │                              │────────────────────────────>│                 │
      │                              │                │                                │
      │                              │ UPDATE blood_inventory SET     │                 │
      │                              │ status = 'RESERVED',           │                 │
      │                              │ reserved_for_request_id = ... │                 │
      │                              │                │                                │
      │                              │<────────────────────────────│                 │
      │                              │                │               │                 │
      │                              │                │               │ Collection staff
      │                              │                │               │ Draw blood (500ml)
      │                              │                │               │
      │                              │  INSERT INTO blood_inventory   │                 │
      │                              │  VALUES (bag_001, 'O+', ...)  │                 │
      │                              │  UPDATE donor_profiles SET     │                 │
      │                              │  last_donation = NOW() ...     │                 │
      │                              │  INSERT INTO donation_history  │                 │
      │                              │────────────────────────────>│                 │
      │                              │                │                                │
      │                              │<────────────────────────────│                 │
      │                              │                │               │                 │
      │ ✓ Blood Collected!           │                │               │ Notification:   │
      │ Status: In Transit           │                │               │ "Blood en route"│
      │<──────────────────────────────────────────────────────────────────────────────│
      │                              │                │               │                 │
      │ Prepare O.R.                 │                │               │                 │
      │ Schedule transfusion         │                │               │                 │
      │                              │                │               │                 │
      │                              │                │               │<──────────────┤
      │                              │                │               │ Rider delivers
      │                              │                │               │ Blood to hospital
      │ ✓ Blood Arrived!             │                │               │
      │ Status: Ready for use        │                │               │
      │<──────────────────────────────────────────────────────────────────────────────│
      │                              │                │               │                 │
      │ Doctor approves usage        │                │               │                 │
      │ Transfusion starts           │                │               │                 │
      │                              │                │               │                 │
      │                              │  UPDATE blood_inventory SET    │                 │
      │                              │  status = 'USED' WHERE         │                 │
      │                              │  bag_id = 'bag_001'           │                 │
      │                              │────────────────────────────>│                 │
      │                              │                │                                │
      │                              │<────────────────────────────│                 │
      │                              │                │               │                 │
      │                              │                │               │ Notification:   │
      │                              │                │               │ "Life Saved!    │
      │                              │                │               │  Hero Badge"    │
      │ ✓ Life Saved!                │                │               │
      │ Status: Fulfilled            │                │               │                 │
      │<──────────────────────────────────────────────────────────────────────────────│
      │                              │                │               │                 │

```

## Step-by-Step Details

### Step 1: Hospital Creates Request
```json
POST /api/v1/request/create
{
  "hospital_id": "hosp-001",
  "blood_type": "O+",
  "units_required": 4,
  "urgency_level": "CRITICAL",
  "patient_condition": "Multiple trauma, internal bleeding",
  "procedure_scheduled_time": "2024-01-15T14:35:00Z",
  "deadline_minutes": 30
}
```

**Response:**
```json
{
  "request_id": "req-001",
  "status": "PENDING",
  "created_at": "2024-01-15T14:23:45Z",
  "deadline_timestamp": "2024-01-15T14:53:45Z"
}
```

### Step 2: System Checks Inventory

**Database Query:**
```sql
SELECT COUNT(*) as available_units 
FROM blood_inventory 
WHERE blood_type = 'O+' 
  AND status = 'AVAILABLE' 
  AND expiry_date > NOW();
```

**If Result = 0:** No stock available → Proceed to Step 3

### Step 3: Find Eligible Donors (Geolocation Service)

**Matching Algorithm:**
```sql
SELECT 
  d.donor_id,
  dp.blood_type,
  SQRT(POW(dl.latitude - h.latitude, 2) + 
       POW(dl.longitude - h.longitude, 2)) * 111 as distance_km,
  dg.total_donations * 5 as reliability_score,
  CASE 
    WHEN dp.last_donation < DATE_SUB(NOW(), INTERVAL 3 MONTH) THEN 30
    WHEN dp.last_donation < DATE_SUB(NOW(), INTERVAL 1 MONTH) THEN 20
    ELSE 10
  END as availability_score
FROM donor_profiles dp
JOIN donor_locations dl ON dp.donor_id = dl.donor_id
JOIN hospital_locations h ON h.hospital_id = 'hosp-001'
JOIN donor_gamification dg ON dp.donor_id = dg.donor_id
WHERE dp.blood_type IN ('O+', 'O-')  -- Compatibility
  AND dp.eligibility_status = 'ELIGIBLE'
  AND SQRT(POW(dl.latitude - h.latitude, 2) + 
           POW(dl.longitude - h.longitude, 2)) * 111 <= 5  -- Within 5km
ORDER BY (reliability_score + availability_score) DESC
LIMIT 10;
```

**Result:** 8 eligible donors found, ranked by score

### Step 4: Send High-Priority Notifications

**For Each Donor (Top 8):**

```sql
INSERT INTO notifications_log VALUES (
  'notif-xxx',
  'donor-99',
  NULL,
  '+919876543210',
  'CRITICAL_EMERGENCY_SMS_PUSH',
  'EMERGENCY: O+ blood needed at Apollo Hospital!',
  'req-001',
  'CRITICAL',
  SENT_AT = NOW()
);
```

**Notification Content:**
```
🚨 EMERGENCY 🚨
Hospital: Apollo Hospital, Delhi
Blood Type: O+
Distance: 2.5 km away
Deadline: 30 minutes

Can you donate within 25 minutes?
📱 TAP ACCEPT → Earn 100 Points!

[ACCEPT] [REJECT]
```

### Step 5: Donor Accepts Request

```json
POST /api/v1/response/{req-001}/accept
{
  "donor_id": "donor-99",
  "can_arrive_in_minutes": 25,
  "current_location": {
    "latitude": 28.5355,
    "longitude": 77.3910
  }
}
```

**Response:**
```json
{
  "response_id": "resp-001",
  "status": "ACCEPTED",
  "confirmation_code": "ABC123",
  "scheduled_pickup_time": "2024-01-15T14:45:00Z",
  "points_offered": 100,
  "notification": "Heading to collection center? We'll guide you!"
}
```

### Step 6: Blood Collection

**Collect 500ml of O+ blood:**
```sql
INSERT INTO donation_history VALUES (
  'don-001',
  'donor-99',
  NOW(),
  'O+',
  0.5,
  'WHOLE_BLOOD',
  ...
);

INSERT INTO blood_inventory VALUES (
  'bag-001',
  'O+',
  'batch-123',
  NOW(),
  NOW(),
  DATE_ADD(NOW(), INTERVAL 42 DAY),
  'Hospital Storage Unit 2',
  'fridge-101',
  4.5,
  'device-001',
  'BAR123456789',
  'RFID789',
  'AVAILABLE',
  'req-001',
  NOW(),
  'hosp-001',
  'donor-99-anonymized',
  'WHOLE_BLOOD',
  1.0,
  500.00,
  'PASS',
  NOW(),
  'staff-001',
  '{"hiv": "negative", "hbsag": "negative", "rpr": "negative"}',
  42,
  42
);
```

### Step 7: Blood in Transit

**Assign Rider & Start Tracking:**
```sql
INSERT INTO delivery_rides VALUES (
  'ride-001',
  'fulfillment-001',
  'rider-005',
  'IN_TRANSIT',
  'hosp-001',
  'hosp-001',
  28.5355, 77.3910,  -- Pickup
  28.5610, 77.2105,  -- Hospital
  2.5,
  15,
  NOW(),
  NULL,
  NOW(),
  NULL,
  NULL,
  NULL,
  NULL,
  4.8,
  4.6,
  4.9,
  'Blood bag temperature stable',
  NOW()
);
```

### Step 8: Blood Delivered & Used

**Mark as Used:**
```sql
UPDATE blood_inventory 
SET status = 'USED', 
    updated_at = NOW() 
WHERE bag_id = 'bag-001';

UPDATE request_responses 
SET collection_completed_at = NOW() 
WHERE response_id = 'resp-001';

UPDATE blood_requests 
SET status = 'FULFILLED', 
    fulfilled_at = NOW() 
WHERE request_id = 'req-001';
```

**Gamification Reward:**
```sql
UPDATE donor_gamification 
SET total_points = total_points + 100,
    total_donations = total_donations + 1,
    estimated_lives_saved = estimated_lives_saved + 1
WHERE donor_id = 'donor-99';

INSERT INTO points_transactions VALUES (
  'trans-001',
  'donor-99',
  100,
  0,
  'EMERGENCY_RESPONSE',
  'Emergency blood donation - Apollo Hospital',
  'req-001',
  NOW()
);
```

### Step 9: Notification to Donor

**Push + SMS:**
```
✅ Your blood saved a life!
Patient at Apollo Hospital is stable.
You've earned "Hero" badge!
100 Points → Redeem for health checkup
```

---

## Error Handling Scenarios

### Scenario: Donor Doesn't Respond
```
If no response in 60 seconds:
  ✗ Move to next donor in ranked list
  ✗ Send notification to Donor #2
  ✗ Update hospital: "Searching for backup donor"
```

### Scenario: Donation Ineligible After Check
```
If medical screening fails:
  ✗ Update donor_profiles SET eligibility_status = 'TEMPORARY_BLOCKED'
  ✗ Notify donor of reason
  ✗ Move to next donor
```

### Scenario: Delivery Vehicle Breakdown
```
If GPS tracking shows stopped for >5 mins:
  ✗ Alert dispatch
  ✗ Get ETA update from rider
  ✗ Notify hospital of delay
  ✗ Trigger temperature alert if bag temp rising
```

---

**This workflow ensures emergency blood requests are fulfilled within 30-45 minutes.**

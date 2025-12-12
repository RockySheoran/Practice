CAMP_ANALYTICS
├── analytics_id (PK)
├── camp_id (FK → CAMPS_DRIVES)
├── total_registrations
├── total_donors_showed_up
├── no_show_count
├── total_units_collected
├── average_hemoglobin
├── blood_type_breakdown (JSON: {A_PLUS: 10, B_MINUS: 5, ...})
├── volunteer_satisfaction_score
├── donor_satisfaction_score
├── cost_per_unit (calculated)
├── success_rate_percentage
├── repeat_donor_count
├── new_donor_count
├── generated_at

CAMP_EXPENSES
├── expense_id (PK)
├── camp_id (FK → CAMPS_DRIVES)
├── expense_category (VENUE, EQUIPMENT, SUPPLIES, TRANSPORT, STAFF, MARKETING)
├── amount (currency)
├── description
├── vendor_name
├── invoice_number
├── payment_status (PENDING, PAID, CANCELLED)
├── paid_date
├── recorded_by (user ID)
├── created_at

CAMP_FEEDBACK
├── feedback_id (PK)
├── camp_id (FK → CAMPS_DRIVES)
├── donor_id (FK → Donor Service)
├── rating (1-5 stars)
├── feedback_text
├── categories_rated (JSON: {cleanliness: 5, staff: 4, ...})
├── would_donate_again (boolean)
├── submitted_at
```

---

## Service 8: Analytics & Gamification Service Database

```
DONOR_REWARDS
├── reward_id (PK)
├── donor_id (FK → Donor Service)
├── reward_type (POINTS, BADGE, VOUCHER, HEALTH_CHECKUP)
├── amount (for points)
├── reward_code (for vouchers)
├── reason (DONATION, REFERRAL, EMERGENCY_DONATION, CAMP_PARTICIPATION, etc.)
├── earned_at
├── expired_at (null if no expiry)
├── is_redeemed (boolean)
├── redeemed_at
├── redeemed_for (what was purchased)
├── created_at

BADGES_ACHIEVEMENTS
├── badge_id (PK)
├── badge_name (e.g., "Silver Donor", "Emergency Hero")
├── badge_code (UNIQUE)
├── description
├── icon_url
├── criteria (JSON: what needs to be achieved)
├── rarity (COMMON, UNCOMMON, RARE, EPIC, LEGENDARY)
├── created_at

DONOR_BADGES (Join table)
├── donor_badge_id (PK)
├── donor_id (FK → Donor Service)
├── badge_id (FK → BADGES_ACHIEVEMENTS)
├── earned_at
├── progress (percentage, nullable if instant earn)

LEADERBOARDS
├── leaderboard_id (PK)
├── leaderboard_type (MONTHLY_DONATIONS, LIFETIME_DONATIONS, MONTHLY_POINTS, CITY_RANKING, etc.)
├── period (DAILY, WEEKLY, MONTHLY, YEARLY, LIFETIME)
├── generated_at
├── valid_until

LEADERBOARD_ENTRIES
├── entry_id (PK)
├── leaderboard_id (FK → LEADERBOARDS)
├── donor_id (FK → Donor Service)
├── rank (1, 2, 3, ...)
├── score (donation count, points, etc.)
├── city (for city-wise rankings)
├── previous_rank (for trend)
├── created_at

POINT_TRANSACTIONS
├── transaction_id (PK)
├── donor_id (FK → Donor Service)
├── transaction_type (EARNED, SPENT, ADJUSTED, EXPIRED)
├── points_amount (can be negative for spent)
├── reason (DONATION, REFERRAL, REDEMPTION, ADMIN_ADJUSTMENT, etc.)
├── reference_id (donation_id, request_id, reward_id, etc.)
├── balance_before
├── balance_after
├── transaction_date

REFERRALS
├── referral_id (PK)
├── referring_donor_id (FK → Donor Service)
├── referred_donor_id (FK → Donor Service)
├── referral_code (UNIQUE)
├── referred_donor_status (PENDING, COMPLETED, CANCELLED)
├── reward_points_earned (by referrer)
├── created_at
├── referred_at (when referred donor completes first donation)

DONATION_IMPACT_TRACKING
├── impact_id (PK)
├── blood_bag_id (FK → Inventory Service)
├── donor_id (FK → Donor Service)
├── hospital_id (FK → Identity Service - Hospital)
├── patient_anonymous_id (de-identified)
├── patient_age_group (optional)
├── patient_gender (optional)
├── medical_procedure (SURGERY, TRANSFUSION, EMERGENCY, etc.)
├── procedure_type (e.g., "Cardiac Surgery", "Accident Trauma")
├── procedure_date
├── patient_recovery_status (RECOVERING, RECOVERED, CRITICAL, LOST)
├── notification_sent_to_donor (boolean)
├── notified_at
├── created_at

SYSTEM_ANALYTICS
├── analytics_id (PK)
├── date
├── total_active_donors
├── total_active_hospitals
├── total_blood_banks
├── total_donations_today
├── total_requests_today
├── average_fulfillment_time_minutes
├── shortage_incidents
├── lives_saved_estimate
├── blood_wastage_units
├── wastage_rate_percentage
├── revenue (if applicable)
├── created_at

ENGAGEMENT_METRICS
├── metric_id (PK)
├── donor_id (FK → Donor Service)
├── last_donation_date
├── days_since_last_donation
├── donation_frequency_days (average gap)
├── app_opens_monthly
├── notifications_opened_count
├── emergency_requests_received
├── emergency_requests_accepted
├── acceptance_rate_percentage
├── churn_risk_score (0-100, higher = more likely to stop)
├── engagement_score (0-100)
├── calculated_at

MACHINE_LEARNING_MODELS
├── model_id (PK)
├── model_name (e.g., "Blood Demand Predictor v1.2")
├── model_type (DEMAND_FORECAST, CHURN_PREDICTION, ELIGIBILITY_CHECK, FRAUD_DETECTION)
├── version
├── training_date
├── accuracy_score
├── f1_score
├── precision
├── recall
├── last_updated
├── model_file_url (S3 path)
├── status (ACTIVE, DEPRECATED, TESTING)

PREDICTIONS
├── prediction_id (PK)
├── model_id (FK → MACHINE_LEARNING_MODELS)
├── prediction_type (DONOR_NEXT_DONATION, BLOOD_SHORTAGE, DONOR_CHURN, DEMAND_SPIKE)
├── entity_id (blood_bank_id, donor_id, etc.)
├── entity_type
├── predicted_value (date, shortage_units, churn_probability, etc.)
├── confidence_score
├── prediction_date
├── actual_outcome (null until event occurs, then boolean or value)
├── accuracy_verified (boolean)
├── created_at
```

---

## Database Design Principles

### 1. Normalization
- Tables are normalized to 3rd Normal Form (3NF)
- No data duplication across services
- Each service owns its domain data

### 2. Relationships
- **Foreign Keys**: Only reference other services in join tables via `*_id` fields
- **No Cross-Database Foreign Keys**: Services do NOT directly join across databases
- **Event-Based Synchronization**: Data consistency maintained via events

### 3. Indexing Strategy
- Primary Key: SERIAL or UUID
- Foreign Keys: Indexed for joins
- Common Query Columns: blood_type, status, created_at
- Geo-Coordinates: Spatial indexes (PostGIS)
- Search: Full-text indexes for text fields

### 4. Data Types
- **Coordinates**: DECIMAL(10, 8) for latitude/longitude
- **Dates**: TIMESTAMP WITH TIME ZONE
- **Enums**: ENUM type in PostgreSQL
- **Money**: NUMERIC(12, 2)
- **Complex Data**: JSON/JSONB for flexible schemas

### 5. Audit Columns
All tables should include:
```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
deleted_at TIMESTAMP NULL (for soft deletes)
```

### 6. Soft Deletes
- Use `deleted_at` for data retention/compliance
- Queries filter WHERE deleted_at IS NULL
- Enables GDPR "right to be forgotten" with data preservation

---

## Service-to-Service Data Synchronization

### Event-Based Flow Example:
```
Donor completes donation:
1. Donor Service records donation
2. Emits EVENT_DONATION_COMPLETE {donor_id, blood_type, units, ...}
3. Inventory Service listens, updates stock
4. Gamification Service listens, awards points
5. Analytics Service listens, updates metrics
6. Notification Service listens, sends thank you message
```

### No Direct Database Access Between Services
- ❌ DON'T: `SELECT * FROM inventory_service.blood_inventory`
- ✅ DO: Listen for `EVENT_BLOOD_STOCK_UPDATED` event

---

## Performance Considerations

### Caching Strategy (Redis)
- Cache blood inventory (TTL: 5 minutes)
- Cache donor eligibility status (TTL: 1 hour)
- Cache leaderboards (TTL: 1 day)
- Cache user profiles (TTL: 6 hours)

### Query Optimization
- Index on (blood_type, status) for inventory queries
- Index on (donor_id, created_at) for donation history
- Index on (request_id, status) for request tracking
- Partition large tables by date (e.g., transactions by year/month)

### Connection Pooling
- Use HikariCP for Java connection pools
- Pool size: 10-20 connections per service


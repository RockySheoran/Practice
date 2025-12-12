# LifeFlow Complete Database Schema

## Database Overview

LifeFlow uses a distributed database architecture with 7 specialized PostgreSQL databases connected through microservices:

```
┌─────────────────────────────────────────────────────────────────┐
│                  LIFEFLOW MICROSERVICES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │  IDENTITY_DB   │  │  DONOR_DB      │  │  INVENTORY_DB  │   │
│  │ (Auth/Users)   │  │ (Profiles)     │  │ (Blood Stock)  │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │  REQUEST_DB    │  │  GEO_DB        │  │  NOTIF_DB      │   │
│  │ (Emergencies)  │  │ (Locations)    │  │ (Logs)         │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              ANALYTICS_DB (Insights)                   │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Complete ER Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         LIFEFLOW ENTITY RELATIONSHIPS                         │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐
│     USERS (Base)    │  ◄─── IDENTITY_DB
├─────────────────────┤
│ user_id (PK)        │
│ email               │
│ phone               │
│ password_hash       │
│ role                │ (ENUM: DONOR, HOSPITAL, ADMIN, STAFF)
│ status              │
│ created_at          │
└──────────┬──────────┘
           │
    ┌──────┴──────┬─────────────┐
    │             │             │
    ▼             ▼             ▼
┌──────────────┐┌─────────────┐┌──────────────┐
│DONOR_PROFILE ││  HOSPITAL   ││   STAFF      │
├──────────────┤├─────────────┤├──────────────┤
│donor_id (FK) ││hosp_id (FK) ││staff_id (FK) │
│blood_type    ││name         ││center_id     │
│weight        ││address      ││designation   │
│hemoglobin    ││contact      ││department    │
│last_donation ││emergency_ln ││verified_at   │
│eligibility   ││blood_bank   ││              │
│              ││capacity     ││              │
└──────┬───────┘└─────┬───────┘└──────────────┘
       │              │
       │              ▼
       │         ┌──────────────────┐
       │         │ HOSPITAL_LOCATION│  ◄─── GEO_DB
       │         ├──────────────────┤
       │         │ hospital_id (PK) │
       │         │ latitude         │
       │         │ longitude        │
       │         │ address          │
       │         └──────────────────┘
       │
       ▼
┌────────────────────────────────────────┐
│  DONATION_HISTORY (1:N)                │◄─── DONOR_DB
├────────────────────────────────────────┤
│ donation_id (PK)                       │
│ donor_id (FK) ──────┐                  │
│ donation_date       │                  │
│ blood_type_collected│                  │
│ units_collected     │                  │
│ center_id (FK)      │                  │
│ staff_id (FK)       │                  │
│ hemoglobin_before   │                  │
│ hemoglobin_after    │                  │
│ health_score        │                  │
│ adverse_events      │                  │
└────────────────────────────────────────┘
       │
       │ (1:N - One donation → Multiple blood bags)
       │
       ▼
┌────────────────────────────────────────┐
│  BLOOD_INVENTORY (1:N)                 │◄─── INVENTORY_DB
├────────────────────────────────────────┤
│ bag_id (PK)                            │
│ donation_id (FK) ───┐                  │
│ blood_type         │                  │
│ batch_number       │                  │
│ donation_date      │                  │
│ expiry_date        │                  │
│ status             │                  │
│ storage_location   │                  │
│ temperature        │                  │
│ barcode/RFID       │                  │
│ quality_status     │                  │
│ reserved_for (FK)  │──┐                │
└────────────────────────────────────────┘
       │                │
       │ (1:N)          │ (1:1)
       │                └─────────┬─────────────────────┐
       │                          │                     │
       ▼                          ▼                     ▼
┌─────────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│ BLOOD_FULFILLMENT   │   │ BLOOD_REQUEST    │   │ REQUEST_RESPONSE │
├─────────────────────┤   ├──────────────────┤   ├──────────────────┤
│fulfillment_id (PK)  │   │request_id (PK)   │   │response_id (PK)  │
│request_id (FK)      │   │hospital_id (FK)  │   │request_id (FK)   │
│bag_id (FK)          │   │blood_type_needed │   │donor_id (FK)     │
│response_id (FK)     │   │units_required    │   │hospital_id (FK)  │
│rider_id             │   │urgency_level     │   │response_status   │
│collection_time      │   │patient_condition │   │scheduled_time    │
│delivery_start       │   │deadline          │   │confirmation_code │
│delivery_end         │   │status            │   │points_earned     │
│blood_used_time      │   │created_at        │   │confirmed_at      │
│notes                │   │fulfilled_at      │   │created_at        │
└─────────────────────┘   └──────────────────┘   └──────────────────┘
       │                          ▲
       │                          │ (1:N - One request → Multiple responses)
       │                          │
       └──────────────────────────┘

┌────────────────────────────────────┐
│  DELIVERY_RIDES                    │◄─── GEO_DB
├────────────────────────────────────┤
│ ride_id (PK)                       │
│ fulfillment_id (FK)                │
│ rider_id                           │
│ status                             │
│ pickup_location                    │
│ delivery_location                  │
│ distance_km                        │
│ estimated_duration                 │
│ actual_duration                    │
│ temperature_maintained             │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  RIDE_TRACKING_POINTS              │◄─── GEO_DB
├────────────────────────────────────┤
│ tracking_id (PK)                   │
│ ride_id (FK) ───────────────────┐  │
│ latitude                         │  │
│ longitude                        │  │
│ speed_kmh                        │  │
│ timestamp                        │  │
└────────────────────────────────────┘ (1:N - One ride → Multiple tracking points)

┌────────────────────────────────────┐
│  DONOR_GAMIFICATION                │◄─── DONOR_DB
├────────────────────────────────────┤
│ gamification_id (PK)               │
│ donor_id (FK - 1:1 relationship)   │
│ total_points                       │
│ total_donations                    │
│ badge_level                        │
│ achievements                       │
│ last_updated                       │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  NOTIFICATIONS_LOG                 │◄─── NOTIFICATION_DB
├────────────────────────────────────┤
│ notification_id (PK)               │
│ user_id (FK)                       │
│ request_id (FK - Optional)         │
│ response_id (FK - Optional)        │
│ notification_type                  │
│ content                            │
│ sent_at                            │
│ delivery_status                    │
│ read_at                            │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  DONOR_LOCATIONS (Real-time)       │◄─── GEO_DB
├────────────────────────────────────┤
│ location_id (PK)                   │
│ donor_id (FK)                      │
│ latitude                           │
│ longitude                          │
│ accuracy_meters                    │
│ location_update_time               │
│ location_source                    │
└────────────────────────────────────┘
```

---

## Database 1: IDENTITY_DB (Authentication)

```sql
-- Users Table
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('DONOR', 'HOSPITAL', 'ADMIN', 'STAFF') NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') DEFAULT 'ACTIVE',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    kyc_verified BOOLEAN DEFAULT FALSE,
    kyc_document_url VARCHAR(500),
    kyc_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- OAuth2 Tokens
CREATE TABLE oauth2_tokens (
    token_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    access_token VARCHAR(500) NOT NULL UNIQUE,
    refresh_token VARCHAR(500) UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
);

-- Audit Logs
CREATE TABLE audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_value LONGTEXT,
    new_value LONGTEXT,
    ip_address VARCHAR(45),
    status ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp)
);
```

---

## Database 2: DONOR_DB (Donor Management)

```sql
-- Donor Profiles (1:1 with Users)
CREATE TABLE donor_profiles (
    donor_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'OTHER'),
    weight_kg DECIMAL(5, 2),
    height_cm INT,
    hemoglobin_level DECIMAL(4, 2),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    pulse_rate INT,
    chronic_diseases VARCHAR(500),
    allergies VARCHAR(500),
    medications TEXT,
    tattoo_date DATE,
    recent_travel VARCHAR(500),
    eligibility_status ENUM('ELIGIBLE', 'TEMPORARY_BLOCKED', 'PERMANENTLY_BLOCKED') DEFAULT 'ELIGIBLE',
    block_until TIMESTAMP NULL,
    verification_status ENUM('VERIFIED', 'UNVERIFIED') DEFAULT 'UNVERIFIED',
    verified_by_admin VARCHAR(50),
    verified_at TIMESTAMP NULL,
    last_eligibility_check TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_blood_type (blood_type),
    INDEX idx_eligibility_status (eligibility_status)
);

-- Donation History (1:N with DonorProfile)
CREATE TABLE donation_history (
    donation_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    donation_date TIMESTAMP NOT NULL,
    blood_type_collected ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'),
    units_collected DECIMAL(3, 1),
    donation_type ENUM('WHOLE_BLOOD', 'PLASMA', 'PLATELETS') DEFAULT 'WHOLE_BLOOD',
    hemoglobin_before DECIMAL(4, 2),
    hemoglobin_after DECIMAL(4, 2),
    collection_center_id VARCHAR(50),
    collecting_staff_id VARCHAR(50),
    staff_notes TEXT,
    adverse_events ENUM('NONE', 'FAINTING', 'NAUSEA', 'DIZZINESS', 'OTHER') DEFAULT 'NONE',
    donation_status ENUM('SUCCESSFUL', 'INCOMPLETE', 'REJECTED') DEFAULT 'SUCCESSFUL',
    bag_barcode VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_donation_date (donation_date),
    INDEX idx_donation_status (donation_status)
);

-- Donor Gamification (1:1 with DonorProfile)
CREATE TABLE donor_gamification (
    gamification_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL UNIQUE,
    total_points INT DEFAULT 0,
    total_donations INT DEFAULT 0,
    estimated_lives_saved INT DEFAULT 0,
    badge_level ENUM('BRONZE', 'SILVER', 'GOLD', 'PLATINUM', 'LEGEND') DEFAULT 'BRONZE',
    achievement_milestones TEXT,
    hero_of_month_count INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_badge_level (badge_level)
);

-- Points Transaction Log (1:N with Donor)
CREATE TABLE points_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    points_earned INT,
    points_redeemed INT,
    transaction_type ENUM('DONATION', 'EMERGENCY_RESPONSE', 'MILESTONE', 'REFERRAL'),
    description VARCHAR(500),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_transaction_date (transaction_date)
);

-- Eligibility Checks (1:N with Donor)
CREATE TABLE eligibility_checks (
    check_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_donation_days INT,
    min_weight_kg DECIMAL(5, 2),
    min_hemoglobin DECIMAL(4, 2),
    age_years INT,
    overall_eligible BOOLEAN,
    reason_if_ineligible VARCHAR(500),
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_check_timestamp (check_timestamp)
);
```

---

## Database 3: INVENTORY_DB (Blood Bank)

```sql
-- Blood Inventory (1:N with DonationHistory via bag_barcode)
CREATE TABLE blood_inventory (
    bag_id VARCHAR(100) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    donation_date TIMESTAMP NOT NULL,
    collection_date TIMESTAMP,
    expiry_date TIMESTAMP NOT NULL,
    storage_location VARCHAR(100),
    fridge_id VARCHAR(50),
    storage_temperature DECIMAL(5, 2),
    barcode VARCHAR(100) UNIQUE,
    rfid_tag VARCHAR(100) UNIQUE,
    status ENUM('AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'USED', 'EXPIRED', 'DISCARDED') DEFAULT 'AVAILABLE',
    reserved_for_request_id VARCHAR(50),
    reserved_at TIMESTAMP NULL,
    reserved_by_hospital_id VARCHAR(50),
    donor_id_anonymized VARCHAR(50),
    blood_component_type ENUM('WHOLE_BLOOD', 'RBC', 'PLASMA', 'PLATELETS') DEFAULT 'WHOLE_BLOOD',
    units_available DECIMAL(3, 1),
    unit_cost DECIMAL(8, 2),
    quality_check_status ENUM('PASS', 'FAIL', 'PENDING') DEFAULT 'PENDING',
    quality_check_date TIMESTAMP NULL,
    test_results TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_status (status),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_batch_number (batch_number)
);

-- Stock Summary (Real-time Stock Levels)
CREATE TABLE stock_summary (
    stock_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL UNIQUE,
    total_available_units INT DEFAULT 0,
    total_reserved_units INT DEFAULT 0,
    reorder_threshold INT DEFAULT 5,
    critical_threshold INT DEFAULT 2,
    alert_triggered BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_alert_triggered (alert_triggered)
);

-- Temperature Monitoring (1:N with BloodInventory)
CREATE TABLE temperature_monitoring (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bag_id VARCHAR(100),
    temperature DECIMAL(5, 2) NOT NULL,
    humidity DECIMAL(5, 2),
    reading_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_triggered BOOLEAN DEFAULT FALSE,
    alert_type ENUM('TOO_HIGH', 'TOO_LOW', 'NONE') DEFAULT 'NONE',
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_reading_time (reading_time)
);

-- Inventory Transactions Log
CREATE TABLE inventory_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    transaction_type ENUM('IN', 'OUT', 'RESERVE', 'RELEASE', 'TRANSFER') NOT NULL,
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    request_id VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50),
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_transaction_date (transaction_date)
);

-- Expiry Management
CREATE TABLE expiry_management (
    expiry_alert_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    days_until_expiry INT,
    alert_level ENUM('WARNING', 'CRITICAL', 'EXPIRED') DEFAULT 'WARNING',
    alert_sent_at TIMESTAMP NULL,
    resolution_action ENUM('DISCARDED', 'TRANSFERRED', 'USED') DEFAULT NULL,
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_alert_level (alert_level)
);
```

---

## Database 4: REQUEST_DB (Emergency Requests)

```sql
-- Blood Requests (Emergency)
CREATE TABLE blood_requests (
    request_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    blood_type_needed ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    units_required DECIMAL(3, 1) NOT NULL,
    urgency_level ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    urgency_numeric_score INT,
    patient_age INT,
    patient_gender ENUM('M', 'F', 'OTHER'),
    patient_condition VARCHAR(500),
    procedure_type VARCHAR(100),
    procedure_scheduled_time TIMESTAMP,
    deadline_minutes INT,
    deadline_timestamp TIMESTAMP,
    status ENUM('PENDING', 'MATCHED', 'ACCEPTED', 'FULFILLED', 'PARTIAL_FULFILLED', 'CANCELLED', 'EXPIRED') DEFAULT 'PENDING',
    blood_bank_stock_checked BOOLEAN DEFAULT FALSE,
    gps_location_hospital VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason VARCHAR(500),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_blood_type_needed (blood_type_needed),
    INDEX idx_status (status),
    INDEX idx_urgency_level (urgency_level),
    INDEX idx_created_at (created_at),
    INDEX idx_deadline_timestamp (deadline_timestamp)
);

-- Request Responses (Donor Responses to Requests) - 1:N with BloodRequest
CREATE TABLE request_responses (
    response_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    donor_id VARCHAR(50) NOT NULL,
    hospital_id VARCHAR(50) NOT NULL,
    response_status ENUM('PENDING', 'ACCEPTED', 'REJECTED', 'NO_RESPONSE', 'CANCELLED') DEFAULT 'PENDING',
    donor_can_arrive_in_minutes INT,
    scheduled_pickup_time TIMESTAMP,
    actual_pickup_time TIMESTAMP NULL,
    confirmed_by_donor_at TIMESTAMP NULL,
    confirmation_code VARCHAR(50),
    confirmation_otp VARCHAR(10),
    donor_arrival_at_center TIMESTAMP NULL,
    collection_completed_at TIMESTAMP NULL,
    rejection_reason VARCHAR(500),
    response_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    points_offered INT DEFAULT 100,
    points_claimed_at TIMESTAMP NULL,
    blood_bag_assigned_id VARCHAR(100),
    matched_score INT,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_response_status (response_status)
);

-- Donor Matching Results
CREATE TABLE donor_matching_results (
    match_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    donor_id VARCHAR(50) NOT NULL,
    blood_type_compatibility VARCHAR(50),
    distance_km DECIMAL(6, 2),
    distance_score INT,
    donor_reliability_score INT,
    final_match_score INT,
    match_rank INT,
    notification_sent_at TIMESTAMP NULL,
    match_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_final_match_score (final_match_score)
);

-- Blood Fulfillment (1:1 with RequestResponse, 1:1 with BloodInventory)
CREATE TABLE blood_fulfillment (
    fulfillment_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    response_id VARCHAR(50),
    blood_bag_id VARCHAR(100),
    donor_id VARCHAR(50),
    hospital_id VARCHAR(50),
    fulfillment_status ENUM('PENDING', 'COLLECTED', 'IN_TRANSIT', 'DELIVERED', 'USED', 'CANCELLED') DEFAULT 'PENDING',
    collection_center_id VARCHAR(50),
    collection_timestamp TIMESTAMP NULL,
    rider_id VARCHAR(50),
    delivery_start_timestamp TIMESTAMP NULL,
    delivery_end_timestamp TIMESTAMP NULL,
    blood_used_timestamp TIMESTAMP NULL,
    temperature_maintained BOOLEAN DEFAULT FALSE,
    fulfillment_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    FOREIGN KEY (response_id) REFERENCES request_responses(response_id),
    INDEX idx_request_id (request_id),
    INDEX idx_fulfillment_status (fulfillment_status)
);

-- Request Status History (Audit Trail)
CREATE TABLE request_status_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50),
    change_reason VARCHAR(500),
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id)
);
```

---

## Database 5: GEO_DB (Geolocation & Logistics)

```sql
-- Donor Locations (Real-time GPS)
CREATE TABLE donor_locations (
    location_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy_meters INT,
    location_update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location_source ENUM('GPS', 'IP', 'MANUAL') DEFAULT 'GPS',
    is_current_location BOOLEAN DEFAULT TRUE,
    INDEX idx_donor_id (donor_id),
    INDEX idx_location_update_time (location_update_time),
    SPATIAL INDEX (POINT(latitude, longitude))
);

-- Hospital Locations (Static)
CREATE TABLE hospital_locations (
    hospital_id VARCHAR(50) PRIMARY KEY,
    hospital_name VARCHAR(200),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address VARCHAR(500),
    contact_phone VARCHAR(20),
    emergency_contact VARCHAR(20),
    blood_bank_capacity INT,
    operating_hours_start TIME,
    operating_hours_end TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    SPATIAL INDEX (POINT(latitude, longitude))
);

-- Delivery Rides (1:1 with BloodFulfillment)
CREATE TABLE delivery_rides (
    ride_id VARCHAR(50) PRIMARY KEY,
    fulfillment_id VARCHAR(50) NOT NULL,
    rider_id VARCHAR(50),
    ride_status ENUM('PENDING', 'ACCEPTED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    pickup_location_hospital_id VARCHAR(50),
    delivery_location_hospital_id VARCHAR(50),
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    distance_km DECIMAL(6, 2),
    estimated_duration_minutes INT,
    pickup_complete_time TIMESTAMP NULL,
    delivery_complete_time TIMESTAMP NULL,
    min_temperature_recorded DECIMAL(4, 2),
    max_temperature_recorded DECIMAL(4, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ride_status (ride_status),
    INDEX idx_fulfillment_id (fulfillment_id)
);

-- Ride Tracking Points (1:N with DeliveryRides)
CREATE TABLE ride_tracking_points (
    tracking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ride_id VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    altitude_meters INT,
    speed_kmh DECIMAL(5, 2),
    accuracy_meters INT,
    tracking_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ride_id) REFERENCES delivery_rides(ride_id),
    INDEX idx_ride_id (ride_id),
    SPATIAL INDEX (POINT(latitude, longitude))
);

-- Distance Cache
CREATE TABLE distance_cache (
    cache_id VARCHAR(50) PRIMARY KEY,
    origin_donor_id VARCHAR(50),
    destination_hospital_id VARCHAR(50),
    distance_km DECIMAL(6, 2),
    duration_minutes INT,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE KEY unique_route (origin_donor_id, destination_hospital_id),
    INDEX idx_expires_at (expires_at)
);
```

---

## Database 6: NOTIFICATION_DB (Logs)

```sql
-- Notifications Log
CREATE TABLE notifications_log (
    notification_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(20),
    notification_type ENUM('SMS', 'EMAIL', 'PUSH', 'WHATSAPP', 'IN_APP') NOT NULL,
    title VARCHAR(255),
    content TEXT NOT NULL,
    related_request_id VARCHAR(50),
    related_response_id VARCHAR(50),
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'CRITICAL') DEFAULT 'NORMAL',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_status ENUM('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED') DEFAULT 'PENDING',
    delivery_timestamp TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    read_status BOOLEAN DEFAULT FALSE,
    failure_reason VARCHAR(500),
    INDEX idx_user_id (user_id),
    INDEX idx_sent_at (sent_at),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_priority (priority)
);

-- Notification Preferences
CREATE TABLE notification_preferences (
    preference_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    sms_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    emergency_alerts_sound BOOLEAN DEFAULT TRUE,
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Database 7: ANALYTICS_DB (Insights & Predictions)

```sql
-- Dashboard Metrics (Real-time)
CREATE TABLE dashboard_metrics (
    metric_id VARCHAR(50) PRIMARY KEY,
    metric_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_active_requests INT DEFAULT 0,
    total_donors_online INT DEFAULT 0,
    critical_requests_pending INT DEFAULT 0,
    average_response_time_minutes DECIMAL(5, 2),
    successful_fulfillments_today INT DEFAULT 0,
    total_units_distributed_today INT DEFAULT 0,
    system_uptime_percent DECIMAL(5, 2),
    INDEX idx_metric_timestamp (metric_timestamp)
);

-- Daily Stats
CREATE TABLE daily_stats (
    stat_id VARCHAR(50) PRIMARY KEY,
    stat_date DATE NOT NULL UNIQUE,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled INT DEFAULT 0,
    total_donors_active INT DEFAULT 0,
    new_donors_registered INT DEFAULT 0,
    total_units_collected INT DEFAULT 0,
    total_units_used INT DEFAULT 0,
    avg_response_time_sec INT,
    estimated_lives_saved INT,
    INDEX idx_stat_date (stat_date)
);

-- Blood Demand Forecast
CREATE TABLE blood_demand_forecast (
    forecast_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    forecast_date DATE,
    predicted_demand INT,
    confidence_percent INT,
    trend_direction ENUM('UP', 'DOWN', 'STABLE'),
    forecast_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_demand INT,
    UNIQUE KEY unique_forecast (blood_type, forecast_date),
    INDEX idx_forecast_date (forecast_date)
);

-- Donor Engagement Analytics
CREATE TABLE donor_engagement_metrics (
    engagement_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    total_donations INT DEFAULT 0,
    donations_this_year INT DEFAULT 0,
    engagement_tier ENUM('INACTIVE', 'OCCASIONAL', 'REGULAR', 'COMMITTED') DEFAULT 'OCCASIONAL',
    churn_risk_score INT,
    predicted_next_donation_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_donor_id (donor_id),
    INDEX idx_engagement_tier (engagement_tier)
);

-- Hospital Performance Analytics
CREATE TABLE hospital_performance (
    performance_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    average_fulfillment_time_minutes INT,
    operational_efficiency_score INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_hospital_id (hospital_id)
);

-- Critical Incidents
CREATE TABLE critical_incidents (
    incident_id VARCHAR(50) PRIMARY KEY,
    incident_type ENUM('STOCK_CRITICAL', 'NO_DONORS_AVAILABLE', 'DELIVERY_FAILED') NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'HIGH',
    request_id VARCHAR(50),
    blood_type_affected VARCHAR(10),
    incident_description TEXT,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    INDEX idx_incident_type (incident_type),
    INDEX idx_severity (severity)
);
```

---

## Relationships Summary

| From | To | Type | Cardinality |
|------|-----|------|-------------|
| Users | DonorProfile | FK | 1:1 |
| Users | Hospital | FK | 1:1 |
| DonorProfile | DonationHistory | FK | 1:N |
| DonorProfile | DonorGamification | FK | 1:1 |
| DonationHistory | BloodInventory | Via barcode | 1:N |
| BloodRequest | RequestResponse | FK | 1:N |
| BloodRequest | BloodFulfillment | FK | 1:N |
| RequestResponse | BloodFulfillment | FK | 1:1 |
| BloodInventory | BloodFulfillment | FK | 1:1 |
| BloodFulfillment | DeliveryRides | FK | 1:1 |
| DeliveryRides | RideTrackingPoints | FK | 1:N |
| Donor | DonorLocations | FK | 1:N |
| Hospital | HospitalLocations | FK | 1:1 |
| Users | NotificationsLog | FK | 1:N |

---

## Data Flow Between Databases

```
IDENTITY_DB
    ↓
    Creates User record
    ↓
DONOR_DB / HOSPITAL setup
    ↓
Donor creates profile → DONOR_DB
    ↓
Donor donates blood → DONATION_HISTORY (DONOR_DB)
    ↓
Blood collected → BLOOD_INVENTORY (INVENTORY_DB)
    ↓
Hospital needs blood → BLOOD_REQUESTS (REQUEST_DB)
    ↓
Matching algorithm → DONOR_MATCHING_RESULTS (REQUEST_DB)
    ↓
Notifications sent → NOTIFICATIONS_LOG (NOTIFICATION_DB)
    ↓
Donor accepts → REQUEST_RESPONSES (REQUEST_DB)
    ↓
Blood fulfillment → BLOOD_FULFILLMENT (REQUEST_DB)
    ↓
Delivery tracking → DELIVERY_RIDES + RIDE_TRACKING_POINTS (GEO_DB)
    ↓
Analytics → ANALYTICS_DB
    ↓
Gamification points awarded → DONOR_GAMIFICATION (DONOR_DB)
```

---

## SQL Initialization Order

1. Create IDENTITY_DB first (users are base entity)
2. Create DONOR_DB (depends on users)
3. Create HOSPITAL/LOCATIONS (depends on users)
4. Create INVENTORY_DB (independent)
5. Create REQUEST_DB (depends on hospital locations)
6. Create GEO_DB (depends on donors and hospitals)
7. Create NOTIFICATION_DB (independent)
8. Create ANALYTICS_DB (independent)


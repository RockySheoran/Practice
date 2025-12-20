# LifeFlow Enhanced Database Schema with Hospital Roles

## Overview
This document provides comprehensive database schema for LifeFlow Blood Donation Management System with complete hospital management, role-based access control, and advanced features.

---

## Database Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  LIFEFLOW MICROSERVICES V2.0                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ IDENTITY_DB  │  │ HOSPITAL_DB  │  │  DONOR_DB    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │ INVENTORY_DB │  │ REQUEST_DB   │  │   GEO_DB     │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │NOTIF_DB      │  │ANALYTICS_DB  │  │   AUDIT_DB   │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Database 1: IDENTITY_DB (User Authentication & Roles)

### Core Tables

#### Users Table (Enhanced)
```sql
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('DONOR', 'HOSPITAL_ADMIN', 'HOSPITAL_STAFF', 'BLOOD_BANK_MANAGER', 
              'HOSPITAL_DIRECTOR', 'ADMIN', 'SUPER_ADMIN', 'AUDITOR', 'RIDER') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'OTHER'),
    profile_photo_url VARCHAR(500),
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED', 'PENDING_VERIFICATION', 'SUSPENDED') DEFAULT 'PENDING_VERIFICATION',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    kyc_verified BOOLEAN DEFAULT FALSE,
    kyc_document_url VARCHAR(500),
    kyc_document_type ENUM('AADHAAR', 'PAN', 'PASSPORT', 'DRIVING_LICENSE'),
    kyc_verified_at TIMESTAMP NULL,
    kyc_verified_by VARCHAR(50),
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_method ENUM('SMS', 'EMAIL', 'AUTHENTICATOR_APP'),
    last_password_change TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    login_attempt_count INT DEFAULT 0,
    locked_until TIMESTAMP NULL,
    device_token_fcm VARCHAR(500), -- Firebase Cloud Messaging
    preferred_language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    updated_by VARCHAR(50),
    deleted_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);

-- Roles and Permissions Mapping
CREATE TABLE role_permissions (
    role_permission_id VARCHAR(50) PRIMARY KEY,
    role VARCHAR(50) NOT NULL,
    permission_code VARCHAR(100) NOT NULL,
    permission_name VARCHAR(200),
    resource_type VARCHAR(50), -- DONOR, HOSPITAL, INVENTORY, REQUEST, etc.
    action ENUM('READ', 'CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'REJECT'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_role_permission (role, permission_code),
    INDEX idx_role (role),
    INDEX idx_permission_code (permission_code)
);

-- User Role Assignment
CREATE TABLE user_roles (
    user_role_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    assigned_by VARCHAR(50),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL, -- For temporary role assignments
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_user_role (user_id, role),
    INDEX idx_user_id (user_id),
    INDEX idx_role (role)
);

-- OAuth2 Tokens (Enhanced)
CREATE TABLE oauth2_tokens (
    token_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    access_token VARCHAR(500) NOT NULL,
    refresh_token VARCHAR(500),
    token_type ENUM('BEARER', 'BASIC', 'JWT') DEFAULT 'BEARER',
    expires_at TIMESTAMP NOT NULL,
    refresh_expires_at TIMESTAMP NULL,
    scope VARCHAR(255), -- List of permissions granted
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMP NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_access_token (access_token),
    INDEX idx_expires_at (expires_at),
    UNIQUE KEY unique_refresh_token (refresh_token)
);

-- Biometric Profiles (Security)
CREATE TABLE biometric_profiles (
    biometric_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    fingerprint_hash VARCHAR(500),
    face_recognition_embedding LONGBLOB,
    iris_scan_hash VARCHAR(500),
    biometric_type ENUM('FINGERPRINT', 'FACE', 'IRIS', 'MULTIMODAL'),
    verified_at TIMESTAMP NULL,
    last_verified TIMESTAMP NULL,
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id)
);

-- Audit Logs (Compliance)
CREATE TABLE audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_value LONGTEXT,
    new_value LONGTEXT,
    change_description VARCHAR(500),
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    status ENUM('SUCCESS', 'FAILED', 'UNAUTHORIZED') DEFAULT 'SUCCESS',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_action (action),
    INDEX idx_resource_type (resource_type)
);
```

---

## Database 2: HOSPITAL_DB (Hospital Management)

### Core Tables

#### Hospital Profiles
```sql
CREATE TABLE hospital_profiles (
    hospital_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    hospital_name VARCHAR(255) NOT NULL,
    hospital_type ENUM('GOVERNMENT', 'PRIVATE', 'NGO', 'RESEARCH', 'MILITARY') NOT NULL,
    license_number VARCHAR(100) UNIQUE,
    license_expiry_date DATE,
    registration_number VARCHAR(100) UNIQUE,
    nab_accreditation BOOLEAN DEFAULT FALSE, -- National Accreditation Board
    aabb_accreditation BOOLEAN DEFAULT FALSE, -- American Association Blood Banks
    iso_certification VARCHAR(100),
    total_beds INT,
    icu_beds INT,
    trauma_beds INT,
    blood_bank_capacity INT NOT NULL,
    founded_year INT,
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_APPROVAL') DEFAULT 'PENDING_APPROVAL',
    approval_status ENUM('APPROVED', 'REJECTED', 'PENDING', 'UNDER_REVIEW'),
    approved_by VARCHAR(50),
    approved_at TIMESTAMP NULL,
    verification_status ENUM('VERIFIED', 'UNVERIFIED', 'REJECTED') DEFAULT 'UNVERIFIED',
    verified_by VARCHAR(50),
    verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_hospital_type (hospital_type),
    INDEX idx_status (status),
    INDEX idx_approval_status (approval_status)
);

#### Hospital Contact Information
```sql
CREATE TABLE hospital_contact_info (
    contact_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL UNIQUE,
    primary_phone VARCHAR(20) NOT NULL,
    secondary_phone VARCHAR(20),
    emergency_hotline VARCHAR(20) NOT NULL,
    admin_email VARCHAR(255) NOT NULL,
    blood_bank_email VARCHAR(255),
    emergency_contact_person_name VARCHAR(100),
    emergency_contact_person_phone VARCHAR(20),
    emergency_contact_person_title VARCHAR(100),
    website_url VARCHAR(500),
    fax VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    INDEX idx_hospital_id (hospital_id)
);
```

#### Hospital Addresses (Multiple)
```sql
CREATE TABLE hospital_addresses (
    address_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    address_type ENUM('PRIMARY', 'SECONDARY', 'BLOOD_BANK', 'EMERGENCY_WARD', 'SURGERY_BLOCK'),
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_address_type (address_type),
    SPATIAL INDEX (POINT(latitude, longitude))
);
```

#### Hospital Operating Hours
```sql
CREATE TABLE hospital_operating_hours (
    operating_hour_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    day_of_week ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'),
    is_open BOOLEAN DEFAULT TRUE,
    opening_time TIME,
    closing_time TIME,
    emergency_available_24_7 BOOLEAN DEFAULT TRUE,
    lunch_break_start TIME,
    lunch_break_end TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    UNIQUE KEY unique_hospital_day (hospital_id, day_of_week),
    INDEX idx_hospital_id (hospital_id)
);
```

#### Hospital Staff Management
```sql
CREATE TABLE hospital_staff (
    staff_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    staff_role ENUM('BLOOD_BANK_MANAGER', 'PHLEBOTOMIST', 'LAB_TECHNICIAN', 
                    'ADMIN_STAFF', 'EMERGENCY_COORDINATOR', 'QUALITY_OFFICER',
                    'INVENTORY_MANAGER', 'DIRECTOR', 'DEPUTY_DIRECTOR') NOT NULL,
    department VARCHAR(100),
    designation VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE,
    license_number VARCHAR(100),
    license_expiry_date DATE,
    certification ENUM('CERTIFIED', 'UNCERTIFIED') DEFAULT 'UNCERTIFIED',
    specialization VARCHAR(200),
    years_of_experience INT,
    shift_timing ENUM('DAY', 'NIGHT', 'FLEXIBLE', 'ON_CALL') DEFAULT 'DAY',
    is_shift_supervisor BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    hire_date DATE,
    termination_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_user_id (user_id),
    INDEX idx_staff_role (staff_role)
);
```

#### Hospital Blood Bank Equipment
```sql
CREATE TABLE hospital_blood_bank_equipment (
    equipment_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_type ENUM('REFRIGERATOR', 'FREEZER', 'INCUBATOR', 'CENTRIFUGE', 
                        'BLOOD_WARMER', 'SEPARATOR', 'TESTING_MACHINE', 'SCANNER'),
    manufacturer VARCHAR(100),
    model_number VARCHAR(100),
    serial_number VARCHAR(100) UNIQUE,
    installation_date DATE,
    warranty_expiry_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    operating_status ENUM('OPERATIONAL', 'UNDER_MAINTENANCE', 'FAULTY', 'DECOMMISSIONED'),
    temperature_range_min DECIMAL(5, 2),
    temperature_range_max DECIMAL(5, 2),
    storage_capacity INT, -- in units
    has_backup_power BOOLEAN DEFAULT FALSE,
    has_temperature_monitoring BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_operating_status (operating_status)
);
```

#### Hospital Service Offerings
```sql
CREATE TABLE hospital_services (
    service_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    service_type ENUM('WHOLE_BLOOD_COLLECTION', 'PLASMA_COLLECTION', 'PLATELET_COLLECTION',
                      'APHERESIS', 'BLOOD_TRANSFUSION', 'BLOOD_TESTING', 'CRYOPRESERVATION',
                      'COMPONENT_SEPARATION', 'EMERGENCY_BLOOD_DELIVERY', 'TRAINING_PROGRAMS'),
    service_name VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    capacity_per_day INT,
    average_processing_time_minutes INT,
    requires_appointment BOOLEAN DEFAULT TRUE,
    cost_per_unit DECIMAL(8, 2),
    service_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    UNIQUE KEY unique_hospital_service (hospital_id, service_type),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_service_type (service_type)
);
```

#### Hospital Performance Metrics
```sql
CREATE TABLE hospital_metrics (
    metric_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    metric_month DATE NOT NULL,
    total_requests_received INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled_requests INT DEFAULT 0,
    avg_fulfillment_time_minutes INT,
    avg_response_time_minutes INT,
    blood_waste_percent DECIMAL(5, 2),
    quality_pass_rate_percent DECIMAL(5, 2),
    donor_satisfaction_score INT, -- 0-100
    staff_efficiency_score INT, -- 0-100
    equipment_uptime_percent DECIMAL(5, 2),
    critical_incidents INT DEFAULT 0,
    emergency_response_count INT DEFAULT 0,
    units_transfused INT DEFAULT 0,
    estimated_lives_saved INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    UNIQUE KEY unique_hospital_month (hospital_id, metric_month),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_metric_month (metric_month)
);
```

#### Hospital Blood Requirements Forecast
```sql
CREATE TABLE hospital_blood_requirements (
    requirement_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'),
    forecast_date DATE,
    average_daily_demand INT,
    peak_demand INT,
    buffer_stock_recommended INT,
    critical_level INT DEFAULT 2,
    safe_level INT DEFAULT 10,
    notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    UNIQUE KEY unique_hospital_blood_type (hospital_id, blood_type, forecast_date),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_forecast_date (forecast_date)
);
```

#### Hospital Certifications & Compliance
```sql
CREATE TABLE hospital_certifications (
    certification_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    certification_name VARCHAR(100) NOT NULL,
    certification_body VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    certificate_url VARCHAR(500),
    compliance_status ENUM('COMPLIANT', 'NON_COMPLIANT', 'PENDING_RENEWAL', 'EXPIRED'),
    audit_score INT, -- 0-100
    last_audit_date DATE,
    next_audit_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_certification_name (certification_name),
    INDEX idx_expiry_date (expiry_date)
);
```

#### Hospital Protocols & SLAs
```sql
CREATE TABLE hospital_service_level_agreements (
    sla_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    sla_name VARCHAR(100),
    emergency_response_time_minutes INT, -- SLA for CRITICAL requests
    urgent_response_time_minutes INT, -- SLA for HIGH requests
    normal_response_time_minutes INT, -- SLA for MEDIUM requests
    minimum_fulfillment_rate_percent DECIMAL(5, 2),
    minimum_uptime_percent DECIMAL(5, 2),
    penalty_for_breach DECIMAL(8, 2),
    reward_for_exceeding DECIMAL(8, 2),
    effective_date DATE,
    expiry_date DATE,
    status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospital_profiles(hospital_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_status (status)
);
```

---

## Database 3: DONOR_DB (Enhanced Donor Management)

```sql
-- DONOR PROFILES (1:1 with Users)
CREATE TABLE donor_profiles (
    donor_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    date_of_birth DATE NOT NULL,
    age INT GENERATED ALWAYS AS (YEAR(CURDATE()) - YEAR(date_of_birth)) STORED,
    gender ENUM('M', 'F', 'OTHER'),
    weight_kg DECIMAL(5, 2),
    height_cm INT,
    bmi DECIMAL(4, 2) GENERATED ALWAYS AS (weight_kg / ((height_cm / 100) * (height_cm / 100))) STORED,
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    hemoglobin_level DECIMAL(4, 2),
    pulse_rate INT,
    body_temperature DECIMAL(4, 2),
    chronic_diseases VARCHAR(500),
    allergies VARCHAR(500),
    medications TEXT,
    tattoo_date DATE,
    recent_travel VARCHAR(500),
    vaccination_status VARCHAR(100),
    preferred_collection_center_id VARCHAR(50),
    preferred_donation_day ENUM('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'),
    preferred_donation_time ENUM('MORNING', 'AFTERNOON', 'EVENING'),
    notification_preference VARCHAR(50),
    eligibility_status ENUM('ELIGIBLE', 'TEMPORARY_BLOCKED', 'PERMANENTLY_BLOCKED', 'PENDING_VERIFICATION') DEFAULT 'PENDING_VERIFICATION',
    block_reason VARCHAR(500),
    block_until TIMESTAMP NULL,
    verification_status ENUM('VERIFIED', 'UNVERIFIED', 'REJECTED') DEFAULT 'UNVERIFIED',
    verified_by VARCHAR(50),
    verified_at TIMESTAMP NULL,
    last_eligibility_check TIMESTAMP NULL,
    health_risk_category ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_blood_type (blood_type),
    INDEX idx_eligibility_status (eligibility_status),
    INDEX idx_age (age)
);

-- DONATION HISTORY (with enhanced tracking)
CREATE TABLE donation_history (
    donation_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    donation_date TIMESTAMP NOT NULL,
    donation_type ENUM('WHOLE_BLOOD', 'PLASMA', 'PLATELETS', 'RED_CELLS', 'APHERESIS') DEFAULT 'WHOLE_BLOOD',
    blood_type_collected ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'),
    units_collected DECIMAL(3, 1),
    collection_center_id VARCHAR(50),
    collecting_staff_id VARCHAR(50),
    health_score_before INT,
    health_score_after INT,
    hemoglobin_before DECIMAL(4, 2),
    hemoglobin_after DECIMAL(4, 2),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    donation_duration_minutes INT,
    pre_donation_notes TEXT,
    post_donation_notes TEXT,
    staff_notes TEXT,
    adverse_events ENUM('NONE', 'FAINTING', 'NAUSEA', 'DIZZINESS', 'BRUISING', 'NERVE_DAMAGE', 'OTHER'),
    adverse_event_details VARCHAR(500),
    donation_status ENUM('SUCCESSFUL', 'INCOMPLETE', 'REJECTED', 'FAILED') DEFAULT 'SUCCESSFUL',
    rejection_reason VARCHAR(500),
    bag_barcode VARCHAR(100),
    next_eligible_date DATE,
    points_earned INT DEFAULT 100,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_donation_date (donation_date),
    INDEX idx_donation_status (donation_status),
    INDEX idx_blood_type_collected (blood_type_collected)
);

-- DONOR GAMIFICATION (1:1 with DonorProfile)
CREATE TABLE donor_gamification (
    gamification_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL UNIQUE,
    total_points INT DEFAULT 0,
    total_donations INT DEFAULT 0,
    estimated_lives_saved INT DEFAULT 0,
    badge_level ENUM('BRONZE', 'SILVER', 'GOLD', 'PLATINUM', 'LEGEND') DEFAULT 'BRONZE',
    badge_progress_percent INT, -- 0-100 for next badge
    total_badges_earned INT DEFAULT 0,
    achievement_milestones JSON,
    hero_of_month_count INT DEFAULT 0,
    hero_of_year_count INT DEFAULT 0,
    top_donor_rank INT,
    loyalty_score INT DEFAULT 0,
    referral_count INT DEFAULT 0,
    last_donation_date DATE,
    consecutive_donations INT DEFAULT 0,
    personal_best_donation_streak INT,
    impact_score INT, -- Calculated based on contributions
    leaderboard_position INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_badge_level (badge_level),
    INDEX idx_top_donor_rank (top_donor_rank),
    INDEX idx_leaderboard_position (leaderboard_position)
);

-- ELIGIBILITY CHECKS (with detailed rules)
CREATE TABLE eligibility_checks (
    check_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    days_since_last_donation INT,
    minimum_donation_interval_days INT DEFAULT 56,
    minimum_weight_kg DECIMAL(5, 2),
    actual_weight_kg DECIMAL(5, 2),
    minimum_hemoglobin DECIMAL(4, 2),
    actual_hemoglobin DECIMAL(4, 2),
    age_years INT,
    age_min INT DEFAULT 18,
    age_max INT DEFAULT 65,
    bmi_value DECIMAL(4, 2),
    bmi_min DECIMAL(4, 2) DEFAULT 18.5,
    bmi_max DECIMAL(4, 2) DEFAULT 29.9,
    medical_conditions_clear BOOLEAN,
    medications_allowed BOOLEAN,
    travel_risk BOOLEAN,
    tattoo_risk BOOLEAN,
    vaccination_clear BOOLEAN,
    acute_illness_present BOOLEAN DEFAULT FALSE,
    chronic_condition_status VARCHAR(100),
    overall_eligible BOOLEAN,
    eligibility_score INT, -- 0-100
    reason_if_ineligible VARCHAR(500),
    next_eligibility_check_date DATE,
    checked_by_system TIMESTAMP,
    checked_by_staff VARCHAR(50),
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_check_timestamp (check_timestamp),
    INDEX idx_overall_eligible (overall_eligible)
);
```

---

## Database 4: INVENTORY_DB (Blood Bank Management)

```sql
CREATE TABLE blood_inventory (
    bag_id VARCHAR(100) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    donation_id VARCHAR(50),
    donor_id_anonymized VARCHAR(50),
    donation_date TIMESTAMP NOT NULL,
    collection_date TIMESTAMP,
    processing_date TIMESTAMP,
    expiry_date TIMESTAMP NOT NULL,
    days_remaining_calculated INT GENERATED ALWAYS AS (DATEDIFF(expiry_date, CURDATE())) STORED,
    storage_location VARCHAR(100),
    fridge_id VARCHAR(50),
    storage_temperature DECIMAL(5, 2),
    temperature_monitoring_device_id VARCHAR(50),
    barcode VARCHAR(100) UNIQUE,
    rfid_tag VARCHAR(100) UNIQUE,
    qr_code_url VARCHAR(500),
    status ENUM('AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'USED', 'EXPIRED', 'DISCARDED', 'QUARANTINE') DEFAULT 'AVAILABLE',
    reserved_for_request_id VARCHAR(50),
    reserved_at TIMESTAMP NULL,
    reserved_by_hospital_id VARCHAR(50),
    blood_component_type ENUM('WHOLE_BLOOD', 'RBC', 'PLASMA', 'PLATELETS', 'CRYOPRECIPITATE', 'FFP'),
    units_available DECIMAL(3, 1),
    unit_cost DECIMAL(8, 2),
    quality_check_status ENUM('PASS', 'FAIL', 'PENDING') DEFAULT 'PENDING',
    quality_check_date TIMESTAMP NULL,
    quality_checked_by VARCHAR(50),
    test_results JSON, -- pathogen tests, viability, sterility
    shelf_life_days INT DEFAULT 42,
    parent_batch_id VARCHAR(50),
    storage_facility_id VARCHAR(50),
    is_irradiated BOOLEAN DEFAULT FALSE,
    is_leukocyte_reduced BOOLEAN DEFAULT FALSE,
    transfusion_status ENUM('NOT_USED', 'PARTIALLY_USED', 'FULLY_USED') DEFAULT 'NOT_USED',
    transfusion_date TIMESTAMP NULL,
    transfused_to_patient_id VARCHAR(100), -- Anonymized
    transfusion_location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_status (status),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_days_remaining_calculated (days_remaining_calculated),
    INDEX idx_batch_number (batch_number),
    INDEX idx_reserved_for_request_id (reserved_for_request_id),
    INDEX idx_storage_location (storage_location),
    INDEX idx_quality_check_status (quality_check_status)
);

-- STOCK SUMMARY (Real-time)
CREATE TABLE stock_summary (
    stock_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL UNIQUE,
    total_available_units INT DEFAULT 0,
    total_reserved_units INT DEFAULT 0,
    total_in_transit_units INT DEFAULT 0,
    total_expired_units INT DEFAULT 0,
    total_used_units INT DEFAULT 0,
    reorder_threshold INT DEFAULT 5,
    critical_threshold INT DEFAULT 2,
    alert_triggered BOOLEAN DEFAULT FALSE,
    alert_type ENUM('WARNING', 'CRITICAL', 'URGENT'),
    alert_triggered_at TIMESTAMP NULL,
    percent_of_capacity INT,
    demand_forecast_next_24h INT,
    supply_adequate_status BOOLEAN,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_alert_triggered (alert_triggered)
);

-- TEMPERATURE MONITORING (IoT Integration)
CREATE TABLE temperature_monitoring (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fridge_id VARCHAR(50) NOT NULL,
    bag_id VARCHAR(100),
    temperature DECIMAL(5, 2) NOT NULL,
    humidity DECIMAL(5, 2),
    reading_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_triggered BOOLEAN DEFAULT FALSE,
    alert_type ENUM('TOO_HIGH', 'TOO_LOW', 'RAPID_CHANGE', 'DOOR_OPEN', 'NONE') DEFAULT 'NONE',
    alert_severity ENUM('INFO', 'WARNING', 'CRITICAL'),
    data_source VARCHAR(50), -- e.g., 'SENSOR_IOT', 'MANUAL_CHECK'
    notification_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_fridge_id (fridge_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_reading_time (reading_time),
    INDEX idx_alert_triggered (alert_triggered)
);

-- INVENTORY TRANSACTIONS LOG (Audit Trail)
CREATE TABLE inventory_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    transaction_type ENUM('IN', 'OUT', 'RESERVE', 'RELEASE', 'TRANSFER', 'DISCARD', 'QUALITY_CHECK', 'IRRADIATION') NOT NULL,
    quantity_change DECIMAL(3, 1),
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    from_hospital_id VARCHAR(50),
    to_hospital_id VARCHAR(50),
    request_id VARCHAR(50),
    notes TEXT,
    performed_by VARCHAR(50),
    approval_by VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_request_id (request_id)
);

-- EXPIRY MANAGEMENT
CREATE TABLE expiry_management (
    expiry_alert_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    days_until_expiry INT,
    alert_level ENUM('WARNING', 'CRITICAL', 'EXPIRED') DEFAULT 'WARNING',
    alert_sent_at TIMESTAMP NULL,
    alert_sent_to_staff_ids JSON,
    resolution_action ENUM('DISCARDED', 'TRANSFERRED', 'USED', 'EXTENDED') DEFAULT NULL,
    resolved_at TIMESTAMP NULL,
    resolver_notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_alert_level (alert_level)
);
```

---

## Database 5: REQUEST_DB (Emergency Request Management)

```sql
CREATE TABLE blood_requests (
    request_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    requesting_staff_id VARCHAR(50) NOT NULL,
    blood_type_needed ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    units_required DECIMAL(3, 1) NOT NULL,
    urgency_level ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    urgency_numeric_score INT, -- 0-100 for ML
    patient_id_anonymized VARCHAR(100),
    patient_age INT,
    patient_gender ENUM('M', 'F', 'OTHER'),
    patient_weight_kg DECIMAL(5, 2),
    patient_condition VARCHAR(500),
    procedure_type VARCHAR(100),
    procedure_scheduled_time TIMESTAMP,
    special_requirements VARCHAR(500), -- e.g., irradiated, specific donor requirements
    deadline_minutes INT,
    deadline_timestamp TIMESTAMP,
    alternative_blood_types VARCHAR(100), -- compatible blood types
    status ENUM('PENDING', 'MATCHED', 'ACCEPTED', 'FULFILLED', 'PARTIAL_FULFILLED', 'CANCELLED', 'EXPIRED') DEFAULT 'PENDING',
    blood_bank_stock_checked BOOLEAN DEFAULT FALSE,
    donor_search_initiated BOOLEAN DEFAULT FALSE,
    gps_location_hospital VARCHAR(100),
    backup_hospital_id VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
    otp_attempts INT DEFAULT 0,
    otp_max_attempts INT DEFAULT 3,
    donor_arrival_at_center TIMESTAMP NULL,
    collection_completed_at TIMESTAMP NULL,
    rejection_reason VARCHAR(500),
    response_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    points_offered INT DEFAULT 100,
    points_claimed_at TIMESTAMP NULL,
    blood_bag_assigned_id VARCHAR(100),
    matched_score INT, -- 0-100 compatibility score
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_response_status (response_status)
);

CREATE TABLE donor_matching_results (
    match_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    donor_id VARCHAR(50) NOT NULL,
    blood_type_compatibility ENUM('EXACT', 'COMPATIBLE', 'ACCEPTABLE', 'INCOMPATIBLE'),
    distance_km DECIMAL(6, 2),
    distance_score INT, -- 0-30 points
    donor_availability_score INT, -- 0-20 points
    donor_reliability_score INT, -- 0-20 points
    donor_response_time_minutes INT,
    urgency_multiplier DECIMAL(2, 1),
    final_match_score INT, -- 0-100
    match_rank INT,
    notification_sent_at TIMESTAMP NULL,
    match_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_final_match_score (final_match_score)
);

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
    delivered_to_hospital_timestamp TIMESTAMP NULL,
    blood_used_timestamp TIMESTAMP NULL,
    patient_outcome ENUM('RECOVERED', 'STABLE', 'CRITICAL', 'DECEASED') DEFAULT 'STABLE',
    temperature_maintained BOOLEAN DEFAULT FALSE,
    delivery_notes TEXT,
    fulfillment_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fulfillment_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    FOREIGN KEY (response_id) REFERENCES request_responses(response_id),
    INDEX idx_request_id (request_id),
    INDEX idx_fulfillment_status (fulfillment_status)
);

CREATE TABLE request_status_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50),
    change_reason VARCHAR(500),
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_changed_at (changed_at)
);
```

---

## Database 6: GEO_DB (Geolocation & Logistics)

```sql
CREATE TABLE delivery_rides (
    ride_id VARCHAR(50) PRIMARY KEY,
    fulfillment_id VARCHAR(50) NOT NULL,
    rider_id VARCHAR(50),
    rider_vehicle_type ENUM('MOTORCYCLE', 'CAR', 'BICYCLE', 'AMBULANCE') DEFAULT 'MOTORCYCLE',
    rider_vehicle_registration VARCHAR(50),
    ride_status ENUM('PENDING', 'ACCEPTED', 'ARRIVING_AT_PICKUP', 'AT_PICKUP', 'DEPARTED_PICKUP', 
                     'IN_TRANSIT', 'ARRIVING_AT_DELIVERY', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    pickup_location_hospital_id VARCHAR(50),
    delivery_location_hospital_id VARCHAR(50),
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    distance_km DECIMAL(6, 2),
    estimated_duration_minutes INT,
    ride_accepted_at TIMESTAMP NULL,
    pickup_start_time TIMESTAMP NULL,
    pickup_complete_time TIMESTAMP NULL,
    delivery_start_time TIMESTAMP NULL,
    delivery_complete_time TIMESTAMP NULL,
    actual_duration_minutes INT,
    temperature_maintained BOOLEAN DEFAULT FALSE,
    min_temperature_recorded DECIMAL(4, 2),
    max_temperature_recorded DECIMAL(4, 2),
    temperature_violation_count INT DEFAULT 0,
    ride_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ride_status (ride_status),
    INDEX idx_fulfillment_id (fulfillment_id),
    INDEX idx_rider_id (rider_id)
);

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
    INDEX idx_tracking_timestamp (tracking_timestamp),
    SPATIAL INDEX (POINT(latitude, longitude))
);

CREATE TABLE geofence_alerts (
    alert_id VARCHAR(50) PRIMARY KEY,
    ride_id VARCHAR(50),
    donor_id VARCHAR(50),
    alert_type ENUM('ENTERED_RADIUS', 'EXITED_RADIUS', 'ARRIVED_AT_PICKUP', 'LEFT_PICKUP', 'ARRIVED_AT_DESTINATION'),
    geofence_radius_km DECIMAL(4, 2),
    alert_triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notification_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ride_id) REFERENCES delivery_rides(ride_id),
    INDEX idx_ride_id (ride_id)
);

CREATE TABLE distance_cache (
    cache_id VARCHAR(50) PRIMARY KEY,
    origin_donor_id VARCHAR(50),
    origin_hospital_id VARCHAR(50),
    destination_hospital_id VARCHAR(50),
    distance_km DECIMAL(6, 2),
    duration_minutes INT,
    route_summary VARCHAR(500),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE KEY unique_route (origin_donor_id, origin_hospital_id, destination_hospital_id),
    INDEX idx_expires_at (expires_at)
);

CREATE TABLE donor_locations (
    location_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy_meters INT,
    location_update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location_source ENUM('GPS', 'IP', 'MANUAL', 'CELL_TOWER'),
    is_current_location BOOLEAN DEFAULT TRUE,
    INDEX idx_donor_id (donor_id),
    INDEX idx_location_update_time (location_update_time),
    SPATIAL INDEX (POINT(latitude, longitude))
);

CREATE TABLE hospital_locations (
    hospital_location_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL UNIQUE,
    hospital_name VARCHAR(200),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address VARCHAR(500),
    contact_phone VARCHAR(20),
    emergency_hotline VARCHAR(20),
    blood_bank_capacity INT,
    operating_hours_start TIME,
    operating_hours_end TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    SPATIAL INDEX (POINT(latitude, longitude))
);
```

---

## Database 7: NOTIFICATION_DB (Notifications & Communication)

```sql
CREATE TABLE notifications_log (
    notification_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(20),
    recipient_whatsapp VARCHAR(20),
    notification_type ENUM('SMS', 'EMAIL', 'PUSH', 'WHATSAPP', 'IN_APP', 'VOICE_CALL') NOT NULL,
    channel VARCHAR(50),
    title VARCHAR(255),
    content TEXT NOT NULL,
    related_request_id VARCHAR(50),
    related_response_id VARCHAR(50),
    related_donation_id VARCHAR(50),
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'CRITICAL') DEFAULT 'NORMAL',
    template_name VARCHAR(100),
    template_variables JSON,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_status ENUM('PENDING', 'QUEUED', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED') DEFAULT 'PENDING',
    delivery_timestamp TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    read_status BOOLEAN DEFAULT FALSE,
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    failure_reason VARCHAR(500),
    provider_message_id VARCHAR(100),
    INDEX idx_user_id (user_id),
    INDEX idx_sent_at (sent_at),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_notification_type (notification_type),
    INDEX idx_priority (priority)
);

CREATE TABLE notification_preferences (
    preference_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    sms_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    whatsapp_enabled BOOLEAN DEFAULT FALSE,
    in_app_enabled BOOLEAN DEFAULT TRUE,
    emergency_alerts_sound BOOLEAN DEFAULT TRUE,
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    time_zone VARCHAR(50) DEFAULT 'UTC',
    language_preference VARCHAR(10) DEFAULT 'en',
    marketing_notifications BOOLEAN DEFAULT TRUE,
    donation_reminders BOOLEAN DEFAULT TRUE,
    emergency_only_notifications BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE notification_templates (
    template_id VARCHAR(50) PRIMARY KEY,
    template_name VARCHAR(100) UNIQUE NOT NULL,
    template_type ENUM('SMS', 'EMAIL', 'PUSH', 'WHATSAPP', 'ALL'),
    subject VARCHAR(255),
    body_template TEXT NOT NULL,
    variables_schema JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_template_name (template_name)
);
```

---

## Database 8: ANALYTICS_DB (Analytics & Insights)

```sql
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
    blood_shortage_alerts INT DEFAULT 0,
    INDEX idx_metric_timestamp (metric_timestamp)
);

CREATE TABLE daily_stats (
    stat_id VARCHAR(50) PRIMARY KEY,
    stat_date DATE NOT NULL UNIQUE,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled INT DEFAULT 0,
    expired_requests INT DEFAULT 0,
    total_donors_active INT DEFAULT 0,
    new_donors_registered INT DEFAULT 0,
    total_units_collected INT DEFAULT 0,
    total_units_used INT DEFAULT 0,
    hospitals_served INT DEFAULT 0,
    avg_response_time_sec INT,
    estimated_lives_saved INT,
    INDEX idx_stat_date (stat_date)
);

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

CREATE TABLE hospital_performance (
    performance_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled INT DEFAULT 0,
    average_fulfillment_time_minutes INT,
    operational_efficiency_score INT,
    donor_satisfaction_score INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_hospital_id (hospital_id)
);

CREATE TABLE critical_incidents (
    incident_id VARCHAR(50) PRIMARY KEY,
    incident_type ENUM('STOCK_CRITICAL', 'NO_DONORS_AVAILABLE', 'DELIVERY_FAILED', 'QUALITY_ISSUE') NOT NULL,
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

## Key Relationships Summary

| Entity 1 | Entity 2 | Relationship | Cardinality |
|----------|----------|--------------|-------------|
| Users | Hospital_Profiles | FK | 1:1 |
| Users | Donor_Profiles | FK | 1:1 |
| Users | Hospital_Staff | FK | 1:N |
| Users | User_Roles | FK | 1:N |
| Hospital_Profiles | Hospital_Contact_Info | FK | 1:1 |
| Hospital_Profiles | Hospital_Addresses | FK | 1:N |
| Hospital_Profiles | Hospital_Staff | FK | 1:N |
| Hospital_Profiles | Hospital_Services | FK | 1:N |
| Hospital_Profiles | Hospital_Metrics | FK | 1:N |
| Donor_Profiles | Donation_History | FK | 1:N |
| Donor_Profiles | Donor_Gamification | FK | 1:1 |
| Donor_Profiles | Eligibility_Checks | FK | 1:N |
| Blood_Requests | Request_Responses | FK | 1:N |
| Blood_Requests | Blood_Fulfillment | FK | 1:N |
| Request_Responses | Blood_Fulfillment | FK | 1:1 |
| Blood_Inventory | Blood_Fulfillment | FK | 1:1 |
| Blood_Fulfillment | Delivery_Rides | FK | 1:1 |
| Delivery_Rides | Ride_Tracking_Points | FK | 1:N |

---

## Data Flow

```
User Registration → IDENTITY_DB
    ↓
Hospital Registration → HOSPITAL_DB
    ↓
Hospital Staff Setup → HOSPITAL_STAFF
    ↓
Donor Registration → IDENTITY_DB → DONOR_DB
    ↓
Donation Process → DONATION_HISTORY → BLOOD_INVENTORY (INVENTORY_DB)
    ↓
Hospital Blood Request → BLOOD_REQUESTS (REQUEST_DB)
    ↓
Matching Algorithm → DONOR_MATCHING_RESULTS
    ↓
Donor Notification → NOTIFICATIONS_LOG (NOTIFICATION_DB)
    ↓
Donor Accepts → REQUEST_RESPONSES
    ↓
Blood Collection → BLOOD_FULFILLMENT
    ↓
Delivery & Tracking → DELIVERY_RIDES + RIDE_TRACKING_POINTS (GEO_DB)
    ↓
Analytics & Insights → ANALYTICS_DB
    ↓
Gamification Points → DONOR_GAMIFICATION
```

This comprehensive schema supports the complete LifeFlow system with robust hospital management, role-based access control, and advanced analytics.

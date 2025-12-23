# LifeFlow Blood Donation System - Comprehensive Database Schema

## Database Architecture Overview

The LifeFlow system follows the **Database-per-Service** pattern where each microservice has its own dedicated PostgreSQL database. This ensures data isolation, independent scaling, and fault tolerance.

## Database List

| Service | Database Name | Port | Purpose |
|---------|---------------|------|---------|
| Identity Service | `lifeflow_identity` | 5432 | User authentication and authorization |
| Donor Service | `lifeflow_donor` | 5433 | Donor management and profiles |
| Hospital Service | `lifeflow_hospital` | 5434 | Hospital and staff management |
| Inventory Service | `lifeflow_inventory` | 5435 | Blood inventory and stock management |
| Request Service | `lifeflow_request` | 5436 | Blood requests and matching |
| Geolocation Service | `lifeflow_geolocation` | 5437 | Location and routing services |
| Notification Service | `lifeflow_notification` | 5438 | Multi-channel notifications |
| Camp Service | `lifeflow_camp` | 5439 | Donation camps and events |
| Analytics Service | `lifeflow_analytics` | 5440 | Analytics and reporting |
| Gamification Service | `lifeflow_gamification` | 5441 | Rewards and gamification |

---

## 1. Identity Service Database (`lifeflow_identity`)

### Tables

#### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    profile_image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    email_verified_at TIMESTAMP,
    phone_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    locked_until TIMESTAMP,
    password_reset_token VARCHAR(255),
    password_reset_expires_at TIMESTAMP,
    two_factor_enabled BOOLEAN DEFAULT false,
    two_factor_secret VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_users_verified ON users(is_verified);
```

#### roles
```sql
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT false,
    permissions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default roles
INSERT INTO roles (name, description, is_system_role, permissions) VALUES
('SUPER_ADMIN', 'Super Administrator with full system access', true, '["*"]'),
('ADMIN', 'System Administrator', true, '["user:*", "donor:*", "hospital:*", "inventory:*", "request:*", "analytics:*"]'),
('DONOR', 'Blood Donor', true, '["donor:read", "donor:update", "request:read", "camp:read"]'),
('HOSPITAL_ADMIN', 'Hospital Administrator', true, '["hospital:*", "staff:*", "request:*", "inventory:read"]'),
('HOSPITAL_STAFF', 'Hospital Staff Member', true, '["request:create", "request:read", "inventory:read", "donor:read"]'),
('CAMP_ORGANIZER', 'Donation Camp Organizer', true, '["camp:*", "donor:read", "volunteer:*"]'),
('LAB_TECHNICIAN', 'Laboratory Technician', true, '["inventory:*", "quality:*", "testing:*"]');
```

#### user_roles
```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_active ON user_roles(is_active);
```

#### user_sessions
```sql
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP NOT NULL,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);
```

#### audit_logs
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id VARCHAR(100),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
```

---

## 2. Donor Service Database (`lifeflow_donor`)

### Tables

#### donors
```sql
CREATE TABLE donors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL, -- References users.id from identity service
    donor_id VARCHAR(20) UNIQUE NOT NULL, -- Human-readable donor ID (e.g., DN001234)
    blood_type VARCHAR(15) NOT NULL CHECK (blood_type IN ('A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE')),
    rh_factor VARCHAR(10) CHECK (rh_factor IN ('POSITIVE', 'NEGATIVE')),
    weight DECIMAL(5,2), -- in kg
    height DECIMAL(5,2), -- in cm
    bmi DECIMAL(4,2) GENERATED ALWAYS AS (weight / ((height/100) * (height/100))) STORED,
    medical_conditions TEXT[],
    current_medications TEXT[],
    allergies TEXT[],
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relationship VARCHAR(50),
    eligibility_status VARCHAR(20) DEFAULT 'PENDING' CHECK (eligibility_status IN ('ELIGIBLE', 'INELIGIBLE', 'PENDING', 'SUSPENDED', 'DEFERRED')),
    eligibility_reason TEXT,
    next_eligible_date DATE,
    last_donation_date DATE,
    total_donations INTEGER DEFAULT 0,
    total_volume_donated INTEGER DEFAULT 0, -- in ml
    total_points INTEGER DEFAULT 0,
    preferred_donation_time VARCHAR(20),
    preferred_notification_method VARCHAR(20) DEFAULT 'EMAIL' CHECK (preferred_notification_method IN ('EMAIL', 'SMS', 'PUSH', 'WHATSAPP', 'ALL')),
    is_available_for_emergency BOOLEAN DEFAULT true,
    is_regular_donor BOOLEAN DEFAULT false,
    donation_frequency VARCHAR(20) DEFAULT 'OCCASIONAL' CHECK (donation_frequency IN ('FIRST_TIME', 'OCCASIONAL', 'REGULAR', 'FREQUENT')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donors_user_id ON donors(user_id);
CREATE INDEX idx_donors_donor_id ON donors(donor_id);
CREATE INDEX idx_donors_blood_type ON donors(blood_type);
CREATE INDEX idx_donors_eligibility_status ON donors(eligibility_status);
CREATE INDEX idx_donors_next_eligible_date ON donors(next_eligible_date);
CREATE INDEX idx_donors_emergency_available ON donors(is_available_for_emergency);
```

#### donor_addresses
```sql
CREATE TABLE donor_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(id) ON DELETE CASCADE,
    address_type VARCHAR(20) DEFAULT 'HOME' CHECK (address_type IN ('HOME', 'WORK', 'OTHER')),
    street_address VARCHAR(255) NOT NULL,
    apartment_unit VARCHAR(50),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_addresses_donor_id ON donor_addresses(donor_id);
CREATE INDEX idx_donor_addresses_location ON donor_addresses(latitude, longitude);
CREATE INDEX idx_donor_addresses_primary ON donor_addresses(is_primary);
```

#### donations
```sql
CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id VARCHAR(20) UNIQUE NOT NULL, -- Human-readable donation ID
    donor_id UUID NOT NULL REFERENCES donors(id),
    donation_date DATE NOT NULL,
    donation_time TIME NOT NULL,
    location_type VARCHAR(20) CHECK (location_type IN ('HOSPITAL', 'CAMP', 'MOBILE_UNIT', 'BLOOD_BANK')),
    location_id UUID, -- References hospital_id, camp_id, or mobile_unit_id
    location_name VARCHAR(255),
    blood_bag_id UUID, -- References blood bag from inventory service
    volume_collected INTEGER, -- in ml
    collection_method VARCHAR(20) DEFAULT 'WHOLE_BLOOD' CHECK (collection_method IN ('WHOLE_BLOOD', 'APHERESIS', 'DOUBLE_RED', 'PLASMA', 'PLATELETS')),
    pre_donation_vitals JSONB, -- {hemoglobin, bp_systolic, bp_diastolic, pulse, temperature, weight}
    post_donation_vitals JSONB,
    donation_status VARCHAR(20) DEFAULT 'COMPLETED' CHECK (donation_status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DEFERRED', 'ADVERSE_REACTION')),
    deferral_reason TEXT,
    deferral_period_days INTEGER,
    adverse_reactions TEXT[],
    staff_notes TEXT,
    donor_feedback TEXT,
    next_eligible_date DATE,
    points_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donations_donor_id ON donations(donor_id);
CREATE INDEX idx_donations_date ON donations(donation_date);
CREATE INDEX idx_donations_status ON donations(donation_status);
CREATE INDEX idx_donations_location ON donations(location_type, location_id);
```

#### health_screenings
```sql
CREATE TABLE health_screenings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(id),
    screening_date DATE NOT NULL,
    screening_type VARCHAR(20) DEFAULT 'PRE_DONATION' CHECK (screening_type IN ('PRE_DONATION', 'ANNUAL', 'FOLLOW_UP', 'POST_TRAVEL')),
    weight DECIMAL(5,2),
    height DECIMAL(5,2),
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    pulse_rate INTEGER,
    temperature DECIMAL(4,2),
    hemoglobin_level DECIMAL(4,2),
    iron_level DECIMAL(4,2),
    recent_travel BOOLEAN DEFAULT false,
    travel_destinations JSONB, -- [{country, from_date, to_date, purpose}]
    recent_tattoos BOOLEAN DEFAULT false,
    tattoo_date DATE,
    recent_piercings BOOLEAN DEFAULT false,
    piercing_date DATE,
    recent_dental_work BOOLEAN DEFAULT false,
    dental_work_date DATE,
    current_medications TEXT[],
    recent_vaccinations JSONB, -- [{vaccine, date, type}]
    feeling_well BOOLEAN DEFAULT true,
    symptoms TEXT[],
    risk_factors JSONB, -- High-risk behaviors assessment
    screening_result VARCHAR(20) DEFAULT 'PENDING' CHECK (screening_result IN ('PASSED', 'FAILED', 'DEFERRED', 'PENDING', 'REQUIRES_REVIEW')),
    deferral_reason TEXT,
    deferral_period_days INTEGER,
    screened_by UUID, -- References staff user_id
    reviewed_by UUID, -- Medical officer review
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_health_screenings_donor_id ON health_screenings(donor_id);
CREATE INDEX idx_health_screenings_date ON health_screenings(screening_date);
CREATE INDEX idx_health_screenings_result ON health_screenings(screening_result);
```

#### donor_preferences
```sql
CREATE TABLE donor_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(id) ON DELETE CASCADE,
    notification_email BOOLEAN DEFAULT true,
    notification_sms BOOLEAN DEFAULT true,
    notification_push BOOLEAN DEFAULT true,
    notification_whatsapp BOOLEAN DEFAULT false,
    emergency_notifications BOOLEAN DEFAULT true,
    marketing_notifications BOOLEAN DEFAULT false,
    reminder_notifications BOOLEAN DEFAULT true,
    appointment_reminders BOOLEAN DEFAULT true,
    preferred_contact_time VARCHAR(50), -- e.g., "9AM-6PM", "EVENING", "WEEKEND"
    preferred_donation_days TEXT[], -- ["MONDAY", "WEDNESDAY", "SATURDAY"]
    preferred_locations UUID[], -- Array of preferred hospital/camp IDs
    language_preference VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'Asia/Kolkata',
    privacy_level VARCHAR(20) DEFAULT 'NORMAL' CHECK (privacy_level IN ('MINIMAL', 'NORMAL', 'ENHANCED')),
    share_achievements BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_preferences_donor_id ON donor_preferences(donor_id);
```

#### donor_medical_history
```sql
CREATE TABLE donor_medical_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(id),
    condition_type VARCHAR(50) NOT NULL, -- 'CHRONIC', 'ACUTE', 'SURGICAL', 'MEDICATION'
    condition_name VARCHAR(100) NOT NULL,
    diagnosis_date DATE,
    treatment_details TEXT,
    current_status VARCHAR(20) CHECK (current_status IN ('ACTIVE', 'RESOLVED', 'MANAGED', 'MONITORING')),
    affects_donation BOOLEAN DEFAULT false,
    medical_clearance_required BOOLEAN DEFAULT false,
    clearance_document_url VARCHAR(500),
    doctor_name VARCHAR(100),
    hospital_name VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_medical_history_donor_id ON donor_medical_history(donor_id);
CREATE INDEX idx_donor_medical_history_affects_donation ON donor_medical_history(affects_donation);
```

---

## 3. Hospital Service Database (`lifeflow_hospital`)

### Tables

#### hospitals
```sql
CREATE TABLE hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id VARCHAR(20) UNIQUE NOT NULL, -- Human-readable hospital ID (e.g., HSP001)
    name VARCHAR(255) NOT NULL,
    hospital_type VARCHAR(50) CHECK (hospital_type IN ('PUBLIC', 'PRIVATE', 'GOVERNMENT', 'CHARITABLE', 'SPECIALTY', 'TEACHING', 'RESEARCH')),
    specialization TEXT[], -- ["CARDIOLOGY", "ONCOLOGY", "TRAUMA", "PEDIATRIC"]
    license_number VARCHAR(100) UNIQUE NOT NULL,
    registration_number VARCHAR(100),
    accreditation_level VARCHAR(20) CHECK (accreditation_level IN ('NABH', 'JCI', 'ISO', 'NABL', 'NONE')),
    accreditation_expiry DATE,
    bed_capacity INTEGER,
    icu_beds INTEGER,
    emergency_beds INTEGER,
    operation_theaters INTEGER,
    emergency_services BOOLEAN DEFAULT false,
    trauma_center_level VARCHAR(10) CHECK (trauma_center_level IN ('LEVEL_1', 'LEVEL_2', 'LEVEL_3', 'LEVEL_4', 'NONE')),
    blood_bank_license VARCHAR(100),
    blood_bank_capacity INTEGER,
    has_component_separation BOOLEAN DEFAULT false,
    has_apheresis_facility BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    verification_date DATE,
    verified_by UUID, -- Admin user who verified
    is_active BOOLEAN DEFAULT true,
    operating_hours JSONB, -- {monday: {open: "08:00", close: "20:00"}, ...}
    website_url VARCHAR(500),
    established_year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospitals_hospital_id ON hospitals(hospital_id);
CREATE INDEX idx_hospitals_name ON hospitals(name);
CREATE INDEX idx_hospitals_type ON hospitals(hospital_type);
CREATE INDEX idx_hospitals_verified ON hospitals(is_verified);
CREATE INDEX idx_hospitals_active ON hospitals(is_active);
CREATE INDEX idx_hospitals_emergency ON hospitals(emergency_services);
```

#### hospital_addresses
```sql
CREATE TABLE hospital_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    address_type VARCHAR(20) DEFAULT 'MAIN' CHECK (address_type IN ('MAIN', 'BRANCH', 'BLOOD_BANK', 'EMERGENCY')),
    street_address VARCHAR(255) NOT NULL,
    landmark VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'India',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT false,
    accessibility_features TEXT[], -- ["WHEELCHAIR_ACCESS", "PARKING", "PUBLIC_TRANSPORT"]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospital_addresses_hospital_id ON hospital_addresses(hospital_id);
CREATE INDEX idx_hospital_addresses_location ON hospital_addresses(latitude, longitude);
CREATE INDEX idx_hospital_addresses_city ON hospital_addresses(city);
```

#### hospital_contacts
```sql
CREATE TABLE hospital_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    contact_type VARCHAR(20) CHECK (contact_type IN ('MAIN', 'EMERGENCY', 'BLOOD_BANK', 'ADMIN', 'APPOINTMENT', 'BILLING')),
    contact_person VARCHAR(100),
    designation VARCHAR(100),
    phone_number VARCHAR(20),
    mobile_number VARCHAR(20),
    email VARCHAR(255),
    extension VARCHAR(10),
    department VARCHAR(100),
    is_primary BOOLEAN DEFAULT false,
    available_24x7 BOOLEAN DEFAULT false,
    available_hours VARCHAR(100), -- "9AM-6PM Mon-Fri"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospital_contacts_hospital_id ON hospital_contacts(hospital_id);
CREATE INDEX idx_hospital_contacts_type ON hospital_contacts(contact_type);
```

#### hospital_staff
```sql
CREATE TABLE hospital_staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References users.id from identity service
    staff_id VARCHAR(20) NOT NULL,
    employee_id VARCHAR(50),
    department VARCHAR(100),
    position VARCHAR(100),
    specialization VARCHAR(100),
    qualification VARCHAR(255),
    license_number VARCHAR(100),
    license_expiry DATE,
    is_blood_bank_certified BOOLEAN DEFAULT false,
    blood_bank_certification_expiry DATE,
    employment_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (employment_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'TERMINATED', 'ON_LEAVE')),
    employment_type VARCHAR(20) DEFAULT 'FULL_TIME' CHECK (employment_type IN ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'CONSULTANT', 'INTERN')),
    hire_date DATE,
    termination_date DATE,
    reporting_manager UUID REFERENCES hospital_staff(id),
    shift_pattern VARCHAR(50), -- "DAY", "NIGHT", "ROTATING"
    emergency_contact JSONB, -- {name, phone, relationship}
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hospital_id, staff_id)
);

CREATE INDEX idx_hospital_staff_hospital_id ON hospital_staff(hospital_id);
CREATE INDEX idx_hospital_staff_user_id ON hospital_staff(user_id);
CREATE INDEX idx_hospital_staff_department ON hospital_staff(department);
CREATE INDEX idx_hospital_staff_status ON hospital_staff(employment_status);
```

#### hospital_departments
```sql
CREATE TABLE hospital_departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    department_code VARCHAR(20),
    department_type VARCHAR(50) CHECK (department_type IN ('CLINICAL', 'NON_CLINICAL', 'SUPPORT', 'ADMINISTRATIVE')),
    head_of_department UUID REFERENCES hospital_staff(id),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    location VARCHAR(100), -- Floor/Wing information
    bed_count INTEGER,
    staff_count INTEGER DEFAULT 0,
    operating_hours JSONB,
    services_offered TEXT[],
    equipment_list TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospital_departments_hospital_id ON hospital_departments(hospital_id);
CREATE INDEX idx_hospital_departments_type ON hospital_departments(department_type);
```

#### hospital_inventory_thresholds
```sql
CREATE TABLE hospital_inventory_thresholds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    blood_type VARCHAR(15) NOT NULL CHECK (blood_type IN ('A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE')),
    component_type VARCHAR(20) DEFAULT 'WHOLE_BLOOD' CHECK (component_type IN ('WHOLE_BLOOD', 'PACKED_RBC', 'PLASMA', 'PLATELETS', 'CRYOPRECIPITATE')),
    minimum_threshold INTEGER NOT NULL DEFAULT 5,
    critical_threshold INTEGER NOT NULL DEFAULT 2,
    maximum_capacity INTEGER NOT NULL DEFAULT 50,
    reorder_level INTEGER NOT NULL DEFAULT 10,
    consumption_rate_per_day DECIMAL(5,2), -- Average daily consumption
    lead_time_days INTEGER DEFAULT 1, -- Time to replenish stock
    seasonal_adjustment DECIMAL(3,2) DEFAULT 1.0, -- Seasonal demand multiplier
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hospital_id, blood_type, component_type)
);

CREATE INDEX idx_hospital_thresholds_hospital_id ON hospital_inventory_thresholds(hospital_id);
CREATE INDEX idx_hospital_thresholds_blood_type ON hospital_inventory_thresholds(blood_type);
```

#### hospital_certifications
```sql
CREATE TABLE hospital_certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
    certification_type VARCHAR(50) NOT NULL, -- 'NABH', 'JCI', 'ISO', 'BLOOD_BANK_LICENSE'
    certification_number VARCHAR(100) NOT NULL,
    issuing_authority VARCHAR(100) NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'REVOKED')),
    document_url VARCHAR(500),
    renewal_reminder_days INTEGER DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hospital_certifications_hospital_id ON hospital_certifications(hospital_id);
CREATE INDEX idx_hospital_certifications_expiry ON hospital_certifications(expiry_date);
```

---

## 4. Inventory Service Database (`lifeflow_inventory`)

### Tables

#### blood_bags
```sql
CREATE TABLE blood_bags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bag_id VARCHAR(50) UNIQUE NOT NULL, -- Barcode/RFID identifier
    batch_number VARCHAR(50),
    donor_id UUID NOT NULL, -- References donor from donor service
    donation_id UUID NOT NULL, -- References donation from donor service
    blood_type VARCHAR(15) NOT NULL CHECK (blood_type IN ('A_POSITIVE', 'A_NEGATIVE', 'B_POSITIVE', 'B_NEGATIVE', 'AB_POSITIVE', 'AB_NEGATIVE', 'O_POSITIVE', 'O_NEGATIVE')),
    rh_factor VARCHAR(10) CHECK (rh_factor IN ('POSITIVE', 'NEGATIVE')),
    collection_date DATE NOT NULL,
    collection_time TIME NOT NULL,
    collection_location_id UUID, -- Hospital or camp ID
    collection_location_name VARCHAR(255),
    volume_ml INTEGER NOT NULL,
    bag_type VARCHAR(20) DEFAULT 'WHOLE_BLOOD' CHECK (bag_type IN ('WHOLE_BLOOD', 'PACKED_RBC', 'PLASMA', 'PLATELETS', 'CRYOPRECIPITATE', 'FRESH_FROZEN_PLASMA')),
    component_preparation_date DATE,
    expiry_date DATE NOT NULL,
    extended_expiry_date DATE, -- If storage conditions allow extension
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('COLLECTED', 'TESTING', 'QUARANTINED', 'AVAILABLE', 'RESERVED', 'ISSUED', 'USED', 'EXPIRED', 'DISCARDED', 'RECALLED')),
    current_location_id UUID, -- Current storage location
    current_location_name VARCHAR(255),
    storage_temperature DECIMAL(4,2), -- Current storage temperature
    temperature_log JSONB, -- Temperature monitoring data
    quality_tests JSONB, -- Test results {hiv: 'NEGATIVE', hbv: 'NEGATIVE', hcv: 'NEGATIVE', syphilis: 'NEGATIVE'}
    processing_notes TEXT,
    reserved_for_request_id UUID,
    reserved_until TIMESTAMP,
    reserved_by UUID, -- Staff who reserved
    issued_date DATE,
    issued_to_hospital_id UUID,
    issued_by UUID, -- Staff who issued
    used_date DATE,
    used_for_patient_id VARCHAR(100), -- Anonymous patient identifier
    cross_match_compatible BOOLEAN,
    discard_reason TEXT,
    discarded_by UUID,
    discarded_date DATE,
    recall_reason TEXT,
    recalled_date DATE,
    chain_of_custody JSONB, -- Movement history
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_blood_bags_bag_id ON blood_bags(bag_id);
CREATE INDEX idx_blood_bags_donor_id ON blood_bags(donor_id);
CREATE INDEX idx_blood_bags_blood_type ON blood_bags(blood_type);
CREATE INDEX idx_blood_bags_status ON blood_bags(status);
CREATE INDEX idx_blood_bags_expiry_date ON blood_bags(expiry_date);
CREATE INDEX idx_blood_bags_collection_date ON blood_bags(collection_date);
CREATE INDEX idx_blood_bags_location ON blood_bags(current_location_id);
CREATE INDEX idx_blood_bags_reserved ON blood_bags(reserved_for_request_id);
```

#### storage_locations
```sql
CREATE TABLE storage_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_code VARCHAR(20) UNIQUE NOT NULL,
    location_name VARCHAR(100) NOT NULL,
    location_type VARCHAR(20) CHECK (location_type IN ('BLOOD_BANK', 'HOSPITAL', 'MOBILE_UNIT', 'PROCESSING_CENTER', 'QUARANTINE', 'TESTING_LAB')),
    facility_id UUID, -- References hospital or facility
    facility_name VARCHAR(255),
    storage_capacity INTEGER,
    current_stock INTEGER DEFAULT 0,
    available_capacity INTEGER GENERATED ALWAYS AS (storage_capacity - current_stock) STORED,
    temperature_range_min DECIMAL(4,2),
    temperature_range_max DECIMAL(4,2),
    current_temperature DECIMAL(4,2),
    humidity_range_min DECIMAL(4,2),
    humidity_range_max DECIMAL(4,2),
    current_humidity DECIMAL(4,2),
    equipment_type VARCHAR(50), -- 'REFRIGERATOR', 'FREEZER', 'PLATELET_AGITATOR'
    equipment_model VARCHAR(100),
    equipment_serial_number VARCHAR(100),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    calibration_due_date DATE,
    backup_power_available BOOLEAN DEFAULT false,
    monitoring_system VARCHAR(50), -- 'AUTOMATED', 'MANUAL', 'HYBRID'
    alert_contacts TEXT[], -- Phone numbers for temperature alerts
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_storage_locations_code ON storage_locations(location_code);
CREATE INDEX idx_storage_locations_type ON storage_locations(location_type);
CREATE INDEX idx_storage_locations_facility ON storage_locations(facility_id);
CREATE INDEX idx_storage_locations_active ON storage_locations(is_active);
```

#### inventory_movements
```sql
CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_id VARCHAR(20) UNIQUE NOT NULL,
    blood_bag_id UUID NOT NULL REFERENCES blood_bags(id),
    movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('COLLECTION', 'TRANSFER', 'RESERVATION', 'ISSUE', 'RETURN', 'DISCARD', 'QUARANTINE', 'TESTING')),
    from_location_id UUID REFERENCES storage_locations(id),
    to_location_id UUID REFERENCES storage_locations(id),
    moved_by UUID NOT NULL, -- Staff user ID
    authorized_by UUID, -- Supervisor authorization if required
    movement_reason TEXT,
    request_id UUID, -- If related to a blood request
    transport_method VARCHAR(20) CHECK (transport_method IN ('MANUAL', 'PNEUMATIC', 'VEHICLE', 'COURIER')),
    transport_container VARCHAR(50),
    temperature_at_movement DECIMAL(4,2),
    temperature_log JSONB, -- Temperature during transport
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_arrival TIMESTAMP,
    actual_arrival TIMESTAMP,
    condition_on_arrival VARCHAR(20) CHECK (condition_on_arrival IN ('GOOD', 'ACCEPTABLE', 'DAMAGED', 'COMPROMISED')),
    notes TEXT,
    digital_signature TEXT, -- Base64 encoded signature
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_movements_blood_bag_id ON inventory_movements(blood_bag_id);
CREATE INDEX idx_inventory_movements_type ON inventory_movements(movement_type);
CREATE INDEX idx_inventory_movements_date ON inventory_movements(movement_date);
CREATE INDEX idx_inventory_movements_request ON inventory_movements(request_id);
```

#### quality_tests
```sql
CREATE TABLE quality_tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id VARCHAR(20) UNIQUE NOT NULL,
    blood_bag_id UUID NOT NULL REFERENCES blood_bags(id),
    test_category VARCHAR(30) NOT NULL CHECK (test_category IN ('INFECTIOUS_DISEASE', 'BLOOD_GROUPING', 'COMPATIBILITY', 'QUALITY_CONTROL', 'COMPONENT_TESTING')),
    test_type VARCHAR(50) NOT NULL, -- 'HIV', 'HBV', 'HCV', 'SYPHILIS', 'ABO_GROUPING', 'RH_TYPING'
    test_method VARCHAR(50), -- 'ELISA', 'NAT', 'RAPID_TEST', 'TUBE_METHOD'
    test_date DATE NOT NULL,
    test_time TIME NOT NULL,
    test_result VARCHAR(20) CHECK (test_result IN ('NEGATIVE', 'POSITIVE', 'REACTIVE', 'NON_REACTIVE', 'INDETERMINATE', 'PENDING', 'INVALID')),
    test_values JSONB, -- Specific test measurements and readings
    reference_ranges JSONB, -- Normal ranges for the test
    interpretation TEXT,
    tested_by UUID NOT NULL, -- Lab technician user ID
    reviewed_by UUID, -- Medical officer review
    equipment_used VARCHAR(100),
    reagent_lot_number VARCHAR(50),
    reagent_expiry_date DATE,
    control_results JSONB, -- Quality control results
    repeat_required BOOLEAN DEFAULT false,
    repeat_reason TEXT,
    final_result VARCHAR(20),
    result_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quality_tests_blood_bag_id ON quality_tests(blood_bag_id);
CREATE INDEX idx_quality_tests_type ON quality_tests(test_type);
CREATE INDEX idx_quality_tests_result ON quality_tests(test_result);
CREATE INDEX idx_quality_tests_date ON quality_tests(test_date);
```

#### inventory_alerts
```sql
CREATE TABLE inventory_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id VARCHAR(20) UNIQUE NOT NULL,
    alert_type VARCHAR(30) NOT NULL CHECK (alert_type IN ('LOW_STOCK', 'CRITICAL_STOCK', 'EXPIRY_WARNING', 'EXPIRED', 'TEMPERATURE_BREACH', 'EQUIPMENT_FAILURE', 'QUALITY_ISSUE')),
    severity VARCHAR(10) DEFAULT 'MEDIUM' CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    blood_type VARCHAR(15),
    component_type VARCHAR(20),
    location_id UUID REFERENCES storage_locations(id),
    blood_bag_id UUID REFERENCES blood_bags(id),
    current_level INTEGER,
    threshold_level INTEGER,
    temperature_reading DECIMAL(4,2),
    alert_message TEXT NOT NULL,
    detailed_description TEXT,
    recommended_actions TEXT[],
    is_acknowledged BOOLEAN DEFAULT false,
    acknowledged_by UUID,
    acknowledged_at TIMESTAMP,
    acknowledgment_notes TEXT,
    is_resolved BOOLEAN DEFAULT false,
    resolved_by UUID,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    escalation_level INTEGER DEFAULT 1,
    escalated_to UUID[],
    auto_generated BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_alerts_type ON inventory_alerts(alert_type);
CREATE INDEX idx_inventory_alerts_severity ON inventory_alerts(severity);
CREATE INDEX idx_inventory_alerts_acknowledged ON inventory_alerts(is_acknowledged);
CREATE INDEX idx_inventory_alerts_resolved ON inventory_alerts(is_resolved);
CREATE INDEX idx_inventory_alerts_location ON inventory_alerts(location_id);
```

---

## Cross-Service Data Relationships

### Event-Driven Data Synchronization

Since each service has its own database, data consistency is maintained through event-driven architecture using Apache Kafka:

#### Key Events:

1. **Identity Service Events:**
   - `UserCreated` - Broadcast to all services
   - `UserUpdated` - Profile changes
   - `UserDeactivated` - Account status changes
   - `RoleAssigned` - Permission changes

2. **Donor Service Events:**
   - `DonorRegistered` - New donor registration
   - `DonorEligibilityChanged` - Eligibility status updates
   - `DonationCompleted` - Successful donation
   - `DonationScheduled` - Appointment booking
   - `HealthScreeningCompleted` - Screening results

3. **Hospital Service Events:**
   - `HospitalRegistered` - New hospital registration
   - `HospitalVerified` - Verification status change
   - `StaffAdded` - New staff member
   - `DepartmentCreated` - New department

4. **Inventory Service Events:**
   - `BloodBagCollected` - New blood bag in inventory
   - `BloodBagTested` - Quality test completed
   - `BloodBagExpiring` - Expiry warning
   - `StockLevelChanged` - Inventory level updates
   - `TemperatureAlert` - Cold chain breach

5. **Request Service Events:**
   - `BloodRequestCreated` - New blood request
   - `EmergencyRequestCreated` - Urgent request
   - `RequestFulfilled` - Request completed
   - `DonorMatched` - Compatible donor found

### Data Consistency Patterns:

1. **Eventual Consistency** - Accept temporary inconsistencies for better performance
2. **Saga Pattern** - Manage distributed transactions across services
3. **Event Sourcing** - Maintain complete audit trail of all changes
4. **CQRS** - Separate read/write models for optimal performance
5. **Outbox Pattern** - Ensure reliable event publishing

### Common Identifiers:
- **user_id** - References users across all services
- **donor_id** - References donors in multiple services  
- **hospital_id** - References hospitals across services
- **request_id** - References blood requests across services
- **blood_bag_id** - References blood inventory across services

### Data Synchronization Strategy:

```sql
-- Example: Donor service listening to user updates
CREATE TABLE user_sync_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sync_status VARCHAR(20) DEFAULT 'COMPLETED'
);
```

This comprehensive database schema provides a robust foundation for the LifeFlow blood donation management system with proper data modeling, indexing strategies, and cross-service synchronization mechanisms.
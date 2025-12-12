-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS donors AUTHORIZATION lifeflow;
SET search_path TO donors, public;

-- ===== ENUMS =====
CREATE TYPE blood_type_enum AS ENUM ('A_PLUS', 'A_MINUS', 'B_PLUS', 'B_MINUS', 'O_PLUS', 'O_MINUS', 'AB_PLUS', 'AB_MINUS');
CREATE TYPE eligibility_status_enum AS ENUM ('ELIGIBLE', 'INELIGIBLE', 'BLOCKED', 'PENDING_VERIFICATION');
CREATE TYPE donor_account_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER');
CREATE TYPE marital_status_enum AS ENUM ('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED');

-- ===== DONORS TABLE =====
CREATE TABLE donors (
    donor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE, -- reference to identity service
    blood_type blood_type_enum NOT NULL,
    rhesus_factor VARCHAR(10),
    weight_kg DECIMAL(5,2) NOT NULL,
    height_cm INTEGER,
    date_of_birth DATE NOT NULL,
    gender gender_enum,
    marital_status marital_status_enum,
    occupation VARCHAR(100),
    company_name VARCHAR(255),
    total_donations INTEGER DEFAULT 0,
    total_lives_impacted INTEGER DEFAULT 0,
    eligibility_status eligibility_status_enum DEFAULT 'PENDING_VERIFICATION',
    eligibility_reason TEXT,
    next_eligible_date DATE,
    account_status donor_account_status_enum DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT weight_check CHECK (weight_kg >= 40 AND weight_kg <= 250),
    CONSTRAINT height_check CHECK (height_cm IS NULL OR (height_cm >= 100 AND height_cm <= 250))
);

CREATE INDEX idx_donors_user_id ON donors(user_id);
CREATE INDEX idx_donors_blood_type ON donors(blood_type);
CREATE INDEX idx_donors_eligibility_status ON donors(eligibility_status);
CREATE INDEX idx_donors_account_status ON donors(account_status);
CREATE INDEX idx_donors_created_at ON donors(created_at);

-- ===== MEDICAL_HISTORY TABLE =====
CREATE TABLE medical_history (
    history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    hemoglobin_level DECIMAL(4,1), -- g/dL
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    weight_at_visit DECIMAL(5,2),
    recent_travel BOOLEAN DEFAULT false,
    travel_destination VARCHAR(255),
    travel_return_date DATE,
    tattoos_or_piercings BOOLEAN DEFAULT false,
    tattoo_date DATE,
    current_medications TEXT[],
    medical_conditions TEXT[],
    recent_illness BOOLEAN DEFAULT false,
    illness_name VARCHAR(255),
    illness_recovery_date DATE,
    recent_surgery BOOLEAN DEFAULT false,
    surgery_type VARCHAR(255),
    surgery_date DATE,
    dental_work BOOLEAN DEFAULT false,
    dental_work_date DATE,
    checked_at TIMESTAMP WITH TIME ZONE NOT NULL,
    checked_by VARCHAR(255), -- doctor/medical professional name
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT hemoglobin_check CHECK (hemoglobin_level IS NULL OR (hemoglobin_level >= 5 AND hemoglobin_level <= 20)),
    CONSTRAINT systolic_check CHECK (blood_pressure_systolic IS NULL OR (blood_pressure_systolic >= 80 AND blood_pressure_systolic <= 200)),
    CONSTRAINT diastolic_check CHECK (blood_pressure_diastolic IS NULL OR (blood_pressure_diastolic >= 40 AND blood_pressure_diastolic <= 130))
);

CREATE INDEX idx_medical_history_donor_id ON medical_history(donor_id);
CREATE INDEX idx_medical_history_checked_at ON medical_history(checked_at);

-- ===== DONATION_RECORDS TABLE =====
CREATE TABLE donation_records (
    donation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    blood_bank_id VARCHAR(255), -- reference to inventory service
    donation_date DATE NOT NULL,
    blood_type_verified blood_type_enum,
    units_donated DECIMAL(3,2) DEFAULT 1.0,
    donation_location VARCHAR(255),
    next_eligible_date DATE,
    status VARCHAR(50) DEFAULT 'COMPLETED', -- COMPLETED, CANCELLED, REJECTED
    cancellation_reason TEXT,
    rejection_reason TEXT,
    blood_bag_ids TEXT[], -- array of bag IDs from inventory service
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_donation_records_donor_id ON donation_records(donor_id);
CREATE INDEX idx_donation_records_donation_date ON donation_records(donation_date);
CREATE INDEX idx_donation_records_status ON donation_records(status);

-- ===== DONOR_PREFERENCES TABLE =====
CREATE TABLE donor_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE UNIQUE,
    push_notifications_enabled BOOLEAN DEFAULT true,
    sms_notifications_enabled BOOLEAN DEFAULT true,
    email_notifications_enabled BOOLEAN DEFAULT true,
    whatsapp_notifications_enabled BOOLEAN DEFAULT false,
    silent_hours_start TIME,
    silent_hours_end TIME,
    silent_hours_timezone VARCHAR(50) DEFAULT 'UTC',
    max_distance_willing_to_travel_km INTEGER DEFAULT 10,
    preferred_donation_times TEXT[],
    preferred_donation_locations VARCHAR(255)[],
    allow_emergency_bypass_silent_mode BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_preferences_donor_id ON donor_preferences(donor_id);

-- ===== DONOR_CONTACTS TABLE =====
CREATE TABLE donor_contacts (
    contact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    emergency_contact_relation VARCHAR(50),
    secondary_contact_name VARCHAR(255),
    secondary_contact_phone VARCHAR(20),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_contacts_donor_id ON donor_contacts(donor_id);

-- ===== ELIGIBILITY_HISTORY TABLE =====
CREATE TABLE eligibility_history (
    eligibility_record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    eligibility_status eligibility_status_enum NOT NULL,
    reason TEXT,
    checked_date TIMESTAMP WITH TIME ZONE NOT NULL,
    valid_until DATE,
    checked_by VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_eligibility_history_donor_id ON eligibility_history(donor_id);
CREATE INDEX idx_eligibility_history_checked_date ON eligibility_history(checked_date);

-- ===== DONOR_SCREENING TABLE =====
CREATE TABLE donor_screening (
    screening_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(donor_id) ON DELETE CASCADE,
    screening_date TIMESTAMP WITH TIME ZONE NOT NULL,
    infectious_disease_screening JSONB,
    viability_test_result VARCHAR(50),
    blood_type_confirmed blood_type_enum,
    quality_status VARCHAR(50), -- PASS, FAIL, PENDING
    screened_by VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_screening_donor_id ON donor_screening(donor_id);

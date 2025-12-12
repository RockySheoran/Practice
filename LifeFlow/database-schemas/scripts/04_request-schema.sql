-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS requests AUTHORIZATION lifeflow;
SET search_path TO requests, public;

-- ===== ENUMS =====
CREATE TYPE blood_type_enum AS ENUM ('A_PLUS', 'A_MINUS', 'B_PLUS', 'B_MINUS', 'O_PLUS', 'O_MINUS', 'AB_PLUS', 'AB_MINUS');
CREATE TYPE urgency_level_enum AS ENUM ('CRITICAL', 'HIGH', 'NORMAL', 'ELECTIVE');
CREATE TYPE request_status_enum AS ENUM ('PENDING', 'MATCHING', 'MATCHED', 'CONFIRMED', 'IN_TRANSIT', 'DELIVERED', 'USED', 'EXPIRED', 'CANCELLED');
CREATE TYPE gender_enum AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- ===== BLOOD_REQUESTS TABLE =====
CREATE TABLE blood_requests (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id VARCHAR(255) NOT NULL, -- reference to hospital from identity service
    patient_blood_type blood_type_enum NOT NULL,
    quantity_needed INTEGER NOT NULL CHECK (quantity_needed > 0),
    urgency_level urgency_level_enum NOT NULL DEFAULT 'NORMAL',
    urgency_color VARCHAR(20) DEFAULT 'YELLOW', -- RED, ORANGE, YELLOW, GREEN
    status request_status_enum DEFAULT 'PENDING',
    status_history JSONB DEFAULT '[]'::jsonb,
    patient_name VARCHAR(255),
    patient_age INTEGER,
    patient_gender gender_enum,
    medical_condition VARCHAR(500),
    hospital_department VARCHAR(100),
    expected_transfusion_time TIMESTAMP WITH TIME ZONE,
    priority_queue_position INTEGER,
    matched_donor_id VARCHAR(255),
    matched_blood_bag_id VARCHAR(255),
    scheduled_pickup_time TIMESTAMP WITH TIME ZONE,
    scheduled_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    request_created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancellation_reason TEXT,
    notes TEXT
);

CREATE INDEX idx_blood_requests_hospital_id ON blood_requests(hospital_id);
CREATE INDEX idx_blood_requests_status ON blood_requests(status);
CREATE INDEX idx_blood_requests_urgency_level ON blood_requests(urgency_level);
CREATE INDEX idx_blood_requests_patient_blood_type ON blood_requests(patient_blood_type);
CREATE INDEX idx_blood_requests_created_at ON blood_requests(created_at);

-- ===== REQUEST_ALTERNATIVES TABLE =====
CREATE TABLE request_alternatives (
    alternative_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    alternative_blood_type blood_type_enum NOT NULL,
    priority_order INTEGER NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_request_alternatives_request_id ON request_alternatives(request_id);

-- ===== MATCHING_RECORDS TABLE =====
CREATE TABLE matching_records (
    matching_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    donor_id VARCHAR(255) NOT NULL,
    match_score DECIMAL(5, 2),
    reason_for_match VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PROPOSED', -- PROPOSED, ACCEPTED, DECLINED, TIMEOUT
    notification_sent_at TIMESTAMP WITH TIME ZONE,
    response_received_at TIMESTAMP WITH TIME ZONE,
    response_type VARCHAR(50),
    decline_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_matching_records_request_id ON matching_records(request_id);
CREATE INDEX idx_matching_records_donor_id ON matching_records(donor_id);
CREATE INDEX idx_matching_records_status ON matching_records(status);

-- ===== REQUEST_ACTIVITY_LOG TABLE =====
CREATE TABLE request_activity_log (
    activity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,
    actor_id VARCHAR(255),
    actor_role VARCHAR(50),
    details JSONB,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_request_activity_log_request_id ON request_activity_log(request_id);
CREATE INDEX idx_request_activity_log_timestamp ON request_activity_log(timestamp);

-- ===== ELECTIVE_REQUESTS TABLE =====
CREATE TABLE elective_requests (
    elective_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME NOT NULL,
    preferred_donor VARCHAR(255),
    status VARCHAR(50) DEFAULT 'SCHEDULED', -- SCHEDULED, RESCHEDULED, COMPLETED, CANCELLED
    confirmation_sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_elective_requests_request_id ON elective_requests(request_id);
CREATE INDEX idx_elective_requests_scheduled_date ON elective_requests(scheduled_date);

-- ===== REQUEST_FULFILLMENT TABLE =====
CREATE TABLE request_fulfillment (
    fulfillment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    blood_bag_id VARCHAR(255) NOT NULL,
    units_delivered DECIMAL(3, 2),
    delivery_confirmation_at TIMESTAMP WITH TIME ZONE,
    transport_id VARCHAR(255),
    delivered_by VARCHAR(255),
    received_by VARCHAR(255),
    temperature_at_delivery DECIMAL(5, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_request_fulfillment_request_id ON request_fulfillment(request_id);
CREATE INDEX idx_request_fulfillment_blood_bag_id ON request_fulfillment(blood_bag_id);

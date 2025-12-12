-- REQUEST & EMERGENCY SERVICE DATABASE
-- Manages blood requests and matching

CREATE DATABASE IF NOT EXISTS lifeflow_request;
USE lifeflow_request;

-- BLOOD REQUEST TABLE (Core)
CREATE TABLE blood_requests (
    request_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    blood_type_needed ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    units_required DECIMAL(3, 1) NOT NULL,
    urgency_level ENUM('CRITICAL', 'HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    urgency_numeric_score INT, -- 0-100 scale for ML
    patient_age INT,
    patient_gender ENUM('M', 'F', 'OTHER'),
    patient_condition VARCHAR(500),
    procedure_type VARCHAR(100),
    procedure_scheduled_time TIMESTAMP,
    deadline_minutes INT,
    deadline_timestamp TIMESTAMP,
    status ENUM('PENDING', 'MATCHED', 'ACCEPTED', 'FULFILLED', 'PARTIAL_FULFILLED', 'CANCELLED', 'EXPIRED') DEFAULT 'PENDING',
    blood_bank_stock_checked BOOLEAN DEFAULT FALSE,
    donor_search_initiated BOOLEAN DEFAULT FALSE,
    gps_location_hospital VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    fulfilled_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason VARCHAR(500),
    notes TEXT,
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_blood_type_needed (blood_type_needed),
    INDEX idx_status (status),
    INDEX idx_urgency_level (urgency_level),
    INDEX idx_created_at (created_at),
    INDEX idx_deadline_timestamp (deadline_timestamp)
);

-- REQUEST RESPONSES (Donor Responses)
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
    response_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    points_offered INT DEFAULT 100,
    points_claimed_at TIMESTAMP NULL,
    blood_bag_assigned_id VARCHAR(100),
    matched_score INT, -- Compatibility score 0-100
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_response_status (response_status),
    INDEX idx_response_created_at (response_created_at)
);

-- DONOR MATCHING RESULTS
CREATE TABLE donor_matching_results (
    match_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    donor_id VARCHAR(50) NOT NULL,
    blood_type_compatibility ENUM('EXACT', 'COMPATIBLE', 'ACCEPTABLE', 'INCOMPATIBLE'),
    distance_km DECIMAL(6, 2),
    distance_score INT, -- 0-30 points
    donor_availability_score INT, -- 0-20 points
    donor_reliability_score INT, -- 0-20 points (based on history)
    donor_response_time_minutes INT,
    urgency_multiplier DECIMAL(2, 1), -- For critical cases
    final_match_score INT, -- 0-100 total
    match_rank INT,
    notification_sent_at TIMESTAMP NULL,
    match_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_final_match_score (final_match_score),
    INDEX idx_match_rank (match_rank)
);

-- BLOOD FULFILLMENT TRACKING
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
    delivery_route_optimized BOOLEAN DEFAULT FALSE,
    delivery_start_timestamp TIMESTAMP NULL,
    delivery_end_timestamp TIMESTAMP NULL,
    delivered_to_hospital_timestamp TIMESTAMP NULL,
    blood_used_timestamp TIMESTAMP NULL,
    gps_pickup_location VARCHAR(100),
    gps_delivery_location VARCHAR(100),
    temperature_maintained BOOLEAN DEFAULT FALSE,
    delivery_notes TEXT,
    fulfillment_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fulfillment_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    FOREIGN KEY (response_id) REFERENCES request_responses(response_id),
    INDEX idx_request_id (request_id),
    INDEX idx_fulfillment_status (fulfillment_status),
    INDEX idx_blood_bag_id (blood_bag_id),
    INDEX idx_fulfillment_created_at (fulfillment_created_at)
);

-- UNMATCHED REQUESTS (For Analytics)
CREATE TABLE unmatched_requests (
    unmatched_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50) NOT NULL,
    blood_type_needed ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'),
    units_required INT,
    reason_unmatched ENUM('NO_STOCK', 'NO_ELIGIBLE_DONORS', 'DISTANCE_TOO_FAR', 'TIME_EXPIRED', 'CANCELLED'),
    unmatched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolution_action VARCHAR(200),
    resolved_at TIMESTAMP NULL,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id),
    INDEX idx_request_id (request_id),
    INDEX idx_reason_unmatched (reason_unmatched)
);

-- REQUEST STATUS HISTORY (Audit Trail)
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

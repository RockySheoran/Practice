-- DONOR MANAGEMENT SERVICE DATABASE
-- Manages donor profiles and medical eligibility

CREATE DATABASE IF NOT EXISTS lifeflow_donor;
USE lifeflow_donor;

-- DONOR PROFILE TABLE
CREATE TABLE donor_profiles (
    donor_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'OTHER'),
    weight_kg DECIMAL(5, 2),
    height_cm INT,
    bmi DECIMAL(4, 2),
    hemoglobin_level DECIMAL(4, 2),
    blood_pressure_systolic INT,
    blood_pressure_diastolic INT,
    pulse_rate INT,
    body_temperature DECIMAL(4, 2),
    chronic_diseases VARCHAR(500),
    allergies VARCHAR(500),
    medications TEXT,
    tattoo_date DATE,
    recent_travel VARCHAR(500),
    vaccination_status VARCHAR(100),
    eligibility_status ENUM('ELIGIBLE', 'TEMPORARY_BLOCKED', 'PERMANENTLY_BLOCKED', 'PENDING_VERIFICATION') DEFAULT 'PENDING_VERIFICATION',
    block_reason VARCHAR(500),
    block_until TIMESTAMP NULL,
    verification_status ENUM('VERIFIED', 'UNVERIFIED', 'REJECTED') DEFAULT 'UNVERIFIED',
    verified_by_admin VARCHAR(50),
    verified_at TIMESTAMP NULL,
    last_eligibility_check TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_blood_type (blood_type),
    INDEX idx_eligibility_status (eligibility_status),
    INDEX idx_block_until (block_until)
);

-- DONATION HISTORY TABLE
CREATE TABLE donation_history (
    donation_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    donation_date TIMESTAMP NOT NULL,
    blood_type_collected ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'),
    units_collected DECIMAL(3, 1),
    donation_type ENUM('WHOLE_BLOOD', 'PLASMA', 'PLATELETS', 'RED_CELLS') DEFAULT 'WHOLE_BLOOD',
    health_score_before INT,
    health_score_after INT,
    hemoglobin_before DECIMAL(4, 2),
    hemoglobin_after DECIMAL(4, 2),
    collection_center_id VARCHAR(50),
    collecting_staff_id VARCHAR(50),
    staff_notes TEXT,
    adverse_events ENUM('NONE', 'FAINTING', 'NAUSEA', 'DIZZINESS', 'OTHER'),
    donation_status ENUM('SUCCESSFUL', 'INCOMPLETE', 'REJECTED', 'FAILED') DEFAULT 'SUCCESSFUL',
    bag_barcode VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_donation_date (donation_date),
    INDEX idx_blood_type_collected (blood_type_collected)
);

-- ELIGIBILITY RULES & CHECKS TABLE
CREATE TABLE eligibility_checks (
    check_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_donation_days INT,
    min_weight_kg DECIMAL(5, 2),
    min_hemoglobin DECIMAL(4, 2),
    age_years INT,
    medical_conditions_clear BOOLEAN,
    medications_allowed BOOLEAN,
    travel_risk BOOLEAN,
    tattoo_risk BOOLEAN,
    vaccination_clear BOOLEAN,
    overall_eligible BOOLEAN,
    reason_if_ineligible VARCHAR(500),
    rechecked_by_system TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_check_timestamp (check_timestamp)
);

-- DONOR MEDICAL HISTORY
CREATE TABLE medical_history (
    history_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    condition_name VARCHAR(100),
    diagnosis_date DATE,
    status ENUM('ACTIVE', 'RESOLVED', 'CHRONIC'),
    treatment_details TEXT,
    last_treatment_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id)
);

-- DONOR GAMIFICATION & REWARDS
CREATE TABLE donor_gamification (
    gamification_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL UNIQUE,
    total_points INT DEFAULT 0,
    total_donations INT DEFAULT 0,
    estimated_lives_saved INT DEFAULT 0,
    badge_level ENUM('BRONZE', 'SILVER', 'GOLD', 'PLATINUM', 'LEGEND') DEFAULT 'BRONZE',
    achievement_milestones TEXT, -- JSON storing unlocked badges
    hero_of_month_count INT DEFAULT 0,
    hero_of_year_count INT DEFAULT 0,
    top_donor_rank INT,
    loyalty_score INT DEFAULT 0,
    referral_count INT DEFAULT 0,
    last_donation_date DATE,
    consecutive_donations INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_badge_level (badge_level),
    INDEX idx_top_donor_rank (top_donor_rank)
);

-- POINTS TRANSACTION LOG
CREATE TABLE points_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    points_earned INT,
    points_redeemed INT,
    transaction_type ENUM('DONATION', 'EMERGENCY_RESPONSE', 'MILESTONE', 'REFERRAL', 'REDEMPTION', 'BONUS'),
    description VARCHAR(500),
    related_request_id VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donor_profiles(donor_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_transaction_date (transaction_date)
);

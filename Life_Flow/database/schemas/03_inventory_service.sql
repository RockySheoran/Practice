-- INVENTORY & BLOOD BANK SERVICE DATABASE
-- Manages blood bag inventory and tracking

CREATE DATABASE IF NOT EXISTS lifeflow_inventory;
USE lifeflow_inventory;

-- BLOOD INVENTORY (Main Table)
CREATE TABLE blood_inventory (
    bag_id VARCHAR(100) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    batch_number VARCHAR(50) NOT NULL,
    donation_date TIMESTAMP NOT NULL,
    collection_date TIMESTAMP,
    processing_date TIMESTAMP,
    expiry_date TIMESTAMP NOT NULL,
    storage_location VARCHAR(100),
    fridge_id VARCHAR(50),
    storage_temperature DECIMAL(5, 2),
    temperature_monitoring_device_id VARCHAR(50),
    barcode VARCHAR(100) UNIQUE,
    rfid_tag VARCHAR(100) UNIQUE,
    status ENUM('AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'USED', 'EXPIRED', 'DISCARDED', 'QUARANTINE') DEFAULT 'AVAILABLE',
    reserved_for_request_id VARCHAR(50),
    reserved_at TIMESTAMP NULL,
    reserved_by_hospital_id VARCHAR(50),
    donor_id_anonymized VARCHAR(50), -- Anonymized reference
    blood_component_type ENUM('WHOLE_BLOOD', 'RBC', 'PLASMA', 'PLATELETS', 'CRYOPRECIPITATE'),
    units_available DECIMAL(3, 1),
    unit_cost DECIMAL(8, 2),
    quality_check_status ENUM('PASS', 'FAIL', 'PENDING') DEFAULT 'PENDING',
    quality_check_date TIMESTAMP NULL,
    quality_checked_by VARCHAR(50),
    test_results TEXT, -- JSON: pathogen tests, viability, etc.
    shelf_life_days INT DEFAULT 42,
    days_remaining_calculated INT,
    parent_batch_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_status (status),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_batch_number (batch_number),
    INDEX idx_reserved_for_request_id (reserved_for_request_id),
    INDEX idx_storage_location (storage_location)
);

-- BLOOD BATCH MANAGEMENT
CREATE TABLE blood_batches (
    batch_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    collection_center_id VARCHAR(50),
    collection_date TIMESTAMP,
    total_units_collected INT,
    processing_completed_date TIMESTAMP,
    batch_status ENUM('PROCESSING', 'READY', 'DISTRIBUTED', 'EXPIRED', 'REJECTED') DEFAULT 'PROCESSING',
    quality_batch_test ENUM('PASSED', 'FAILED') DEFAULT 'FAILED',
    pathogen_screening_result VARCHAR(500),
    batch_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_batch_status (batch_status),
    INDEX idx_collection_date (collection_date)
);

-- INVENTORY STOCK LEVELS (Real-time View)
CREATE TABLE stock_summary (
    stock_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL UNIQUE,
    total_available_units INT DEFAULT 0,
    total_reserved_units INT DEFAULT 0,
    total_expired_units INT DEFAULT 0,
    reorder_threshold INT DEFAULT 5,
    critical_threshold INT DEFAULT 2,
    alert_triggered BOOLEAN DEFAULT FALSE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_alert_triggered (alert_triggered)
);

-- TEMPERATURE MONITORING LOG
CREATE TABLE temperature_monitoring (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fridge_id VARCHAR(50) NOT NULL,
    bag_id VARCHAR(100),
    temperature DECIMAL(5, 2) NOT NULL,
    humidity DECIMAL(5, 2),
    reading_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alert_triggered BOOLEAN DEFAULT FALSE,
    alert_type ENUM('TOO_HIGH', 'TOO_LOW', 'RAPID_CHANGE', 'NONE') DEFAULT 'NONE',
    data_source VARCHAR(50),
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_fridge_id (fridge_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_reading_time (reading_time),
    INDEX idx_alert_triggered (alert_triggered)
);

-- INVENTORY TRANSACTIONS LOG
CREATE TABLE inventory_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    transaction_type ENUM('IN', 'OUT', 'RESERVE', 'RELEASE', 'TRANSFER', 'DISCARD') NOT NULL,
    quantity_change DECIMAL(3, 1),
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    from_hospital_id VARCHAR(50),
    to_hospital_id VARCHAR(50),
    request_id VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by VARCHAR(50),
    notes TEXT,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_request_id (request_id)
);

-- EXPIRY ALERTS & MANAGEMENT
CREATE TABLE expiry_management (
    expiry_alert_id VARCHAR(50) PRIMARY KEY,
    bag_id VARCHAR(100) NOT NULL,
    days_until_expiry INT,
    alert_level ENUM('WARNING', 'CRITICAL', 'EXPIRED') DEFAULT 'WARNING',
    alert_sent_at TIMESTAMP NULL,
    resolution_action ENUM('DISCARDED', 'TRANSFERRED', 'USED') DEFAULT NULL,
    resolved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bag_id) REFERENCES blood_inventory(bag_id),
    INDEX idx_bag_id (bag_id),
    INDEX idx_alert_level (alert_level),
    INDEX idx_days_until_expiry (days_until_expiry)
);

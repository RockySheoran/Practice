-- IDENTITY & PROFILE SERVICE DATABASE
-- Handles user authentication and registration

CREATE DATABASE IF NOT EXISTS lifeflow_identity;
USE lifeflow_identity;

-- USERS TABLE (Core Entity)
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('DONOR', 'HOSPITAL', 'ADMIN', 'STAFF') NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED', 'PENDING_VERIFICATION') DEFAULT 'PENDING_VERIFICATION',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    kyc_verified BOOLEAN DEFAULT FALSE,
    kyc_document_url VARCHAR(500),
    kyc_verified_at TIMESTAMP NULL,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role),
    INDEX idx_status (status)
);

-- OAUTH2 TOKENS TABLE
CREATE TABLE oauth2_tokens (
    token_id VARCHAR(100) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    access_token VARCHAR(500) NOT NULL,
    refresh_token VARCHAR(500),
    token_type ENUM('BEARER', 'BASIC') DEFAULT 'BEARER',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_access_token (access_token),
    UNIQUE KEY unique_refresh_token (refresh_token)
);

-- BIOMETRIC PROFILES TABLE
CREATE TABLE biometric_profiles (
    biometric_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    fingerprint_hash VARCHAR(500),
    face_recognition_embedding LONGBLOB,
    iris_scan_hash VARCHAR(500),
    biometric_type ENUM('FINGERPRINT', 'FACE', 'IRIS', 'MULTIMODAL'),
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP NULL,
    last_verified TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id)
);

-- AUDIT LOG TABLE (Security/Compliance)
CREATE TABLE audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(100),
    old_value LONGTEXT,
    new_value LONGTEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    status ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_action (action)
);

-- Create initial admin user (password should be changed on first login)
INSERT INTO users (user_id, email, password_hash, role, first_name, last_name, status, email_verified, kyc_verified)
VALUES ('admin-001', 'admin@lifeflow.local', SHA2('admin123', 256), 'ADMIN', 'Admin', 'User', 'ACTIVE', TRUE, TRUE)
ON DUPLICATE KEY UPDATE user_id = user_id;

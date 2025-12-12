-- NOTIFICATION SERVICE DATABASE
-- Logs notifications and manages delivery

CREATE DATABASE IF NOT EXISTS lifeflow_notifications;
USE lifeflow_notifications;

-- NOTIFICATION LOG (Immutable)
CREATE TABLE notifications_log (
    notification_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(20),
    recipient_whatsapp VARCHAR(20),
    notification_type ENUM('SMS', 'EMAIL', 'PUSH', 'WHATSAPP', 'IN_APP') NOT NULL,
    channel VARCHAR(50), -- e.g., 'Twilio', 'SendGrid', 'Firebase', 'WhatsApp Business API'
    title VARCHAR(255),
    content TEXT NOT NULL,
    related_request_id VARCHAR(50),
    related_response_id VARCHAR(50),
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
    last_retry_at TIMESTAMP NULL,
    failure_reason VARCHAR(500),
    provider_message_id VARCHAR(100),
    provider_response_code VARCHAR(50),
    INDEX idx_user_id (user_id),
    INDEX idx_sent_at (sent_at),
    INDEX idx_delivery_status (delivery_status),
    INDEX idx_notification_type (notification_type),
    INDEX idx_related_request_id (related_request_id),
    INDEX idx_priority (priority)
);

-- NOTIFICATION PREFERENCES
CREATE TABLE notification_preferences (
    preference_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE,
    sms_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    whatsapp_enabled BOOLEAN DEFAULT FALSE,
    in_app_enabled BOOLEAN DEFAULT TRUE,
    emergency_alerts_sound BOOLEAN DEFAULT TRUE,
    emergency_alerts_bypass_silent BOOLEAN DEFAULT TRUE,
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    time_zone VARCHAR(50) DEFAULT 'UTC',
    language_preference VARCHAR(10) DEFAULT 'en',
    marketing_notifications BOOLEAN DEFAULT TRUE,
    donation_reminders BOOLEAN DEFAULT TRUE,
    emergency_only_notifications BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);

-- NOTIFICATION TEMPLATES
CREATE TABLE notification_templates (
    template_id VARCHAR(50) PRIMARY KEY,
    template_name VARCHAR(100) UNIQUE NOT NULL,
    template_type ENUM('SMS', 'EMAIL', 'PUSH', 'WHATSAPP', 'ALL'),
    subject VARCHAR(255),
    body_template TEXT NOT NULL,
    variables_schema JSON, -- Schema for expected variables
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_template_name (template_name),
    INDEX idx_template_type (template_type)
);

-- Insert Common Templates
INSERT INTO notification_templates VALUES
('tpl-001', 'EMERGENCY_BLOOD_NEEDED', 'PUSH', 'Emergency Blood Needed', 'Emergency! {{blood_type}} blood needed at {{hospital_name}}. Can you donate in {{time_minutes}} mins? You''ll earn {{points}} points!', '{"blood_type": "string", "hospital_name": "string", "time_minutes": "int", "points": "int"}', NOW(), NOW(), TRUE),
('tpl-002', 'DONOR_ACCEPTED_CONFIRM', 'SMS', NULL, 'Hi {{donor_name}}, thanks for accepting! Please report to {{center_name}} by {{time}}. Confirmation code: {{code}}', '{"donor_name": "string", "center_name": "string", "time": "string", "code": "string"}', NOW(), NOW(), TRUE),
('tpl-003', 'HOSPITAL_DONOR_MATCHED', 'EMAIL', 'Donor Matched for Your Request', 'Good news! We found {{count}} eligible donors near {{location}} for your {{blood_type}} blood request.', '{"count": "int", "location": "string", "blood_type": "string"}', NOW(), NOW(), TRUE),
('tpl-004', 'BLOOD_IN_TRANSIT', 'PUSH', 'Your Blood Unit in Transit', 'Your blood unit is on the way to {{hospital_name}}. ETA: {{eta_minutes}} minutes.', '{"hospital_name": "string", "eta_minutes": "int"}', NOW(), NOW(), TRUE),
('tpl-005', 'BLOOD_USED_NOTIFICATION', 'PUSH', 'Life Saved!', 'Great news! Your blood unit helped save a patient at {{hospital_name}}. You''re a hero! 🩸', '{"hospital_name": "string"}', NOW(), NOW(), TRUE);

-- NOTIFICATION BATCH JOBS (For bulk sending)
CREATE TABLE notification_batches (
    batch_id VARCHAR(50) PRIMARY KEY,
    batch_name VARCHAR(100),
    template_id VARCHAR(50),
    target_user_count INT,
    users_notified INT DEFAULT 0,
    batch_status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (template_id) REFERENCES notification_templates(template_id),
    INDEX idx_batch_status (batch_status)
);

-- NOTIFICATION SERVICE HEALTH (Monitoring)
CREATE TABLE notification_service_health (
    health_id VARCHAR(50) PRIMARY KEY,
    check_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sms_provider_status ENUM('UP', 'DOWN', 'DEGRADED') DEFAULT 'UP',
    email_provider_status ENUM('UP', 'DOWN', 'DEGRADED') DEFAULT 'UP',
    push_provider_status ENUM('UP', 'DOWN', 'DEGRADED') DEFAULT 'UP',
    whatsapp_provider_status ENUM('UP', 'DOWN', 'DEGRADED') DEFAULT 'UP',
    response_time_ms INT,
    error_rate_percent DECIMAL(5, 2),
    messages_in_queue INT DEFAULT 0,
    circuit_breaker_sms ENUM('CLOSED', 'OPEN', 'HALF_OPEN') DEFAULT 'CLOSED',
    circuit_breaker_email ENUM('CLOSED', 'OPEN', 'HALF_OPEN') DEFAULT 'CLOSED',
    INDEX idx_check_timestamp (check_timestamp)
);

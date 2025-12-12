-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS notifications AUTHORIZATION lifeflow;
SET search_path TO notifications, public;

-- ===== ENUMS =====
CREATE TYPE notification_type_enum AS ENUM ('EMERGENCY_REQUEST', 'MATCHING_RESULT', 'STATUS_UPDATE', 'ACHIEVEMENT', 'REMINDER', 'SYSTEM_ALERT', 'PROMOTIONAL');
CREATE TYPE notification_priority_enum AS ENUM ('HIGH', 'NORMAL', 'LOW');
CREATE TYPE channel_enum AS ENUM ('PUSH', 'SMS', 'EMAIL', 'WHATSAPP', 'IN_APP');
CREATE TYPE delivery_status_enum AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED', 'OPT_OUT', 'CANCELLED');
CREATE TYPE notification_frequency_enum AS ENUM ('REAL_TIME', 'DAILY_DIGEST', 'WEEKLY_DIGEST', 'MONTHLY_DIGEST');

-- ===== NOTIFICATIONS TABLE =====
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id VARCHAR(255) NOT NULL, -- user ID from identity service
    notification_type notification_type_enum NOT NULL,
    title VARCHAR(255),
    message TEXT NOT NULL,
    body TEXT,
    channels channel_enum[] NOT NULL,
    priority notification_priority_enum DEFAULT 'NORMAL',
    action_required BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    scheduled_send_at TIMESTAMP WITH TIME ZONE,
    status delivery_status_enum DEFAULT 'PENDING',
    read_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_notifications_recipient_id ON notifications(recipient_id);
CREATE INDEX idx_notifications_notification_type ON notifications(notification_type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_status ON notifications(status);

-- ===== NOTIFICATION_DELIVERY_LOG TABLE =====
CREATE TABLE notification_delivery_log (
    delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(notification_id) ON DELETE CASCADE,
    channel channel_enum NOT NULL,
    recipient_identifier VARCHAR(255),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    delivery_status delivery_status_enum NOT NULL,
    failure_reason TEXT,
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP WITH TIME ZONE,
    response_code VARCHAR(50),
    notes TEXT
);

CREATE INDEX idx_notification_delivery_log_notification_id ON notification_delivery_log(notification_id);
CREATE INDEX idx_notification_delivery_log_channel ON notification_delivery_log(channel);
CREATE INDEX idx_notification_delivery_log_delivery_status ON notification_delivery_log(delivery_status);

-- ===== NOTIFICATION_TEMPLATES TABLE =====
CREATE TABLE notification_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(255) NOT NULL UNIQUE,
    template_type channel_enum NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'EN',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    variables TEXT[] DEFAULT '{}'::TEXT[]
);

CREATE INDEX idx_notification_templates_template_name ON notification_templates(template_name);
CREATE INDEX idx_notification_templates_template_type ON notification_templates(template_type);

-- ===== USER_NOTIFICATION_PREFERENCES TABLE =====
CREATE TABLE user_notification_preferences (
    preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL UNIQUE,
    push_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT true,
    email_enabled BOOLEAN DEFAULT true,
    whatsapp_enabled BOOLEAN DEFAULT false,
    in_app_enabled BOOLEAN DEFAULT true,
    silent_hours_start TIME,
    silent_hours_end TIME,
    silent_hours_timezone VARCHAR(50) DEFAULT 'UTC',
    allow_emergency_bypass BOOLEAN DEFAULT true,
    notification_frequency notification_frequency_enum DEFAULT 'REAL_TIME',
    preferred_language VARCHAR(10) DEFAULT 'EN',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_notification_preferences_user_id ON user_notification_preferences(user_id);

-- ===== SMS_LOGS TABLE =====
CREATE TABLE sms_logs (
    sms_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(notification_id) ON DELETE SET NULL,
    phone_number VARCHAR(20) NOT NULL,
    sms_content TEXT NOT NULL,
    provider VARCHAR(50),
    provider_message_id VARCHAR(255),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    status delivery_status_enum DEFAULT 'PENDING',
    cost DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sms_logs_phone_number ON sms_logs(phone_number);
CREATE INDEX idx_sms_logs_status ON sms_logs(status);

-- ===== EMAIL_LOGS TABLE =====
CREATE TABLE email_logs (
    email_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(notification_id) ON DELETE SET NULL,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    body_html TEXT,
    body_text TEXT,
    provider VARCHAR(50),
    provider_message_id VARCHAR(255),
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    status delivery_status_enum DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_logs_recipient_email ON email_logs(recipient_email);
CREATE INDEX idx_email_logs_status ON email_logs(status);

-- ===== PUSH_NOTIFICATION_LOGS TABLE =====
CREATE TABLE push_notification_logs (
    push_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(notification_id) ON DELETE SET NULL,
    device_token TEXT NOT NULL,
    provider VARCHAR(50),
    provider_message_id VARCHAR(255),
    sent_at TIMESTAMP WITH TIME ZONE,
    received_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    status delivery_status_enum DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_push_notification_logs_status ON push_notification_logs(status);

-- ===== UNSUBSCRIBE_LOGS TABLE =====
CREATE TABLE unsubscribe_logs (
    unsubscribe_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    reason VARCHAR(255),
    notification_type notification_type_enum,
    channel channel_enum,
    unsubscribed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_unsubscribe_logs_user_id ON unsubscribe_logs(user_id);

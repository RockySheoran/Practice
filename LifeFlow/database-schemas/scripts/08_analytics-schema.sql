-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS analytics AUTHORIZATION lifeflow;
SET search_path TO analytics, public;

-- ===== ENUMS =====
CREATE TYPE badge_rarity_enum AS ENUM ('COMMON', 'UNCOMMON', 'RARE', 'EPIC', 'LEGENDARY');
CREATE TYPE leaderboard_type_enum AS ENUM ('MONTHLY_DONATIONS', 'LIFETIME_DONATIONS', 'MONTHLY_POINTS', 'CITY_RANKING', 'ORGANIZATION_RANKING', 'EMERGENCY_DONATIONS');
CREATE TYPE leaderboard_period_enum AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY', 'LIFETIME');
CREATE TYPE transaction_type_enum AS ENUM ('EARNED', 'SPENT', 'ADJUSTED', 'EXPIRED', 'REFUNDED');
CREATE TYPE referral_status_enum AS ENUM ('PENDING', 'COMPLETED', 'CANCELLED');
CREATE TYPE prediction_type_enum AS ENUM ('DONOR_NEXT_DONATION', 'BLOOD_SHORTAGE', 'DONOR_CHURN', 'DEMAND_SPIKE');
CREATE TYPE model_type_enum AS ENUM ('DEMAND_FORECAST', 'CHURN_PREDICTION', 'ELIGIBILITY_CHECK', 'FRAUD_DETECTION');

-- ===== DONOR_REWARDS TABLE =====
CREATE TABLE donor_rewards (
    reward_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id VARCHAR(255) NOT NULL,
    reward_type VARCHAR(50), -- POINTS, BADGE, VOUCHER, HEALTH_CHECKUP
    amount INTEGER,
    reward_code VARCHAR(100),
    reason VARCHAR(100), -- DONATION, REFERRAL, EMERGENCY_DONATION, CAMP_PARTICIPATION
    earned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expired_at TIMESTAMP WITH TIME ZONE,
    is_redeemed BOOLEAN DEFAULT false,
    redeemed_at TIMESTAMP WITH TIME ZONE,
    redeemed_for TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_rewards_donor_id ON donor_rewards(donor_id);
CREATE INDEX idx_donor_rewards_reward_type ON donor_rewards(reward_type);
CREATE INDEX idx_donor_rewards_is_redeemed ON donor_rewards(is_redeemed);

-- ===== BADGES_ACHIEVEMENTS TABLE =====
CREATE TABLE badges_achievements (
    badge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    badge_name VARCHAR(255) NOT NULL,
    badge_code VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    criteria JSONB NOT NULL,
    rarity badge_rarity_enum DEFAULT 'COMMON',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_badges_achievements_badge_code ON badges_achievements(badge_code);

-- ===== DONOR_BADGES TABLE =====
CREATE TABLE donor_badges (
    donor_badge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id VARCHAR(255) NOT NULL,
    badge_id UUID NOT NULL REFERENCES badges_achievements(badge_id) ON DELETE CASCADE,
    earned_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    progress INTEGER DEFAULT 100, -- percentage (0-100)
    
    UNIQUE(donor_id, badge_id)
);

CREATE INDEX idx_donor_badges_donor_id ON donor_badges(donor_id);
CREATE INDEX idx_donor_badges_badge_id ON donor_badges(badge_id);

-- ===== LEADERBOARDS TABLE =====
CREATE TABLE leaderboards (
    leaderboard_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leaderboard_type leaderboard_type_enum NOT NULL,
    period leaderboard_period_enum NOT NULL,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_leaderboards_leaderboard_type ON leaderboards(leaderboard_type);
CREATE INDEX idx_leaderboards_period ON leaderboards(period);

-- ===== LEADERBOARD_ENTRIES TABLE =====
CREATE TABLE leaderboard_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leaderboard_id UUID NOT NULL REFERENCES leaderboards(leaderboard_id) ON DELETE CASCADE,
    donor_id VARCHAR(255) NOT NULL,
    rank INTEGER NOT NULL,
    score DECIMAL(12, 2) NOT NULL,
    city VARCHAR(100),
    previous_rank INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_leaderboard_entries_leaderboard_id ON leaderboard_entries(leaderboard_id);
CREATE INDEX idx_leaderboard_entries_donor_id ON leaderboard_entries(donor_id);
CREATE INDEX idx_leaderboard_entries_rank ON leaderboard_entries(rank);

-- ===== POINT_TRANSACTIONS TABLE =====
CREATE TABLE point_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id VARCHAR(255) NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    points_amount INTEGER NOT NULL,
    reason VARCHAR(255),
    reference_id VARCHAR(255),
    balance_before INTEGER,
    balance_after INTEGER,
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_point_transactions_donor_id ON point_transactions(donor_id);
CREATE INDEX idx_point_transactions_transaction_type ON point_transactions(transaction_type);
CREATE INDEX idx_point_transactions_transaction_date ON point_transactions(transaction_date);

-- ===== REFERRALS TABLE =====
CREATE TABLE referrals (
    referral_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referring_donor_id VARCHAR(255) NOT NULL,
    referred_donor_id VARCHAR(255),
    referral_code VARCHAR(50) NOT NULL UNIQUE,
    referred_donor_status referral_status_enum DEFAULT 'PENDING',
    reward_points_earned INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    referred_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_referrals_referring_donor_id ON referrals(referring_donor_id);
CREATE INDEX idx_referrals_referred_donor_id ON referrals(referred_donor_id);
CREATE INDEX idx_referrals_referral_code ON referrals(referral_code);

-- ===== DONATION_IMPACT_TRACKING TABLE =====
CREATE TABLE donation_impact_tracking (
    impact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bag_id VARCHAR(255) NOT NULL,
    donor_id VARCHAR(255) NOT NULL,
    hospital_id VARCHAR(255),
    patient_anonymous_id VARCHAR(255),
    patient_age_group VARCHAR(20),
    patient_gender VARCHAR(20),
    medical_procedure VARCHAR(100), -- SURGERY, TRANSFUSION, EMERGENCY
    procedure_type VARCHAR(255),
    procedure_date DATE,
    patient_recovery_status VARCHAR(50), -- RECOVERING, RECOVERED, CRITICAL, LOST
    notification_sent_to_donor BOOLEAN DEFAULT false,
    notified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donation_impact_tracking_donor_id ON donation_impact_tracking(donor_id);
CREATE INDEX idx_donation_impact_tracking_blood_bag_id ON donation_impact_tracking(blood_bag_id);

-- ===== SYSTEM_ANALYTICS TABLE =====
CREATE TABLE system_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    total_active_donors INTEGER DEFAULT 0,
    total_active_hospitals INTEGER DEFAULT 0,
    total_blood_banks INTEGER DEFAULT 0,
    total_donations_today INTEGER DEFAULT 0,
    total_requests_today INTEGER DEFAULT 0,
    average_fulfillment_time_minutes DECIMAL(8, 2),
    shortage_incidents INTEGER DEFAULT 0,
    lives_saved_estimate INTEGER DEFAULT 0,
    blood_wastage_units INTEGER DEFAULT 0,
    wastage_rate_percentage DECIMAL(5, 2),
    revenue DECIMAL(14, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_analytics_date ON system_analytics(date);

-- ===== ENGAGEMENT_METRICS TABLE =====
CREATE TABLE engagement_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id VARCHAR(255) NOT NULL UNIQUE,
    last_donation_date DATE,
    days_since_last_donation INTEGER,
    donation_frequency_days INTEGER,
    app_opens_monthly INTEGER DEFAULT 0,
    notifications_opened_count INTEGER DEFAULT 0,
    emergency_requests_received INTEGER DEFAULT 0,
    emergency_requests_accepted INTEGER DEFAULT 0,
    acceptance_rate_percentage DECIMAL(5, 2),
    churn_risk_score DECIMAL(5, 2), -- 0-100, higher = more likely to stop
    engagement_score DECIMAL(5, 2), -- 0-100
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_engagement_metrics_donor_id ON engagement_metrics(donor_id);
CREATE INDEX idx_engagement_metrics_churn_risk_score ON engagement_metrics(churn_risk_score);

-- ===== MACHINE_LEARNING_MODELS TABLE =====
CREATE TABLE machine_learning_models (
    model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(255) NOT NULL,
    model_type model_type_enum NOT NULL,
    version VARCHAR(50),
    training_date TIMESTAMP WITH TIME ZONE,
    accuracy_score DECIMAL(5, 4),
    f1_score DECIMAL(5, 4),
    precision DECIMAL(5, 4),
    recall DECIMAL(5, 4),
    last_updated TIMESTAMP WITH TIME ZONE,
    model_file_url VARCHAR(500), -- S3 path
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, DEPRECATED, TESTING
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_machine_learning_models_model_type ON machine_learning_models(model_type);
CREATE INDEX idx_machine_learning_models_status ON machine_learning_models(status);

-- ===== PREDICTIONS TABLE =====
CREATE TABLE predictions (
    prediction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id UUID NOT NULL REFERENCES machine_learning_models(model_id) ON DELETE SET NULL,
    prediction_type prediction_type_enum NOT NULL,
    entity_id VARCHAR(255),
    entity_type VARCHAR(50),
    predicted_value VARCHAR(255),
    confidence_score DECIMAL(5, 4),
    prediction_date DATE NOT NULL,
    actual_outcome VARCHAR(255),
    accuracy_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_predictions_model_id ON predictions(model_id);
CREATE INDEX idx_predictions_prediction_type ON predictions(prediction_type);
CREATE INDEX idx_predictions_entity ON predictions(entity_id, entity_type);

-- ===== BLOOD_TYPE_COMPATIBILITY TABLE =====
CREATE TABLE blood_type_compatibility (
    compatibility_id SERIAL PRIMARY KEY,
    blood_type_donor VARCHAR(10) NOT NULL,
    blood_type_recipient VARCHAR(10) NOT NULL,
    is_compatible BOOLEAN NOT NULL,
    notes TEXT,
    
    UNIQUE(blood_type_donor, blood_type_recipient)
);

INSERT INTO blood_type_compatibility (blood_type_donor, blood_type_recipient, is_compatible) VALUES
-- O- (Universal Donor) can donate to all
('O_MINUS', 'O_MINUS', true),
('O_MINUS', 'O_PLUS', true),
('O_MINUS', 'A_MINUS', true),
('O_MINUS', 'A_PLUS', true),
('O_MINUS', 'B_MINUS', true),
('O_MINUS', 'B_PLUS', true),
('O_MINUS', 'AB_MINUS', true),
('O_MINUS', 'AB_PLUS', true),

-- O+ can donate to O+, A+, B+, AB+
('O_PLUS', 'O_PLUS', true),
('O_PLUS', 'O_MINUS', false),
('O_PLUS', 'A_PLUS', true),
('O_PLUS', 'A_MINUS', false),
('O_PLUS', 'B_PLUS', true),
('O_PLUS', 'B_MINUS', false),
('O_PLUS', 'AB_PLUS', true),
('O_PLUS', 'AB_MINUS', false),

-- A- can donate to A-, A+, AB-, AB+
('A_MINUS', 'A_MINUS', true),
('A_MINUS', 'A_PLUS', true),
('A_MINUS', 'AB_MINUS', true),
('A_MINUS', 'AB_PLUS', true),
('A_MINUS', 'O_MINUS', false),
('A_MINUS', 'O_PLUS', false),
('A_MINUS', 'B_MINUS', false),
('A_MINUS', 'B_PLUS', false),

-- A+ can donate to A+, AB+
('A_PLUS', 'A_PLUS', true),
('A_PLUS', 'AB_PLUS', true),
('A_PLUS', 'O_PLUS', false),
('A_PLUS', 'O_MINUS', false),
('A_PLUS', 'A_MINUS', false),
('A_PLUS', 'B_PLUS', false),
('A_PLUS', 'B_MINUS', false),
('A_PLUS', 'AB_MINUS', false),

-- B- can donate to B-, B+, AB-, AB+
('B_MINUS', 'B_MINUS', true),
('B_MINUS', 'B_PLUS', true),
('B_MINUS', 'AB_MINUS', true),
('B_MINUS', 'AB_PLUS', true),
('B_MINUS', 'O_MINUS', false),
('B_MINUS', 'O_PLUS', false),
('B_MINUS', 'A_MINUS', false),
('B_MINUS', 'A_PLUS', false),

-- B+ can donate to B+, AB+
('B_PLUS', 'B_PLUS', true),
('B_PLUS', 'AB_PLUS', true),
('B_PLUS', 'O_PLUS', false),
('B_PLUS', 'O_MINUS', false),
('B_PLUS', 'B_MINUS', false),
('B_PLUS', 'A_PLUS', false),
('B_PLUS', 'A_MINUS', false),
('B_PLUS', 'AB_MINUS', false),

-- AB- can donate to AB-, AB+
('AB_MINUS', 'AB_MINUS', true),
('AB_MINUS', 'AB_PLUS', true),
('AB_MINUS', 'A_MINUS', false),
('AB_MINUS', 'A_PLUS', false),
('AB_MINUS', 'B_MINUS', false),
('AB_MINUS', 'B_PLUS', false),
('AB_MINUS', 'O_MINUS', false),
('AB_MINUS', 'O_PLUS', false),

-- AB+ (Universal Recipient) can receive from all
('AB_PLUS', 'AB_PLUS', true),
('AB_PLUS', 'AB_MINUS', false),
('AB_PLUS', 'A_MINUS', false),
('AB_PLUS', 'A_PLUS', false),
('AB_PLUS', 'B_MINUS', false),
('AB_PLUS', 'B_PLUS', false),
('AB_PLUS', 'O_MINUS', false),
('AB_PLUS', 'O_PLUS', false);

-- ===== SYSTEM_CONFIG TABLE =====
CREATE TABLE system_config (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(255) NOT NULL UNIQUE,
    config_value TEXT,
    config_type VARCHAR(50), -- STRING, INTEGER, BOOLEAN, JSON
    description TEXT,
    is_editable BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO system_config (config_key, config_value, config_type, description) VALUES
('geofence_radius_km', '5', 'INTEGER', 'Default geofence radius in kilometers'),
('max_blood_storage_days', '42', 'INTEGER', 'Maximum blood storage days'),
('min_weight_for_donation', '50', 'INTEGER', 'Minimum weight in kg for donation'),
('min_hemoglobin_level', '12.5', 'DECIMAL', 'Minimum hemoglobin level in g/dL'),
('emergency_response_sla_minutes', '20', 'INTEGER', 'SLA for emergency blood requests'),
('donation_cooldown_months', '3', 'INTEGER', 'Months between donations'),
('reward_points_per_donation', '100', 'INTEGER', 'Base reward points per donation'),
('enable_gamification', 'true', 'BOOLEAN', 'Enable gamification features'),
('enable_predictive_analytics', 'true', 'BOOLEAN', 'Enable ML predictions');

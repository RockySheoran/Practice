-- ANALYTICS & DASHBOARD SERVICE DATABASE
-- Manages metrics, insights, and predictive data

CREATE DATABASE IF NOT EXISTS lifeflow_analytics;
USE lifeflow_analytics;

-- REAL-TIME DASHBOARD METRICS
CREATE TABLE dashboard_metrics (
    metric_id VARCHAR(50) PRIMARY KEY,
    metric_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_active_requests INT DEFAULT 0,
    total_donors_online INT DEFAULT 0,
    critical_requests_pending INT DEFAULT 0,
    average_response_time_minutes DECIMAL(5, 2),
    successful_fulfillments_today INT DEFAULT 0,
    total_units_distributed_today INT DEFAULT 0,
    system_uptime_percent DECIMAL(5, 2),
    average_donor_distance_km DECIMAL(6, 2),
    blood_shortage_alerts INT DEFAULT 0,
    api_error_rate_percent DECIMAL(5, 2),
    notification_delivery_rate_percent DECIMAL(5, 2),
    INDEX idx_metric_timestamp (metric_timestamp)
);

-- HOURLY AGGREGATED STATS
CREATE TABLE hourly_stats (
    stat_id VARCHAR(50) PRIMARY KEY,
    stat_hour TIMESTAMP NOT NULL,
    requests_created INT DEFAULT 0,
    requests_fulfilled INT DEFAULT 0,
    requests_failed INT DEFAULT 0,
    donors_responded INT DEFAULT 0,
    blood_units_collected INT DEFAULT 0,
    avg_fulfillment_time_minutes INT,
    peak_concurrent_requests INT,
    INDEX idx_stat_hour (stat_hour)
);

-- DAILY AGGREGATED STATS
CREATE TABLE daily_stats (
    stat_id VARCHAR(50) PRIMARY KEY,
    stat_date DATE NOT NULL,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled INT DEFAULT 0,
    expired_requests INT DEFAULT 0,
    total_donors_active INT DEFAULT 0,
    new_donors_registered INT DEFAULT 0,
    total_units_collected INT DEFAULT 0,
    total_units_used INT DEFAULT 0,
    blood_shortage_incidents INT DEFAULT 0,
    hospitals_served INT DEFAULT 0,
    avg_response_time_sec INT,
    estimated_lives_saved INT,
    UNIQUE KEY unique_date (stat_date),
    INDEX idx_stat_date (stat_date)
);

-- BLOOD TYPE DEMAND FORECAST
CREATE TABLE blood_demand_forecast (
    forecast_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    forecast_date DATE,
    predicted_demand INT,
    confidence_percent INT,
    seasonality_factor DECIMAL(4, 2),
    trend_direction ENUM('UP', 'DOWN', 'STABLE'),
    forecast_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actual_demand INT,
    forecast_accuracy_percent INT,
    UNIQUE KEY unique_forecast (blood_type, forecast_date),
    INDEX idx_forecast_date (forecast_date),
    INDEX idx_blood_type (blood_type)
);

-- BLOOD STOCK PREDICTION
CREATE TABLE stock_prediction (
    prediction_id VARCHAR(50) PRIMARY KEY,
    blood_type ENUM('O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-') NOT NULL,
    current_stock INT,
    predicted_stock_24h INT,
    predicted_stock_7d INT,
    shortage_probability_percent INT,
    days_to_critical_24h INT,
    recommended_collection_units INT,
    prediction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_blood_type (blood_type),
    INDEX idx_prediction_timestamp (prediction_timestamp)
);

-- DONOR ENGAGEMENT ANALYTICS
CREATE TABLE donor_engagement_metrics (
    engagement_id VARCHAR(50) PRIMARY KEY,
    donor_id VARCHAR(50) NOT NULL,
    total_donations INT DEFAULT 0,
    donations_this_year INT DEFAULT 0,
    donations_last_30_days INT DEFAULT 0,
    average_days_between_donations INT,
    last_donation_date DATE,
    total_points_earned INT DEFAULT 0,
    total_points_redeemed INT DEFAULT 0,
    lifetime_value_score INT,
    engagement_tier ENUM('INACTIVE', 'OCCASIONAL', 'REGULAR', 'COMMITTED', 'LEGEND') DEFAULT 'OCCASIONAL',
    churn_risk_score INT, -- 0-100, 100 = high risk
    predicted_next_donation_date DATE,
    gamification_influence_percent INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_donor_id (donor_id),
    INDEX idx_engagement_tier (engagement_tier),
    INDEX idx_churn_risk_score (churn_risk_score)
);

-- HOSPITAL PERFORMANCE ANALYTICS
CREATE TABLE hospital_performance (
    performance_id VARCHAR(50) PRIMARY KEY,
    hospital_id VARCHAR(50) NOT NULL,
    total_requests INT DEFAULT 0,
    fulfilled_requests INT DEFAULT 0,
    partial_fulfilled INT DEFAULT 0,
    average_fulfillment_time_minutes INT,
    emergency_vs_planned_ratio DECIMAL(4, 2),
    average_units_per_request INT,
    donor_satisfaction_score INT,
    operational_efficiency_score INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_hospital_id (hospital_id)
);

-- CRITICAL INCIDENTS LOG
CREATE TABLE critical_incidents (
    incident_id VARCHAR(50) PRIMARY KEY,
    incident_type ENUM('STOCK_CRITICAL', 'NO_DONORS_AVAILABLE', 'DELIVERY_FAILED', 'QUALITY_ISSUE', 'SYSTEM_OUTAGE') NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'HIGH',
    request_id VARCHAR(50),
    blood_type_affected VARCHAR(10),
    incident_description TEXT,
    impact_estimate VARCHAR(200),
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    resolution_notes TEXT,
    INDEX idx_incident_type (incident_type),
    INDEX idx_severity (severity),
    INDEX idx_reported_at (reported_at)
);

-- A/B TESTING EXPERIMENTS
CREATE TABLE ab_tests (
    test_id VARCHAR(50) PRIMARY KEY,
    test_name VARCHAR(100),
    test_type ENUM('NOTIFICATION_MESSAGE', 'UI_FLOW', 'GAMIFICATION', 'INCENTIVE') NOT NULL,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    control_group_size INT,
    variant_group_size INT,
    control_conversion_rate DECIMAL(5, 2),
    variant_conversion_rate DECIMAL(5, 2),
    statistical_significance BOOLEAN DEFAULT FALSE,
    winning_variant VARCHAR(100),
    recommendation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_test_type (test_type)
);

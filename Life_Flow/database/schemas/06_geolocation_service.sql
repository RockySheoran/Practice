-- DELIVERY RIDES/LOGISTICS
CREATE TABLE delivery_rides (
    ride_id VARCHAR(50) PRIMARY KEY,
    fulfillment_id VARCHAR(50) NOT NULL,
    rider_id VARCHAR(50),
    ride_status ENUM('PENDING', 'ACCEPTED', 'ARRIVING_AT_PICKUP', 'AT_PICKUP', 'DEPARTED_PICKUP', 'IN_TRANSIT', 'ARRIVING_AT_DELIVERY', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    pickup_location_hospital_id VARCHAR(50),
    delivery_location_hospital_id VARCHAR(50),
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    distance_km DECIMAL(6, 2),
    estimated_duration_minutes INT,
    ride_accepted_at TIMESTAMP NULL,
    pickup_start_time TIMESTAMP NULL,
    pickup_complete_time TIMESTAMP NULL,
    delivery_start_time TIMESTAMP NULL,
    delivery_complete_time TIMESTAMP NULL,
    actual_duration_minutes INT,
    temperature_maintained BOOLEAN DEFAULT FALSE,
    min_temperature_recorded DECIMAL(4, 2),
    max_temperature_recorded DECIMAL(4, 2),
    ride_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_ride_status (ride_status),
    INDEX idx_fulfillment_id (fulfillment_id),
    INDEX idx_rider_id (rider_id)
);

-- RIDE TRACKING POINTS (GPS breadcrumbs)
CREATE TABLE ride_tracking_points (
    tracking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ride_id VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    altitude_meters INT,
    speed_kmh DECIMAL(5, 2),
    accuracy_meters INT,
    tracking_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ride_id) REFERENCES delivery_rides(ride_id),
    INDEX idx_ride_id (ride_id),
    INDEX idx_tracking_timestamp (tracking_timestamp),
    SPATIAL INDEX (POINT(latitude, longitude))
);

-- GEOFENCE ALERTS
CREATE TABLE geofence_alerts (
    alert_id VARCHAR(50) PRIMARY KEY,
    ride_id VARCHAR(50),
    donor_id VARCHAR(50),
    alert_type ENUM('ENTERED_RADIUS', 'EXITED_RADIUS', 'ARRIVED_AT_PICKUP', 'LEFT_PICKUP', 'ARRIVED_AT_DESTINATION') NOT NULL,
    geofence_radius_km DECIMAL(4, 2),
    alert_triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notification_sent BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ride_id) REFERENCES delivery_rides(ride_id),
    INDEX idx_ride_id (ride_id),
    INDEX idx_donor_id (donor_id),
    INDEX idx_alert_triggered_at (alert_triggered_at)
);

-- DISTANCE CALCULATIONS CACHE
CREATE TABLE distance_cache (
    cache_id VARCHAR(50) PRIMARY KEY,
    origin_donor_id VARCHAR(50),
    origin_hospital_id VARCHAR(50),
    destination_hospital_id VARCHAR(50),
    distance_km DECIMAL(6, 2),
    duration_minutes INT,
    route_summary VARCHAR(500),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    UNIQUE KEY unique_route (origin_donor_id, origin_hospital_id, destination_hospital_id),
    INDEX idx_expires_at (expires_at)
);

-- NEARBY DONORS SEARCH LOG
CREATE TABLE nearby_donors_search (
    search_id VARCHAR(50) PRIMARY KEY,
    request_id VARCHAR(50),
    hospital_id VARCHAR(50),
    search_radius_km INT,
    blood_type_needed VARCHAR(10),
    donors_found INT,
    search_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    query_execution_time_ms INT,
    INDEX idx_request_id (request_id),
    INDEX idx_hospital_id (hospital_id),
    INDEX idx_search_timestamp (search_timestamp)
);
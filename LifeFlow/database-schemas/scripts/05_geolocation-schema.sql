-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS geolocation AUTHORIZATION lifeflow;
SET search_path TO geolocation, public;

-- Extensions for geographic data
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- ===== ENUMS =====
CREATE TYPE entity_type_enum AS ENUM ('HOSPITAL', 'BLOOD_BANK', 'DONOR', 'BLOOD_BAG');
CREATE TYPE tracking_status_enum AS ENUM ('ACTIVE', 'COMPLETED', 'ABANDONED');
CREATE TYPE travel_mode_enum AS ENUM ('DRIVING', 'BIKING', 'WALKING', 'TRANSIT');
CREATE TYPE vehicle_type_enum AS ENUM ('CAR', 'BIKE', 'AMBULANCE', 'VAN');
CREATE TYPE delivery_status_enum AS ENUM ('INITIATED', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED', 'FAILED');
CREATE TYPE geofence_event_type_enum AS ENUM ('ENTERED', 'EXITED', 'DWELL');

-- ===== LOCATIONS TABLE =====
CREATE TABLE locations (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    coordinates GEOMETRY(Point, 4326) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    accuracy_meters INTEGER
);

CREATE INDEX idx_locations_entity ON locations(entity_type, entity_id);
CREATE INDEX idx_locations_coordinates ON locations USING GIST(coordinates);
CREATE INDEX idx_locations_recorded_at ON locations(recorded_at);

-- ===== LIVE_TRACKING_SESSIONS TABLE =====
CREATE TABLE live_tracking_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id VARCHAR(255),
    blood_bag_id VARCHAR(255),
    transport_vehicle_id UUID,
    donor_id VARCHAR(255),
    start_location GEOMETRY(Point, 4326),
    end_location GEOMETRY(Point, 4326),
    start_latitude DECIMAL(10, 8),
    start_longitude DECIMAL(11, 8),
    end_latitude DECIMAL(10, 8),
    end_longitude DECIMAL(11, 8),
    actual_path GEOMETRY(LineString, 4326),
    session_status tracking_status_enum DEFAULT 'ACTIVE',
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    estimated_arrival_time TIMESTAMP WITH TIME ZONE,
    actual_arrival_time TIMESTAMP WITH TIME ZONE,
    notes TEXT
);

CREATE INDEX idx_live_tracking_sessions_request_id ON live_tracking_sessions(request_id);
CREATE INDEX idx_live_tracking_sessions_session_status ON live_tracking_sessions(session_status);

-- ===== ROUTES TABLE =====
CREATE TABLE routes (
    route_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_coordinates GEOMETRY(Point, 4326) NOT NULL,
    to_coordinates GEOMETRY(Point, 4326) NOT NULL,
    distance_km DECIMAL(10, 2),
    distance_meters INTEGER,
    estimated_duration_minutes INTEGER,
    traffic_condition VARCHAR(50), -- LIGHT, MODERATE, HEAVY, BLOCKED
    polyline TEXT, -- encoded route from Google Maps
    travel_mode travel_mode_enum DEFAULT 'DRIVING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_routes_from_coordinates ON routes USING GIST(from_coordinates);
CREATE INDEX idx_routes_to_coordinates ON routes USING GIST(to_coordinates);

-- ===== DISTANCE_MATRIX TABLE =====
CREATE TABLE distance_matrix (
    matrix_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_entity_id VARCHAR(255) NOT NULL,
    from_entity_type VARCHAR(50) NOT NULL,
    to_entity_id VARCHAR(255) NOT NULL,
    to_entity_type VARCHAR(50) NOT NULL,
    distance_meters INTEGER,
    distance_km DECIMAL(10, 2),
    estimated_duration_seconds INTEGER,
    travel_mode travel_mode_enum DEFAULT 'DRIVING',
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_distance_matrix_from ON distance_matrix(from_entity_id, from_entity_type);
CREATE INDEX idx_distance_matrix_to ON distance_matrix(to_entity_id, to_entity_type);

-- ===== GEO_FENCES TABLE =====
CREATE TABLE geo_fences (
    geofence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    center_coordinates GEOMETRY(Point, 4326) NOT NULL,
    center_latitude DECIMAL(10, 8),
    center_longitude DECIMAL(11, 8),
    radius_km DECIMAL(10, 2) DEFAULT 5.0,
    is_active BOOLEAN DEFAULT true,
    geofence_polygon GEOMETRY(Polygon, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_geo_fences_entity_id ON geo_fences(entity_id);
CREATE INDEX idx_geo_fences_center_coordinates ON geo_fences USING GIST(center_coordinates);
CREATE INDEX idx_geo_fences_is_active ON geo_fences(is_active);

-- ===== DONOR_LOCATIONS TABLE =====
CREATE TABLE donor_locations (
    donor_location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id VARCHAR(255) NOT NULL,
    coordinates GEOMETRY(Point, 4326) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accuracy_meters INTEGER,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    in_geofence BOOLEAN DEFAULT false,
    geofence_id UUID REFERENCES geo_fences(geofence_id),
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_donor_locations_donor_id ON donor_locations(donor_id);
CREATE INDEX idx_donor_locations_coordinates ON donor_locations USING GIST(coordinates);
CREATE INDEX idx_donor_locations_timestamp ON donor_locations(timestamp);

-- ===== TRANSPORT_VEHICLES TABLE =====
CREATE TABLE transport_vehicles (
    vehicle_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_registration_number VARCHAR(50) NOT NULL UNIQUE,
    driver_id VARCHAR(255),
    vehicle_type vehicle_type_enum NOT NULL,
    current_coordinates GEOMETRY(Point, 4326),
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT true,
    gps_device_id VARCHAR(100),
    has_temperature_monitoring BOOLEAN DEFAULT false,
    last_gps_update TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transport_vehicles_driver_id ON transport_vehicles(driver_id);
CREATE INDEX idx_transport_vehicles_is_active ON transport_vehicles(is_active);

-- ===== DELIVERY_LOGS TABLE =====
CREATE TABLE delivery_logs (
    delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transport_vehicle_id UUID NOT NULL REFERENCES transport_vehicles(vehicle_id),
    request_id VARCHAR(255),
    blood_bag_id VARCHAR(255),
    driver_id VARCHAR(255),
    pickup_location_coordinates GEOMETRY(Point, 4326),
    delivery_location_coordinates GEOMETRY(Point, 4326),
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivery_time TIMESTAMP WITH TIME ZONE,
    distance_traveled_km DECIMAL(10, 2),
    fuel_consumed DECIMAL(6, 2),
    status delivery_status_enum DEFAULT 'INITIATED',
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delivery_logs_transport_vehicle_id ON delivery_logs(transport_vehicle_id);
CREATE INDEX idx_delivery_logs_request_id ON delivery_logs(request_id);
CREATE INDEX idx_delivery_logs_status ON delivery_logs(status);

-- ===== GEOFENCE_EVENTS TABLE =====
CREATE TABLE geofence_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    geofence_id UUID NOT NULL REFERENCES geo_fences(geofence_id),
    donor_id VARCHAR(255),
    event_type geofence_event_type_enum NOT NULL,
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dwell_time_seconds INTEGER,
    triggered_notification BOOLEAN DEFAULT false,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_geofence_events_geofence_id ON geofence_events(geofence_id);
CREATE INDEX idx_geofence_events_donor_id ON geofence_events(donor_id);
CREATE INDEX idx_geofence_events_event_timestamp ON geofence_events(event_timestamp);

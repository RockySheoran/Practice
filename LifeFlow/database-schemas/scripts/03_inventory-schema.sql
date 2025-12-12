-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS inventory AUTHORIZATION lifeflow;
SET search_path TO inventory, public;

-- ===== ENUMS =====
CREATE TYPE blood_type_enum AS ENUM ('A_PLUS', 'A_MINUS', 'B_PLUS', 'B_MINUS', 'O_PLUS', 'O_MINUS', 'AB_PLUS', 'AB_MINUS');
CREATE TYPE blood_bag_status_enum AS ENUM ('AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'DELIVERED', 'USED', 'EXPIRED', 'DISCARDED', 'QUARANTINED');
CREATE TYPE blood_bank_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE quality_check_status_enum AS ENUM ('PASS', 'FAIL', 'PENDING');
CREATE TYPE transaction_type_enum AS ENUM ('INBOUND', 'OUTBOUND', 'TRANSFER', 'ADJUSTMENT', 'DISPOSAL');

-- ===== BLOOD_BANKS TABLE =====
CREATE TABLE blood_banks (
    blood_bank_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    organization_name VARCHAR(255),
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    zip_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    manager_id VARCHAR(255), -- reference to user from identity service
    license_number VARCHAR(100),
    license_expiry_date DATE,
    is_active BOOLEAN DEFAULT true,
    status blood_bank_status_enum DEFAULT 'ACTIVE',
    storage_capacity_units INTEGER NOT NULL,
    current_storage_usage INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_blood_banks_city ON blood_banks(city);
CREATE INDEX idx_blood_banks_is_active ON blood_banks(is_active);
CREATE INDEX idx_blood_banks_manager_id ON blood_banks(manager_id);

-- ===== BLOOD_INVENTORY TABLE =====
CREATE TABLE blood_inventory (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    blood_type blood_type_enum NOT NULL,
    unit_count INTEGER DEFAULT 0,
    reserved_units INTEGER DEFAULT 0,
    available_units INTEGER GENERATED ALWAYS AS (unit_count - reserved_units) STORED,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_counted_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(blood_bank_id, blood_type),
    CONSTRAINT unit_count_check CHECK (unit_count >= 0),
    CONSTRAINT reserved_units_check CHECK (reserved_units >= 0),
    CONSTRAINT available_units_check CHECK ((unit_count - reserved_units) >= 0)
);

CREATE INDEX idx_blood_inventory_blood_bank_id ON blood_inventory(blood_bank_id);
CREATE INDEX idx_blood_inventory_blood_type ON blood_inventory(blood_type);

-- ===== BLOOD_BAGS TABLE =====
CREATE TABLE blood_bags (
    bag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    barcode_number VARCHAR(100) NOT NULL UNIQUE,
    rfid_tag VARCHAR(100) UNIQUE,
    batch_id VARCHAR(100),
    blood_type blood_type_enum NOT NULL,
    donor_id VARCHAR(255), -- reference from donor service
    donation_date DATE NOT NULL,
    collection_date TIMESTAMP WITH TIME ZONE NOT NULL,
    collection_location VARCHAR(255),
    expiry_date DATE NOT NULL,
    storage_location VARCHAR(255),
    fridge_id UUID,
    status blood_bag_status_enum DEFAULT 'AVAILABLE',
    current_temperature DECIMAL(5, 2),
    temperature_history JSONB DEFAULT '[]'::jsonb,
    quality_check_status quality_check_status_enum DEFAULT 'PENDING',
    quality_check_date TIMESTAMP WITH TIME ZONE,
    quality_check_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_blood_bags_blood_bank_id ON blood_bags(blood_bank_id);
CREATE INDEX idx_blood_bags_barcode_number ON blood_bags(barcode_number);
CREATE INDEX idx_blood_bags_blood_type ON blood_bags(blood_type);
CREATE INDEX idx_blood_bags_status ON blood_bags(status);
CREATE INDEX idx_blood_bags_expiry_date ON blood_bags(expiry_date);
CREATE INDEX idx_blood_bags_donor_id ON blood_bags(donor_id);

-- ===== FRIDGES TABLE =====
CREATE TABLE fridges (
    fridge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    fridge_code VARCHAR(50) NOT NULL,
    capacity INTEGER NOT NULL,
    current_load INTEGER DEFAULT 0,
    temperature_setpoint DECIMAL(5, 2) NOT NULL DEFAULT 4.0,
    current_temperature DECIMAL(5, 2),
    temperature_alert_min DECIMAL(5, 2) DEFAULT 2.0,
    temperature_alert_max DECIMAL(5, 2) DEFAULT 6.0,
    is_operational BOOLEAN DEFAULT true,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    model VARCHAR(100),
    serial_number VARCHAR(100),
    installed_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT capacity_check CHECK (capacity > 0)
);

CREATE INDEX idx_fridges_blood_bank_id ON fridges(blood_bank_id);
CREATE INDEX idx_fridges_is_operational ON fridges(is_operational);

-- ===== TEMPERATURE_LOGS TABLE =====
CREATE TABLE temperature_logs (
    log_id BIGSERIAL PRIMARY KEY,
    fridge_id UUID NOT NULL REFERENCES fridges(fridge_id) ON DELETE CASCADE,
    recorded_temperature DECIMAL(5, 2) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sensor_id VARCHAR(100),
    is_alert_triggered BOOLEAN DEFAULT false,
    notes TEXT
);

CREATE INDEX idx_temperature_logs_fridge_id ON temperature_logs(fridge_id);
CREATE INDEX idx_temperature_logs_timestamp ON temperature_logs(timestamp);

-- ===== BLOOD_BAG_MOVEMENT_HISTORY TABLE =====
CREATE TABLE blood_bag_movement_history (
    movement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bag_id UUID NOT NULL REFERENCES blood_bags(bag_id) ON DELETE CASCADE,
    from_status blood_bag_status_enum,
    to_status blood_bag_status_enum NOT NULL,
    from_location VARCHAR(255),
    to_location VARCHAR(255),
    moved_by VARCHAR(255),
    reason VARCHAR(255),
    moved_at TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_blood_bag_movement_history_bag_id ON blood_bag_movement_history(bag_id);
CREATE INDEX idx_blood_bag_movement_history_moved_at ON blood_bag_movement_history(moved_at);

-- ===== BATCH_RECORDS TABLE =====
CREATE TABLE batch_records (
    batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    batch_name VARCHAR(255) NOT NULL,
    donation_drive_id VARCHAR(255),
    total_units_collected INTEGER NOT NULL,
    total_units_in_stock INTEGER DEFAULT 0,
    collection_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    collection_end_date TIMESTAMP WITH TIME ZONE,
    quality_status VARCHAR(50) DEFAULT 'PENDING', -- ALL_PASS, SOME_FAILED, ALL_FAILED
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_batch_records_blood_bank_id ON batch_records(blood_bank_id);
CREATE INDEX idx_batch_records_collection_start_date ON batch_records(collection_start_date);

-- ===== INVENTORY_TRANSACTIONS TABLE =====
CREATE TABLE inventory_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    blood_type blood_type_enum NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    quantity INTEGER NOT NULL,
    reason VARCHAR(255),
    reference_id VARCHAR(255),
    transaction_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    recorded_by VARCHAR(255),
    notes TEXT
);

CREATE INDEX idx_inventory_transactions_blood_bank_id ON inventory_transactions(blood_bank_id);
CREATE INDEX idx_inventory_transactions_blood_type ON inventory_transactions(blood_type);
CREATE INDEX idx_inventory_transactions_transaction_type ON inventory_transactions(transaction_type);
CREATE INDEX idx_inventory_transactions_transaction_date ON inventory_transactions(transaction_date);

-- ===== STOCK_FORECASTS TABLE =====
CREATE TABLE stock_forecasts (
    forecast_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blood_bank_id UUID NOT NULL REFERENCES blood_banks(blood_bank_id) ON DELETE CASCADE,
    blood_type blood_type_enum NOT NULL,
    forecast_date DATE NOT NULL,
    predicted_demand INTEGER,
    confidence_level DECIMAL(5, 2),
    recommendation VARCHAR(50), -- STOCK_UP, NORMAL, REDUCE
    model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_stock_forecasts_blood_bank_id ON stock_forecasts(blood_bank_id);
CREATE INDEX idx_stock_forecasts_forecast_date ON stock_forecasts(forecast_date);

# Inventory & Blood Bank Service - Database Schema

**Database**: `lifeflow_inventory_db`
**Purpose**: Blood stock management, unit tracking, expiry handling, batch management

## ER Diagram

```
┌────────────────────┐
│ blood_banks        │
│────────────────────│
│ bank_id (PK)       │◄────┐
│ bank_name          │     │
│ location           │     │
│ capacity           │     │
└────────────────────┘     │
         │                 │
         │      ┌──────────▼──────────┐
         │      │ blood_bags          │
         │      │──────────────────────
         │      │ bag_id (PK)         │
         │      │ bank_id (FK)────────┼──┐
         │      │ batch_id            │  │
         │      │ blood_type          │  │
         │      │ collection_date     │  │
         │      │ expiry_date         │  │
         │      │ status              │  │
         │      └─────────────────────┘  │
         │                               │
    ┌────▼────────────────┐              │
    │ blood_stock_        │              │
    │ summary             │              │
    │──────────────────────              │
    │ stock_id (PK)       │              │
    │ bank_id (FK)────────┼──────────────┘
    │ blood_type          │
    │ rh_factor           │
    │ available_units     │
    │ reserved_units      │
    │ used_units          │
    │ last_updated        │
    └─────────────────────┘
                │
         ┌──────▼────────────┐
         │ batch_records      │
         │──────────────────── 
         │ batch_id (PK)      │
         │ collection_date    │
         │ total_units        │
         │ available          │
         │ status             │
         └────────────────────┘

         ┌──────────────────┐
         │ stock_movements   │
         │──────────────────│
         │ movement_id(PK)  │
         │ bag_id(FK)       │
         │ from_status      │
         │ to_status        │
         │ reason           │
         │ moved_at         │
         └──────────────────┘
```

## Tables

### 1. blood_banks
Master data for blood banks and storage facilities.

```sql
CREATE TABLE blood_banks (
  bank_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Bank Information
  bank_name VARCHAR(255) NOT NULL,
  bank_code VARCHAR(50) UNIQUE NOT NULL,
  
  -- Location
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  zip_code VARCHAR(20),
  country VARCHAR(100),
  latitude NUMERIC(10, 8),
  longitude NUMERIC(11, 8),
  
  -- Contact
  phone_number VARCHAR(20),
  email VARCHAR(255),
  
  -- Facility Details
  capacity_units INTEGER NOT NULL,  -- Max units that can be stored
  currently_available_units INTEGER DEFAULT 0,
  fridge_count INTEGER,
  
  -- Operating Hours
  opening_time TIME,
  closing_time TIME,
  emergency_number VARCHAR(20),
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Hospital Association
  associated_hospital_id UUID,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_bank_name ON blood_banks(bank_name);
CREATE INDEX idx_bank_location ON blood_banks(city, state);
CREATE INDEX idx_bank_code ON blood_banks(bank_code);
CREATE INDEX idx_bank_active ON blood_banks(is_active);
```

### 2. blood_bags
Individual blood unit tracking with barcode/RFID.

```sql
CREATE TABLE blood_bags (
  bag_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_id UUID NOT NULL REFERENCES blood_banks(bank_id),
  batch_id UUID NOT NULL REFERENCES batch_records(batch_id),
  
  -- Identification
  barcode VARCHAR(100) UNIQUE NOT NULL,
  rfid_tag VARCHAR(100),
  bag_serial_number VARCHAR(50),
  
  -- Blood Classification
  blood_type ENUM('O', 'A', 'B', 'AB') NOT NULL,
  rh_factor ENUM('POSITIVE', 'NEGATIVE') NOT NULL,
  
  -- Collection & Expiry
  collection_date DATE NOT NULL,
  collection_time TIME,
  expiry_date DATE NOT NULL,  -- Usually 35-42 days after collection
  
  -- Volume
  volume_ml INTEGER DEFAULT 450,
  
  -- Storage Location
  fridge_number INTEGER,
  shelf_position VARCHAR(50),
  rack_position VARCHAR(50),
  
  -- Quality Checks
  hemoglobin_g_dl NUMERIC(5, 2),
  platelet_count INTEGER,
  wbc_count NUMERIC(10, 2),
  
  -- Status
  bag_status ENUM(
    'AVAILABLE',         -- Ready for use
    'RESERVED',          -- Allocated to a request
    'IN_TRANSIT',        -- Being delivered
    'TRANSFUSED',        -- Used for transfusion
    'EXPIRED',           -- Expired, need disposal
    'DAMAGED',           -- Damaged, unusable
    'QUARANTINE',        -- Under testing
    'DISCARDED'          -- Properly disposed
  ) DEFAULT 'AVAILABLE',
  
  -- Used Information
  used_for_request_id UUID,
  used_at_hospital_id UUID,
  transfused_date DATE,
  transfused_time TIME,
  transfused_by UUID,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_bag_bank ON blood_bags(bank_id);
CREATE INDEX idx_bag_barcode ON blood_bags(barcode);
CREATE INDEX idx_bag_blood_type ON blood_bags(blood_type, rh_factor);
CREATE INDEX idx_bag_status ON blood_bags(bag_status);
CREATE INDEX idx_bag_expiry ON blood_bags(expiry_date);
CREATE INDEX idx_bag_batch ON blood_bags(batch_id);
CREATE INDEX idx_bag_available ON blood_bags(bag_status, expiry_date) WHERE bag_status = 'AVAILABLE';
CREATE INDEX idx_bag_request ON blood_bags(used_for_request_id);
```

### 3. batch_records
Batch tracking for quality assurance.

```sql
CREATE TABLE batch_records (
  batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Batch Information
  batch_number VARCHAR(100) UNIQUE NOT NULL,
  batch_code VARCHAR(50),
  
  -- Collection Details
  collection_date DATE NOT NULL,
  collection_center VARCHAR(255),
  collection_type ENUM('DONATION_DRIVE', 'WALK_IN', 'SCHEDULED') DEFAULT 'WALK_IN',
  
  -- Counts
  total_units_collected INTEGER NOT NULL,
  units_available INTEGER DEFAULT 0,
  units_reserved INTEGER DEFAULT 0,
  units_used INTEGER DEFAULT 0,
  units_expired INTEGER DEFAULT 0,
  units_discarded INTEGER DEFAULT 0,
  
  -- Quality Assurance
  passed_qa BOOLEAN DEFAULT FALSE,
  qa_checked_at TIMESTAMP,
  qa_checked_by UUID,
  qa_remarks TEXT,
  
  -- Status
  batch_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CLOSED') DEFAULT 'PENDING',
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID
);

CREATE INDEX idx_batch_number ON batch_records(batch_number);
CREATE INDEX idx_batch_collection_date ON batch_records(collection_date);
CREATE INDEX idx_batch_status ON batch_records(batch_status);
```

### 4. blood_stock_summary
Denormalized view for fast inventory queries (updated via triggers).

```sql
CREATE TABLE blood_stock_summary (
  stock_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_id UUID NOT NULL REFERENCES blood_banks(bank_id),
  
  -- Blood Classification
  blood_type ENUM('O', 'A', 'B', 'AB') NOT NULL,
  rh_factor ENUM('POSITIVE', 'NEGATIVE') NOT NULL,
  
  -- Counts
  available_units INTEGER DEFAULT 0,
  reserved_units INTEGER DEFAULT 0,
  total_units INTEGER DEFAULT 0,
  
  -- Alerts
  low_stock_threshold INTEGER DEFAULT 10,
  is_low_stock BOOLEAN DEFAULT FALSE,
  
  -- Last Updated
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Audit
  updated_by UUID,
  
  UNIQUE (bank_id, blood_type, rh_factor)
);

CREATE INDEX idx_stock_bank ON blood_stock_summary(bank_id);
CREATE INDEX idx_stock_type ON blood_stock_summary(blood_type, rh_factor);
CREATE INDEX idx_stock_available ON blood_stock_summary(available_units);
```

### 5. stock_movements
Audit trail of all blood unit status changes.

```sql
CREATE TABLE stock_movements (
  movement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bag_id UUID NOT NULL REFERENCES blood_bags(bag_id),
  
  -- Movement Details
  from_status ENUM(
    'AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'TRANSFUSED', 
    'EXPIRED', 'DAMAGED', 'QUARANTINE', 'DISCARDED'
  ) NOT NULL,
  to_status ENUM(
    'AVAILABLE', 'RESERVED', 'IN_TRANSIT', 'TRANSFUSED', 
    'EXPIRED', 'DAMAGED', 'QUARANTINE', 'DISCARDED'
  ) NOT NULL,
  
  -- Reason for Movement
  movement_reason VARCHAR(255),
  description TEXT,
  
  -- Related Entities
  request_id UUID,
  hospital_id UUID,
  
  -- Performed By
  moved_by UUID,
  moved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT
);

CREATE INDEX idx_movement_bag ON stock_movements(bag_id);
CREATE INDEX idx_movement_status ON stock_movements(from_status, to_status);
CREATE INDEX idx_movement_request ON stock_movements(request_id);
CREATE INDEX idx_movement_date ON stock_movements(moved_at);
```

### 6. expiry_alerts
Alerts for blood units approaching expiry.

```sql
CREATE TABLE expiry_alerts (
  alert_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bag_id UUID NOT NULL REFERENCES blood_bags(bag_id),
  
  -- Alert Details
  expiry_date DATE NOT NULL,
  days_until_expiry INTEGER,
  
  -- Alert Status
  alert_status ENUM('PENDING', 'ACKNOWLEDGED', 'RESOLVED') DEFAULT 'PENDING',
  alert_sent_at TIMESTAMP,
  acknowledged_by UUID,
  acknowledged_at TIMESTAMP,
  
  -- Action Taken
  action_taken TEXT,
  action_taken_by UUID,
  action_taken_at TIMESTAMP,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expiry_bag ON expiry_alerts(bag_id);
CREATE INDEX idx_expiry_status ON expiry_alerts(alert_status);
CREATE INDEX idx_expiry_date ON expiry_alerts(expiry_date);
```

---

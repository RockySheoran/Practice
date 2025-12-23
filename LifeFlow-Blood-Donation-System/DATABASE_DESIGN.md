# LifeFlow - Database Design & ER Diagrams

## Database Architecture Overview

LifeFlow follows the **Database per Service** pattern where each microservice owns and manages its own PostgreSQL database schema. This ensures data isolation, service autonomy, and prevents database-level coupling between services.

## Database Naming Convention

- **Database Names**: `lifeflow_{service_name}`
- **Table Names**: `snake_case` (e.g., `blood_requests`, `donation_history`)
- **Column Names**: `snake_case` (e.g., `created_at`, `blood_type`)
- **Primary Keys**: `id` (UUID type)
- **Foreign Keys**: `{table_name}_id` (e.g., `donor_id`, `hospital_id`)

## Service Database Schemas

### 1. Identity Service Database (`lifeflow_identity`)

#### Tables:
- **users**: Core user authentication data
- **roles**: System roles (DONOR, HOSPITAL, ADMIN, etc.)
- **user_roles**: Many-to-many relationship between users and roles
- **user_profiles**: Extended user profile information
- **audit_logs**: Security and access audit trail

#### ER Diagram:
```
users (1) ←→ (M) user_roles (M) ←→ (1) roles
users (1) ←→ (1) user_profiles
users (1) ←→ (M) audit_logs
```

#### Key Tables Structure:

**users**
```sql
id (UUID, PK)
username (VARCHAR, UNIQUE)
email (VARCHAR, UNIQUE)
password_hash (VARCHAR)
phone_number (VARCHAR)
is_active (BOOLEAN)
is_verified (BOOLEAN)
last_login_at (TIMESTAMP)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

**roles**
```sql
id (UUID, PK)
name (VARCHAR, UNIQUE) -- DONOR, HOSPITAL, ADMIN, SUPER_ADMIN
description (TEXT)
permissions (JSONB)
created_at (TIMESTAMP)
```

### 2. Donor Service Database (`lifeflow_donor`)

#### Tables:
- **donors**: Core donor information
- **donation_history**: Complete donation records
- **medical_history**: Health and medical information
- **eligibility_status**: Current eligibility state
- **health_screenings**: Pre-donation health checks

#### ER Diagram:
```
donors (1) ←→ (M) donation_history
donors (1) ←→ (1) medical_history
donors (1) ←→ (1) eligibility_status
donors (1) ←→ (M) health_screenings
```

#### Key Tables Structure:

**donors**
```sql
id (UUID, PK)
user_id (UUID, FK to identity.users)
blood_type (ENUM: A+, A-, B+, B-, AB+, AB-, O+, O-)
rh_factor (ENUM: POSITIVE, NEGATIVE)
date_of_birth (DATE)
gender (ENUM: MALE, FEMALE, OTHER)
weight (DECIMAL)
height (DECIMAL)
address (JSONB)
emergency_contact (JSONB)
preferred_donation_center (UUID)
total_donations (INTEGER)
last_donation_date (DATE)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

**donation_history**
```sql
id (UUID, PK)
donor_id (UUID, FK)
donation_date (DATE)
donation_center_id (UUID)
blood_bag_id (UUID)
volume_donated (INTEGER) -- in ml
hemoglobin_level (DECIMAL)
blood_pressure (VARCHAR)
donation_type (ENUM: WHOLE_BLOOD, PLASMA, PLATELETS)
staff_id (UUID)
notes (TEXT)
created_at (TIMESTAMP)
```

### 3. Hospital Service Database (`lifeflow_hospital`)

#### Tables:
- **hospitals**: Hospital information
- **hospital_staff**: Staff members and their roles
- **hospital_inventory**: Current blood inventory at hospital
- **certifications**: Hospital certifications and licenses
- **emergency_contacts**: Emergency contact information

#### Key Tables Structure:

**hospitals**
```sql
id (UUID, PK)
user_id (UUID, FK to identity.users)
name (VARCHAR)
registration_number (VARCHAR, UNIQUE)
hospital_type (ENUM: PUBLIC, PRIVATE, SPECIALTY)
address (JSONB)
coordinates (POINT) -- PostGIS for geolocation
contact_info (JSONB)
capacity (INTEGER)
specializations (TEXT[])
is_trauma_center (BOOLEAN)
is_active (BOOLEAN)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### 4. Inventory Service Database (`lifeflow_inventory`)

#### Tables:
- **blood_bags**: Individual blood bag tracking
- **inventory_levels**: Current stock levels by location
- **blood_banks**: Blood bank information
- **storage_locations**: Physical storage locations
- **expiry_alerts**: Automated expiry notifications

#### Key Tables Structure:

**blood_bags**
```sql
id (UUID, PK)
barcode (VARCHAR, UNIQUE)
rfid_tag (VARCHAR, UNIQUE)
blood_type (ENUM)
rh_factor (ENUM)
donor_id (UUID, FK to donor.donors)
collection_date (DATE)
expiry_date (DATE)
volume (INTEGER) -- in ml
status (ENUM: AVAILABLE, RESERVED, USED, EXPIRED, DISCARDED)
blood_bank_id (UUID)
storage_location_id (UUID)
temperature_log (JSONB)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

**inventory_levels**
```sql
id (UUID, PK)
blood_bank_id (UUID)
blood_type (ENUM)
rh_factor (ENUM)
current_stock (INTEGER)
reserved_stock (INTEGER)
minimum_threshold (INTEGER)
maximum_capacity (INTEGER)
last_updated (TIMESTAMP)
```

### 5. Request Service Database (`lifeflow_request`)

#### Tables:
- **blood_requests**: All blood requests
- **emergency_requests**: Emergency-specific data
- **request_status**: Status tracking
- **compatibility_matrix**: Blood type compatibility rules
- **sla_tracking**: Service level agreement monitoring

#### Key Tables Structure:

**blood_requests**
```sql
id (UUID, PK)
hospital_id (UUID, FK)
patient_id (VARCHAR) -- Anonymized patient identifier
blood_type_needed (ENUM)
rh_factor_needed (ENUM)
quantity_needed (INTEGER) -- in units
urgency_level (ENUM: ROUTINE, URGENT, EMERGENCY, CRITICAL)
medical_condition (VARCHAR)
surgery_date (TIMESTAMP)
request_status (ENUM: PENDING, MATCHED, FULFILLED, CANCELLED, EXPIRED)
created_by (UUID) -- Hospital staff member
notes (TEXT)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
fulfilled_at (TIMESTAMP)
```

### 6. Geolocation Service Database (`lifeflow_geolocation`)

#### Tables:
- **locations**: Geographic locations
- **routes**: Optimized delivery routes
- **deliveries**: Active delivery tracking
- **tracking_data**: Real-time location data
- **geographic_zones**: Service area definitions

#### Key Tables Structure:

**locations**
```sql
id (UUID, PK)
entity_type (ENUM: DONOR, HOSPITAL, BLOOD_BANK, CAMP)
entity_id (UUID)
address (TEXT)
coordinates (POINT) -- PostGIS
city (VARCHAR)
state (VARCHAR)
postal_code (VARCHAR)
country (VARCHAR)
is_active (BOOLEAN)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### 7. Notification Service Database (`lifeflow_notification`)

#### Tables:
- **notifications**: All notification records
- **notification_preferences**: User communication preferences
- **delivery_status**: Notification delivery tracking
- **templates**: Message templates
- **channels**: Communication channels

#### Key Tables Structure:

**notifications**
```sql
id (UUID, PK)
recipient_id (UUID)
recipient_type (ENUM: DONOR, HOSPITAL, ADMIN)
channel (ENUM: SMS, EMAIL, PUSH, WHATSAPP)
template_id (UUID)
subject (VARCHAR)
message (TEXT)
priority (ENUM: LOW, NORMAL, HIGH, CRITICAL)
status (ENUM: PENDING, SENT, DELIVERED, FAILED, BOUNCED)
scheduled_at (TIMESTAMP)
sent_at (TIMESTAMP)
delivered_at (TIMESTAMP)
metadata (JSONB)
created_at (TIMESTAMP)
```

### 8. Camp Service Database (`lifeflow_camp`)

#### Tables:
- **camps**: Donation drive events
- **venues**: Event locations
- **volunteers**: Volunteer information
- **resources**: Equipment and resource allocation
- **registrations**: Donor registrations for camps

#### Key Tables Structure:

**camps**
```sql
id (UUID, PK)
name (VARCHAR)
description (TEXT)
organizer_id (UUID)
venue_id (UUID)
start_date (DATE)
end_date (DATE)
start_time (TIME)
end_time (TIME)
target_donations (INTEGER)
actual_donations (INTEGER)
status (ENUM: PLANNED, ACTIVE, COMPLETED, CANCELLED)
registration_required (BOOLEAN)
max_participants (INTEGER)
current_participants (INTEGER)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### 9. Analytics Service Database (`lifeflow_analytics`)

#### Tables:
- **analytics_data**: Aggregated data for analysis
- **predictions**: ML model predictions
- **reports**: Generated reports
- **ml_models**: Machine learning model metadata
- **dashboards**: Dashboard configurations

### 10. Gamification Service Database (`lifeflow_gamification`)

#### Tables:
- **user_points**: Point balances and history
- **badges**: Available badges and achievements
- **achievements**: User achievement records
- **rewards**: Available rewards catalog
- **leaderboards**: Competition rankings

#### Key Tables Structure:

**user_points**
```sql
id (UUID, PK)
user_id (UUID, FK to identity.users)
current_points (INTEGER)
lifetime_points (INTEGER)
tier_level (ENUM: BRONZE, SILVER, GOLD, PLATINUM, DIAMOND)
last_activity_date (DATE)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

## Cross-Service Data Relationships

### Data Consistency Patterns

1. **Event Sourcing**: Critical events are stored and can be replayed
2. **SAGA Pattern**: Distributed transactions across services
3. **Eventually Consistent**: Non-critical data synchronization

### Reference Data Management

- **User IDs**: Shared across all services via Identity Service
- **Blood Types**: Standardized enum across all services
- **Geographic Data**: Shared coordinate system (WGS84)

## Database Performance Considerations

### Indexing Strategy
- **Primary Keys**: UUID with B-tree indexes
- **Foreign Keys**: Indexed for join performance
- **Search Fields**: Composite indexes for common queries
- **Geographic Data**: PostGIS spatial indexes

### Partitioning Strategy
- **Time-based**: Partition large tables by date (donation_history, notifications)
- **Hash-based**: Distribute data evenly across partitions
- **Range-based**: Partition by geographic regions

### Backup and Recovery
- **Point-in-time Recovery**: 30-day retention
- **Cross-region Replication**: Disaster recovery
- **Automated Backups**: Daily full backups, hourly incrementals

## Data Security and Compliance

### Encryption
- **At Rest**: AES-256 encryption for all databases
- **In Transit**: TLS 1.3 for all database connections
- **Column-level**: Sensitive PII data encrypted

### Data Anonymization
- **Donor Data**: Anonymized for hospital requests
- **Patient Data**: No direct patient identifiers stored
- **Analytics**: Aggregated data only

### Audit Trail
- **All Changes**: Complete audit log of data modifications
- **Access Logs**: Who accessed what data when
- **Compliance Reports**: HIPAA/GDPR compliance reporting

## Complete ER Diagram (Conceptual)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Identity      │    │     Donor       │    │    Hospital     │
│   Service       │    │    Service      │    │    Service      │
│                 │    │                 │    │                 │
│ • users         │◄──►│ • donors        │    │ • hospitals     │
│ • roles         │    │ • donation_hist │    │ • hospital_staff│
│ • user_roles    │    │ • medical_hist  │    │ • certifications│
│ • user_profiles │    │ • eligibility   │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Inventory     │    │    Request      │    │  Geolocation    │
│   Service       │    │    Service      │    │    Service      │
│                 │    │                 │    │                 │
│ • blood_bags    │◄──►│ • blood_requests│◄──►│ • locations     │
│ • inventory_lvl │    │ • emergency_req │    │ • routes        │
│ • blood_banks   │    │ • request_status│    │ • deliveries    │
│ • storage_loc   │    │ • compatibility │    │ • tracking_data │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Notification   │    │     Camp        │    │  Gamification   │
│   Service       │    │    Service      │    │    Service      │
│                 │    │                 │    │                 │
│ • notifications │    │ • camps         │    │ • user_points   │
│ • preferences   │    │ • venues        │    │ • badges        │
│ • delivery_stat │    │ • volunteers    │    │ • achievements  │
│ • templates     │    │ • registrations │    │ • rewards       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```
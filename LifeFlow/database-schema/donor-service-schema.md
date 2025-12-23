# Donor Management Service - Database Schema

**Database**: `lifeflow_donor_db`
**Purpose**: Donor profiles, medical history, eligibility tracking, donation records

## ER Diagram

```
┌──────────────────┐
│ donor_profiles   │
│──────────────────│
│ donor_id (PK)    │◄────┬──────────┐
│ user_id (FK)     │     │          │
│ blood_type       │     │          │
│ rh_factor        │     │          │
│ date_of_birth    │     │          │
│ gender           │     │          │
│ weight_kg        │     │          │
└──────────────────┘     │          │
         │               │          │
    ┌────▼─────────┐     │          │
    │ medical_     │     │          │
    │ history      │     │          │
    │──────────────│     │          │
    │ record_id(PK)│     │          │
    │ donor_id(FK) │     │          │
    │ test_type    │     │          │
    │ result       │     │          │
    │ test_date    │     │          │
    └──────────────┘     │          │
                         │    ┌─────▼──────────┐
    ┌────────────────┐   │    │ donation_      │
    │ eligibility_   │   │    │ history        │
    │ records        │   │    │─────────────────
    │────────────────│   │    │ donation_id(PK)│
    │ record_id(PK)  │   │    │ donor_id(FK)   │
    │ donor_id(FK)───┼───┤    │ blood_unit_id  │
    │ status         │   │    │ donation_date  │
    │ reason         │   │    │ amount_ml      │
    │ valid_until    │   │    │ status         │
    │ checked_at     │   │    │ hospital_id    │
    └────────────────┘   │    └────────────────┘
                         │
                    ┌────▼──────────────┐
                    │ deferral_records   │
                    │──────────────────── 
                    │ deferral_id(PK)    │
                    │ donor_id(FK)       │
                    │ reason             │
                    │ deferred_until     │
                    │ created_at         │
                    └────────────────────┘
```

## Tables

### 1. donor_profiles
Core donor information and blood type.

```sql
CREATE TABLE donor_profiles (
  donor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES identity_db.users(user_id),
  
  -- Blood Type
  blood_type ENUM('O', 'A', 'B', 'AB') NOT NULL,
  rh_factor ENUM('POSITIVE', 'NEGATIVE') NOT NULL,
  
  -- Personal Information
  date_of_birth DATE NOT NULL,
  gender ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
  weight_kg NUMERIC(5, 2) NOT NULL,  -- Must be >= 50kg for donation
  height_cm INTEGER,
  
  -- Contact Information
  primary_phone VARCHAR(20),
  alternate_phone VARCHAR(20),
  
  -- Address
  address_line1 VARCHAR(255),
  address_line2 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  zip_code VARCHAR(20),
  country VARCHAR(100),
  latitude NUMERIC(10, 8),
  longitude NUMERIC(11, 8),
  
  -- Donor Status
  donor_status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'DEFERRED') DEFAULT 'ACTIVE',
  is_first_time BOOLEAN DEFAULT TRUE,
  
  -- Notification Preferences
  notify_via_sms BOOLEAN DEFAULT TRUE,
  notify_via_email BOOLEAN DEFAULT TRUE,
  notify_via_whatsapp BOOLEAN DEFAULT FALSE,
  notify_via_push BOOLEAN DEFAULT TRUE,
  
  -- Emergency Contact
  emergency_contact_name VARCHAR(255),
  emergency_contact_phone VARCHAR(20),
  emergency_contact_relation VARCHAR(50),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID,
  updated_by UUID,
  verified_at TIMESTAMP
);

CREATE INDEX idx_donor_user ON donor_profiles(user_id);
CREATE INDEX idx_donor_blood_type ON donor_profiles(blood_type, rh_factor);
CREATE INDEX idx_donor_status ON donor_profiles(donor_status);
CREATE INDEX idx_donor_location ON donor_profiles(latitude, longitude);
CREATE INDEX idx_donor_city ON donor_profiles(city);
```

### 2. medical_history
Medical tests and conditions tracking.

```sql
CREATE TABLE medical_history (
  history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Test Information
  test_type ENUM('BLOOD_GROUP', 'HIV', 'HEPATITIS_B', 'HEPATITIS_C', 'SYPHILIS', 'MALARIA', 'COVID_19') NOT NULL,
  test_result ENUM('NEGATIVE', 'POSITIVE', 'INCONCLUSIVE') NOT NULL,
  
  -- Test Details
  test_date DATE NOT NULL,
  test_method VARCHAR(100),
  tested_at_facility VARCHAR(255),
  
  -- Results
  remarks TEXT,
  next_test_due_date DATE,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID
);

CREATE INDEX idx_medical_donor ON medical_history(donor_id);
CREATE INDEX idx_medical_test_type ON medical_history(test_type);
CREATE INDEX idx_medical_result ON medical_history(test_result);
CREATE INDEX idx_medical_date ON medical_history(test_date);
CREATE INDEX idx_medical_donor_date ON medical_history(donor_id, test_date DESC);
```

### 3. eligibility_records
Donation eligibility status tracking.

```sql
CREATE TABLE eligibility_records (
  record_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Eligibility Status
  is_eligible BOOLEAN NOT NULL,
  reason VARCHAR(255),  -- If not eligible, reason why
  
  -- Assessment Details
  hemoglobin_level NUMERIC(5, 2),  -- g/dL (min 12.5 for females, 13.5 for males)
  platelet_count NUMERIC(10, 0),   -- per microliter
  wbc_count NUMERIC(10, 2),         -- per microliter
  
  -- Recent Conditions
  has_recent_travel BOOLEAN DEFAULT FALSE,
  has_tattoo_last_6_months BOOLEAN DEFAULT FALSE,
  has_piercing_last_6_months BOOLEAN DEFAULT FALSE,
  has_medication BOOLEAN DEFAULT FALSE,
  medication_list TEXT,
  
  -- Checking
  checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valid_until TIMESTAMP NOT NULL,  -- Eligibility valid for 6 months
  checked_by UUID REFERENCES identity_db.users(user_id),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_elig_donor ON eligibility_records(donor_id);
CREATE INDEX idx_elig_status ON eligibility_records(is_eligible);
CREATE INDEX idx_elig_valid_until ON eligibility_records(valid_until);
CREATE INDEX idx_elig_donor_latest ON eligibility_records(donor_id, checked_at DESC);
```

### 4. deferral_records
Temporary deferral of donors (e.g., after donation, illness, travel).

```sql
CREATE TABLE deferral_records (
  deferral_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Deferral Details
  deferral_reason ENUM(
    'POST_DONATION',           -- Standard 56-day deferral
    'LOW_HEMOGLOBIN',         -- Medical reason
    'ILLNESS',                -- Temporary illness
    'MEDICATION',             -- Taking medication
    'TRAVEL',                 -- Recent travel to endemic area
    'PREGNANCY',              -- Post-pregnancy deferral
    'ORGAN_TRANSPLANT',       -- Permanent
    'TATTOO_PIERCING',        -- 6-month deferral
    'BLOOD_EXPOSURE',         -- Accidental exposure
    'OTHER'                   -- Manual deferral
  ) NOT NULL,
  
  deferral_description TEXT,
  deferred_from_date DATE NOT NULL,
  deferred_until_date DATE NOT NULL,
  
  -- Is Permanent?
  is_permanent BOOLEAN DEFAULT FALSE,
  
  -- Deferral Action
  created_by UUID REFERENCES identity_db.users(user_id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- For Review
  review_notes TEXT,
  reviewed_by UUID REFERENCES identity_db.users(user_id),
  reviewed_at TIMESTAMP
);

CREATE INDEX idx_deferral_donor ON deferral_records(donor_id);
CREATE INDEX idx_deferral_dates ON deferral_records(deferred_from_date, deferred_until_date);
CREATE INDEX idx_deferral_active ON deferral_records(donor_id, deferred_until_date);
```

### 5. donation_history
Record of all donations made by donor.

```sql
CREATE TABLE donation_history (
  donation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Donation Details
  donation_date DATE NOT NULL,
  donation_time TIME,
  blood_unit_id UUID,  -- Link to inventory_db.blood_bags
  amount_ml INTEGER NOT NULL,  -- Usually 450ml per donation
  
  -- Donation Type
  donation_type ENUM('WHOLE_BLOOD', 'PLASMA', 'PLATELET', 'RED_CELL') DEFAULT 'WHOLE_BLOOD',
  
  -- Hospital Information
  hospital_id UUID,  -- Hospital where donation was made
  hospital_name VARCHAR(255),
  blood_bank_id UUID,  -- Blood bank where collected
  
  -- Vital Signs (at collection)
  donor_temp_celsius NUMERIC(4, 1),
  donor_pulse INTEGER,
  donor_blood_pressure VARCHAR(10),  -- e.g., "120/80"
  
  -- Post-Donation
  adverse_reactions TEXT,
  notes TEXT,
  
  -- Status
  donation_status ENUM('COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'COMPLETED',
  
  -- Used Information
  blood_used BOOLEAN DEFAULT FALSE,
  used_at_hospital UUID,
  used_at_date DATE,
  recipient_anonymous_id UUID,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID
);

CREATE INDEX idx_donation_donor ON donation_history(donor_id);
CREATE INDEX idx_donation_date ON donation_history(donation_date);
CREATE INDEX idx_donation_blood_unit ON donation_history(blood_unit_id);
CREATE INDEX idx_donation_used ON donation_history(blood_used);
CREATE INDEX idx_donation_hospital ON donation_history(hospital_id);
CREATE INDEX idx_donation_donor_date ON donation_history(donor_id, donation_date DESC);
```

### 6. donor_rewards
Gamification points and badges.

```sql
CREATE TABLE donor_rewards (
  reward_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Points System
  total_points INTEGER DEFAULT 0,
  lifetime_donations INTEGER DEFAULT 0,
  lifetime_blood_ml INTEGER DEFAULT 0,
  
  -- Badges
  badge_name VARCHAR(100),
  badge_description TEXT,
  badge_icon_url VARCHAR(500),
  badge_earned_at TIMESTAMP,
  
  -- Tier Status
  donor_tier ENUM('BRONZE', 'SILVER', 'GOLD', 'PLATINUM', 'DIAMOND') DEFAULT 'BRONZE',
  
  -- Rewards Redeemed
  rewards_redeemed INTEGER DEFAULT 0,
  last_reward_redeemed_at TIMESTAMP,
  
  -- Audit
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_rewards_donor ON donor_rewards(donor_id);
CREATE INDEX idx_rewards_tier ON donor_rewards(donor_tier);
CREATE INDEX idx_rewards_points ON donor_rewards(total_points DESC);
```

### 7. donor_testimonials
Success stories of blood recipients (anonymized).

```sql
CREATE TABLE donor_testimonials (
  testimonial_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES donor_profiles(donor_id),
  
  -- Anonymous Patient Info
  patient_name_anonymous VARCHAR(255),
  patient_age_range VARCHAR(20),
  patient_medical_condition TEXT,
  
  -- Testimonial
  testimonial_text TEXT NOT NULL,
  impact_statement TEXT,
  
  -- Media
  photo_url VARCHAR(500),
  video_url VARCHAR(500),
  
  -- Status
  is_approved BOOLEAN DEFAULT FALSE,
  approved_by UUID REFERENCES identity_db.users(user_id),
  approved_at TIMESTAMP,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID
);

CREATE INDEX idx_testimonial_donor ON donor_testimonials(donor_id);
CREATE INDEX idx_testimonial_approved ON donor_testimonials(is_approved);
```

### 8. donor_preferences
Communication and notification settings.

```sql
CREATE TABLE donor_preferences (
  preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL UNIQUE REFERENCES donor_profiles(donor_id) ON DELETE CASCADE,
  
  -- Notification Settings
  prefer_sms_notifications BOOLEAN DEFAULT TRUE,
  prefer_email_notifications BOOLEAN DEFAULT TRUE,
  prefer_push_notifications BOOLEAN DEFAULT TRUE,
  prefer_whatsapp_notifications BOOLEAN DEFAULT FALSE,
  
  -- Request Settings
  auto_accept_requests BOOLEAN DEFAULT FALSE,
  preferred_donation_frequency ENUM('MONTHLY', 'QUARTERLY', 'BIANNUALLY', 'AS_NEEDED') DEFAULT 'AS_NEEDED',
  max_distance_km INTEGER DEFAULT 10,
  
  -- Privacy Settings
  allow_vein_to_vein_tracking BOOLEAN DEFAULT TRUE,
  allow_data_sharing_research BOOLEAN DEFAULT FALSE,
  
  -- Language
  preferred_language VARCHAR(50) DEFAULT 'en_US',
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID
);

CREATE INDEX idx_prefs_donor ON donor_preferences(donor_id);
```

---

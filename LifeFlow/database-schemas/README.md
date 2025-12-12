# LifeFlow Database Schemas

This directory contains all database schemas for the LifeFlow microservices architecture.

## Overview

Each microservice has its own PostgreSQL database with complete schema separation:

- **lifeflow_identity**: Authentication & user management
- **lifeflow_donors**: Donor profiles & donation records
- **lifeflow_inventory**: Blood bank inventory & stock management
- **lifeflow_requests**: Blood request & emergency handling
- **lifeflow_geolocation**: Location tracking & logistics
- **lifeflow_notifications**: Notification system & preferences
- **lifeflow_camps**: Donation camps & events
- **lifeflow_analytics**: Analytics, gamification & predictions

## Quick Start

### 1. Using Docker Compose
```bash
# All databases are automatically initialized
docker-compose up -d postgres

# Verify databases were created
docker exec -it lifeflow-postgres psql -U lifeflow -l
```

### 2. Using Manual Script
```bash
# Make script executable
chmod +x scripts/init-all-services.sh

# Run initialization script
./scripts/init-all-services.sh

# Or with custom parameters
POSTGRES_HOST=localhost POSTGRES_PORT=5432 \
POSTGRES_USER=lifeflow POSTGRES_PASSWORD=password \
./scripts/init-all-services.sh
```

### 3. Manual Initialization
```bash
# Create individual databases
psql -U postgres -c "CREATE DATABASE lifeflow_donors OWNER lifeflow;"
psql -U postgres -c "CREATE DATABASE lifeflow_inventory OWNER lifeflow;"
# ... etc

# Initialize schemas
psql -U lifeflow -d lifeflow_donors -f scripts/02_donor-schema.sql
psql -U lifeflow -d lifeflow_inventory -f scripts/03_inventory-schema.sql
# ... etc
```

## Schema Files

### 01_identity-auth-schema.sql
User authentication, roles, KYC documents, sessions, 2FA

**Key Tables**:
- `users`: User accounts
- `roles`: Role definitions
- `user_roles`: User-role assignments
- `kyc_documents`: KYC document tracking
- `sessions`: User sessions
- `audit_logs`: Security audit trail

### 02_donor-schema.sql
Donor profiles, medical history, donations, eligibility

**Key Tables**:
- `donors`: Donor profiles
- `medical_history`: Medical records
- `donation_records`: Donation history
- `donor_preferences`: Communication preferences
- `eligibility_history`: Eligibility status tracking

### 03_inventory-schema.sql
Blood inventory, stock management, expiry tracking

**Key Tables**:
- `blood_banks`: Blood bank details
- `blood_inventory`: Current stock levels
- `blood_bags`: Individual blood bags
- `fridges`: Refrigeration units
- `inventory_transactions`: Stock movements
- `stock_forecasts`: Predicted demand

### 04_request-schema.sql
Blood requests, emergency handling, matching

**Key Tables**:
- `blood_requests`: Blood requests from hospitals
- `matching_records`: Donor-request matching
- `request_alternatives`: Compatible blood types
- `elective_requests`: Scheduled requests
- `request_fulfillment`: Delivery tracking

### 05_geolocation-schema.sql
Location tracking, geofences, logistics

**Key Tables**:
- `locations`: Entity locations
- `live_tracking_sessions`: Real-time tracking
- `geo_fences`: Geofence definitions
- `donor_locations`: Donor GPS locations
- `transport_vehicles`: Delivery vehicles
- `delivery_logs`: Delivery history

### 06_notification-schema.sql
Notifications, preferences, delivery logs

**Key Tables**:
- `notifications`: Notification records
- `notification_templates`: Message templates
- `user_notification_preferences`: User preferences
- `sms_logs`: SMS delivery logs
- `email_logs`: Email delivery logs
- `push_notification_logs`: Push notifications

### 07_camp-schema.sql
Donation camps, volunteers, events

**Key Tables**:
- `camps_drives`: Donation camp information
- `camp_registrations`: Donor registrations
- `volunteers`: Volunteer information
- `camp_analytics`: Camp statistics
- `camp_expenses`: Cost tracking

### 08_analytics-schema.sql
Analytics, gamification, predictions, rewards

**Key Tables**:
- `donor_rewards`: Reward records
- `badges_achievements`: Badge definitions
- `donor_badges`: Donor badge achievements
- `leaderboards`: Leaderboard data
- `point_transactions`: Point history
- `machine_learning_models`: ML model registry
- `predictions`: Prediction records
- `blood_type_compatibility`: Blood type compatibility matrix

## Design Principles

### 1. Normalization
- All schemas normalized to 3NF
- No data duplication
- Referential integrity maintained

### 2. Indexing Strategy
- Primary keys indexed (implicit)
- Foreign keys indexed
- Frequently searched columns indexed
- Date columns indexed for range queries
- Spatial indexes for geolocation

### 3. Data Types
- UUID for distributed IDs
- JSONB for flexible structures
- DECIMAL for monetary values
- GEOMETRY (PostGIS) for coordinates
- TIMESTAMP WITH TIME ZONE for all dates

### 4. Audit & Compliance
- `created_at` on all tables
- `updated_at` on mutable tables
- `deleted_at` for soft deletes
- Audit logs for sensitive operations

### 5. Constraints
- NOT NULL on required fields
- CHECK constraints for valid ranges
- UNIQUE on business keys
- Foreign keys with ON DELETE rules

## Migrations

Database migrations use Flyway naming convention:

```
V1.0__initial_schema.sql
V1.1__add_audit_tables.sql
V1.2__add_blood_type_compatibility.sql
V2.0__add_machine_learning_tables.sql
```

### Running Migrations
```bash
# Migrations auto-run on service startup
# Location: src/main/resources/db/migration/

# Manual migration
mvn flyway:migrate -Dflyway.configFiles=flyway.conf
```

## Performance Optimization

### Indexing
All frequently queried columns are indexed:
```sql
-- Donor service
CREATE INDEX idx_donors_blood_type ON donors(blood_type);
CREATE INDEX idx_donations_donation_date ON donations(donation_date);

-- Request service
CREATE INDEX idx_requests_status ON blood_requests(status);
CREATE INDEX idx_requests_created_at ON blood_requests(created_at);

-- Inventory service
CREATE INDEX idx_blood_bags_expiry_date ON blood_bags(expiry_date);
```

### Materialized Views
Pre-calculated queries for complex analytics:
```sql
CREATE MATERIALIZED VIEW donor_stats AS
SELECT donor_id, COUNT(*) as total_donations, SUM(units_donated) as total_units
FROM donation_records
GROUP BY donor_id;

REFRESH MATERIALIZED VIEW donor_stats;
```

### Partitioning
Large tables partitioned by date:
```sql
CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

## Backup & Recovery

### Automated Backups
```bash
# Daily backup at 2 AM UTC
pg_dump -Fc lifeflow_donors > backup_$(date +%Y%m%d).dump

# Restore from backup
pg_restore -d lifeflow_donors backup_20240115.dump
```

### Point-in-Time Recovery
```bash
# Enable WAL archiving
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal_archive/%f'

# Restore to specific time
pg_basebackup -D /backup/base -Fp -Xs -P
```

## Monitoring & Maintenance

### Check Table Sizes
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Analyze & Vacuum
```bash
# Monthly maintenance
VACUUM ANALYZE; -- in each database

# Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Query Performance
```sql
-- Enable query logging
log_min_duration_statement = 1000 -- log queries > 1 second

-- Check slow queries
SELECT query, calls, mean_time, max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

## Troubleshooting

### Connection Issues
```bash
# Test connection
psql -h localhost -U lifeflow -d lifeflow_donors

# Check PostgreSQL logs
tail -f /var/log/postgresql/postgresql.log

# Verify database exists
psql -U postgres -l | grep lifeflow
```

### Migration Errors
```bash
# Check Flyway status
mvn flyway:info

# Repair (use cautiously)
mvn flyway:repair

# Clean & reset (dev only!)
mvn flyway:clean
```

### Performance Issues
```bash
# Identify missing indexes
SELECT schemaname, tablename, attname
FROM pg_stat_user_tables t
JOIN pg_attribute a ON t.relid = a.attrelid
WHERE seq_scan > idx_scan AND idx_scan = 0;

# Run explain on slow queries
EXPLAIN ANALYZE SELECT * FROM donors WHERE blood_type = 'O_PLUS';
```

## Related Documentation

- Architecture: `../02_ARCHITECTURE.md`
- ER Diagrams: `../04_ER_DIAGRAMS.md`
- Setup Guide: `../10_DEVELOPMENT_SETUP.md`
- API Documentation: `../05_API_GATEWAY_DESIGN.md`

---

**Last Updated**: 2024-01-15  
**Version**: 1.0

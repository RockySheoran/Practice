-- ===== CREATE DATABASES =====
CREATE DATABASE lifeflow_identity OWNER lifeflow;
CREATE DATABASE lifeflow_donors OWNER lifeflow;
CREATE DATABASE lifeflow_inventory OWNER lifeflow;
CREATE DATABASE lifeflow_requests OWNER lifeflow;
CREATE DATABASE lifeflow_geolocation OWNER lifeflow;
CREATE DATABASE lifeflow_notifications OWNER lifeflow;
CREATE DATABASE lifeflow_camps OWNER lifeflow;
CREATE DATABASE lifeflow_analytics OWNER lifeflow;

-- ===== GRANT PERMISSIONS =====
GRANT ALL PRIVILEGES ON DATABASE lifeflow_identity TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_donors TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_inventory TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_requests TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_geolocation TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_notifications TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_camps TO lifeflow;
GRANT ALL PRIVILEGES ON DATABASE lifeflow_analytics TO lifeflow;

-- Note: Run individual schema scripts in each database:
-- psql -U lifeflow -d lifeflow_identity -f scripts/01_identity-auth-schema.sql
-- psql -U lifeflow -d lifeflow_donors -f scripts/02_donor-schema.sql
-- ... and so on for other services

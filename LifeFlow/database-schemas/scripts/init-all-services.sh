#!/bin/bash

# ===== LifeFlow Database Initialization Script =====
# This script initializes all databases and schemas for LifeFlow microservices
# Usage: ./init-all-services.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database credentials
POSTGRES_USER="${POSTGRES_USER:-lifeflow}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-dev_password}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}LifeFlow Database Initialization${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Check if PostgreSQL is accessible
echo -e "${YELLOW}Checking PostgreSQL connection...${NC}"
if ! PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT" -tc "SELECT 1" > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Cannot connect to PostgreSQL${NC}"
    echo "Host: $POSTGRES_HOST"
    echo "Port: $POSTGRES_PORT"
    echo "User: $POSTGRES_USER"
    exit 1
fi
echo -e "${GREEN}✓ PostgreSQL connection successful${NC}"
echo ""

# Function to create database
create_database() {
    local db_name=$1
    echo -e "${YELLOW}Creating database: $db_name${NC}"
    
    PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT" -tc \
        "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1 || \
        PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT" \
        -c "CREATE DATABASE $db_name OWNER $POSTGRES_USER;"
    
    echo -e "${GREEN}✓ Database created: $db_name${NC}"
}

# Function to execute SQL file in database
execute_sql_file() {
    local db_name=$1
    local sql_file=$2
    
    if [ ! -f "$sql_file" ]; then
        echo -e "${RED}ERROR: SQL file not found: $sql_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Executing SQL file: $sql_file${NC}"
    PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT" \
        -d "$db_name" -f "$sql_file" > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Schema initialized: $db_name${NC}"
}

echo -e "${YELLOW}Creating databases...${NC}"
create_database "lifeflow_identity"
create_database "lifeflow_donors"
create_database "lifeflow_inventory"
create_database "lifeflow_requests"
create_database "lifeflow_geolocation"
create_database "lifeflow_notifications"
create_database "lifeflow_camps"
create_database "lifeflow_analytics"
echo ""

echo -e "${YELLOW}Initializing schemas...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

execute_sql_file "lifeflow_identity" "$SCRIPT_DIR/01_identity-auth-schema.sql"
execute_sql_file "lifeflow_donors" "$SCRIPT_DIR/02_donor-schema.sql"
execute_sql_file "lifeflow_inventory" "$SCRIPT_DIR/03_inventory-schema.sql"
execute_sql_file "lifeflow_requests" "$SCRIPT_DIR/04_request-schema.sql"
execute_sql_file "lifeflow_geolocation" "$SCRIPT_DIR/05_geolocation-schema.sql"
execute_sql_file "lifeflow_notifications" "$SCRIPT_DIR/06_notification-schema.sql"
execute_sql_file "lifeflow_camps" "$SCRIPT_DIR/07_camp-schema.sql"
execute_sql_file "lifeflow_analytics" "$SCRIPT_DIR/08_analytics-schema.sql"
echo ""

echo -e "${YELLOW}Verifying schema creation...${NC}"
for db in lifeflow_identity lifeflow_donors lifeflow_inventory lifeflow_requests \
          lifeflow_geolocation lifeflow_notifications lifeflow_camps lifeflow_analytics; do
    
    table_count=$(PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" \
        -p "$POSTGRES_PORT" -d "$db" -tc \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema');")
    
    echo -e "${GREEN}✓ $db: $table_count tables created${NC}"
done
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Database initialization completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

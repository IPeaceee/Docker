#!/bin/bash
# restore.sh - Restore PostgreSQL database from backup
# Usage: ./scripts/restore.sh <backup_file> [target_db]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing backup file argument${NC}"
    echo ""
    echo "Usage: $0 <backup_file> [target_db]"
    echo ""
    echo "Examples:"
    echo "  $0 ./backups/myapp_db-2025-01-15_02-00.sql.gz"
    echo "  $0 ./backups/myapp_db-2025-01-15_02-00.sql.gz restored_db"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/*.{sql.gz,tar,sql} 2>/dev/null || echo "  No backup files found"
    exit 1
fi

BACKUP_FILE="$1"
TARGET_DB="${2:-}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

# Source environment variables
source .env

# Use TARGET_DB or fallback to POSTGRES_DB
if [ -z "$TARGET_DB" ]; then
    TARGET_DB="$POSTGRES_DB"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

# Determine active postgres container
POSTGRES_CONTAINER=""
if docker ps --filter "name=postgres-db-prod" --filter "status=running" | grep -q postgres-db-prod; then
    POSTGRES_CONTAINER="postgres-db-prod"
elif docker ps --filter "name=postgres-db" --filter "status=running" | grep -q postgres-db; then
    POSTGRES_CONTAINER="postgres-db"
else
    echo -e "${RED}Error: No PostgreSQL container is running${NC}"
    echo "Please start the database first:"
    echo "  docker compose --profile dev up -d    # For development"
    echo "  docker compose --profile prod up -d   # For production"
    exit 1
fi

echo -e "${BLUE}=== PostgreSQL Database Restore ===${NC}"
echo ""
echo "Backup file:  $BACKUP_FILE"
echo "Target DB:    $TARGET_DB"
echo "Container:    $POSTGRES_CONTAINER"
echo ""

# Warning for existing database
if [ "$TARGET_DB" = "$POSTGRES_DB" ]; then
    echo -e "${YELLOW}⚠ WARNING: You are about to restore to the active database!${NC}"
    echo -e "${YELLOW}⚠ This will OVERWRITE existing data in: $TARGET_DB${NC}"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Restore cancelled."
        exit 0
    fi
fi

# Create target database if it doesn't exist (only if different from main DB)
if [ "$TARGET_DB" != "$POSTGRES_DB" ]; then
    echo "Creating target database: $TARGET_DB"
    docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -c "CREATE DATABASE $TARGET_DB;" 2>/dev/null || true
fi

echo "Starting restore..."

# Determine file type and restore accordingly
if [[ "$BACKUP_FILE" == *.sql.gz ]]; then
    echo "Restoring from gzipped SQL file..."
    gunzip -c "$BACKUP_FILE" | docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$TARGET_DB"
elif [[ "$BACKUP_FILE" == *.tar ]]; then
    echo "Restoring from tar archive..."
    docker exec -i "$POSTGRES_CONTAINER" pg_restore -U "$POSTGRES_USER" -d "$TARGET_DB" -v < "$BACKUP_FILE"
elif [[ "$BACKUP_FILE" == *.sql ]]; then
    echo "Restoring from plain SQL file..."
    cat "$BACKUP_FILE" | docker exec -i "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$TARGET_DB"
else
    echo -e "${RED}Error: Unsupported backup file format${NC}"
    echo "Supported formats: .sql, .sql.gz, .tar"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Restore completed successfully${NC}"
    echo ""
    echo "Database: $TARGET_DB"
    
    # Show database size
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$TARGET_DB" -c "\l+ $TARGET_DB"
else
    echo -e "${RED}✗ Restore failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Done!${NC}"

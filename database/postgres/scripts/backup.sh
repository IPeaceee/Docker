#!/bin/bash
# backup.sh - Manual backup trigger for PostgreSQL
# Usage: ./scripts/backup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PostgreSQL Manual Backup ===${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

# Source environment variables
source .env

# Determine which profile is running
BACKUP_CONTAINER="postgres-backup"

# Check if backup container is running
if ! docker ps --filter "name=${BACKUP_CONTAINER}" --filter "status=running" | grep -q ${BACKUP_CONTAINER}; then
    echo -e "${YELLOW}Warning: Backup container is not running${NC}"
    echo "Starting backup service..."
    
    # Try to determine active profile
    if docker ps --filter "name=postgres-db-prod" --filter "status=running" | grep -q postgres-db-prod; then
        docker compose --profile prod up -d backup
    else
        docker compose --profile dev up -d backup
    fi
    
    # Wait for container to be ready
    sleep 3
fi

echo "Triggering manual backup..."

# Execute backup by sending SIGUSR1 to the backup process
docker compose exec backup sh -c '/backup.sh'

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Backup completed successfully${NC}"
    echo ""
    echo "Backup files location: ./backups/"
    ls -lh ./backups/ | tail -5
else
    echo -e "${RED}✗ Backup failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Done!${NC}"

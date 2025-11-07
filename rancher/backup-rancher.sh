#!/bin/bash

# Rancher Backup Script for Internal Environment
# This script creates backups of Rancher data and configuration

set -euo pipefail

# Configuration
BACKUP_DIR="./backups"
RANCHER_DATA_DIR="./rancher_data"
RANCHER_LOGS_DIR="./rancher_logs"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="rancher_backup_${DATE}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo "Starting Rancher backup: ${BACKUP_NAME}"

# Create backup
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
    -C "$(dirname "${RANCHER_DATA_DIR}")" \
    "$(basename "${RANCHER_DATA_DIR}")" \
    "$(basename "${RANCHER_LOGS_DIR}")" \
    docker-compose.yml \
    .env 2>/dev/null || true

# Verify backup
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" ]; then
    echo "Backup created successfully: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    
    # Calculate and display backup size
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
    echo "Backup size: ${BACKUP_SIZE}"
else
    echo "Error: Backup failed!"
    exit 1
fi

# Clean old backups
echo "Cleaning backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "rancher_backup_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

# List current backups
echo "Current backups:"
ls -lh "${BACKUP_DIR}"/rancher_backup_*.tar.gz 2>/dev/null || echo "No backups found"

echo "Backup completed successfully!"
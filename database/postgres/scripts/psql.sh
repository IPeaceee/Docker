#!/bin/bash
# psql.sh - Interactive PostgreSQL client wrapper
# Usage: 
#   docker compose run --rm psql-runner                    # Interactive mode
#   docker compose run --rm psql-runner -f /migrations/001_init.sql
#   docker compose run --rm psql-runner -c "SELECT version();"

set -euo pipefail

# If no arguments provided, start interactive psql
if [ $# -eq 0 ]; then
    exec psql
else
    # Execute with provided arguments
    exec psql "$@"
fi

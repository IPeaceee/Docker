-- Initialize common PostgreSQL extensions
-- This file is executed automatically on first database creation

-- UUID support
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Full text search with trigram support
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Additional indexing methods
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Query performance tracking
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Additional data types
-- CREATE EXTENSION IF NOT EXISTS hstore;
-- CREATE EXTENSION IF NOT EXISTS citext;

-- PostGIS for geospatial data (uncomment if needed)
-- CREATE EXTENSION IF NOT EXISTS postgis;

-- Log extensions created
DO $$
BEGIN
  RAISE NOTICE 'PostgreSQL extensions initialized successfully';
END $$;

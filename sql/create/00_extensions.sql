-- ============================================================================
-- 00 -- EXTENSIONS
-- ============================================================================
-- Required Postgres extensions for the canonical schema.  Run first.
-- All statements are idempotent.
-- ============================================================================

-- UUID generation (uuid_generate_v4, etc.).
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Cryptographic helpers, incl. gen_random_uuid() used by table defaults.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Vector similarity search for embedding columns.
CREATE EXTENSION IF NOT EXISTS "vector";

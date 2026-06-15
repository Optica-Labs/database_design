-- ============================================================================
-- CANONICAL DATABASE CREATION ORCHESTRATOR
-- ============================================================================
-- Stands up the complete data-storage schema in a fresh Postgres-compatible
-- database (PostgreSQL 14+, Supabase, AWS Aurora/RDS, self-hosted).
--
-- Usage:
--   psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
--
-- Idempotent: safe to re-run.  To rebuild from scratch, run sql/create/reset.sql
-- first (DESTRUCTIVE -- drops every canonical object).
-- ============================================================================

\set ON_ERROR_STOP on

\echo '==> 00 extensions'
\ir create/00_extensions.sql

\echo '==> 10 schema (sequences, tables, constraints, indexes)'
\ir create/10_schema_canonical.sql

\echo '==> 20 views'
\ir create/20_views.sql

\echo '==> 30 seed reference data'
\ir create/30_seed_reference.sql

\echo '==> 99 verify'
\ir create/99_verify.sql

\echo '==> done'

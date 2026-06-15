# `sql/create/` — Canonical database creation (source of truth)

This directory is the **authoritative source for standing up the data-storage
schema** in a fresh Postgres-compatible environment (PostgreSQL 14+, Supabase,
AWS Aurora/RDS, self-hosted). It reflects the live database schema, with the
`alpha` naming convention transitioned to **`peregrine`** (see
[../legacy/README.md](../legacy/README.md) for the name map).

## Run it

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

The orchestrator [../create.sql](../create.sql) applies, in order:

| Step | File | Purpose |
| ---- | ---- | ------- |
| 00 | [00_extensions.sql](00_extensions.sql) | `uuid-ossp`, `pgcrypto`, `vector` |
| 10 | [10_schema_canonical.sql](10_schema_canonical.sql) | 26 sequences, 94 tables, constraints, indexes |
| 20 | [20_views.sql](20_views.sql) | 6 reporting views |
| 30 | [30_seed_reference.sql](30_seed_reference.sql) | product catalog (`ai-range`, `peregrine`) |
| 99 | [99_verify.sql](99_verify.sql) | post-create sanity asserts |

Every statement is idempotent (`IF NOT EXISTS` / guarded constraints), so the
pipeline is safe to re-run. To rebuild from scratch, run the destructive
teardown first:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create/reset.sql
```

## Generated files — do not edit by hand

`10_schema_canonical.sql`, `20_views.sql` and `reset.sql` are generated from the
live schema export. Regenerate after a new schema snapshot:

```bash
python3 scripts/generate_canonical_schema.py   # schema + views + reset
python3 scripts/generate_variants.py           # product variants
python3 scripts/verify_canonical_schema.py     # structural check vs snapshot
```

Sources of truth for the generators:
[../../docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql](../../docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql)
(tables/constraints/indexes) and
[../../docs/verification/LIVE_SCHEMA_SNAPSHOT.json](../../docs/verification/LIVE_SCHEMA_SNAPSHOT.json)
(view definitions, verification oracle).

## Product variants

[../variants/](../variants/) holds `ai_range_only.sql` and `peregrine_only.sql`,
script-derived subsets of the canonical schema (membership in
[../variants/manifests.json](../variants/manifests.json)). They are
self-contained and FK-consistent.

## Not in scope here

Row-level security, triggers and stored functions are intentionally excluded
from this creation pipeline; they are planned as a separate, later phase.

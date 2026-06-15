# Database Design

Canonical, PostgreSQL-compatible database creation repo for Optica.

## Current Source Of Truth

Use the canonical create pipeline:

- `sql/create.sql` (entry point)
- `sql/create/README.md` (how to run, reset, regenerate)

Pipeline artifacts:

- `sql/create/10_schema_canonical.sql` (94 tables, 26 sequences)
- `sql/create/20_views.sql` (6 views)
- `sql/create/30_seed_reference.sql` (reference products)
- `sql/create/99_verify.sql` (post-create assertions)

Product variants (script-derived):

- `sql/variants/ai_range_only.sql` (65 tables)
- `sql/variants/peregrine_only.sql` (24 tables)

## Quick Start

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

Optional clean rebuild:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create/reset.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Regenerate Artifacts

```bash
python3 scripts/generate_canonical_schema.py
python3 scripts/generate_variants.py
python3 scripts/generate_peregrine_snapshot.py
python3 scripts/verify_canonical_schema.py
```

## Documentation

- `GETTING_STARTED.md`
- `MASTER_INDEX.md`
- `DOCUMENTATION.md`
- `sql/README.md`
- `docs/verification/README.md`

## Notes

- Naming convention is peregrine.
- Historical material is preserved in `docs/archive/`.

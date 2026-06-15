# Alignment Verification

## Canonical Targets

- `sql/create/10_schema_canonical.sql` (94 tables, 26 sequences)
- `sql/create/20_views.sql` (6 views)
- `sql/variants/ai_range_only.sql` (65 tables)
- `sql/variants/peregrine_only.sql` (24 tables)

## Verification Inputs

- `docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql`
- `docs/verification/LIVE_SCHEMA_SNAPSHOT.json`

## Verification Command

```bash
python3 scripts/verify_canonical_schema.py
```

## Deployment

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

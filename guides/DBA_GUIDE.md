# DBA Guide

## Standard Deployment

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Clean Rebuild

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create/reset.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Validation

- Built-in checks: `sql/create/99_verify.sql`
- Structural verifier: `python3 scripts/verify_canonical_schema.py`

## Current Footprint

- 94 base tables
- 26 sequences
- 6 views

## References

- `sql/create/README.md`
- `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md`

# Supabase Compatibility Report

## Status

Supabase-compatible canonical pipeline is available and validated for the current
source-of-truth schema.

## Canonical Deploy Path

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Canonical Artifact Scope

- `sql/create/10_schema_canonical.sql`: 94 tables, 26 sequences
- `sql/create/20_views.sql`: 6 views
- `sql/variants/ai_range_only.sql`: 65-table subset
- `sql/variants/peregrine_only.sql`: 24-table subset

## Validation References

- `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md`
- `docs/verification/LIVE_SCHEMA_SNAPSHOT.md`
- `sql/ALIGNMENT_VERIFICATION.md`

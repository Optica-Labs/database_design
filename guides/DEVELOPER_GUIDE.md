# Developer Guide

## Primary Workflow

1. Generate artifacts when inputs change:

```bash
python3 scripts/generate_canonical_schema.py
python3 scripts/generate_variants.py
python3 scripts/generate_peregrine_snapshot.py
```

2. Verify structure:

```bash
python3 scripts/verify_canonical_schema.py
```

3. Deploy canonical schema:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Artifacts You Own

- `sql/create/10_schema_canonical.sql`
- `sql/create/20_views.sql`
- `sql/create/reset.sql`
- `sql/variants/ai_range_only.sql`
- `sql/variants/peregrine_only.sql`

## Current Counts

- Canonical: 94 tables, 26 sequences, 6 views
- Variants: 65/24 tables

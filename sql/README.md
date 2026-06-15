# SQL Directory Reference

## Canonical Deployment (Source Of Truth)

Use:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

Details: `sql/create/README.md`

## Canonical Artifacts

- `sql/create/00_extensions.sql`
- `sql/create/10_schema_canonical.sql` (94 tables, 26 sequences)
- `sql/create/20_views.sql` (6 views)
- `sql/create/30_seed_reference.sql`
- `sql/create/99_verify.sql`
- `sql/create/reset.sql`

## Variants

- `sql/variants/ai_range_only.sql` (65 tables)
- `sql/variants/peregrine_only.sql` (24 tables)
- `sql/variants/manifests.json`

## Legacy/Reference

- `sql/schemas/` contains older schema files retained for reference.
- `sql/legacy/README.md` documents naming transition mapping.

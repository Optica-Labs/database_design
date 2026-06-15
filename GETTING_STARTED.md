# Getting Started

## Fastest Path

1. Confirm `DATABASE_URL` is set.
2. Run:

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

3. Verify post-create checks completed successfully.

## Optional Clean Rebuild

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create/reset.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## What You Get

- 94 base tables
- 26 sequences
- 6 views
- reference products seeded

## Next Docs

- `sql/create/README.md`
- `sql/README.md`
- `docs/verification/README.md`

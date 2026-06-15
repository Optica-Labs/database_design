# Supabase Quick Deployment

This quick guide now delegates to the canonical deployment pipeline.

## Run

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## Optional Reset

```bash
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create/reset.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f sql/create.sql
```

## See Also

- `sql/create/README.md`
- `sql/README.md`

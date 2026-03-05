# Live Supabase Alignment Report (Method 1)

Date: March 4, 2026  
Environment: Transaction Pooler endpoint via Method 1 (`SUPABASE_*` vars)  
Verification Script: [scripts/verify_live_alignment.py](scripts/verify_live_alignment.py)

## Scope

This verification compares:

1. Supabase schema files in [sql/schemas/supabase](sql/schemas/supabase)
2. Key documentation claims in [DOCUMENTATION.md](DOCUMENTATION.md) and [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md)
3. Live Supabase `public` schema metadata

## Connection Method Used

- Method 1 (`psycopg2` + individual env vars): `SUPABASE_HOST`, `SUPABASE_PORT`, `SUPABASE_DB`, `SUPABASE_USER`, `SUPABASE_PASSWORD`
- Result: connection successful and queries executed

## Live Database Snapshot

- Public relations found: 96
- Base tables: 90
- Views: 6

## Schema Alignment Result

### ✅ Core supabase modular schema files are aligned

Expected tables parsed from:
- [sql/schemas/supabase/01_extensions_and_products.sql](sql/schemas/supabase/01_extensions_and_products.sql)
- [sql/schemas/supabase/01_conversations_and_turns.sql](sql/schemas/supabase/01_conversations_and_turns.sql)
- [sql/schemas/supabase/02_llm_invocations.sql](sql/schemas/supabase/02_llm_invocations.sql)

Expected table set (8):
- `products`
- `tenants`
- `client_product_subscriptions`
- `generation_runs`
- `conversations`
- `turns`
- `quality_metrics`
- `llm_invocations`

Verification outcome:
- Missing from live DB: **0**
- Present in live DB: **8/8**

Conclusion: the repo’s current modular Supabase schema is fully present in the live DB.

## Documentation Alignment Result

### ✅ Some major data claims are accurate

In [DOCUMENTATION.md](DOCUMENTATION.md), the following table record counts match live DB:

- `llm_invocations`: documented 25,257, live 25,257
- `prompt_generator_responses`: documented 10,464, live 10,464
- `scenarios`: documented 70, live 70
- `scenario_intents`: documented 50, live 50
- `threat_vectors`: documented 276, live 276
- `personas`: documented 67, live 67

### ⚠️ One major summary claim is not aligned

In [DOCUMENTATION.md](DOCUMENTATION.md), claim:
- “All 25 tables migrated”

Live DB currently has:
- 90 base tables (plus 6 views)

Conclusion: this summary statement is now outdated for the current live environment.

### ⚠️ Documentation link integrity issues remain

References in [DOCUMENTATION.md](DOCUMENTATION.md) point to missing files, including:
- [docs/SCHEMA_ARCHITECTURE.md](docs/SCHEMA_ARCHITECTURE.md)
- [docs/NEXUS_INTEGRATION.md](docs/NEXUS_INTEGRATION.md)
- [docs/ARCHITECTURE_GUIDE.md](docs/ARCHITECTURE_GUIDE.md)

These links do not exist in the current workspace.

## Overall Verdict

- Schema files vs live DB: **ALIGNED** (for modular Supabase scope)
- Documentation vs live DB: **PARTIALLY ALIGNED**
  - Data counts: mostly aligned
  - Table-count summary and some links: not aligned

## Recommended Next Updates

1. Update the migration summary wording in [DOCUMENTATION.md](DOCUMENTATION.md) to distinguish:
   - historical migration milestone (`25` tables at migration time), and
   - current live footprint (`90` base tables + `6` views)
2. Fix or remove broken references in [DOCUMENTATION.md](DOCUMENTATION.md)
3. Keep [scripts/verify_live_alignment.py](scripts/verify_live_alignment.py) as the repeatable verification check before releases

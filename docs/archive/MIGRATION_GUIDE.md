# Supabase Data Migration Guide

**ARCHIVED SNAPSHOT** (Feb 23, 2026): Historical migration procedure documentation.  
For current verification of live alignment, see `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md` and run `scripts/verify_live_alignment.py`.

**Purpose:** Migrate all data from the original AI-Range database to the consolidated database while preserving all relationships, IDs, and data integrity.

---

## Quick Start

### 1. Update .env File

Add both database URLs to your `.env`:

```env
# Original AI-Range Database
SOURCE_SUPABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/[DB]

# New Consolidated Database
TARGET_SUPABASE_URL=postgresql://postgres:[PASSWORD]@[HOST]:5432/[DB]
```

**Example:**
```env
SOURCE_SUPABASE_URL=postgresql://postgres:abc123@db.old.supabase.co:5432/postgres
TARGET_SUPABASE_URL=postgresql://postgres:xyz789@db.new.supabase.co:5432/postgres
```

### 2. Ensure Schema Exists in Target

If the target database is empty, first deploy the schema:

```bash
python3 scripts/upload_schema_supabase.py
# OR
# Use Supabase Dashboard SQL Editor → paste schema_complete.sql → Execute
```

### 3. Run Migration

```bash
python3 scripts/migrate_supabase_data.py
```

The script will:
- ✅ Connect to both databases
- ✅ Migrate all tables with proper FK ordering
- ✅ Preserve all IDs and sequences
- ✅ Reset sequences to correct values
- ✅ Validate row counts
- ✅ Generate migration report

---

## Migration Features

### Data Preservation
- **IDs Preserved:** All UUIDs, BIGSERIALs, and custom IDs preserved exactly
- **Sequences Reset:** Automatically sets sequence next value to MAX(id) + 1
- **All Data Types:** Handles UUID, TEXT, BIGSERIAL, JSONB, TIMESTAMP, BOOLEAN, etc.
- **NULL Values:** Properly migrates NULL values and defaults

### Foreign Key Handling
- Disables triggers/constraints during insert to avoid constraint violations
- Migrates tables in logical order based on dependencies
- Re-enables constraints after migration

### Data Integrity
- **Duplicate Prevention:** Uses `ON CONFLICT DO NOTHING` to skip duplicates
- **Validation:** Compares row counts between source and target
- **Error Tracking:** Logs all errors and warnings
- **Transaction Safety:** Each table wrapped in transaction

### Performance
- Batch operations for efficiency
- Parallel table processing ready
- Minimal lock time

---

## Migration Process

### Step-by-Step Execution

```
1. Connection Validation
   ├─ Connect to source database
   └─ Connect to target database

2. Table Discovery
   ├─ Identify all tables in public schema
   └─ Identify all tables in nexus_alpha schema

3. Data Migration (per table)
   ├─ Fetch all rows from source
   ├─ Disable table triggers
   ├─ Insert rows into target
   ├─ Re-enable table triggers
   └─ Commit transaction

4. Sequence Reset
   ├─ Find all sequences in public schema
   ├─ Find all sequences in nexus_alpha schema
   └─ Set sequence next value = MAX(id) + 1

5. Data Validation
   ├─ Compare row counts per table
   ├─ Verify total row counts match
   └─ Report any mismatches

6. Report Generation
   ├─ Save migration_report.json
   └─ Log summary statistics
```

---

## Example Output

```
[2026-02-23 10:15:30] INFO: ======================================================================
[2026-02-23 10:15:30] INFO: SUPABASE DATA MIGRATION STARTED
[2026-02-23 10:15:30] INFO: ======================================================================
[2026-02-23 10:15:30] INFO: Connected to SOURCE database
[2026-02-23 10:15:31] INFO: Connected to TARGET database
[2026-02-23 10:15:31] INFO: Found 91 tables to migrate

[2026-02-23 10:15:31] INFO: ======================================================================
[2026-02-23 10:15:31] INFO: MIGRATING DATA
[2026-02-23 10:15:31] INFO: ======================================================================
[2026-02-23 10:15:31] INFO: Fetching data from products...
[2026-02-23 10:15:32] SUCCESS: ✅ Migrated 2 rows to products
[2026-02-23 10:15:32] INFO: Fetching data from tenants...
[2026-02-23 10:15:33] SUCCESS: ✅ Migrated 5 rows to tenants
[2026-02-23 10:15:33] INFO: Fetching data from personas...
[2026-02-23 10:15:40] SUCCESS: ✅ Migrated 1247 rows to personas

... (more tables) ...

[2026-02-23 10:25:15] INFO: ======================================================================
[2026-02-23 10:25:15] INFO: RESETTING SEQUENCES
[2026-02-23 10:25:15] INFO: ======================================================================
[2026-02-23 10:25:16] INFO: Reset sequence public.products_id_seq to 3
[2026-02-23 10:25:16] INFO: Reset sequence public.tenants_id_seq to 6

... (more sequences) ...

[2026-02-23 10:25:20] INFO: ======================================================================
[2026-02-23 10:25:20] INFO: VALIDATING MIGRATION
[2026-02-23 10:25:20] INFO: ======================================================================
[2026-02-23 10:25:45] INFO: Source total rows: 145,832
[2026-02-23 10:25:45] INFO: Target total rows: 145,832
[2026-02-23 10:25:45] SUCCESS: ✅ VALIDATION SUCCESSFUL - All rows migrated correctly!

[2026-02-23 10:25:45] INFO: ======================================================================
[2026-02-23 10:25:45] INFO: MIGRATION COMPLETE
[2026-02-23 10:25:45] INFO: ======================================================================
[2026-02-23 10:25:45] INFO: Tables migrated: 91
[2026-02-23 10:25:45] INFO: Total rows migrated: 145,832
```

---

## Migration Report (migration_report.json)

```json
{
  "start_time": "2026-02-23T10:15:30.123456",
  "end_time": "2026-02-23T10:25:45.789012",
  "tables_migrated": [
    {
      "table": "products",
      "rows": 2
    },
    {
      "table": "tenants",
      "rows": 5
    },
    {
      "table": "personas",
      "rows": 1247
    },
    ...
  ],
  "total_rows_migrated": 145832,
  "errors": [],
  "warnings": []
}
```

---

## Troubleshooting

### Connection Errors

**Error:** `ERROR: FATAL: password authentication failed`

**Solution:**
- Verify credentials in .env file
- Check for special characters in password (escape if needed)
- Ensure database exists and is accessible

---

### Foreign Key Constraint Violations

**Error:** `ERROR: duplicate key value violates unique constraint`

**Solution:**
- Script uses `ON CONFLICT DO NOTHING` to handle this
- Check if data already exists in target
- Run `TRUNCATE` on all tables first if starting fresh

---

### Sequence Mismatch

**Error:** `ERROR: nextval() called on uninitialized sequence`

**Solution:**
- Script automatically resets sequences
- Manually reset if needed:
  ```sql
  SELECT setval('table_id_seq', (SELECT MAX(id) FROM table) + 1);
  ```

---

### Row Count Mismatch

**Error:** `⚠️ VALIDATION WARNING - Row count mismatch detected`

**Solution:**
- Check migration_report.json for which tables don't match
- Verify source database connection
- Check target database for pre-existing data
- Re-run migration on problematic tables

---

## Advanced Options

### Migrate Specific Tables Only

Edit the migration script to filter tables:

```python
# In get_table_dependencies() method
# Add WHERE clause to filter
cursor.execute("""
    SELECT table_name, table_schema
    FROM information_schema.tables
    WHERE table_schema IN ('public', 'nexus_alpha')
    AND table_type = 'BASE TABLE'
    AND table_name IN ('personas', 'scenarios', 'generations')  # Only these tables
    ORDER BY table_schema, table_name
""")
```

---

### Verify Before Migration

Run a pre-migration check:

```python
# Add to main() before migration
source_conn = psycopg2.connect(source_db_url)
target_conn = psycopg2.connect(target_db_url)

source_cursor = source_conn.cursor()
source_cursor.execute("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema IN ('public', 'nexus_alpha')")
source_table_count = source_cursor.fetchone()[0]

print(f"Source has {source_table_count} tables")
print(f"Target will receive {source_table_count} tables")
print("Ready to proceed? (y/n): ")
```

---

### Post-Migration Verification

After migration completes, verify:

```sql
-- Check table count
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema IN ('public', 'nexus_alpha');

-- Check specific table
SELECT COUNT(*) FROM personas;

-- Verify sequences
SELECT sequencename, last_value FROM pg_sequences 
WHERE schemaname = 'public';

-- Check foreign key integrity
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND table_schema = 'public';
```

---

## Data Tables Migrated

### Core Tables (Product Layer)
- products
- tenants
- client_product_subscriptions
- product_usage

### AI Agents & Models
- ai_agents
- client_models
- client_model_products

### Personas & Traits
- personas
- persona_demographics
- persona_behavioral_traits
- persona_psychographic_traits
- persona_technographic_traits
- persona_linguistic_traits
- persona_memories
- persona_reflections
- persona_plans
- persona_actions

### Test Framework
- test_categories
- test_types
- scenarios
- scenario_intents
- scenario_personas
- adversarial_test_cases
- test_executions
- test_sessions

### Generation Pipeline
- generation_runs
- conversations
- turns
- quality_metrics
- telemetry

### Nexus Integration
- nexus_prompt_library
- client_prompt_submissions
- product_prompt_lineage

### Agent Interactions
- agent_interactions
- agent_interaction_libraries
- agent_interaction_inputs
- agent_interaction_outputs
- agent_interaction_flow
- agent_interaction_decisions
- agent_interaction_metrics

### Safety & Compliance
- safety_assessments
- safety_alerts
- compliance_reports
- audit_logs

### Nexus Alpha (16 tables)
- nexus_alpha.conversations
- nexus_alpha.turns
- nexus_alpha.risk_metrics
- nexus_alpha.robustness_analysis
- nexus_alpha.fragility_scores
- nexus_alpha.sycophancy_analysis
- nexus_alpha.embeddings
- nexus_alpha.vectors_2d
- + 8 more support tables

---

## Support

For issues or questions:
1. Check migration_report.json for errors
2. Review console output for warnings
3. Verify .env file configuration
4. Test connections with `scripts/test_supabase_connection.py`
5. Check Supabase dashboard logs


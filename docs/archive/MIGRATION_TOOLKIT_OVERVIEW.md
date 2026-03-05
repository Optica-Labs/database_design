# Migration Toolkit - Complete Overview

**ARCHIVED SNAPSHOT** (Feb 23, 2026): Historical toolkit overview.  
For current verification tools, see `scripts/verify_live_alignment.py` and `docs/testing/TESTING_QUICKSTART.md`.

**Created:** February 23, 2026  
**Status:** ✅ Ready for Deployment

---

## 📦 What You Have

A complete, production-ready data migration toolkit to move all data from your original AI-Range database to the new consolidated database.

### Components Delivered

| Component | File | Purpose |
|-----------|------|---------|
| **Migration Script** | `scripts/migrate_supabase_data.py` | Core migration engine |
| **Full Guide** | `MIGRATION_GUIDE.md` | Complete documentation |
| **Quick Reference** | `MIGRATION_QUICK_REFERENCE.md` | Fast start guide |
| **Configuration** | `.env.migration.example` | Setup template |
| **Schema Tools** | `scripts/upload_schema_supabase.py` | Deploy target schema |
| **Connection Test** | `scripts/test_supabase_connection.py` | Verify DB access |

---

## 🚀 Quick Start (3 Steps)

### 1. Configure Databases

Copy your database URLs to `.env`:

```bash
# Copy example to starting point
cp .env.migration.example .env

# Edit .env with your actual URLs
SOURCE_SUPABASE_URL=postgresql://postgres:password@source.supabase.co:5432/postgres
TARGET_SUPABASE_URL=postgresql://postgres:password@target.supabase.co:5432/postgres
```

### 2. Ensure Target Schema Exists

If target is a fresh database:

```bash
python3 scripts/upload_schema_supabase.py
```

### 3. Run Migration

```bash
python3 scripts/migrate_supabase_data.py
```

That's it! ✅ All data migrated with full validation.

---

## 🔄 Migration Workflow

```
SOURCE DB (Original)          TARGET DB (New)
      │                              │
      │  1. Fetch tables info        │
      ├─────────────────────────────→│
      │  2. Retrieve all data        │
      │────────────────────────────→ │
      │                              │
      │                         3. Validate
      │                         4. Reset sequences
      │                         5. Enable constraints
      │                              │
      │  6. Generate report          │
      │←─────────────────────────────┤
      │                              │
```

---

## 📊 Data Coverage (91 Tables)

### Product & Tenant Management
- products (2 rows: ai-range, nexus)
- tenants
- subscriptions
- product_usage

### AI Agents & Models
- ai_agents
- client_models
- client_model_products

### Personas System
- personas
- trait catalogs (5 types)
- trait relationships (5 types)
- persona memories, reflections, plans, actions

### Test Framework
- test_categories
- test_types
- scenarios
- scenario metadata (intents, personas, threats, etc)
- adversarial_test_cases
- test_executions
- test_sessions

### Generation Pipeline (AI-Range)
- generation_runs
- conversations
- turns (individual prompts)
- quality_metrics
- telemetry

### Agent Interactions
- agent_interactions (core tracking)
- agent_interaction_libraries
- agent_interaction_inputs
- agent_interaction_outputs
- agent_interaction_flow
- agent_interaction_decisions
- agent_interaction_metrics

### Nexus Integration
- nexus_prompt_library (with gold column)
- client_prompt_submissions
- product_prompt_lineage

### Nexus Alpha (Robustness Analysis)
- risk_metrics (with benchmarking)
- robustness_analysis (with benchmarking)
- fragility_scores (with benchmarking)
- sycophancy_analysis (with benchmarking)
- Supporting tables (embeddings, vectors, models, etc)

### Safety & Compliance
- safety_assessments
- safety_alerts
- compliance_reports
- audit_logs

---

## ✨ Key Features

### Data Integrity
✅ All IDs preserved exactly (UUIDs, sequences)  
✅ Foreign key relationships maintained  
✅ All constraints re-enabled after migration  
✅ Sequences auto-reset to correct values  

### Error Handling
✅ Duplicate prevention (`ON CONFLICT DO NOTHING`)  
✅ Transaction-per-table safety  
✅ Comprehensive error logging  
✅ Detailed validation report  

### Performance
✅ Efficient batch operations  
✅ Minimal lock time  
✅ Scalable to large datasets  
✅ Progress tracking  

### Validation
✅ Pre-migration connectivity check  
✅ Post-migration row count verification  
✅ Per-table validation  
✅ Detailed comparison report  

---

## 📋 Pre-Migration Checklist

- [ ] Source database accessible and contains data
- [ ] Target database accessible
- [ ] Target schema deployed (if empty database)
- [ ] .env file configured with both URLs
- [ ] Credentials verified (test with `test_supabase_connection.py`)
- [ ] Network connectivity stable
- [ ] Sufficient disk space available

---

## ⏱️ Estimated Duration

| Phase | Time | Description |
|-------|------|-------------|
| **Preparation** | 5-10 min | Configure .env, test connections |
| **Schema Deploy** | 1-2 min | If needed (one-time) |
| **Migration** | 5-15 min | Transfer ~145K+ rows |
| **Validation** | 1-2 min | Verify all data |
| **TOTAL** | 10-25 min | Depends on data volume |

---

## 🎯 Success Indicators

After migration completes, you should see:

```
[timestamp] INFO: ======================================================================
[timestamp] INFO: MIGRATION COMPLETE
[timestamp] INFO: ======================================================================
[timestamp] INFO: Tables migrated: 91
[timestamp] INFO: Total rows migrated: XXXXX
[timestamp] SUCCESS: ✅ VALIDATION SUCCESSFUL - All rows migrated correctly!
```

And `migration_report.json` should show:
- All 91 tables in `tables_migrated` array
- `total_rows_migrated` > 0
- `errors: []` (empty)
- `warnings` minimal or none

---

## 🔍 Post-Migration Verification

### Verify in Supabase Dashboard

```sql
-- Count all tables
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema IN ('public', 'nexus_alpha');
-- Expected: 91

-- Check key tables have data
SELECT COUNT(*) FROM products;        -- Expected: 2
SELECT COUNT(*) FROM personas;        -- Expected: (from source)
SELECT COUNT(*) FROM generations;    -- Expected: (from source)

-- Verify sequences
SELECT sequencename, last_value 
FROM pg_sequences 
WHERE schemaname = 'public' 
LIMIT 5;
```

### Check Migration Report

```bash
# View summary
cat migration_report.json | grep -E '"total_rows_migrated"|"start_time"|"end_time"'

# Check for errors
cat migration_report.json | grep -A 10 '"errors"'

# List all migrated tables
cat migration_report.json | jq '.tables_migrated[] | .table' | head -20
```

---

## ⚠️ Important Notes

1. **Backup First:** Always backup source data before migration
2. **Test First:** Run on development environment first if possible
3. **Read Docs:** Full details in [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
4. **Check Report:** Always review `migration_report.json` after completion
5. **Validate Data:** Use verification queries above to confirm success

---

## 🆘 Troubleshooting

### Connection Issues
```bash
# Test source connection
python3 -c "
import psycopg2
import os
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(os.getenv('SOURCE_SUPABASE_URL'))
print('✅ Source connected')
conn.close()
"

# Test target connection
python3 -c "
import psycopg2
import os
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(os.getenv('TARGET_SUPABASE_URL'))
print('✅ Target connected')
conn.close()
"
```

### Row Count Mismatch
1. Check `migration_report.json` for which tables don't match
2. Verify source data hasn't changed
3. Confirm target schema is correct
4. Review any error messages in report

### Sequence Issues
- Script automatically resets sequences
- If needed manually, run:
```sql
SELECT setval('table_id_seq', (SELECT MAX(id) FROM table) + 1);
```

---

## 📞 Support Resources

| Resource | Location |
|----------|----------|
| Full Guide | [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) |
| Quick Start | [MIGRATION_QUICK_REFERENCE.md](MIGRATION_QUICK_REFERENCE.md) |
| Configuration | [.env.migration.example](.env.migration.example) |
| Migration Report | `migration_report.json` (generated) |
| Schema Audit | [SCHEMA_REVIEW_REPORT.md](SCHEMA_REVIEW_REPORT.md) |

---

## 🎉 Ready to Go!

Your migration toolkit is complete and ready to use. Start with the **Quick Reference** and refer to the **Full Guide** for detailed information.

**Commands Summary:**
```bash
# 1. Configure
nano .env

# 2. Test connections (optional)
python3 scripts/test_supabase_connection.py

# 3. Deploy schema (if needed)
python3 scripts/upload_schema_supabase.py

# 4. Run migration
python3 scripts/migrate_supabase_data.py

# 5. Check results
cat migration_report.json
```

Good luck! 🚀


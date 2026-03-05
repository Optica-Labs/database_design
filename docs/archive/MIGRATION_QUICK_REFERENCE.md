# Data Migration - Quick Reference

**ARCHIVED SNAPSHOT** (Feb 24, 2026): Historical quick reference for 24-table migration.  
For current live database state, see `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md`.

## 🚀 3-Step Migration

### Step 1: Configure Credentials
```bash
# Edit .env file with your database URLs:
SOURCE_SUPABASE_URL=postgresql://postgres:PASSWORD@source.supabase.co:5432/postgres
TARGET_SUPABASE_URL=postgresql://postgres:PASSWORD@target.supabase.co:5432/postgres
```

### Step 2: Deploy Schema (if needed)
```bash
# Only if target database is empty:
python3 scripts/upload_schema_supabase.py
```

### Step 3: Run Migration
```bash
python3 scripts/migrate_supabase_data.py
```

---

## 📊 What Gets Migrated

| Category | Count | Examples |
|----------|-------|----------|
| **Core Tables** | 4 | products, tenants, subscriptions, usage |
| **Personas** | 11 | personas, traits, memories, reflections |
| **Test Framework** | 8 | scenarios, test cases, executions |
| **Generation Pipeline** | 5 | runs, conversations, turns, metrics |
| **Agent Interactions** | 7 | interactions, flow, decisions, metrics |
| **Safety & Compliance** | 4 | assessments, alerts, reports, logs |
| **Nexus Alpha** | 16 | risk metrics, robustness, fragility, etc |
| **Other** | 16 | models, agents, traits, threats, etc |
| **TOTAL** | **91 tables** | All data preserved |

---

## ⚙️ Migration Features

✅ **Preserves All IDs** - UUIDs, sequences, custom IDs  
✅ **Respects Foreign Keys** - Proper table ordering  
✅ **Resets Sequences** - Auto-configures next values  
✅ **Validates Data** - Compares row counts before/after  
✅ **Handles All Types** - UUID, BIGSERIAL, JSONB, TIMESTAMP, etc  
✅ **Error Tracking** - Detailed logs and report  
✅ **No Data Loss** - Comprehensive data integrity checks  

---

## 📋 Before Migration Checklist

- [ ] Both Supabase databases accessible
- [ ] Target database has schema deployed (or will deploy via script)
- [ ] .env file configured with both database URLs
- [ ] Source database credentials verified
- [ ] Target database credentials verified
- [ ] Sufficient disk space available
- [ ] Network connectivity stable

---

## ⏱️ Expected Timeline

| Step | Duration | Notes |
|------|----------|-------|
| Connection setup | <1 min | Quick connection test |
| Schema deployment (if needed) | 1-2 min | One-time setup |
| Data migration | 5-15 min | Depends on data volume |
| Sequence reset | <1 min | Automatic |
| Validation | 1-2 min | Compares row counts |
| **Total** | **~10-20 min** | Varies by data size |

---

## 🔍 Post-Migration Verification

After migration, verify success:

```bash
# Check for any errors
cat migration_report.json | grep -A 5 '"errors"'

# Verify row counts match
grep 'total_rows_migrated' migration_report.json

# Test specific queries on target database
psql [TARGET_URL] -c "SELECT COUNT(*) FROM personas;"
```

---

## ❌ Troubleshooting Quick Fixes

| Issue | Fix |
|-------|-----|
| **Connection refused** | Check .env URLs, verify database online |
| **Authentication failed** | Verify password, check special chars |
| **Table not found** | Ensure schema deployed first |
| **Row mismatch** | Check migration_report.json for details |
| **Sequence error** | Script auto-fixes, re-run if needed |

---

## 📁 Migration Files Created

```
scripts/
├── migrate_supabase_data.py      # Main migration script
├── upload_schema_supabase.py     # Schema deployment (existing)
└── test_supabase_connection.py   # Connection tester (existing)

.env                              # Your credentials
.env.migration.example            # Example config
MIGRATION_GUIDE.md               # Full documentation
SCHEMA_REVIEW_REPORT.md          # Schema validation (existing)
migration_report.json            # Generated after migration
```

---

## 🎯 Success Criteria

Migration is successful when:

✅ Script completes without fatal errors  
✅ migration_report.json shows all tables  
✅ Total rows source = total rows target  
✅ No critical errors in report  
✅ Validation shows "ALL ROWS MIGRATED CORRECTLY"  

---

## 🆘 Need Help?

1. **Read:** [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
2. **Check:** migration_report.json for specific errors
3. **Verify:** .env file configuration
4. **Test:** `python3 scripts/test_supabase_connection.py`
5. **Review:** Console output for warning messages


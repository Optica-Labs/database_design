# 🗂️ Where to Find Everything - Navigation Guide

**Quick Reference for Database Schema & Documentation**

---

## 📍 I Want To...

### Start Using Supabase
```
👉 Go to: sql/schemas/supabase/README.md
   - Overview of all 4 setup files
   - Table relationships diagram
   - Key features explanation
   - Example queries
```

### Deploy the Schema
```
👉 Execute these in order:
   1. sql/schemas/supabase/01_extensions_and_products.sql
   2. sql/schemas/supabase/01_conversations_and_turns.sql
   3. sql/schemas/supabase/02_llm_invocations.sql

👉 Then verify with:
   sql/schemas/supabase/00_SETUP_GUIDE.sql
```

### Understand Data Relationships
```
👉 See: sql/schemas/supabase/README.md (lines ~28-45)
   Mermaid diagram shows all FK relationships
```

### Write Queries
```
👉 Examples in: sql/schemas/supabase/README.md (lines ~93-160)
   - Get conversations with turns and invocations
   - Pipeline stage performance analysis
   - Agent usage statistics
   - Quality metrics queries
```

### Check Migration Status
```
👉 See: docs/MIGRATION_SUMMARY.md
   - 25 tables migrated ✅
   - 100,000+ records transferred ✅
   - 0 duplicates verified ✅
   - 27 orphaned refs handled ✅
```

### Understand Product Architecture
```
👉 See: docs/PRODUCT_LAYER_ARCHITECTURE.md
   - AI-Range vs Nexus products
   - Persona system details
   - Test framework structure
   - Threat vectors & assessment
```

### Learn About Nexus Alpha Platform
```
👉 See: docs/NEXUS_ALPHA_ARCHITECTURE.md
   - Risk metrics from embeddings
   - Robustness analysis (ρ)
   - Fragility assessment (φ)
   - Sycophancy detection
```

### Find CAT-ASTROPHIC Integration
```
👉 See: docs/CAT_ASTROPHIC_INTEGRATION.md
   - Prompt generation details
   - Conversation structure
   - Turn management
   - Quality metrics
```

### See Recent Changes
```
👉 See: CHANGELOG.md
   - Migration completion (Feb 25, 2026)
   - Data cleanup activities
   - Schema changes
   - Bug fixes & improvements
```

### Understand Migration Process
```
👉 See: docs/MIGRATION_SUMMARY.md (Phase details)
   - Phase 1: Schema Creation
   - Phase 2: Data Migration
   - Phase 3: Deduplication
   - Phase 4: Cleanup
   - Phase 5: Orphaned Reference Handling
   - Phase 6: Final Verification
```

### Check Full Schema Audit
```
👉 See: SCHEMA_ALIGNMENT_AUDIT.md
   - Comprehensive alignment review
   - Table-by-table verification
   - Documentation quality assessment
   - Issues & recommendations
```

### Find Issues & Fix Priorities
```
👉 See: SCHEMA_ALIGNMENT_ISSUES.md
   - 5 identified issues with details
   - Priority levels (🔴 HIGH to 🟡 LOW)
   - Estimated fix times
   - Implementation checklist
```

### Get Visual Overview
```
👉 See: ALIGNMENT_SUMMARY.md
   - At a glance status (A+ grade)
   - What's working perfectly
   - Areas needing clarification
   - Quick fix checklist
```

---

## 📁 File Organization & Purpose

### Active Deployment Files (Use These)
```
sql/schemas/supabase/
├── 00_SETUP_GUIDE.sql              📍 Verification queries after setup
├── 01_extensions_and_products.sql  📍 Part 1: Core setup (run first)
├── 01_conversations_and_turns.sql  📍 Part 2: Conversation tracking (run second)
├── 02_llm_invocations.sql         📍 Part 3: LLM tracking (run third)
└── README.md                       📍 Start here! (Complete guide)
```

### Documentation Files
```
docs/
├── MIGRATION_SUMMARY.md            📍 Migration results & verification
├── NEXUS_ALPHA_ARCHITECTURE.md     📍 Risk analysis platform details
├── PRODUCT_LAYER_ARCHITECTURE.md   📍 Products: AI-Range vs Nexus
├── CAT_ASTROPHIC_INTEGRATION.md    📍 Conversation & generation system
└── NEXUS_PRODUCTS_INTEGRATION.md   📍 Nexus product details
```

### Root Documentation
```
├── README.md                       📍 Quick start & overview
├── CHANGELOG.md                    📍 Complete change history
├── DOCUMENTATION.md                📍 Documentation index
├── SCHEMA_ALIGNMENT_AUDIT.md       📍 Full alignment analysis
├── SCHEMA_ALIGNMENT_ISSUES.md      📍 Issues & fixes
└── ALIGNMENT_SUMMARY.md            📍 Visual summary (this guide)
```

### Legacy/Reference Files (Don't Use for Deployment)
```
sql/schemas/
├── schema_complete.sql             📋 91 tables (archived version)
├── schema_integrated.sql           📋 60 tables (earlier version)
├── agent_interactions_schema.sql   📋 Agent tracking subset
├── llm_invocations_schema.sql     📋 LLM tracking subset
├── schema.sql                      📋 Original SQL Server schema
├── README.md                       ⚠️ Update pending (version clarification)
└── AUDIT_REPORT.md                📋 Schema audit results
```

### Scripts & Tools
```
scripts/
├── check_unmigrated_data.py        🔧 Verify migration status
├── migrate_*.py                    🔧 Data migration utilities
├── test_supabase_connection.py     🔧 Connection testing
├── remove_*_duplicates.py          🔧 Duplicate cleanup
└── README.md                       📖 Scripts documentation
```

---

## 🎯 By Role

### 👨‍💻 Software Developer
**Start Here**: [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md)

**Then**: 
1. Review table relationships
2. Check example queries
3. Understand column definitions
4. Plan your queries

**Reference**: [ALIGNMENT_SUMMARY.md](ALIGNMENT_SUMMARY.md) - quick overview

---

### 🗄️ Database Administrator
**Start Here**: [sql/schemas/supabase/00_SETUP_GUIDE.sql](sql/schemas/supabase/00_SETUP_GUIDE.sql)

**Then**:
1. Execute the 3 setup files in order
2. Run verification queries
3. Check [docs/MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md) for data status
4. Monitor performance with provided indexes

**Reference**: [SCHEMA_ALIGNMENT_AUDIT.md](SCHEMA_ALIGNMENT_AUDIT.md) - technical details

---

### 📊 Data Analyst
**Start Here**: [docs/MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md)

**Then**:
1. Understand what data exists and where
2. Check example queries in [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md)
3. Review table relationships for joins
4. Plan your analysis queries

**Reference**: [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md#-example-queries) - query examples

---

### 🏢 Project Manager
**Start Here**: [README.md](README.md)

**Then**:
1. Check [CHANGELOG.md](CHANGELOG.md) for timeline
2. Review [docs/MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md) for status
3. See [ALIGNMENT_SUMMARY.md](ALIGNMENT_SUMMARY.md) for quality grade (A+)

**Key Stats**:
- ✅ Migration Complete (Feb 25, 2026)
- ✅ 25 tables, 100,000+ records
- ✅ Zero data loss
- ✅ Ready for production

---

### 🏗️ System Architect
**Start Here**: [SCHEMA_ALIGNMENT_AUDIT.md](SCHEMA_ALIGNMENT_AUDIT.md)

**Then**:
1. Review schema design decisions
2. Check relationship diagrams
3. Understand indexing strategy
4. Review identified gaps

**Also See**:
- [docs/PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md) - product structure
- [docs/NEXUS_ALPHA_ARCHITECTURE.md](docs/NEXUS_ALPHA_ARCHITECTURE.md) - analytics platform
- [docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md) - generation system

---

### 🔍 DevOps/Deployment Engineer
**Start Here**: [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md)

**Steps**:
1. Deploy 3 SQL files in order
2. Run verification queries from [00_SETUP_GUIDE.sql](sql/schemas/supabase/00_SETUP_GUIDE.sql)
3. Check scripts in [scripts/README.md](scripts/README.md) for data migration
4. Verify with [check_unmigrated_data.py](scripts/check_unmigrated_data.py)

**Troubleshooting**: See [SCHEMA_ALIGNMENT_ISSUES.md](SCHEMA_ALIGNMENT_ISSUES.md) if issues arise

---

## 🔗 Common Navigation Paths

### "I need to deploy the database"
```
1. sql/schemas/supabase/README.md          (understand structure)
2. sql/schemas/supabase/01_extensions...   (execute part 1)
3. sql/schemas/supabase/01_conversations.. (execute part 2)
4. sql/schemas/supabase/02_llm_invocations (execute part 3)
5. sql/schemas/supabase/00_SETUP_GUIDE.sql (run verification)
```

### "I need to understand the data"
```
1. ALIGNMENT_SUMMARY.md                    (quick overview)
2. sql/schemas/supabase/README.md          (structure details)
3. docs/MIGRATION_SUMMARY.md               (what data exists)
4. sql/queries/queries.sql                 (example queries)
```

### "I need to migrate data"
```
1. docs/MIGRATION_SUMMARY.md               (completed migration)
2. scripts/README.md                       (migration tools)
3. scripts/check_unmigrated_data.py        (verify status)
4. scripts/migrate_*.py                    (if needed)
```

### "Something doesn't align"
```
1. ALIGNMENT_SUMMARY.md                    (quick visual)
2. SCHEMA_ALIGNMENT_ISSUES.md              (identified issues)
3. SCHEMA_ALIGNMENT_AUDIT.md               (full analysis)
4. Contact: [See issue priorities]
```

### "I need product architecture details"
```
1. docs/PRODUCT_LAYER_ARCHITECTURE.md      (AI-Range vs Nexus)
2. docs/NEXUS_PRODUCTS_INTEGRATION.md      (Nexus product)
3. docs/CAT_ASTROPHIC_INTEGRATION.md       (Conversation system)
4. docs/NEXUS_ALPHA_ARCHITECTURE.md        (Analytics platform)
```

---

## 📞 Quick Links

| Need | Go To | Purpose |
|------|-------|---------|
| Setup guide | [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md) | Step-by-step schema setup |
| Verify queries | [00_SETUP_GUIDE.sql](sql/schemas/supabase/00_SETUP_GUIDE.sql) | Confirm successful deployment |
| Example queries | [README.md](sql/schemas/supabase/README.md#-example-queries) | Learn how to query data |
| Migration status | [MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md) | See what data was migrated |
| Architecture | [PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md) | Understand system design |
| Issues | [SCHEMA_ALIGNMENT_ISSUES.md](SCHEMA_ALIGNMENT_ISSUES.md) | Find and prioritize fixes |
| Full audit | [SCHEMA_ALIGNMENT_AUDIT.md](SCHEMA_ALIGNMENT_AUDIT.md) | Comprehensive analysis |
| Changes | [CHANGELOG.md](CHANGELOG.md) | See what changed |

---

## ✨ Recommended Reading Order (First Time)

1. **Start (5 min)**: [README.md](README.md)
   - Overview and quick start

2. **Setup (10 min)**: [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md)
   - Understand what you're deploying

3. **Summary (5 min)**: [ALIGNMENT_SUMMARY.md](ALIGNMENT_SUMMARY.md)
   - Know the current state

4. **Deploy (30 min)**: Execute SQL files from [sql/schemas/supabase/](sql/schemas/supabase/)
   - Set up your database

5. **Verify (10 min)**: Run queries from [00_SETUP_GUIDE.sql](sql/schemas/supabase/00_SETUP_GUIDE.sql)
   - Confirm successful setup

6. **Learn (20 min)**: Review examples in [sql/schemas/supabase/README.md](sql/schemas/supabase/README.md#-example-queries)
   - Write your first queries

7. **Deep Dive (Optional)**: [SCHEMA_ALIGNMENT_AUDIT.md](SCHEMA_ALIGNMENT_AUDIT.md)
   - Full technical details

---

**Last Updated**: March 4, 2026  
**Status**: ✅ Complete & Aligned

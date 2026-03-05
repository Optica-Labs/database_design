# SQL Directory Reference

**Status**: ✅ Production-Ready + Supabase Verified (100% Compatible)  
**Last Updated**: March 4, 2026  
**Quick Deploy**: [SUPABASE_QUICK_DEPLOYMENT.md](SUPABASE_QUICK_DEPLOYMENT.md) (5 min)

---

## 📁 Directory Structure

```
sql/
├── 🚀 DEPLOYMENT & DEPLOYMENT GUIDES
│   ├── SUPABASE_QUICK_DEPLOYMENT.md          ⭐ 5-minute deployment guide
│   ├── SUPABASE_COMPATIBILITY_REPORT.md      472-line technical verification
│   ├── ALIGNMENT_VERIFICATION.md             100% compatibility summary
│   └── README.md                             (This index)
│
├── 🗄️ schemas/ - Production Schemas (Ready to Deploy)
│   ├── README.md                             📋 Schema selection guide
│   ├── schema_unified_complete.sql           🟢 Full DB (84 tables)
│   ├── schema_ai_range_only.sql              🟢 AI-Range (75 tables)
│   ├── schema_nexus_only.sql                 🟢 Nexus (35 tables)
│   ├── AUDIT_REPORT.md                       Audit results
│   │
│   ├── supabase/ - Supabase-specific
│   │   ├── README.md                         Setup guide
│   │   ├── 00_SETUP_GUIDE.sql               Setup script
│   │   ├── 01_conversations_and_turns.sql   Conversation schema
│   │   ├── 01_extensions_and_products.sql   Extensions setup
│   │   ├── 02_llm_invocations.sql           LLM tracking
│   │   └── archive/                          (6 archived schemas)
│   │
│   └── archive/ - Historical Schemas
│       ├── schema.sql                        Original schema
│       ├── schema_complete.sql               Intermediate version
│       ├── schema_integrated.sql             Earlier version
│       ├── agent_interactions_schema.sql     Partial schema
│       ├── llm_invocations_schema.sql        Partial schema
│       └── supabase_schema.sql               Partial schema
│
├── 🔄 migrations/ - Migration Scripts
│   └── migration_script.sql                  Data migration SQL
│
├── 📝 queries/ - Query Examples
│   ├── queries.sql                           Common queries
│   └── cat_astrophic_queries.sql             CAT-A specific queries
│
├── 👁️ views/ - Database Views
│   ├── nexus_views.sql                       Nexus analysis views
│   └── cat_astrophic_views.sql               CAT-A analysis views
│
└── 🌱 sample_data/ - Test Data
    └── sample_data.sql                       Sample data for testing
```

---

## 🚀 Quick Deploy
- `schema_integrated.sql` - Pre-split unified version
- `agent_interactions_schema.sql` - Partial AI-Range schema
- `llm_invocations_schema.sql` - Partial integration schema
- `supabase_schema.sql` - Supabase-specific variant

### `/views/` - Database Views
Materialized and logical views for reporting and analysis:

- **`cat_astrophic_views.sql`**
  - Views for prompt generation pipeline analysis
  - Queries on conversations, turns, quality metrics, telemetry
  - Useful for: Generation run reporting, coverage analysis

- **`nexus_views.sql`**
  - Views for Nexus Alpha analysis pipeline
  - Risk metrics, model performance, robustness analysis views
  - Useful for: Risk dashboards, model evaluation reports

### `/queries/` - Common Queries and Utilities
Ad-hoc and utility queries for data inspection and analysis:

- **`queries.sql`**
  - Common analysis queries
  - Data validation queries
  - Debugging queries

- **`cat_astrophic_queries.sql`**
  - Specialized queries for prompt generation pipeline
  - Conversation and turn analysis
  - Quality metric aggregations

### `/migrations/` - Schema Migration Scripts
Database migration scripts for version management:

- **`migration_script.sql`**
  - Transformation and data migration logic
  - Table modifications and schema upgrades
  - Data transformation between schema versions

### `/sample_data/` - Sample Data
Test and development data:

- **`sample_data.sql`**
  - Representative data for testing
  - Demo personas, scenarios, test cases
  - Sample model outputs and assessments

### `/supabase/` - Supabase-Specific Configuration
Supabase-specific schema and setup scripts (if using Supabase backend):

- Individual setup and extension files
- See `supabase/README.md` for details

## Quick Start Guide

### For Development
```bash
# Load complete unified schema with all tables
psql -f sql/schemas/schema_unified_complete.sql
psql -f sql/sample_data/sample_data.sql
```

### For AI-Range Only Deployment
```bash
# Load AI-Range product schema
psql -f sql/schemas/schema_ai_range_only.sql
psql -f sql/migrations/migration_script.sql  # If needed
```

### For Nexus Only Deployment
```bash
# Load Nexus product schema
psql -f sql/schemas/schema_nexus_only.sql
psql -f sql/migrations/migration_script.sql  # If needed
```

### Create Analysis Views
```bash
# After loading base schema, create views
psql -f sql/views/cat_astrophic_views.sql
psql -f sql/views/nexus_views.sql
```

## File Statistics

| File | Purpose | Lines | Type |
|------|---------|-------|------|
| schema_unified_complete.sql | Full database | ~1,700 | Schema |
| schema_ai_range_only.sql | AI-Range only | ~1,200 | Schema |
| schema_nexus_only.sql | Nexus only | ~800 | Schema |
| cat_astrophic_views.sql | Generation views | - | Views |
| nexus_views.sql | Analysis views | - | Views |
| queries.sql | Utility queries | - | Queries |
| cat_astrophic_queries.sql | Generation queries | - | Queries |
| migration_script.sql | Migrations | - | Scripts |
| sample_data.sql | Test data | - | Data |

## Important Notes

### Schema Selection
- **Always use `schema_unified_complete.sql`** for full deployments and development
- Use product-specific schemas only for dedicated single-product deployments
- Product schemas include all necessary shared infrastructure for standalone operation

### Multi-Tenancy
All schemas support multi-tenancy via:
- `tenants` table (tenant isolation)
- `client_product_subscriptions` table (product access control)
- `product_id` and `tenant_id` fields in data tables

### Extensions Required
Ensure PostgreSQL is configured with:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";
```

### Indexes
All schemas include comprehensive indexes for:
- Primary and unique keys
- Foreign key lookups
- Status and date-based queries
- Full-text search preparation
- Vector similarity searches

## Maintenance

### When Adding New Tables
1. Update the appropriate schema file(s)
2. Add corresponding indexes
3. Document in README
4. Create views if needed
5. Add sample data if applicable

### When Modifying Schemas
1. Create a migration script in `/migrations/`
2. Test on unified schema first
3. Test on product-specific schemas
4. Document breaking changes

## Related Documentation
- See `docs/NEXUS_ALPHA_ARCHITECTURE.md` for Nexus design details
- See `docs/PRODUCT_LAYER_ARCHITECTURE.md` for product structure
- See `docs/MIGRATION_SUMMARY.md` for schema evolution history

# Database Design & Migration

Complete database schema and data migration from SOURCE to TARGET databases.

## Status: ✅ MIGRATION COMPLETE + SUPABASE VERIFIED

- **All 25 tables migrated** ✅
- **100,000+ records transferred** ✅  
- **Zero duplicates verified** ✅
- **Data integrity confirmed** ✅
- **Three production-ready schemas created** ✅
- **100% Supabase compatibility verified** ✅

## 🎯 Quick Navigation

### 📖 Start Here
- **[MASTER_INDEX.md](MASTER_INDEX.md)** - Complete repository map and quick links
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - 5-minute quick reference for all users

### 👥 By Your Role
- **👨‍💻 [Developer Guide](guides/DEVELOPER_GUIDE.md)** - Setup, deployment, API integration
- **👨‍💼 [DBA Guide](guides/DBA_GUIDE.md)** - Deployment, monitoring, maintenance
- **📊 [Data Scientist Guide](guides/DATA_SCIENTIST_GUIDE.md)** - Database access, analysis, queries
- **📋 [Project Manager Guide](guides/PROJECT_MANAGER_GUIDE.md)** - Status tracking, team coordination

### 🚀 Quick Deploy
- **[sql/SUPABASE_QUICK_DEPLOYMENT.md](sql/SUPABASE_QUICK_DEPLOYMENT.md)** - Deploy in 5 minutes ⭐ START HERE
- **[sql/schemas/README.md](sql/schemas/README.md)** - Schema selection guide
- **[sql/SUPABASE_COMPATIBILITY_REPORT.md](sql/SUPABASE_COMPATIBILITY_REPORT.md)** - Technical verification

### 📚 Documentation Index
- **Full Index**: [DOCUMENTATION.md](DOCUMENTATION.md)
- **Change Log**: [CHANGELOG.md](CHANGELOG.md)

## Quick Start

### Verify Migration
```bash
python3 scripts/check_unmigrated_data.py
```

### Setup
```bash
# Install dependencies (symlinked to config/requirements.txt)
pip install -r requirements.txt

# Copy environment template (symlinked to config/.env.example)
cp .env.example .env

# Edit .env with Supabase credentials
```

**Note**: Configuration files are now organized in [`config/`](config/) with symlinks in root for convenience.

## Quick Links

### Database Schemas (Production-Ready)
- **[schema_unified_complete.sql](sql/schemas/schema_unified_complete.sql)** - Full deployment (84 tables)
- **[schema_ai_range_only.sql](sql/schemas/schema_ai_range_only.sql)** - AI-Range only (75 tables)
- **[schema_nexus_only.sql](sql/schemas/schema_nexus_only.sql)** - Nexus only (35 tables)

### Supabase Deployment
- **[SUPABASE_QUICK_DEPLOYMENT.md](sql/SUPABASE_QUICK_DEPLOYMENT.md)** - 5-minute deployment guide ⭐ START HERE
- **[SUPABASE_COMPATIBILITY_REPORT.md](sql/SUPABASE_COMPATIBILITY_REPORT.md)** - Technical verification (472 lines)
- **[ALIGNMENT_VERIFICATION.md](sql/ALIGNMENT_VERIFICATION.md)** - Compatibility summary

## Key Directories

| Directory | Purpose |
|-----------|---------|
| [`config/`](config/) | **Configuration files** - Environment templates, requirements, API reports |
| [`tests/`](tests/) | **Test scripts** - Connection tests and validation |
| [`guides/`](guides/) | **Role-specific guides** - Developer, DBA, Data Scientist, Project Manager |
| [`sql/`](sql/) | Schema definitions, migrations, and Supabase deployment guides |
| [`sql/schemas/`](sql/schemas/) | Three production-ready deployment schemas (unified, AI-Range, Nexus) |
| [`scripts/`](scripts/) | Migration and verification scripts |
| [`docs/`](docs/) | Complete documentation |

## Key Tables

| Table | Records | Notes |
|-------|---------|-------|
| `llm_invocations` | 25,257 | Unified table for personas + scenarios |
| `prompt_generator_responses` | 10,464 | LLM response tracking |
| `scenarios` | 70 | Test scenarios |
| `scenario_intents` | 50 | Detailed intents (orphaned refs handled) |
| `threat_vectors` | 276 | Security threat definitions |
| `personas` | 67 | User personas |

## Documentation

### Schema & Deployment
- **Schema Overview**: [sql/README.md](sql/README.md)
- **Schema Details**: [sql/schemas/README.md](sql/schemas/README.md)
- **Supabase Deployment**: [sql/SUPABASE_QUICK_DEPLOYMENT.md](sql/SUPABASE_QUICK_DEPLOYMENT.md) ⭐ START HERE FOR DEPLOYMENT
- **Compatibility Report**: [sql/SUPABASE_COMPATIBILITY_REPORT.md](sql/SUPABASE_COMPATIBILITY_REPORT.md)

### Migration & History
- **Complete Guide**: [docs/MIGRATION_SUMMARY.md](docs/MIGRATION_SUMMARY.md)
- **Architecture**: [docs/PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md)
- **Changes**: [CHANGELOG.md](CHANGELOG.md)
- **Scripts**: [scripts/README.md](scripts/README.md)

## Migration Summary

### Data Transformations
- **20,767 ai_personas** → llm_invocations (pipeline_stage='persona_generation')
- **4,590 ai_scenarios** → llm_invocations (pipeline_stage='scenario_creation')
- **25 supporting tables** → 1:1 mapped with schema transformation

### Cleanup Operations
- ✅ Removed 12,841 synthetic ai_personas from prompt_generator_responses
- ✅ Removed 9,000 duplicate llm_invocations records
- ✅ Sanitized 27 scenario_intents with orphaned references

### Quality Assurance
- ✅ All mandatory fields preserved
- ✅ Foreign key constraints enforced
- ✅ Complete audit trail maintained

## Environment Setup

Required in `.env`:
```
SOURCE_SUPABASE_SERVICE_KEY=...
TARGET_SUPABASE_SERVICE_KEY=...
```

See `.env.example` for template.

## Common Commands

```bash
# Check migration status
python3 scripts/check_unmigrated_data.py

# Migrate remaining records
python3 scripts/migrate_missing_scenario_intents.py

# Remove duplicates
python3 scripts/remove_llm_invocations_duplicates.py

# Test connection
python3 scripts/test_supabase_connection.py
```

## Related Documentation

- [Architecture Guide](docs/ARCHITECTURE_GUIDE.md)
- [Product Integration](docs/NEXUS_INTEGRATION.md)
- [CAT ASTROPHIC Integration](docs/CAT_ASTROPHIC_INTEGRATION.md)
- [Schema Details](sql/schemas/schema_complete.sql)

---

**Status**: ✅ Production Ready  
**Last Updated**: February 25, 2026

**5. Link Model to Products**
```sql
INSERT INTO client_model_products (model_id, product_id, tenant_id, enabled)
SELECT 
    cm.model_id,
    p.id,
    cm.tenant_id,
    TRUE
FROM client_models cm
CROSS JOIN products p
WHERE cm.model_name = 'SafetyTester-v1'
  AND p.product_code = 'ai-range';
```

## 📖 Documentation & Examples

See [queries.sql](sql/queries/queries.sql) for comprehensive examples including:
- Safety assessment queries
- Persona-scenario relevance analysis
- Threat vector analytics
- Compliance reporting
- Alert management

## 🎯 Common Use Cases

### 1. Adversarial Testing
Execute adversarial tests against client models and capture outputs for evaluation.

### 2. Persona-Driven Risk Assessment
Use personas with specific traits to test model behavior against simulated user profiles and attack vectors.

### 3. Prompt Generation & Optimization
Generate diverse, targeted prompts at scale using PromptGoblin v2 with quality metrics and human-in-the-loop review.

### 4. Safety Assessment
Multi-agent evaluation assesses model outputs for:
- Toxicity and harmful content
- Bias and discrimination
- Jailbreak attempts
- Prompt injection attacks
- Data privacy violations
- Compliance violations

### 5. Risk Analytics
Multi-dimensional risk analysis across:
- Threat vectors and attack patterns
- Persona-specific vulnerabilities
- Scenario-based risk modeling
- Trend analysis and prediction

### 6. Compliance & Reporting
Automated compliance documentation including:
- Test execution summaries
- Pass/fail rates and trends
- Critical issues and remediation
- Safety scores and metrics
- Audit trail verification

## 📚 Documentation Resources (Consolidated)

### Start Here
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Consolidated master documentation for the full repository
-- **[MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** - Quick reference guide and file index
-- **[MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** - Repository map and file locations

### Architecture & Design
- **[AI_RANGE_UNIFIED_ARCHITECTURE.md](AI_RANGE_UNIFIED_ARCHITECTURE.md)** - AI-Range + Nexus unified architecture
- **[docs/NEXUS_PRODUCTS_INTEGRATION.md](docs/NEXUS_PRODUCTS_INTEGRATION.md)** - Product layer and multi-tenancy design
- **[MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** - Product layer ER diagram (see index)

### Schema & Diagrams
- **[MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** - Original ER diagrams (see index)
- **[MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** - Agent-specific ER diagrams (see index)
- **[sql/schemas/schema_integrated.sql](sql/schemas/schema_integrated.sql)** - Integrated DDL schema

### Specialized Systems
- **[docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md)** - Cat-Astrophic (PromptGoblin v2) integration
- **[docs/NEXUS_INTEGRATION.md](docs/NEXUS_INTEGRATION.md)** - Nexus prompt ingestion and lineage
- **[sql/views/cat_astrophic_views.sql](sql/views/cat_astrophic_views.sql)** - Cat-Astrophic analytical views
- **[sql/views/nexus_views.sql](sql/views/nexus_views.sql)** - Nexus analytical views

### Code & Examples
- **[sql/queries/queries.sql](sql/queries/queries.sql)** - Comprehensive query examples
- **[sql/queries/cat_astrophic_queries.sql](sql/queries/cat_astrophic_queries.sql)** - Cat-Astrophic query examples
- **[sql/sample_data/sample_data.sql](sql/sample_data/sample_data.sql)** - Sample data for testing
- **[sql/migrations/migration_script.sql](sql/migrations/migration_script.sql)** - Data migration from legacy systems

## 🔧 Technology Stack

- **Database**: PostgreSQL 14+ (with pgvector, uuid-ossp extensions)
- **Schema**: 60+ tables optimized for complex analytical queries
- **Data Types**: JSONB (flexible metadata), UUID (multi-tenancy), Arrays, Vectors
- **Features**: Row-level security, Views, Indexes, Foreign keys, Triggers

## 🏗️ Architecture Principles

1. **Single Source of Truth** - Unified integrated database
2. **Multi-Tenancy** - Enterprise-grade tenant isolation
3. **Product-Scoped** - All operational tables link to AI-Range product
4. **Auditable** - Complete immutable audit trail
5. **Extensible** - JSONB fields for future requirements
6. **Performant** - 50+ indexes optimized for common queries
7. **Flexible** - Supports multiple testing paradigms and trait systems

## 📊 Data Flow Example

```
Tenant → Product Subscription → Client Models → Test Sessions
   ↓                ↓                 ↓              ↓
Personas → Trait Assignments → Scenarios → Test Executions
   ↓                ↓                 ↓              ↓
Memories  Threat Vectors    Intent Mapping    Safety Assessments
Reflections Risk Factors     Personas Linked    Alerts Generated
```

## 🔑 Key Metrics Tracked

- **Safety Score** (0-100) - Composite safety rating
- **Risk Level** - Low, Medium, High, Critical classifications
- **Pass Rate** - Percentage of tests passed/failed
- **Threat Coverage** - Proportion of threat vectors tested
- **Persona Relevance** - Relevance scores for persona-scenario pairs
- **Prompt Quality** - Diversity, coverage, and quality metrics
- **Compliance Status** - Regulatory requirement fulfillment
- **Incident Trends** - Safety incident patterns over time

## ⚡ Performance Optimization

The schema includes:
- **Comprehensive indexing** - Foreign keys, composite indexes, GIN indexes for JSONB
- **Analytical views** - Pre-aggregated data for common analyses
- **Query optimization** - CTEs, window functions, efficient joins
- **Maintenance tools** - VACUUM, ANALYZE, REINDEX procedures

See [DOCUMENTATION.md](DOCUMENTATION.md) for optimization details.

## 🔐 Security Features

- **Multi-tenancy isolation** - Row-level security via tenant_id
- **Audit logging** - Complete tracking of all modifications
- **Referential integrity** - Foreign key constraints
- **Data validation** - Check constraints and triggers
- **Access control** - PostgreSQL role-based security

## 📝 Maintenance

Regular maintenance tasks:
```sql
ANALYZE;                    -- Update statistics (weekly)
VACUUM;                     -- Reclaim space (weekly)
REINDEX DATABASE ...;       -- Rebuild indexes (monthly)
```

See [DOCUMENTATION.md](DOCUMENTATION.md) for full maintenance procedures.

## 🤝 Contributing

To extend or modify the database:

1. Update `sql/schemas/schema_integrated.sql` with table changes
2. Document changes in relevant `docs/` files
3. Add example queries to `sql/queries/queries.sql`
4. Update ER diagrams in the documentation index (`MASTER_DOCUMENTATION_INDEX.md`)
5. Add migration steps if needed to `sql/migrations/migration_script.sql`
6. Update this README if architecture changes

## 📄 License

This database design is provided as-is for use in AI safety and security testing systems.

## 🙋 Support & Questions

- **Schema questions?** → See [DOCUMENTATION.md](DOCUMENTATION.md)
- **Integration questions?** → See [DOCUMENTATION.md](DOCUMENTATION.md)
- **Deployment questions?** → See [DOCUMENTATION.md](DOCUMENTATION.md)
- **Query examples?** → See [sql/queries/queries.sql](sql/queries/queries.sql)
- **Architecture questions?** → See [docs/NEXUS_PRODUCTS_INTEGRATION.md](docs/NEXUS_PRODUCTS_INTEGRATION.md)
- **Prompt generation?** → See [docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md)

---

**Version**: 2.0 (Integrated)  
**Status**: Production Ready  
**Last Updated**: 2024  
**Database**: PostgreSQL 14+ 

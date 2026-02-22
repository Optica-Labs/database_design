# Archived: README (moved to canonical documentation)

This README has been archived. The canonical project overview and onboarding guidance live in `DOCUMENTATION.md` and `MASTER_DOCUMENTATION_INDEX.md`.

Archived copy (full content preserved): [docs/archive/README.md](docs/archive/README.md)

For navigation and role-based guides start with [MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md) or the consolidated `DOCUMENTATION.md`.

---

See the archived copy in `docs/archive/README.md` for the full preserved content.
### Installation

**1. Deploy the Schema**
```bash
psql -d your_database -f sql/schemas/schema_integrated.sql
```

**2. Create a Tenant**
```sql
INSERT INTO tenants (tenant_name, client_id, industry)
VALUES ('Acme Corp', 'acme-001', 'Technology');
```

**3. Subscribe to AI-Range**
```sql
INSERT INTO client_product_subscriptions (tenant_id, product_id, subscription_tier, subscription_status)
SELECT 
    t.id,
    p.id,
    'enterprise',
    'active'
FROM tenants t
CROSS JOIN products p
WHERE t.tenant_name = 'Acme Corp'
  AND p.product_code = 'ai-range';
```

**4. Register a Client Model**
```sql
INSERT INTO client_models (tenant_id, client_id, model_name, model_version, model_type, endpoint_url)
SELECT 
    id,
    'acme-001',
    'SafetyTester-v1',
    '1.0.0',
    'llm',
    'https://api.acme.com/models/tester'
FROM tenants
WHERE tenant_name = 'Acme Corp';
```

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

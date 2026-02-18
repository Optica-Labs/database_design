# Integrated Adversarial AI Safety & Persona Testing Database

## 🎯 Overview

This repository contains a **unified PostgreSQL database schema** that integrates two complementary AI safety testing systems:

1. **Adversarial AI Safety Testing** - Traditional model testing, safety assessments, and compliance tracking
2. **AI Persona Testing & Risk Assessment** - Persona-driven testing, scenario generation, and cognitive risk analysis

## 🚀 What's New in the Integration

### Unified Persona System
- **Single `personas` table** supporting regular, adversarial, and internal persona types
- **Flexible trait system** via catalog tables (demographic, behavioral, psychographic, technographic, linguistic)
- **Cognitive modeling** with memories, reflections, plans, and actions

### Multi-Tenancy Support
- **Central tenant management** for enterprise deployments
- **Consistent isolation** across models, sessions, personas, and scenarios
- **Flexible client identification** (UUID-based or legacy client_id)

### Enhanced Test Framework
- **Dual testing paradigms**: Traditional adversarial test cases + persona-driven scenarios
- **Test sessions** for unified tracking across testing approaches
- **Structured test organization** via test sets, units, and turns

### Comprehensive Risk Framework
- **Threat vectors** with examples and detection methods
- **Context profiles** for customer intake and risk assessment
- **Risk-scenario-persona linkages** for holistic analysis

## 📁 Repository Structure

```
database_design/
├── schema.sql                    # Original SQL Server schema
├── schema_integrated.sql         # ⭐ NEW: Integrated PostgreSQL schema
├── migration_script.sql          # ⭐ NEW: Data migration script
├── ER_DIAGRAM.md                 # Original ER diagram
├── ER_DIAGRAM_INTEGRATED.md      # ⭐ NEW: Integrated ER diagram
├── INTEGRATION_GUIDE.md          # ⭐ NEW: Detailed integration guide
├── DOCUMENTATION.md              # Original documentation
├── queries.sql                   # Example queries
├── sample_data.sql              # Sample data
└── README.md                     # This file
```

## 🗄️ Schema Highlights

### Core Architecture

```
tenants
    ↓
├── client_models (models under test)
├── test_sessions (testing sessions)
├── personas (test personas)
└── context_profiles (customer context)
         ↓
    risk_assessments
         ↓
    threat_vectors → scenarios → test_executions
```

### Key Tables

| Category | Tables | Purpose |
|----------|--------|---------|
| **Multi-Tenancy** | `tenants` | Central tenant/client management |
| **Personas** | `personas`, `persona_demographics`, `persona_behavioral_traits`, etc. | Flexible persona system with trait catalogs |
| **Cognition** | `persona_memories`, `persona_reflections`, `persona_plans`, `persona_actions` | Cognitive modeling for personas |
| **Use Cases** | `use_cases`, `cohorts`, `sub_cohorts` | Organizational hierarchy |
| **Threats & Risks** | `threat_vectors`, `threat_examples`, `risks`, `harms` | Threat taxonomy |
| **Scenarios** | `scenarios`, `scenario_intents`, `scenario_personas` | Test scenario management |
| **Context** | `context_profiles`, `risk_assessments` | Customer intake and risk analysis |
| **Testing** | `test_categories`, `test_types`, `adversarial_test_cases` | Test organization |
| **Execution** | `test_sessions`, `test_executions`, `test_sets`, `test_units`, `test_turns` | Test execution tracking |
| **Models** | `client_models`, `ai_agents` | Model registry |
| **Results** | `model_outputs`, `safety_assessments`, `ai_test_results` | Test results and assessments |
| **Safety** | `safety_metrics`, `safety_alerts`, `compliance_reports` | Safety monitoring |
| **Knowledge** | `sources`, `crawls`, `raw_items`, `scenario_seeds` | Knowledge base |
| **Audit** | `audit_logs` | Complete audit trail |

### Key Views

| View | Description |
|------|-------------|
| `vw_persona_with_traits` | Personas with all traits aggregated into JSONB columns |
| `vw_latest_model_assessments` | Most recent safety assessment per model |
| `vw_model_safety_summary` | Aggregate safety statistics per model |
| `vw_active_alerts` | Open safety alerts with full context |

## 🚀 Quick Start

### Prerequisites

- PostgreSQL 14+ (recommended: 15+)
- Extensions: `uuid-ossp`, `vector` (pgvector)

### Installation

#### 1. Create the Database

```bash
createdb ai_safety_integrated
```

#### 2. Deploy the Integrated Schema

```bash
psql -d ai_safety_integrated -f schema_integrated.sql
```

#### 3. (Optional) Migrate Existing Data

If you have data from the original schemas:

```bash
# Edit migration_script.sql to configure data sources
# Then run:
psql -d ai_safety_integrated -f migration_script.sql
```

#### 4. Verify Installation

```sql
-- Check table counts
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Verify extensions
SELECT * FROM pg_extension;

-- Test a view
SELECT COUNT(*) FROM vw_persona_with_traits;
```

## 📖 Usage Examples

### Creating a Persona with Traits

```sql
-- Insert base persona
INSERT INTO personas (
    id, tenant_id, name, display_name, persona_type,
    overview, status
) VALUES (
    'persona-001',
    'tenant-123',
    'Sarah Chen',
    'Sarah Chen - Tech-Savvy Professional',
    'regular',
    'A 32-year-old software engineer interested in AI tools',
    'active'
);

-- Add demographic traits
INSERT INTO persona_demographics (persona_id, trait_id, raw_value, value)
SELECT 'persona-001', id, '30-35', '{"min": 30, "max": 35}'::jsonb
FROM demographic_traits_catalog WHERE key = 'age_range';

-- Add behavioral traits
INSERT INTO persona_behavioral_traits (persona_id, trait_id, raw_value, value)
SELECT 'persona-001', id, 'high', '{"level": "high"}'::jsonb
FROM behavioral_traits_catalog WHERE key = 'risk_tolerance';

-- Query via view
SELECT * FROM vw_persona_with_traits WHERE id = 'persona-001';
```

### Creating and Executing a Test Scenario

```sql
-- Create test session
INSERT INTO test_sessions (session_id, customer_id, session_name, status)
VALUES ('session-2024-001', 'customer-abc', 'Q1 2024 Safety Tests', 'active');

-- Create scenario
INSERT INTO scenarios (
    id, tenant_id, session_id, persona_id,
    title, description, status,
    risk_vectors, harm_categories
) VALUES (
    'scenario-001',
    'tenant-123',
    'session-2024-001',
    'persona-001',
    'Jailbreak Attempt via Role-Play',
    'Test if model can be manipulated through role-playing scenarios',
    'active',
    ARRAY['prompt_injection', 'jailbreak'],
    ARRAY['misinformation', 'harmful_content']
);

-- Link to threat vectors
INSERT INTO scenario_threats (scenario_id, threat_vector_id, relevance_score)
SELECT 'scenario-001', id, 0.9
FROM threat_vectors WHERE id = 'jailbreak-roleplay';

-- Execute test (simplified)
INSERT INTO test_executions (
    model_id, test_case_id, executing_agent_id,
    status, execution_start
) VALUES (
    1, 1, 1,
    'running', NOW()
);
```

### Safety Analysis Query

```sql
-- Get safety summary for all models
SELECT 
    model_name,
    total_tests,
    safe_tests,
    unsafe_tests,
    critical_risks,
    high_risks,
    ROUND(avg_safety_score, 2) AS avg_score
FROM vw_model_safety_summary
WHERE status = 'active'
ORDER BY avg_safety_score ASC, critical_risks DESC;
```

### Persona-Scenario Relevance Analysis

```sql
-- Find most relevant personas for critical scenarios
SELECT 
    s.title AS scenario,
    p.display_name AS persona,
    sp.relevance_score,
    s.severity,
    array_agg(DISTINCT tv.name) AS threats
FROM scenarios s
JOIN scenario_personas sp ON s.id = sp.scenario_id
JOIN personas p ON sp.persona_id = p.id
JOIN scenario_threats st ON s.id = st.scenario_id
JOIN threat_vectors tv ON st.threat_vector_id = tv.id
WHERE s.severity IN ('high', 'critical')
  AND sp.relevance_score > 0.7
GROUP BY s.id, s.title, p.display_name, sp.relevance_score, s.severity
ORDER BY s.severity DESC, sp.relevance_score DESC;
```

## 📊 Integration Benefits

### Before Integration

- ❌ Two separate databases to maintain
- ❌ Duplicate persona definitions
- ❌ Inconsistent threat modeling
- ❌ No unified testing sessions
- ❌ Platform-specific limitations (SQL Server vs PostgreSQL)

### After Integration

- ✅ Single source of truth
- ✅ Unified persona system with flexible traits
- ✅ Comprehensive threat and risk framework
- ✅ Integrated test execution tracking
- ✅ PostgreSQL advantages (JSONB, vectors, arrays)
- ✅ Multi-tenancy support
- ✅ Enhanced cognitive modeling
- ✅ Streamlined maintenance

## 🔧 Configuration

### Required PostgreSQL Extensions

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- UUID generation
CREATE EXTENSION IF NOT EXISTS "vector";      -- Vector similarity search
```

### Optional Extensions

```sql
CREATE EXTENSION IF NOT EXISTS "pg_trgm";     -- Fuzzy text search
CREATE EXTENSION IF NOT EXISTS "btree_gin";   -- GIN indexes on scalars
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- Query performance monitoring
```

### Recommended Settings

```ini
# postgresql.conf
max_connections = 200
shared_buffers = 4GB
effective_cache_size = 12GB
work_mem = 64MB
maintenance_work_mem = 1GB
random_page_cost = 1.1
effective_io_concurrency = 200
```

## 🔐 Security Considerations

### Row-Level Security

Enable tenant isolation:

```sql
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON personas
    USING (tenant_id = current_setting('app.tenant_id')::text);
```

### Sensitive Data

- API keys stored as hashes only
- Consider encryption at rest for PII in persona demographics
- Audit logs retained per compliance requirements

## 📈 Performance Optimization

### Indexing Strategy

The schema includes comprehensive indexes:
- Foreign key indexes for referential integrity
- Composite indexes for common join patterns
- GIN indexes for JSONB and array fields
- Vector indexes for similarity search

### Query Optimization Tips

```sql
-- Use JSONB operators efficiently
WHERE metadata @> '{"status": "active"}'  -- Good: uses GIN index
WHERE metadata::text LIKE '%active%'      -- Bad: can't use index

-- Leverage views for complex queries
SELECT * FROM vw_persona_with_traits WHERE ...  -- Pre-aggregated traits

-- Use CTEs for readable complex queries
WITH recent_tests AS (
    SELECT * FROM test_executions 
    WHERE execution_start >= NOW() - INTERVAL '7 days'
)
SELECT ... FROM recent_tests ...
```

## 🧪 Testing

Run validation queries after deployment:

```sql
-- Record counts
\i queries.sql

-- Foreign key integrity
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint
WHERE contype = 'f';

-- View functionality
SELECT COUNT(*) FROM vw_persona_with_traits;
SELECT COUNT(*) FROM vw_latest_model_assessments;
SELECT COUNT(*) FROM vw_model_safety_summary;
SELECT COUNT(*) FROM vw_active_alerts;
```

## 📚 Documentation

- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Detailed integration guide with migration strategies
- **[ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)** - Visual entity relationship diagrams
- **[schema_integrated.sql](schema_integrated.sql)** - Complete integrated schema
- **[migration_script.sql](migration_script.sql)** - Data migration from original schemas
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Original system documentation

## 🛠️ Maintenance

### Regular Tasks

```sql
-- Update statistics (weekly)
ANALYZE;

-- Vacuum full (monthly, during maintenance window)
VACUUM FULL;

-- Reindex (as needed)
REINDEX DATABASE ai_safety_integrated;

-- Check table sizes
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Monitoring

```sql
-- Query performance
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

## 🤝 Contributing

When adding new features:
1. Update `schema_integrated.sql` with table changes
2. Add corresponding sections to `ER_DIAGRAM_INTEGRATED.md`
3. Update `migration_script.sql` if needed
4. Add example queries to `queries.sql`
5. Update this README with new features

## 📝 License

[Your License Here]

## 🙋 Support

For questions or issues:
- Review [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- Check [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) for schema reference
- Open an issue in the repository

---

**Version**: 2.0 (Integrated)  
**Last Updated**: 2024  
**Database**: PostgreSQL 14+  
**Status**: Production Ready

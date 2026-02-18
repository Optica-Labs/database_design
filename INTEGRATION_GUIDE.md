# Database Integration Guide

## Overview

This guide documents the integration of two database schemas into a unified PostgreSQL database for adversarial AI safety testing and persona-based risk assessment.

## Integrated Systems

### 1. Original Adversarial AI Safety System (SQL Server)
- **Purpose**: Model testing, safety assessments, compliance tracking
- **Key Features**:
  - Client model registration and management
  - Adversarial test case execution
  - Safety assessments and metrics
  - Compliance reporting
  - Alert management

### 2. AI Persona Testing & Risk Assessment System (PostgreSQL)
- **Purpose**: Persona-driven testing, scenario generation, risk analysis
- **Key Features**:
  - Flexible persona system with trait catalogs
  - Context profiles and risk assessments
  - Threat vector management
  - Scenario intent modeling
  - Test session management

## Integration Strategy

### Unified PostgreSQL Platform

The integrated schema uses PostgreSQL as the target platform for several reasons:

1. **Vector Embeddings**: Native support via pgvector extension
2. **JSONB**: Superior JSON support for flexible metadata
3. **Arrays**: Native array types for flexible data structures
4. **Extensibility**: Rich ecosystem of extensions
5. **Performance**: Better for complex queries and analytics

### Key Integration Points

#### 1. Unified Persona System

**Merged Tables**: `ai_personas` + `personas` → `personas`

**Strategy**:
- Single `personas` table with `persona_type` field ('regular', 'adversarial', 'internal')
- Retained all fields from both original tables
- Flexible trait system via separate trait catalog tables
- Supports both simple (JSONB) and structured (trait tables) attribute storage

**Migration Considerations**:
```sql
-- Map ai_personas fields to unified personas
INSERT INTO personas (
    id, tenant_id, session_id, name, display_name,
    persona_type, bio, quote, language, is_ai,
    -- Additional fields from original personas table
    use_case_id, cohort_id, sub_cohort_id, archetype, status
)
SELECT ... FROM ai_personas
UNION ALL
SELECT ... FROM personas;
```

#### 2. Test Execution Framework

**Integration**:
- Kept separate `test_executions` (traditional adversarial tests)
- Kept `ai_test_results` (persona-based tests)
- Linked via `test_sessions` for unified tracking

**Rationale**:
- Different testing paradigms require different result structures
- Common session management provides unified tracking
- Cross-references enable holistic analysis

#### 3. Scenario System

**Merged Tables**: `ai_scenarios` + `scenarios` → `scenarios`

**Strategy**:
- Combined all fields from both tables
- Added `scenario_intents` for detailed intent modeling
- Maintained relationships to personas, threats, and test types

#### 4. Multi-tenancy

**New Addition**: `tenants` table

**Purpose**:
- Central tenant/client management
- Consistent tenant isolation across all entities
- Supports both client_id (legacy) and UUID-based identification

#### 5. Context & Risk Assessment

**Preserved**: Original context and risk assessment tables

**Enhancements**:
- Linked `context_profiles` to `tenants` table
- Maintained JSONB structure for flexibility
- Risk assessments feed into scenario and threat generation

## Schema Highlights

### Flexible Trait System

```
personas → persona_demographics → demographic_traits_catalog
        → persona_behavioral_traits → behavioral_traits_catalog
        → persona_psychographic_traits → psychographic_traits_catalog
        → persona_technographic_traits → technographic_traits_catalog
        → persona_linguistic_traits → linguistic_traits_catalog
```

**Benefits**:
- Dynamic trait definition without schema changes
- Type-safe trait values with validation
- Persona-type specific traits
- Sub-cohort applicability

### Test Organization Hierarchy

```
test_categories
    ↓
├─ adversarial_test_cases (traditional)
├─ test_types (categorized tests)
└─ test_sets
       ↓
    test_units
       ↓
    test_turns (conversational tests)
```

### Cognitive Persona System

```
personas
    ↓
├─ persona_memories (episodic memory)
├─ persona_reflections (higher-order reasoning)
├─ persona_plans (goal-oriented behavior)
└─ persona_actions (interaction history)
```

## Migration Path

### Phase 1: Schema Creation

```bash
# Create integrated schema
psql -U username -d database_name -f schema_integrated.sql
```

### Phase 2: Data Migration

```bash
# Migrate data from original schemas
psql -U username -d database_name -f migration_script.sql
```

### Phase 3: Validation

```sql
-- Verify record counts
SELECT 'personas' AS table_name, COUNT(*) FROM personas
UNION ALL
SELECT 'scenarios', COUNT(*) FROM scenarios
UNION ALL
SELECT 'test_executions', COUNT(*) FROM test_executions;

-- Check foreign key integrity
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint
WHERE contype = 'f';
```

## Data Type Conversions

### SQL Server → PostgreSQL

| SQL Server | PostgreSQL | Notes |
|------------|------------|-------|
| BIGINT IDENTITY | BIGSERIAL | Auto-incrementing integer |
| NVARCHAR(MAX) | TEXT | Unlimited length text |
| DATETIME2 | TIMESTAMP WITH TIME ZONE | Timezone-aware timestamps |
| BIT | BOOLEAN | True/false values |
| DECIMAL(5,2) | NUMERIC(5,2) | Fixed precision numbers |

### JSON Handling

**SQL Server**:
```sql
-- Store as NVARCHAR(MAX)
-- Access via JSON_VALUE(), JSON_QUERY()
```

**PostgreSQL**:
```sql
-- Store as JSONB (binary JSON)
-- Access via ->, ->>, @>, etc.
-- Indexable with GIN indexes
```

## Key Views

### vw_persona_with_traits
Aggregates all persona traits into JSONB columns for easy querying.

```sql
SELECT * FROM vw_persona_with_traits
WHERE persona_type = 'adversarial'
  AND demographics->>'age' = '25-34';
```

### vw_latest_model_assessments
Shows the most recent safety assessment for each model.

```sql
SELECT * FROM vw_latest_model_assessments
WHERE risk_level = 'critical';
```

### vw_model_safety_summary
Aggregate safety statistics per model.

```sql
SELECT * FROM vw_model_safety_summary
WHERE avg_safety_score < 70
ORDER BY critical_risks DESC;
```

### vw_active_alerts
All open safety alerts with full context.

```sql
SELECT * FROM vw_active_alerts
WHERE severity IN ('high', 'critical')
  AND hours_open > 24;
```

## Performance Considerations

### Indexing Strategy

1. **Foreign Keys**: Automatically indexed for referential integrity
2. **Temporal Queries**: Indexes on timestamp fields
3. **Status Fields**: Indexes on enum-like status columns
4. **Composite Indexes**: For common join patterns
5. **Vector Indexes**: For embedding similarity search

### Query Optimization

**Use JSONB operators efficiently**:
```sql
-- Good: Uses GIN index
WHERE metadata @> '{"status": "active"}'

-- Avoid: Can't use index
WHERE metadata::text LIKE '%active%'
```

**Partition large tables**:
```sql
-- Consider partitioning audit_logs by timestamp
CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### Connection Pooling

Recommended pooler configuration:
```
max_connections = 200
shared_buffers = 4GB
effective_cache_size = 12GB
work_mem = 64MB
```

## Security Considerations

### Row-Level Security (RLS)

```sql
-- Enable RLS on multi-tenant tables
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;

-- Create tenant isolation policy
CREATE POLICY tenant_isolation ON personas
    USING (tenant_id = current_setting('app.tenant_id')::text);
```

### Sensitive Data

- **API Keys**: Store only hashed values in `client_models.api_key_hash`
- **PII**: Consider encryption at rest for persona demographic data
- **Audit Logs**: Retain for compliance requirements

## Extension Requirements

```sql
-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Vector similarity search
CREATE EXTENSION IF NOT EXISTS "vector";

-- Advanced text search (optional)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

## Testing the Integration

### Unit Tests

```sql
-- Test persona creation with traits
BEGIN;
INSERT INTO personas (id, tenant_id, name, display_name, persona_type)
VALUES ('test-001', 'tenant-001', 'Test User', 'Test User', 'regular');

INSERT INTO persona_demographics (persona_id, trait_id, raw_value)
VALUES ('test-001', 1, '25-34');

SELECT * FROM vw_persona_with_traits WHERE id = 'test-001';
ROLLBACK;
```

### Integration Tests

```sql
-- Test full test execution flow
BEGIN;
-- Insert test session
-- Insert test execution
-- Insert model output
-- Insert safety assessment
-- Verify view data
ROLLBACK;
```

## Monitoring & Maintenance

### Key Metrics to Monitor

1. **Table Sizes**:
   ```sql
   SELECT schemaname, tablename,
          pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
   FROM pg_tables
   WHERE schemaname = 'public'
   ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
   ```

2. **Query Performance**:
   ```sql
   SELECT query, mean_exec_time, calls
   FROM pg_stat_statements
   ORDER BY mean_exec_time DESC
   LIMIT 10;
   ```

3. **Index Usage**:
   ```sql
   SELECT schemaname, tablename, indexname, idx_scan
   FROM pg_stat_user_indexes
   WHERE idx_scan = 0
   ORDER BY pg_relation_size(indexrelid) DESC;
   ```

### Vacuum & Analyze

```sql
-- Regular maintenance
VACUUM ANALYZE personas;
VACUUM ANALYZE test_executions;
VACUUM ANALYZE safety_assessments;
```

## Common Query Patterns

### 1. Find personas with specific traits
```sql
SELECT p.*
FROM personas p
JOIN persona_behavioral_traits pbt ON p.id = pbt.persona_id
JOIN behavioral_traits_catalog btc ON pbt.trait_id = btc.id
WHERE btc.key = 'risk_tolerance'
  AND pbt.raw_value = 'high';
```

### 2. Scenario relevance analysis
```sql
SELECT s.title, p.display_name, sp.relevance_score
FROM scenarios s
JOIN scenario_personas sp ON s.id = sp.scenario_id
JOIN personas p ON sp.persona_id = p.id
WHERE sp.relevance_score > 0.7
ORDER BY sp.relevance_score DESC;
```

### 3. Safety trend analysis
```sql
SELECT 
    DATE_TRUNC('day', assessed_at) AS assessment_date,
    AVG(safety_score) AS avg_safety_score,
    COUNT(*) AS total_assessments,
    COUNT(*) FILTER (WHERE is_safe = false) AS unsafe_count
FROM safety_assessments
WHERE assessed_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', assessed_at)
ORDER BY assessment_date;
```

### 4. Threat vector coverage
```sql
SELECT 
    tv.name AS threat_vector,
    COUNT(DISTINCT st.scenario_id) AS scenario_count,
    COUNT(DISTINCT te.id) AS test_count
FROM threat_vectors tv
LEFT JOIN scenario_threats st ON tv.id = st.threat_vector_id
LEFT JOIN scenarios s ON st.scenario_id = s.id
LEFT JOIN test_executions te ON s.session_id::text = te.session_id::text
GROUP BY tv.id, tv.name
ORDER BY test_count DESC;
```

## Troubleshooting

### Issue: Slow persona queries with traits

**Solution**: Ensure GIN indexes on JSONB trait values:
```sql
CREATE INDEX idx_persona_demographics_value 
ON persona_demographics USING GIN (value);
```

### Issue: Vector search performance

**Solution**: Create vector indexes:
```sql
CREATE INDEX idx_personas_embedding 
ON personas USING ivfflat (embedding vector_cosine_ops);
```

### Issue: Lock contention on test_executions

**Solution**: Use appropriate isolation levels and shorter transactions:
```sql
BEGIN ISOLATION LEVEL READ COMMITTED;
-- Your operations
COMMIT;
```

## Next Steps

1. **Implement row-level security** for multi-tenant isolation
2. **Set up replication** for high availability
3. **Configure backup strategy** (daily full, continuous WAL archiving)
4. **Implement connection pooling** (PgBouncer/PgPool)
5. **Set up monitoring** (pg_stat_statements, pgBadger)
6. **Create materialized views** for expensive aggregations
7. **Document API endpoints** that interact with this schema

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgvector Extension](https://github.com/pgvector/pgvector)
- [JSONB Operators](https://www.postgresql.org/docs/current/functions-json.html)
- [Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)

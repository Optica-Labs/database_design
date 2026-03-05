# Database Schemas

## Overview
This directory contains three complete, production-ready database schemas for different deployment scenarios.

## 🚀 Supabase Compatibility

✅ **All schemas are fully Supabase-compatible and ready for deployment!**

See [../SUPABASE_COMPATIBILITY_REPORT.md](../SUPABASE_COMPATIBILITY_REPORT.md) for:
- Detailed compatibility analysis
- Deployment verification checklist
- Performance characteristics
- Recommended optional additions

### Quick Deployment to Supabase
1. Go to Supabase Dashboard → SQL Editor
2. Copy entire schema file content
3. Paste into editor
4. Click "Run"
5. Verify with post-deployment queries (see report)

---

## Available Schemas

### 1. schema_unified_complete.sql ⭐ PRIMARY
**Complete production database with all features from both products**

**Contents:**
- 84 CREATE TABLE statements
- All AI-Range tables (personas, scenarios, testing, safety)
- All Nexus tables (risk analysis, sycophancy detection)
- All shared infrastructure (products, tenants, models, audit)
- 40+ performance indexes
- 100+ foreign key constraints

**Use Cases:**
- ✅ Full development environments
- ✅ Complete testing
- ✅ Production deployments with both products
- ✅ Monolithic architecture

**Size:** ~49 KB (1,700 lines)

### 2. schema_ai_range_only.sql
**AI-Range product with all parent/dependency tables**

**Contents:**
- 75 CREATE TABLE statements (67 AI-Range + 8 shared)
- Complete AI-Range product functionality
- All shared infrastructure required by AI-Range

**Use Cases:**
- ✅ Dedicated AI-Range deployments
- ✅ AI-Range microservice architecture
- ✅ Standalone AI testing platform

**Size:** ~46 KB (1,200 lines)

### 3. schema_nexus_only.sql
**Nexus platform with all parent/dependency tables**

**Contents:**
- 35 CREATE TABLE statements (16 Nexus + 3 prompt + 3 model + 5 catalogs + 8 shared)
- Complete Nexus analysis pipeline
- Includes `product_prompt_lineage` for AI-Range traceability

**Use Cases:**
- ✅ Dedicated Nexus deployments
- ✅ Nexus microservice architecture
- ✅ Standalone AI assurance platform

**Size:** ~31 KB (~800 lines)

## Schema Comparison

| Feature | Unified | AI-Range | Nexus |
|---------|---------|----------|-------|
| **Tables** | 84 | 75 | 35 |
| Product Code | both | ai-range | nexus |
| Personas | ✅ | ✅ | ❌ |
| Scenarios | ✅ | ✅ | ❌ |
| Testing Framework | ✅ | ✅ | ❌ |
| Risk Metrics | ✅ | ❌ | ✅ |
| Robustness Analysis | ✅ | ❌ | ✅ |
| Sycophancy Detection | ✅ | ❌ | ✅ |
| Shared Infrastructure | ✅ | ✅ | ✅ |

## Shared Tables (All Schemas)

Every schema includes these foundational tables:
- `products` - Product definitions (filtered by product_code)
- `tenants` - Multi-tenancy support
- `client_product_subscriptions` - Product access control
- `ai_agents` - Testing/evaluation agents
- `client_models` - Client-provided models
- `client_model_products` - Model-product associations
- `product_usage` - Usage tracking
- `audit_logs` - Audit trail
- Trait catalogs (demographic, behavioral, psychographic, technographic, linguistic)

## Features

- **PostgreSQL 14+** - Full compatibility
- **Extensions** - uuid-ossp, vector (for embeddings)
- **Multi-Tenancy** - Built-in tenant isolation
- **Indexes** - 40+ performance indexes in each schema
- **Constraints** - 100+ foreign key relationships
- **JSONB Support** - For flexible metadata storage
- **UUID Primary Keys** - All tables
- **Timestamps** - Full audit trail on all tables

## Verification

After loading schema, verify:

```sql
-- Count tables
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check key tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name LIMIT 10;

-- Verify extensions
SELECT * FROM pg_extension WHERE extname IN ('uuid-ossp', 'vector');

-- Check product entries
SELECT product_code, product_name FROM products;
```
    'products', 
    'tenants', 
    'personas', 
    'scenarios', 
    'agent_interactions',
    'generation_runs',
    'nexus_prompt_library'
)
ORDER BY table_name;
```

## Support Files

- `schema_integrated.sql` - Previous version (without agent interactions)
- `agent_interactions_schema.sql` - Agent tracking tables only
- `schema.sql` - Original SQL Server schema (203 lines)

## Migration Path

If you already have `schema_integrated.sql` deployed:
1. Run only `agent_interactions_schema.sql` to add the missing tables
2. Or drop the existing schema and run `schema_complete.sql` for a clean install

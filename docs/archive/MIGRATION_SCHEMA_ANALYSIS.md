# Migration Schema Analysis
## SOURCE vs TARGET Database Comparison

**Date:** 2026-02-23  
**Migration Status:** Partial (3,471 rows migrated across 6 tables)

---

## Executive Summary

The TARGET database (new Supabase) uses **schema_complete.sql** which has **91 tables** with a **product-layer architecture** (multi-tenant, product-scoped). The SOURCE database (old Supabase) has a **simpler structure without product_id foreign keys** on most tables.

### Critical Issues:

1. **Missing `product_id` in SOURCE tables** - Most SOURCE tables don't have `product_id` column
2. **Schema mismatch** - SOURCE table structures differ from TARGET expectations
3. **Foreign key violations** - TARGET requires parent records (products, tenants, use_cases) that don't exist yet
4. **Data conflicts** - Some TARGET tables already have data from previous migration attempts

---

## Table-by-Table Analysis

### ✅ Successfully Migrated (6 tables)

#### 1. **demographic_traits_catalog** (16 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** Catalog table, no FK dependencies

#### 2. **behavioral_traits_catalog** (14 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** Catalog table, no FK dependencies

#### 3. **psychographic_traits_catalog** (16 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** Catalog table, no FK dependencies

#### 4. **technographic_traits_catalog** (14 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** Catalog table, no FK dependencies

#### 5. **linguistic_traits_catalog** (15 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** Catalog table, no FK dependencies

#### 6. **nyc_test_results** (3,396 rows)
- **Status:** ✅ Success
- **Issues:** None
- **Reason:** No FK dependencies in current schema

---

### ❌ Missing from SOURCE (404 Not Found)

These tables exist in TARGET schema but not in SOURCE database:

- `products` ❌
- `tenants` ❌
- `client_product_subscriptions` ❌
- `product_usage` ❌
- `ai_agents` ❌
- `client_models` ❌
- `client_model_products` ❌
- `test_categories` ❌
- `adversarial_test_cases` ❌
- `test_executions` ❌
- `model_outputs` ❌
- `generation_runs` ❌
- `agent_interactions` ❌
- `agent_interaction_*` (6 related tables) ❌
- `conversations` ❌
- `turns` ❌
- `quality_metrics` ❌
- `telemetry` ❌
- `client_prompt_submissions` ❌
- `nexus_prompt_library` ❌
- `product_prompt_lineage` ❌
- `safety_assessments` ❌
- `safety_metrics` ❌
- `safety_alerts` ❌
- `compliance_reports` ❌
- `audit_logs` ❌

**Total:** ~35 tables don't exist in SOURCE

---

### ⚠️ Schema Mismatch (400 Bad Request)

These tables exist in SOURCE but have incompatible structure with TARGET:

#### **use_cases** (2 rows)
**SOURCE columns:**
```
id, slug, name, description, created_at, updated_at
```
**TARGET expects:**
```
id, product_id (FK), slug, name, description, created_at, updated_at
```
**Issue:** Missing `product_id` - needs default product UUID inserted

---

#### **cohorts** (9 rows - 409 Conflict)
**SOURCE columns:**
```
id, use_case_id, name, description, created_at, updated_at
```
**TARGET expects:** Same structure
**Issue:** Data already exists (from previous migration) - need to clear or skip

---

#### **sub_cohorts** (49 rows - 409 Conflict)
**SOURCE columns:**
```
id, cohort_id, name, description, created_at, updated_at, persona_type
```
**TARGET expects:** Same structure  
**Issue:** Data already exists - need to clear or skip

---

#### **personas** (67 rows)
**SOURCE columns:**
```
id, tenant_id, display_name, actor_type, domain, intent, skill_level, 
traits, constraints, description, source, embedding, created_at, name, 
attributes, use_case_id, cohort_id, sub_cohort_id, slug, archetype, 
persona_type, status, version, overview, created_by, updated_at
```
**TARGET expects:**
```
id, product_id (FK), tenant_id, session_id, use_case_id, cohort_id, 
sub_cohort_id, name, display_name, persona_type, archetype, status, 
[...many more fields...]
```
**Issues:**
1. Missing `product_id` - needs default product UUID
2. `tenant_id` is TEXT in SOURCE, UUID in TARGET
3. Many additional fields in TARGET schema

**Transformation needed:**
```sql
-- Example transform
INSERT INTO personas (id, product_id, tenant_id, name, display_name, ...)
SELECT 
    id,
    '00000000-0000-0000-0000-000000000001'::uuid as product_id,  -- Default product
    tenant_id::uuid,  -- Cast if valid UUID format
    name,
    display_name,
    ...
FROM source_personas;
```

---

#### **context_profiles** (32 rows)
**SOURCE columns:**
```
id, source_intake_id, industry, primary_use_case, objectives, guardrails, 
frameworks, policies, api_endpoints, model_stack, personas_seed, risks_seed, 
notes, goals, integration_scan, endpoint_url, ml_stack, custom_models, 
guardrails_endpoint, guardrails_auth, api_access_level, legal_regulatory, 
regular_users_type, regular_users, attackers_type, attackers, ai_agents_type, 
ai_agents, user_distribution, plans, created_at, updated_at
```
**TARGET expects:**
```
id, product_id (FK), [similar fields...]
```
**Issue:** Missing `product_id`

---

#### **risk_assessments** (6 rows)
**SOURCE columns:**
```
id, context_profile_id, source_intake_id, assessment_mode, threats, scenarios, 
summary, agent_endpoint, generation_time_ms, api_response_status, error_message, 
created_at, updated_at
```
**TARGET expects:**
```
id, product_id (FK), [similar fields...]
```
**Issue:** Missing `product_id`

---

#### **threat_vectors** (276 rows)
**SOURCE columns:**
```
id, source, raw_json, name, description, threat_categories, harm_categories, 
modalities, framework_alignment, metadata, severity, created_at, updated_at, 
embedding, category, tags, mitigation, id_uuid
```
**TARGET expects:**
```
id (TEXT), product_id (FK), [similar fields...]
```
**Issues:**
1. Missing `product_id`
2. Has extra `id_uuid` column not in TARGET

---

#### **threat_examples** (37 rows)
**Issue:** Missing `product_id`

---

#### **risks** (2 rows)
**Issue:** Missing `product_id`

---

#### **harms** (1 row)
**Issue:** Missing `product_id`

---

#### **test_types** (12 rows)
**SOURCE columns:**
```
id, name, description, embedding, category, created_at, session_id
```
**TARGET expects:**
```
id (TEXT), product_id (FK), name, description, category, test_characteristics, 
metadata, created_at, updated_at
```
**Issues:**
1. Missing `product_id`
2. Has `session_id` not in TARGET
3. Missing `test_characteristics`, `metadata`

---

#### **scenarios** (70 rows)
**SOURCE columns:**
```
id, tenant_id, title, description, status, risk_vectors, harm_categories, 
stack_tags, metadata, created_at, updated_at, session_id, constraints, 
persona_id, context, expected_behaviors, objectives, generated_prompt, name, tags
```
**TARGET expects:**
```
id (TEXT), product_id (FK), tenant_id, session_id, persona_id, use_case_id, 
title, description, [many more fields...]
```
**Issues:**
1. Missing `product_id`
2. Missing `use_case_id` FK
3. `tenant_id` might need UUID cast

---

#### **scenario_intents** (50 rows)
**Issue:** Missing `product_id`

---

#### **scenario_threats** (60 rows)
**Issue:** Missing `product_id`

---

#### **scenario_scores** (60 rows)
**Issue:** Missing `product_id`

---

#### **scenario_test_types** (720 rows)
**Issue:** Missing `product_id`

---

#### **test_sessions** (282 rows)
**SOURCE columns:**
```
id, session_id, customer_data, status, created_at, updated_at, customer_id, 
session_name, description, metadata, tags
```
**TARGET expects:**
```
id, product_id (FK), tenant_id (FK), customer_id, session_id, [similar fields...]
```
**Issues:**
1. Missing `product_id`
2. Missing `tenant_id` FK (has `customer_id` instead)

---

#### **prompt_generator_responses** (1,284 rows)
**SOURCE columns:**
```
id, session_id, persona_id, persona_name, test_types, prompts, raw_output, created_at
```
**TARGET expects:**
```
id, product_id (FK), session_id, tenant_id, persona_id, scenario_id, model_id, 
[many more fields for LLM tracking...]
```
**Issues:**
1. Missing `product_id`, `tenant_id`, `scenario_id`, `model_id`
2. SOURCE is simplified, TARGET has extensive LLM invocation tracking
3. Major structural difference

---

## Required Transformations

### Phase 1: Setup Foundation (Prerequisites)

1. **Ensure default products exist:**
```sql
INSERT INTO products (id, product_code, product_name, description, status) VALUES
('00000000-0000-0000-0000-000000000001', 'ai-range', 'AI Range', 'Migrated from legacy', 'active'),
('00000000-0000-0000-0000-000000000002', 'nexus', 'Nexus', 'Migrated from legacy', 'active')
ON CONFLICT (product_code) DO NOTHING;
```

2. **Create default tenant for legacy data:**
```sql
INSERT INTO tenants (id, tenant_name, status) VALUES
('00000000-0000-0000-0000-000000000001', 'legacy-migration', 'active')
ON CONFLICT DO NOTHING;
```

3. **Clear conflicting data (if needed):**
```sql
-- Option 1: Delete existing data
DELETE FROM cohorts;
DELETE FROM sub_cohorts;
DELETE FROM persona_demographics;
-- ... etc

-- Option 2: Use ON CONFLICT DO NOTHING in migration
```

### Phase 2: Transform and Migrate

#### Simple tables (add product_id):
```python
def transform_simple_table(source_data, table_name):
    """Add product_id to tables that just need it"""
    default_product_id = '00000000-0000-0000-0000-000000000001'
    
    for row in source_data:
        row['product_id'] = default_product_id
    
    return source_data
```

#### Complex tables (personas, scenarios, etc.):
```python
def transform_personas(source_data):
    """Transform personas with type casting and field mapping"""
    default_product_id = '00000000-0000-0000-0000-000000000001'
    
    transformed = []
    for row in source_data:
        new_row = {
            'id': row['id'],
            'product_id': default_product_id,
            'tenant_id': row.get('tenant_id'),  # May need UUID casting
            'name': row.get('name') or row.get('display_name'),
            'display_name': row.get('display_name'),
            'persona_type': row.get('persona_type', 'regular'),
            'status': row.get('status', 'active'),
            # Map other fields...
        }
        transformed.append(new_row)
    
    return transformed
```

---

## Migration Strategy Recommendations

### Option 1: Transform SOURCE data during migration
**Pros:**
- SOURCE DB stays untouched
- All logic in migration script
- Easy to re-run

**Cons:**
- Complex transformation logic
- Slower migration

**Implementation:**
```python
# Modify migrate_supabase_api.py to add transformation layer
def fetch_and_transform(table_name):
    source_data = fetch_from_source(table_name)
    transformed_data = transform_data(table_name, source_data)
    insert_to_target(table_name, transformed_data)
```

### Option 2: Update SOURCE schema first (NOT RECOMMENDED)
**Pros:**
- Cleaner migration
- Direct copy

**Cons:**
- Modifies production SOURCE DB
- Risky
- Requires downtime

### Option 3: Use TARGET defaults and manual cleanup
**Pros:**
- Quick migration
- Clean up later

**Cons:**
- Data quality issues
- Hard to trace lineage

---

## Recommended Next Steps

1. **Choose default product strategy:**
   - Use single 'ai-range' product for all legacy data?
   - Or map by table/feature to 'ai-range' vs 'nexus'?

2. **Handle tenant_id casting:**
   - Check if SOURCE `tenant_id` values are valid UUIDs
   - Create mapping table if not

3. **Update migration script to transform data:**
   - Add transformation functions for each table
   - Add `product_id` default
   - Handle type casting
   - Map field names

4. **Clear TARGET conflicts:**
   ```sql
   DELETE FROM cohorts;
   DELETE FROM sub_cohorts;
   DELETE FROM persona_demographics;
   DELETE FROM persona_behavioral_traits;
   DELETE FROM persona_psychographic_traits;
   DELETE FROM persona_technographic_traits;
   DELETE FROM persona_linguistic_traits;
   ```

5. **Run migration with transformations**

6. **Validate data integrity:**
   - Check row counts match
   - Verify FK relationships
   - Test application queries

---

## Summary Statistics

- **Total tables in schema_complete.sql:** 91
- **Tables in SOURCE:** ~60 (estimated)
- **Successfully migrated:** 6 tables (3,471 rows)
- **Need transformation:** ~25 tables
- **Missing from SOURCE:** ~35 tables
- **Remaining rows to migrate:** ~5,500+ rows (estimated)

**Primary blocker:** Missing `product_id` foreign key in SOURCE tables
**Secondary blocker:** Data conflicts from previous migration attempts
**Tertiary blocker:** Field name/type mismatches

---

## Files Reference

- **TARGET Schema:** `/Users/apeak/optica/database_design/sql/schemas/schema_complete.sql` (2,513 lines, 91 tables)
- **Migration Script:** `/Users/apeak/optica/database_design/scripts/migrate_supabase_api.py`
- **Migration Report:** `/Users/apeak/optica/database_design/migration_api_report.json`

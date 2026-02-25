# Migration Transformation Plan
## Complete Data Migration from SOURCE to TARGET Supabase

**Date:** 2026-02-23  
**Status:** Ready for Implementation  
**Estimated Time:** 4-6 hours  
**Risk Level:** Medium (requires data transformation and schema updates)

---

## Executive Summary

This plan addresses the complete migration of ~5,500+ rows across ~25 tables from the SOURCE database (old schema without product_id) to the TARGET database (new product-layer architecture with product_id foreign keys).

**Key Strategy:** Transform data during migration by adding required fields (product_id, proper UUIDs) and handle conflicts through selective deletion or upsert logic.

---

## Phase 1: Environment Preparation (30 minutes)

### Step 1.1: Backup Current STATE
```bash
# Backup TARGET database current state
cd /Users/apeak/optica/database_design

# Export migration report for reference
cp migration_api_report.json migration_api_report_backup_$(date +%Y%m%d_%H%M%S).json

# Document what's already migrated
echo "Already migrated: demographic_traits_catalog (16), behavioral_traits_catalog (14), psychographic_traits_catalog (16), technographic_traits_catalog (14), linguistic_traits_catalog (15), nyc_test_results (3396)" > migration_checkpoint.txt
```

### Step 1.2: Create Default Products and Tenant in TARGET
```python
# Create: scripts/setup_migration_defaults.py
import requests
import os
from dotenv import load_dotenv

load_dotenv()

TARGET_URL = os.getenv('TARGET_SUPABASE_API_URL')
TARGET_KEY = os.getenv('TARGET_SUPABASE_SERVICE_KEY')

headers = {
    'apikey': TARGET_KEY,
    'Authorization': f'Bearer {TARGET_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
}

# Default product IDs for migration
AI_RANGE_PRODUCT_ID = '11111111-1111-1111-1111-111111111111'
NEXUS_PRODUCT_ID = '22222222-2222-2222-2222-222222222222'
DEFAULT_TENANT_ID = '99999999-9999-9999-9999-999999999999'

# Check and insert products
print("Setting up products...")
products = [
    {
        'id': AI_RANGE_PRODUCT_ID,
        'product_code': 'ai-range',
        'product_name': 'AI Range',
        'description': 'Migrated from legacy database',
        'status': 'active'
    },
    {
        'id': NEXUS_PRODUCT_ID,
        'product_code': 'nexus',
        'product_name': 'Nexus',
        'description': 'Migrated from legacy database',
        'status': 'active'
    }
]

for product in products:
    response = requests.post(
        f'{TARGET_URL}/rest/v1/products',
        headers=headers,
        json=product
    )
    if response.status_code in [200, 201]:
        print(f"✅ Product {product['product_code']} created")
    elif response.status_code == 409:
        print(f"ℹ️  Product {product['product_code']} already exists")
    else:
        print(f"❌ Error creating product {product['product_code']}: {response.status_code}")
        print(response.text)

# Check and insert default tenant
print("\nSetting up default tenant...")
tenant = {
    'id': DEFAULT_TENANT_ID,
    'tenant_name': 'legacy-migration-tenant',
    'status': 'active',
    'metadata': {'source': 'legacy_migration', 'migration_date': '2026-02-23'}
}

response = requests.post(
    f'{TARGET_URL}/rest/v1/tenants',
    headers=headers,
    json=tenant
)

if response.status_code in [200, 201]:
    print("✅ Default tenant created")
elif response.status_code == 409:
    print("ℹ️  Default tenant already exists")
else:
    print(f"❌ Error creating tenant: {response.status_code}")
    print(response.text)

print("\n" + "="*60)
print("MIGRATION DEFAULTS READY")
print("="*60)
print(f"AI Range Product ID: {AI_RANGE_PRODUCT_ID}")
print(f"Nexus Product ID: {NEXUS_PRODUCT_ID}")
print(f"Default Tenant ID: {DEFAULT_TENANT_ID}")
```

**Run:**
```bash
python3 scripts/setup_migration_defaults.py
```

### Step 1.3: Clear Conflicting Data (if needed)
```python
# Create: scripts/clear_conflicting_data.py
import requests
import os
from dotenv import load_dotenv

load_dotenv()

TARGET_URL = os.getenv('TARGET_SUPABASE_API_URL')
TARGET_KEY = os.getenv('TARGET_SUPABASE_SERVICE_KEY')

headers = {
    'apikey': TARGET_KEY,
    'Authorization': f'Bearer {TARGET_KEY}',
    'Content-Type': 'application/json'
}

# Tables with 409 conflicts
conflict_tables = [
    'persona_linguistic_traits',
    'persona_technographic_traits',
    'persona_psychographic_traits',
    'persona_behavioral_traits',
    'persona_demographics',
    'sub_cohorts',
    'cohorts'
]

print("WARNING: This will delete existing data from conflict tables!")
confirm = input("Type 'DELETE' to confirm: ")

if confirm == 'DELETE':
    for table in conflict_tables:
        response = requests.delete(
            f'{TARGET_URL}/rest/v1/{table}?id=neq.00000000-0000-0000-0000-000000000000',
            headers=headers
        )
        if response.status_code == 204:
            print(f"✅ Cleared {table}")
        else:
            print(f"⚠️  {table}: {response.status_code}")
    print("\n✅ Conflict tables cleared")
else:
    print("❌ Cancelled")
```

---

## Phase 2: Update Migration Script (1 hour)

### Step 2.1: Create Transformation Module
```python
# Create: scripts/data_transformations.py
"""
Data transformation functions for SOURCE to TARGET migration.
Handles adding product_id, type conversions, and field mapping.
"""

import uuid

# Default IDs from setup
AI_RANGE_PRODUCT_ID = '11111111-1111-1111-1111-111111111111'
NEXUS_PRODUCT_ID = '22222222-2222-2222-2222-222222222222'
DEFAULT_TENANT_ID = '99999999-9999-9999-9999-999999999999'

def is_valid_uuid(value):
    """Check if string is valid UUID"""
    if not value:
        return False
    try:
        uuid.UUID(str(value))
        return True
    except:
        return False

def ensure_uuid(value, default=None):
    """Convert to UUID or return default"""
    if is_valid_uuid(value):
        return str(value)
    return default or str(uuid.uuid4())

def add_product_id(row, product_id=AI_RANGE_PRODUCT_ID):
    """Add product_id to row"""
    row['product_id'] = product_id
    return row

def transform_use_cases(rows):
    """Transform use_cases: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_cohorts(rows):
    """Transform cohorts: no changes needed, already compatible"""
    return rows

def transform_sub_cohorts(rows):
    """Transform sub_cohorts: no changes needed"""
    return rows

def transform_personas(rows):
    """Transform personas: add product_id, handle tenant_id"""
    transformed = []
    for row in rows:
        # Add product_id
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Handle tenant_id - if not valid UUID, use default
        if not is_valid_uuid(row.get('tenant_id')):
            row['tenant_id'] = DEFAULT_TENANT_ID
        
        # Ensure session_id is present (can be null)
        if 'session_id' not in row:
            row['session_id'] = None
        
        transformed.append(row)
    return transformed

def transform_persona_traits(rows, trait_type):
    """Transform persona_*_traits tables"""
    # These junction tables should work as-is if personas are migrated first
    return rows

def transform_context_profiles(rows):
    """Transform context_profiles: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_risk_assessments(rows):
    """Transform risk_assessments: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_threat_vectors(rows):
    """Transform threat_vectors: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        # Remove id_uuid if present (not in TARGET schema)
        row.pop('id_uuid', None)
        transformed.append(row)
    return transformed

def transform_threat_examples(rows):
    """Transform threat_examples: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_risks(rows):
    """Transform risks: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_harms(rows):
    """Transform harms: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_test_types(rows):
    """Transform test_types: add product_id, remove session_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        # Remove fields not in TARGET
        row.pop('session_id', None)
        # Add missing fields with defaults
        if 'test_characteristics' not in row:
            row['test_characteristics'] = {}
        if 'metadata' not in row:
            row['metadata'] = {}
        if 'updated_at' not in row:
            row['updated_at'] = row.get('created_at')
        transformed.append(row)
    return transformed

def transform_scenarios(rows):
    """Transform scenarios: add product_id, handle tenant_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Handle tenant_id
        if row.get('tenant_id') and not is_valid_uuid(row['tenant_id']):
            row['tenant_id'] = DEFAULT_TENANT_ID
        
        # use_case_id can be null
        if 'use_case_id' not in row:
            row['use_case_id'] = None
        
        transformed.append(row)
    return transformed

def transform_scenario_intents(rows):
    """Transform scenario_intents: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_scenario_threats(rows):
    """Transform scenario_threats: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_scenario_scores(rows):
    """Transform scenario_scores: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_scenario_test_types(rows):
    """Transform scenario_test_types: add product_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        transformed.append(row)
    return transformed

def transform_test_sessions(rows):
    """Transform test_sessions: add product_id, tenant_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Map customer_id to tenant_id if needed
        if 'tenant_id' not in row and 'customer_id' in row:
            row['tenant_id'] = DEFAULT_TENANT_ID
        
        transformed.append(row)
    return transformed

def transform_prompt_generator_responses(rows):
    """Transform prompt_generator_responses: add product_id, tenant_id, etc."""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Add required fields that SOURCE doesn't have
        if 'tenant_id' not in row:
            row['tenant_id'] = DEFAULT_TENANT_ID
        
        # scenario_id and model_id can be null
        if 'scenario_id' not in row:
            row['scenario_id'] = None
        if 'model_id' not in row:
            row['model_id'] = None
        
        # Map SOURCE fields to TARGET fields
        if 'prompts' in row and 'generated_content' not in row:
            row['generated_content'] = row['prompts']
        
        transformed.append(row)
    return transformed

# Transformation registry
TRANSFORMATIONS = {
    'use_cases': transform_use_cases,
    'cohorts': transform_cohorts,
    'sub_cohorts': transform_sub_cohorts,
    'personas': transform_personas,
    'persona_demographics': transform_persona_traits,
    'persona_behavioral_traits': transform_persona_traits,
    'persona_psychographic_traits': transform_persona_traits,
    'persona_technographic_traits': transform_persona_traits,
    'persona_linguistic_traits': transform_persona_traits,
    'context_profiles': transform_context_profiles,
    'risk_assessments': transform_risk_assessments,
    'threat_vectors': transform_threat_vectors,
    'threat_examples': transform_threat_examples,
    'risks': transform_risks,
    'harms': transform_harms,
    'test_types': transform_test_types,
    'scenarios': transform_scenarios,
    'scenario_intents': transform_scenario_intents,
    'scenario_threats': transform_scenario_threats,
    'scenario_scores': transform_scenario_scores,
    'scenario_test_types': transform_scenario_test_types,
    'test_sessions': transform_test_sessions,
    'prompt_generator_responses': transform_prompt_generator_responses,
}

def transform_table_data(table_name, rows):
    """Apply transformation for a specific table"""
    if table_name in TRANSFORMATIONS:
        return TRANSFORMATIONS[table_name](rows)
    return rows  # Return unchanged if no transformation defined
```

### Step 2.2: Update Migration Script
```python
# Modify: scripts/migrate_supabase_api.py
# Add import at top:
from data_transformations import transform_table_data

# Update migrate_table method (around line 150):
def migrate_table(self, table):
    """Migrate a single table with transformation support"""
    self.logger.info(f"Migrating {table}...")
    
    # Fetch data from source
    all_data = []
    offset = 0
    
    while True:
        data = self.fetch_table_data(table, offset)
        if data is None:
            self.logger.warning(f"Failed to fetch {table}")
            return False
        
        if not data:
            break
        
        all_data.extend(data)
        self.logger.info(f"  Fetched {len(data)} rows (total: {len(all_data)})")
        offset += len(data)
        
        if len(data) < 1000:
            break
    
    if not all_data:
        self.logger.info(f"No data to migrate for {table}")
        return True
    
    # *** ADD TRANSFORMATION HERE ***
    try:
        transformed_data = transform_table_data(table, all_data)
        self.logger.info(f"  Transformed {len(transformed_data)} rows")
    except Exception as e:
        self.logger.error(f"Error transforming {table}: {e}")
        return False
    
    # Insert transformed data
    success = self.insert_table_data(table, transformed_data)
    
    if success:
        self.logger.success(f"✅ Migrated {len(transformed_data)} rows to {table}")
        self.stats['tables_migrated'].append({
            'table': table,
            'rows': len(transformed_data)
        })
        self.stats['total_rows'] += len(transformed_data)
        return True
    else:
        self.logger.error(f"❌ Failed to migrate {table}")
        return False
```

---

## Phase 3: Execute Staged Migration (2-3 hours)

### Stage 1: Foundation Tables (Priority 1)
**Tables:** use_cases → cohorts → sub_cohorts  
**Reason:** Required by personas

```bash
# Update get_tables() in migrate_supabase_api.py to start with these:
# Run migration
python3 scripts/migrate_supabase_api.py
```

**Expected Result:**
- use_cases: 2 rows ✅
- cohorts: 9 rows ✅
- sub_cohorts: 49 rows ✅

### Stage 2: Personas and Traits (Priority 1)
**Tables:** personas → persona_demographics → persona_behavioral_traits → persona_psychographic_traits → persona_technographic_traits → persona_linguistic_traits

**Expected Result:**
- personas: 67 rows ✅
- persona_demographics: 328 rows ✅
- persona_behavioral_traits: 156 rows ✅
- persona_psychographic_traits: 166 rows ✅
- persona_technographic_traits: 165 rows ✅
- persona_linguistic_traits: 114 rows ✅

### Stage 3: Context and Risk (Priority 2)
**Tables:** context_profiles → risk_assessments

**Expected Result:**
- context_profiles: 32 rows ✅
- risk_assessments: 6 rows ✅

### Stage 4: Threats and Risks (Priority 2)
**Tables:** threat_vectors → threat_examples → risks → harms

**Expected Result:**
- threat_vectors: 276 rows ✅
- threat_examples: 37 rows ✅
- risks: 2 rows ✅
- harms: 1 row ✅

### Stage 5: Testing Infrastructure (Priority 2)
**Tables:** test_types → scenarios → scenario_intents → scenario_threats → scenario_scores → scenario_test_types

**Expected Result:**
- test_types: 12 rows ✅
- scenarios: 70 rows ✅
- scenario_intents: 50 rows ✅
- scenario_threats: 60 rows ✅
- scenario_scores: 60 rows ✅
- scenario_test_types: 720 rows ✅

### Stage 6: Sessions and Results (Priority 3)
**Tables:** test_sessions → prompt_generator_responses

**Expected Result:**
- test_sessions: 282 rows ✅
- prompt_generator_responses: 1,284 rows ✅

---

## Phase 4: Validation (1 hour)

### Step 4.1: Row Count Validation
```python
# Create: scripts/validate_migration.py
import requests
import os
from dotenv import load_dotenv

load_dotenv()

SOURCE_URL = os.getenv('SOURCE_SUPABASE_API_URL')
SOURCE_KEY = os.getenv('SOURCE_SUPABASE_SERVICE_KEY')
TARGET_URL = os.getenv('TARGET_SUPABASE_API_URL')
TARGET_KEY = os.getenv('TARGET_SUPABASE_SERVICE_KEY')

def get_count(url, key, table):
    headers = {
        'apikey': key,
        'Authorization': f'Bearer {key}',
        'Prefer': 'count=exact'
    }
    response = requests.head(f'{url}/rest/v1/{table}', headers=headers)
    if response.status_code == 200:
        return int(response.headers.get('Content-Range', '0-0/0').split('/')[-1])
    return None

tables_to_check = [
    'use_cases', 'cohorts', 'sub_cohorts', 'personas',
    'context_profiles', 'risk_assessments', 'threat_vectors',
    'test_types', 'scenarios', 'test_sessions', 'prompt_generator_responses'
]

print("\n" + "="*80)
print("MIGRATION VALIDATION REPORT")
print("="*80)
print(f"{'Table':<40} {'Source':<15} {'Target':<15} {'Status':<10}")
print("-"*80)

for table in tables_to_check:
    source_count = get_count(SOURCE_URL, SOURCE_KEY, table)
    target_count = get_count(TARGET_URL, TARGET_KEY, table)
    
    if source_count is None:
        status = "N/A"
    elif source_count == target_count:
        status = "✅ MATCH"
    else:
        status = "⚠️  DIFF"
    
    print(f"{table:<40} {str(source_count):<15} {str(target_count):<15} {status:<10}")

print("="*80)
```

### Step 4.2: Foreign Key Validation
```sql
-- Run in TARGET Supabase SQL Editor

-- Check for orphaned records
SELECT 'personas missing use_case_id' as issue, COUNT(*) as count
FROM personas 
WHERE use_case_id IS NOT NULL 
  AND use_case_id NOT IN (SELECT id FROM use_cases)
UNION ALL
SELECT 'personas missing product_id', COUNT(*)
FROM personas 
WHERE product_id NOT IN (SELECT id FROM products)
UNION ALL
SELECT 'scenarios missing persona_id', COUNT(*)
FROM scenarios 
WHERE persona_id IS NOT NULL 
  AND persona_id NOT IN (SELECT id FROM personas);
```

### Step 4.3: Data Integrity Checks
```sql
-- Check product_id distribution
SELECT 
    p.product_name,
    COUNT(DISTINCT per.id) as personas_count,
    COUNT(DISTINCT s.id) as scenarios_count,
    COUNT(DISTINCT ts.id) as test_sessions_count
FROM products p
LEFT JOIN personas per ON per.product_id = p.id
LEFT JOIN scenarios s ON s.product_id = p.id
LEFT JOIN test_sessions ts ON ts.product_id = p.id
GROUP BY p.id, p.product_name;

-- Check tenant_id usage
SELECT 
    COUNT(DISTINCT tenant_id) as unique_tenants,
    COUNT(*) as total_records
FROM personas;
```

---

## Phase 5: Post-Migration Cleanup (30 minutes)

### Step 5.1: Update Metadata
```sql
-- Add migration metadata to products
UPDATE products 
SET metadata = jsonb_set(
    metadata, 
    '{migration}', 
    '{"completed": true, "date": "2026-02-23", "source": "legacy_supabase"}'::jsonb
)
WHERE product_code IN ('ai-range', 'nexus');

-- Add migration timestamp to migrated records
UPDATE personas 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{migrated_from_legacy}',
    'true'::jsonb
)
WHERE product_id = '11111111-1111-1111-1111-111111111111';
```

### Step 5.2: Create Migration Summary Report
```python
# Run validation script again and save output
python3 scripts/validate_migration.py > migration_validation_report_$(date +%Y%m%d_%H%M%S).txt
```

### Step 5.3: Document Findings
```bash
# Create final summary
cat > MIGRATION_COMPLETE.md << 'EOF'
# Migration Completion Report

**Date:** $(date)
**Status:** Complete
**Total Rows Migrated:** [FROM VALIDATION REPORT]

## Summary Statistics
- Foundation tables: X rows
- Personas and traits: X rows
- Context and risk: X rows
- Threats: X rows
- Testing: X rows
- Sessions and responses: X rows

## Known Issues
[Document any discrepancies or issues found during validation]

## Next Steps
1. Application testing with migrated data
2. Performance optimization if needed
3. Archive SOURCE database
4. Update documentation
EOF
```

---

## Rollback Strategy

If migration fails at any stage:

### Option 1: Clear TARGET and Restart
```sql
-- Clear all migrated data (preserves catalog tables)
TRUNCATE TABLE prompt_generator_responses CASCADE;
TRUNCATE TABLE test_sessions CASCADE;
TRUNCATE TABLE scenario_test_types CASCADE;
TRUNCATE TABLE scenario_scores CASCADE;
TRUNCATE TABLE scenario_threats CASCADE;
TRUNCATE TABLE scenario_intents CASCADE;
TRUNCATE TABLE scenarios CASCADE;
TRUNCATE TABLE test_types CASCADE;
TRUNCATE TABLE harms CASCADE;
TRUNCATE TABLE risks CASCADE;
TRUNCATE TABLE threat_examples CASCADE;
TRUNCATE TABLE threat_vectors CASCADE;
TRUNCATE TABLE risk_assessments CASCADE;
TRUNCATE TABLE context_profiles CASCADE;
TRUNCATE TABLE persona_linguistic_traits CASCADE;
TRUNCATE TABLE persona_technographic_traits CASCADE;
TRUNCATE TABLE persona_psychographic_traits CASCADE;
TRUNCATE TABLE persona_behavioral_traits CASCADE;
TRUNCATE TABLE persona_demographics CASCADE;
TRUNCATE TABLE personas CASCADE;
TRUNCATE TABLE sub_cohorts CASCADE;
TRUNCATE TABLE cohorts CASCADE;
TRUNCATE TABLE use_cases CASCADE;
```

### Option 2: Selective Table Reset
```bash
# Clear specific table
python3 -c "
import requests, os
from dotenv import load_dotenv
load_dotenv()
url = os.getenv('TARGET_SUPABASE_API_URL')
key = os.getenv('TARGET_SUPABASE_SERVICE_KEY')
table = 'TABLE_NAME'  # Replace
requests.delete(f'{url}/rest/v1/{table}?id=neq.00000000-0000-0000-0000-000000000000',
    headers={'apikey': key, 'Authorization': f'Bearer {key}'})
"
```

---

## Success Criteria

Migration is complete when:

✅ All SOURCE table rows counted in TARGET  
✅ No orphaned foreign key references  
✅ product_id present on all migrated records  
✅ Default products and tenant created  
✅ Validation queries return expected results  
✅ Sample application queries work correctly  
✅ Performance is acceptable (< 2s for common queries)  

---

## Timeline

| Phase | Duration | Dependencies |
|-------|----------|--------------|
| Phase 1: Environment Prep | 30 min | None |
| Phase 2: Script Updates | 1 hour | Phase 1 |
| Phase 3: Execute Migration | 2-3 hours | Phase 2 |
| Phase 4: Validation | 1 hour | Phase 3 |
| Phase 5: Cleanup | 30 min | Phase 4 |
| **TOTAL** | **5-6 hours** | |

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Data loss | Low | High | Backup before start, SOURCE DB unchanged |
| FK violations | Medium | High | Staged migration, validate each stage |
| Performance issues | Low | Medium | Batch inserts, monitor API rate limits |
| Type conversion errors | Medium | Medium | Transformation testing, error handling |
| Incomplete migration | Low | High | Validation scripts, rollback procedures |

---

## Contact & Support

**Migration Lead:** [Your Name]  
**Backup Contact:** [Backup Name]  
**Emergency Rollback Authority:** [Authority Name]  

**Documentation:**
- Schema: `/sql/schemas/schema_complete.sql`
- Analysis: `MIGRATION_SCHEMA_ANALYSIS.md`
- This Plan: `MIGRATION_TRANSFORMATION_PLAN.md`

---

## Approval

- [ ] Plan reviewed by technical lead
- [ ] Backup strategy confirmed
- [ ] Rollback procedure tested
- [ ] Stakeholders notified of migration window
- [ ] Ready to execute

**Approved by:** ________________  
**Date:** ________________

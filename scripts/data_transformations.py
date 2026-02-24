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

def transform_persona_traits(rows):
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
    """Transform threat_vectors: add product_id, remove id_uuid"""
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

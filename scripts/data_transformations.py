"""
Data transformation functions for SOURCE to TARGET migration.
Handles adding product_id, type conversions, and field mapping.
"""

import uuid

# Actual product IDs from TARGET database
AI_RANGE_PRODUCT_ID = '29e90830-dab0-422e-9c24-9ba2ba6bcad5'
NEXUS_PRODUCT_ID = '5a1961c3-848c-4cdb-adb6-7d66891bf5f1'
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
    """Transform personas: add product_id, handle tenant_id, fix persona_type"""
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
        
        # Fix persona_type - must be 'regular', 'adversarial', or 'internal'
        persona_type = row.get('persona_type', 'regular')
        if persona_type == 'regular_user':
            row['persona_type'] = 'regular'
        elif persona_type not in ['regular', 'adversarial', 'internal']:
            row['persona_type'] = 'regular'
        
        # Ensure required fields exist
        if not row.get('name'):
            row['name'] = row.get('display_name', 'Unknown')
        if not row.get('display_name'):
            row['display_name'] = row.get('name', 'Unknown')
        
        transformed.append(row)
    return transformed

def transform_persona_traits(rows):
    """Transform persona_*_traits tables - composite key tables"""
    # These junction tables use (persona_id, trait_id) as composite primary key
    # Remove 'id' field if present, as it's not in the target schema
    transformed = []
    for row in rows:
        row.pop('id', None)
        transformed.append(row)
    return transformed

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
    """Transform test_types: add product_id, remove session_id, add category_id"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        # Remove fields not in TARGET
        row.pop('session_id', None)
        # Add missing fields with defaults
        if 'category_id' not in row or row.get('category_id') is None:
            # Generate category_id based on category name if available
            category = row.get('category', 'general')
            # Map to numeric ID (1-10 for different categories)
            category_map = {
                'general': 1,
                'security': 2,
                'performance': 3,
                'accuracy': 4,
                'safety': 5,
                'bias': 6,
                'toxicity': 7,
                'jailbreak': 8,
                'prompt_injection': 9,
                'other': 10
            }
            row['category_id'] = category_map.get(category.lower() if category else 'general', 1)
        transformed.append(row)
    return transformed

def transform_scenarios(rows):
    """Transform scenarios: add product_id, handle tenant_id"""
    # Known missing persona IDs that should be set to NULL
    missing_persona_ids = {
        'e4dd8008-0a9e-4386-b2d7-e5f561bbab74',
        'b406dae0-0779-41ea-8738-a41e81d018be',
        '4f04adcb-b7f0-432a-81c9-55270ff4942e',
        '795b9ebd-a0db-4844-b8d9-605f4965876f',
        '973e4429-917c-4063-9bf4-b2a4032d7f24'
    }
    
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Handle tenant_id - ensure it exists and is valid
        if not row.get('tenant_id') or not is_valid_uuid(row['tenant_id']):
            row['tenant_id'] = DEFAULT_TENANT_ID
        
        # Remove use_case_id - not in TARGET schema
        row.pop('use_case_id', None)
        
        # Handle persona_id - set to NULL if persona doesn't exist
        if row.get('persona_id') in missing_persona_ids:
            row['persona_id'] = None
        
        # session_id can be null
        if 'session_id' not in row:
            row['session_id'] = None
        
        # Ensure required fields have values
        if not row.get('title'):
            row['title'] = row.get('scenario_name', row.get('name', 'Unknown Scenario'))
        
        # Map name field if needed
        if not row.get('name'):
            row['name'] = row.get('scenario_name', row.get('title', 'Unknown'))
        
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
    """Transform prompt_generator_responses: add product_id, handle required fields"""
    transformed = []
    for row in rows:
        row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Handle tenant_id (not in TARGET schema - remove it)
        row.pop('tenant_id', None)
        
        # Map SOURCE fields to TARGET required fields
        # final_prompt (required)
        if not row.get('final_prompt'):
            row['final_prompt'] = row.get('prompt', row.get('prompts', row.get('generated_text', 'No prompt')))
        
        # final_response (required, must be JSONB)
        if not row.get('final_response'):
            if row.get('response'):
                row['final_response'] = row['response'] if isinstance(row['response'], dict) else {'text': str(row['response'])}
            else:
                row['final_response'] = {'text': row.get('generated_text', 'No response')}
        
        # invocation_id (required UUID)
        if not row.get('invocation_id') or not is_valid_uuid(row['invocation_id']):
            row['invocation_id'] = str(uuid.uuid4())
        
        # model_id (required)
        if not row.get('model_id'):
            row['model_id'] = row.get('model_name', row.get('model', 'unknown-model'))
        
        # Map other fields
        if 'scenario_id' not in row:
            row['scenario_id'] = None
        if 'test_type_id' not in row:
            row['test_type_id'] = None
        if 'persona_id' not in row:
            row['persona_id'] = None
        
        # Ensure status is valid
        valid_status = ['success', 'failed', 'error']
        if row.get('status') not in valid_status:
            row['status'] = 'success'
        
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

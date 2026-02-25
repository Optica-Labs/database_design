"""
Data transformation functions for SOURCE to TARGET migration.
Handles adding product_id, type conversions, and field mapping.
"""

import uuid
import json

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
        # Build new row with ONLY TARGET schema columns
        new_row = {}
        
        # Always include ID
        new_row['id'] = row.get('id', str(uuid.uuid4()))
        
        # Required fields
        new_row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Map SOURCE fields to TARGET required fields
        # final_prompt (required) - extract from prompts list or other fields
        if row.get('final_prompt'):
            new_row['final_prompt'] = row['final_prompt']
        elif row.get('prompt'):
            new_row['final_prompt'] = row['prompt']
        elif row.get('prompts'):
            # SOURCE has a list of prompts, serialize to string
            prompts = row['prompts']
            if isinstance(prompts, list) and prompts:
                new_row['final_prompt'] = json.dumps(prompts)
            else:
                new_row['final_prompt'] = str(prompts)
        else:
            new_row['final_prompt'] = 'No prompt'
        
        # final_response (required, must be JSONB)
        if row.get('final_response'):
            new_row['final_response'] = row['final_response'] if isinstance(row['final_response'], dict) else {'text': str(row['final_response'])}
        elif row.get('response'):
            new_row['final_response'] = row['response'] if isinstance(row['response'], dict) else {'text': str(row['response'])}
        elif row.get('raw_output'):
            new_row['final_response'] = row['raw_output'] if isinstance(row['raw_output'], dict) else {'text': str(row['raw_output'])}
        else:
            new_row['final_response'] = {'text': 'No response'}
        
        # invocation_id (required UUID, UNIQUE)
        if row.get('invocation_id') and is_valid_uuid(row['invocation_id']):
            new_row['invocation_id'] = row['invocation_id']
        else:
            new_row['invocation_id'] = str(uuid.uuid4())
        
        # model_id (required)
        if row.get('model_id'):
            new_row['model_id'] = row['model_id']
        elif row.get('model_name'):
            new_row['model_id'] = row['model_name']
        elif row.get('model'):
            new_row['model_id'] = row['model']
        else:
            new_row['model_id'] = 'unknown-model'
        
        # Optional reference fields - only add if present and valid
        if row.get('generation_run_id') and is_valid_uuid(row['generation_run_id']):
            new_row['generation_run_id'] = row['generation_run_id']
        
        # session_id must be UUID - SOURCE has string like "session-1762782582591", skip it
        if row.get('session_id'):
            sid = row['session_id']
            if is_valid_uuid(sid):
                new_row['session_id'] = sid
            # else: skip - not a valid UUID, can't reference test_sessions
        
        # conversation_id, turn_id - preserve if present
        if row.get('conversation_id'):
            new_row['conversation_id'] = str(row['conversation_id'])[:100]
        if row.get('turn_id'):
            new_row['turn_id'] = str(row['turn_id'])[:100]
        
        # Persona/scenario context - only add if valid UUIDs or TEXTs
        # For prompt_generator_responses, we can't reliably validate persona_ids exist,
        # so we nullify them to avoid FK constraint violations
        # if row.get('persona_id'):
        #     pid = row['persona_id']
        #     if pid not in missing_persona_ids:
        #         if isinstance(pid, str) and (is_valid_uuid(pid) or len(pid) < 100):
        #             new_row['persona_id'] = pid
        # Note: Skipping persona_id to avoid FK constraint violations
        
        if row.get('persona_name'):
            new_row['persona_name'] = str(row['persona_name'])[:255]
        
        if row.get('scenario_id'):
            sid = row['scenario_id']
            if isinstance(sid, str) and len(sid) < 100:
                new_row['scenario_id'] = sid
        
        if row.get('test_type_id'):
            tid = row['test_type_id']
            if isinstance(tid, str) and len(tid) < 100:
                new_row['test_type_id'] = tid
        
        if row.get('threat_vector_id') and is_valid_uuid(row['threat_vector_id']):
            new_row['threat_vector_id'] = row['threat_vector_id']
        
        # Generated content optional fields
        if row.get('generated_text'):
            new_row['generated_text'] = row['generated_text']
        
        if row.get('test_types'):
            new_row['test_types'] = row['test_types'] if isinstance(row['test_types'], (dict, list)) else json.loads(str(row['test_types'])) if isinstance(str(row['test_types']), str) else row['test_types']
        
        if row.get('raw_output'):
            new_row['raw_output'] = row['raw_output'] if isinstance(row['raw_output'], dict) else json.loads(str(row['raw_output'])) if isinstance(str(row['raw_output']), str) else None
        
        # Optional tracking fields
        if row.get('model_name'):
            new_row['model_name'] = str(row['model_name'])[:255]
        if row.get('model_version'):
            new_row['model_version'] = str(row['model_version'])[:100]
        if row.get('provider'):
            new_row['provider'] = str(row['provider'])[:100]
        
        # Execution metrics
        if row.get('latency_ms'):
            try:
                new_row['latency_ms'] = float(row['latency_ms'])
            except (ValueError, TypeError):
                pass
        
        if row.get('prompt_tokens'):
            try:
                new_row['prompt_tokens'] = int(row['prompt_tokens'])
            except (ValueError, TypeError):
                new_row['prompt_tokens'] = 0
        
        if row.get('completion_tokens'):
            try:
                new_row['completion_tokens'] = int(row['completion_tokens'])
            except (ValueError, TypeError):
                new_row['completion_tokens'] = 0
        
        if row.get('total_tokens'):
            try:
                new_row['total_tokens'] = int(row['total_tokens'])
            except (ValueError, TypeError):
                new_row['total_tokens'] = 0
        
        # Error handling
        if row.get('error_code'):
            new_row['error_code'] = str(row['error_code'])[:100]
        if row.get('error_message'):
            new_row['error_message'] = row['error_message']
        
        # Caching and retry
        if row.get('cache_hit') is not None:
            new_row['cache_hit'] = bool(row['cache_hit'])
        
        if row.get('retry_count'):
            try:
                new_row['retry_count'] = int(row['retry_count'])
            except (ValueError, TypeError):
                new_row['retry_count'] = 0
        
        if row.get('invocation_type'):
            valid_types = ['async', 'sync']
            inv_type = str(row['invocation_type']).lower()
            if inv_type in valid_types:
                new_row['invocation_type'] = inv_type
        
        # Metadata
        if row.get('metadata'):
            new_row['metadata'] = row['metadata'] if isinstance(row['metadata'], dict) else {'raw': str(row['metadata'])}
        
        # Status validation
        valid_status = ['success', 'failed', 'error']
        if row.get('status') and row['status'] in valid_status:
            new_row['status'] = row['status']
        else:
            new_row['status'] = 'success'
        
        # Timestamps
        if row.get('created_at'):
            new_row['created_at'] = row['created_at']
        
        if row.get('completed_at'):
            new_row['completed_at'] = row['completed_at']
        
        transformed.append(new_row)
    return transformed

def transform_ai_personas(rows):
    """Transform ai_personas: insert into prompt_generator_responses as LLM invocation results"""
    transformed = []
    for row in rows:
        # Create an LLM invocation record with all ai_personas data as the model response
        new_row = {}
        
        # Use deterministic UUID5 to avoid collisions with existing ids
        if row.get('id'):
            new_row['id'] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"ai_personas:{row.get('id')}"))
        else:
            new_row['id'] = str(uuid.uuid4())
        new_row['product_id'] = AI_RANGE_PRODUCT_ID
        
        # Capture all ai_personas fields (except id) as the final_response JSON
        persona_data = {k: v for k, v in row.items() if k != 'id'}
        new_row['final_response'] = persona_data
        
        # Extract useful fields for other columns
        new_row['final_prompt'] = f"Generate persona: {row.get('name', 'Unknown')}"
        
        # LLM invocation details (deterministic UUID5)
        if row.get('id'):
            new_row['invocation_id'] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"ai_personas_invocation:{row.get('id')}"))
        else:
            new_row['invocation_id'] = str(uuid.uuid4())
        new_row['model_id'] = 'ai-personas-generator'
        new_row['provider'] = 'internal'
        
        # Context
        if row.get('session_id'):
            # Note: session_id from ai_personas is a string like "session-1762308729800"
            # It won't match test_sessions UUID, so we skip it
            pass
        
        new_row['status'] = 'success'
        
        # Preserve created_at if present
        if row.get('created_at'):
            new_row['created_at'] = row['created_at']
        
        # Default metadata
        new_row['metadata'] = {
            'source': 'ai_personas',
            'persona_id': row.get('id'),
            'name': row.get('name'),
            'cohort': row.get('cohort'),
            'sub_cohort': row.get('sub_cohort')
        }
        
        transformed.append(new_row)
    return transformed

def transform_ai_scenarios(rows):
    """Transform ai_scenarios: insert into prompt_generator_responses as LLM invocation results"""
    transformed = []
    for row in rows:
        new_row = {}

        # Use deterministic UUID5 to avoid collisions with existing ids
        if row.get('id'):
            new_row['id'] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"ai_scenarios:{row.get('id')}"))
        else:
            new_row['id'] = str(uuid.uuid4())
        new_row['product_id'] = AI_RANGE_PRODUCT_ID

        scenario_data = {k: v for k, v in row.items() if k != 'id'}
        new_row['final_response'] = scenario_data

        scenario_name = row.get('name') or row.get('title') or row.get('scenario') or 'Unknown'
        new_row['final_prompt'] = f"Generate scenario: {scenario_name}"

        if row.get('id'):
            new_row['invocation_id'] = str(uuid.uuid5(uuid.NAMESPACE_URL, f"ai_scenarios_invocation:{row.get('id')}"))
        else:
            new_row['invocation_id'] = str(uuid.uuid4())
        new_row['model_id'] = 'ai-scenarios-generator'
        new_row['provider'] = 'internal'
        new_row['status'] = 'success'

        if row.get('created_at'):
            new_row['created_at'] = row['created_at']

        new_row['metadata'] = {
            'source': 'ai_scenarios',
            'scenario_id': row.get('id'),
            'name': row.get('name') or row.get('title') or row.get('scenario')
        }

        transformed.append(new_row)
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
    'ai_personas': transform_ai_personas,
    'ai_scenarios': transform_ai_scenarios,
}

def transform_table_data(table_name, rows):
    """Apply transformation for a specific table"""
    if table_name in TRANSFORMATIONS:
        return TRANSFORMATIONS[table_name](rows)
    return rows  # Return unchanged if no transformation defined

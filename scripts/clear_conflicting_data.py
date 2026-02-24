#!/usr/bin/env python3
"""
Clear conflicting data from TARGET database to allow clean migration.
"""
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

# Tables with conflicts - in reverse dependency order for deletion
conflict_tables = [
    'prompt_generator_responses',
    'test_sessions',
    'scenario_test_types',
    'scenario_scores',
    'scenario_threats',
    'scenario_intents',
    'scenarios',
    'test_types',
    'harms',
    'risks',
    'threat_examples',
    'threat_vectors',
    'risk_assessments',
    'context_profiles',
    'persona_linguistic_traits',
    'persona_technographic_traits',
    'persona_psychographic_traits',
    'persona_behavioral_traits',
    'persona_demographics',
    'personas',
    'sub_cohorts',
    'cohorts',
    'use_cases'
]

print("\n" + "="*70)
print("⚠️  WARNING: DATA DELETION")
print("="*70)
print("This will DELETE existing data from the following tables:")
for table in conflict_tables:
    print(f"  - {table}")
print("\nThis is necessary to allow the migration to proceed cleanly.")
print("="*70 + "\n")

confirm = input("Type 'DELETE' to confirm (or anything else to cancel): ")

if confirm == 'DELETE':
    print("\nDeleting data...")
    for table in conflict_tables:
        # Delete all rows where id is not a special system ID
        response = requests.delete(
            f'{TARGET_URL}/rest/v1/{table}?id=neq.00000000-0000-0000-0000-000000000000',
            headers=headers
        )
        if response.status_code == 204:
            print(f"✅ Cleared {table}")
        elif response.status_code == 404:
            print(f"⚠️  {table}: Table not found (404)")
        else:
            print(f"⚠️  {table}: {response.status_code} - {response.text[:100]}")
    print("\n✅ Conflict tables cleared - ready for migration")
else:
    print("\n❌ Cancelled - no data was deleted")

#!/usr/bin/env python3
"""Check for duplicate rows in migrated tables"""
import os
import requests
from dotenv import load_dotenv

load_dotenv()

target_url = os.getenv('TARGET_SUPABASE_API_URL')
target_key = os.getenv('TARGET_SUPABASE_SERVICE_KEY')

migrated_tables = [
    'use_cases', 'cohorts', 'sub_cohorts', 'personas',
    'persona_demographics', 'persona_behavioral_traits',
    'persona_psychographic_traits', 'persona_technographic_traits',
    'persona_linguistic_traits', 'context_profiles', 'risk_assessments',
    'threat_vectors', 'threat_examples', 'risks', 'harms', 'test_types',
    'test_sessions'
]

print("Checking for duplicates in migrated tables...")
print("=" * 70)

for table in migrated_tables:
    url = f'{target_url}/rest/v1/{table}?select=id'
    headers = {
        'apikey': target_key,
        'Authorization': f'Bearer {target_key}',
        'Prefer': 'count=exact'
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        content_range = response.headers.get('Content-Range', '0')
        total_rows = content_range.split('/')[-1]
        ids = [row['id'] for row in response.json()]
        unique_ids = set(ids)
        
        has_duplicates = len(ids) != len(unique_ids)
        status = "❌ HAS DUPLICATES" if has_duplicates else "✅ No duplicates"
        
        print(f"{table:40} Total: {total_rows:>4} | {status}")
        
        if has_duplicates:
            from collections import Counter
            dupes = [id for id, count in Counter(ids).items() if count > 1]
            print(f"  Duplicate IDs: {dupes[:5]}")
    else:
        print(f"{table:40} Error: {response.status_code}")

print("=" * 70)

#!/usr/bin/env python3
"""
Migrate ai_personas from SOURCE to llm_invocations in TARGET
20,767 persona rows → LLM invocation records
"""

import os
import requests
from dotenv import load_dotenv
from datetime import datetime
import json

load_dotenv()

# Database connections
SOURCE_URL = "https://hxejcqyxkvqujbzjcpmk.supabase.co"
TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
SOURCE_KEY = os.getenv("SOURCE_SUPABASE_SERVICE_KEY")
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

if not SOURCE_KEY or not TARGET_KEY:
    print("❌ Error: SUPABASE_SERVICE_KEY environment variables not set")
    print("   Make sure .env file has SOURCE_SUPABASE_SERVICE_KEY and TARGET_SUPABASE_SERVICE_KEY")
    exit(1)

# Product IDs
AI_RANGE_PRODUCT_ID = "29e90830-dab0-422e-9c24-9ba2ba6bcad5"

def fetch_ai_personas(offset=0, limit=1000):
    """Fetch ai_personas from SOURCE database"""
    url = f"{SOURCE_URL}/rest/v1/ai_personas"
    headers = {
        "apikey": SOURCE_KEY,
        "Authorization": f"Bearer {SOURCE_KEY}",
        "Range": f"{offset}-{offset + limit - 1}"
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"❌ Error fetching ai_personas: {response.status_code}")
        print(response.text)
        return []

def transform_persona_to_invocation(persona):
    """Transform ai_persona to llm_invocation record"""
    
    # Build agent_metadata with all persona details
    agent_metadata = {
        "name": persona.get("name"),
        "age": persona.get("age"),
        "sex": persona.get("sex"),
        "cohort": persona.get("cohort"),
        "sub_cohort": persona.get("sub_cohort"),
        "marital_status": persona.get("marital_status"),
        "children": persona.get("children"),
        "income_range": persona.get("income_range"),
        "education": persona.get("education"),
        "occupation": persona.get("occupation"),
        "state": persona.get("state"),
        "city": persona.get("city"),
        "country": persona.get("country"),
        "region": persona.get("region"),
        "cultural_background": persona.get("cultural_background"),
        "ideology": persona.get("ideology"),
        "political_leaning": persona.get("political_leaning"),
        "health_status": persona.get("health_status"),
        "communication_style": persona.get("communication_style"),
        "technical_skills": persona.get("technical_skills"),
        "interests": persona.get("interests"),
        "personality_traits": persona.get("personality_traits"),
        "source_id": persona.get("id"),
        "source_table": "ai_personas"
    }
    
    # Build final_response with structured persona data
    final_response = json.dumps(agent_metadata, indent=2)
    
    return {
        "invocation_id": str(persona.get("id")),  # Generate from persona ID
        "product_id": AI_RANGE_PRODUCT_ID,
        "agent_id": persona.get("id"),
        "agent_name": persona.get("name"),
        "agent_type": "persona",
        "agent_cohort": persona.get("cohort"),
        "agent_sub_cohort": persona.get("sub_cohort"),
        "agent_metadata": agent_metadata,
        "pipeline_stage": "persona_generation",
        "process_phase": "setup",
        "model_id": "ai-personas-generator",
        "model_name": "internal-persona-generator",
        "provider": "internal",
        "final_prompt": f"Generate persona profile: {persona.get('name', 'Unknown')}",
        "final_response": final_response,
        "raw_output": agent_metadata,
        "status": "success",
        "invocation_type": "generation",
        "metadata": {
            "source": "ai_personas_migration",
            "migrated_at": datetime.utcnow().isoformat(),
            "original_id": persona.get("id")
        },
        "created_at": persona.get("created_at", datetime.utcnow().isoformat()),
        "completed_at": persona.get("created_at", datetime.utcnow().isoformat())
    }

def insert_llm_invocations(invocations):
    """Insert invocations into TARGET llm_invocations table"""
    url = f"{TARGET_URL}/rest/v1/llm_invocations"
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates"
    }
    
    response = requests.post(url, headers=headers, json=invocations)
    if response.status_code in [200, 201]:
        return True, len(invocations)
    else:
        print(f"❌ Batch insert failed: {response.status_code}")
        print(response.text)
        return False, 0

def migrate_personas():
    """Main migration function"""
    print("🚀 Starting ai_personas → llm_invocations migration")
    print(f"📊 Fetching from: {SOURCE_URL}")
    print(f"📥 Inserting to: {TARGET_URL}")
    print()
    
    offset = 0
    batch_size = 500  # Larger batches
    total_migrated = 0
    total_errors = 0
    batch_num = 0
    
    while True:
        # Fetch batch
        personas = fetch_ai_personas(offset, batch_size)
        if not personas:
            break
        
        batch_num += 1
        if batch_num % 5 == 0:  # Show progress every 5 batches
            print(f"📦 Processing batch {batch_num}: {offset}-{offset + len(personas)}")
        
        # Transform to invocations
        invocations = [transform_persona_to_invocation(p) for p in personas]
        
        # Insert batch
        success, count = insert_llm_invocations(invocations)
        
        if success:
            total_migrated += count
            if batch_num % 5 == 0:
                print(f"   ✅ Inserted {count} records")
        else:
            total_errors += len(invocations)
            print(f"   ❌ Batch {batch_num} failed - {len(invocations)} records")
        
        # Move to next batch
        offset += len(personas)
        
        # Stop if we got fewer records than batch_size
        if len(personas) < batch_size:
            break
    
    print()
    print("=" * 60)
    print(f"✅ Migration Complete!")
    print(f"📊 Total migrated: {total_migrated}")
    print(f"❌ Total errors: {total_errors}")
    print("=" * 60)

if __name__ == "__main__":
    migrate_personas()

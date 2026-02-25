#!/usr/bin/env python3
"""
Migrate ai_scenarios from SOURCE to llm_invocations in TARGET
4,590 scenario rows → LLM invocation records
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

def fetch_ai_scenarios(offset=0, limit=1000):
    """Fetch ai_scenarios from SOURCE database"""
    url = f"{SOURCE_URL}/rest/v1/ai_scenarios"
    headers = {
        "apikey": SOURCE_KEY,
        "Authorization": f"Bearer {SOURCE_KEY}",
        "Range": f"{offset}-{offset + limit - 1}"
    }
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"❌ Error fetching ai_scenarios: {response.status_code}")
        print(response.text)
        return []

def get_target_scenario_id(scenario_name):
    """Check if scenario exists in TARGET scenarios table"""
    url = f"{TARGET_URL}/rest/v1/scenarios"
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}"
    }
    params = {
        "name": f"eq.{scenario_name}",
        "select": "id"
    }
    
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200 and response.json():
        return response.json()[0].get("id")
    return None

def transform_scenario_to_invocation(scenario):
    """Transform ai_scenario to llm_invocation record"""
    
    # Build scenario metadata
    scenario_metadata = {
        "scenario_name": scenario.get("scenario"),
        "persona_id": scenario.get("persona_id"),
        "description": scenario.get("description"),
        "intent": scenario.get("intent"),
        "threat_type": scenario.get("threat_type"),
        "severity": scenario.get("severity"),
        "context": scenario.get("context"),
        "expected_behavior": scenario.get("expected_behavior"),
        "source_id": scenario.get("id"),
        "source_table": "ai_scenarios"
    }
    
    # Build final_response with scenario data
    final_response = json.dumps(scenario_metadata, indent=2)
    
    # Try to link to existing scenario in TARGET
    target_scenario_id = None
    if scenario.get("scenario"):
        target_scenario_id = get_target_scenario_id(scenario.get("scenario"))
    
    return {
        "invocation_id": str(scenario.get("id")),  # Generate from scenario ID
        "product_id": AI_RANGE_PRODUCT_ID,
        "scenario_id": target_scenario_id,  # Link to TARGET scenario if exists
        "agent_id": None,  # Cannot parse string persona_id to UUID
        "agent_name": None,  # Not available in ai_scenarios
        "agent_type": "scenario_generator",
        "agent_metadata": scenario_metadata,
        "pipeline_stage": "scenario_creation",
        "process_phase": "setup",
        "workflow_step": scenario.get("threat_type"),
        "model_id": "ai-scenario-generator",
        "model_name": "internal-scenario-generator",
        "provider": "internal",
        "final_prompt": f"Generate scenario: {scenario.get('scenario', 'Unknown')}",
        "final_response": final_response,
        "raw_output": scenario_metadata,
        "status": "success",
        "invocation_type": "generation",
        "metadata": {
            "source": "ai_scenarios_migration",
            "migrated_at": datetime.utcnow().isoformat(),
            "original_id": scenario.get("id"),
            "severity": scenario.get("severity"),
            "intent": scenario.get("intent")
        },
        "tags": [scenario.get("threat_type")] if scenario.get("threat_type") else [],
        "created_at": scenario.get("created_at", datetime.utcnow().isoformat()),
        "completed_at": scenario.get("created_at", datetime.utcnow().isoformat())
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
        print(response.text[:500])  # Show first 500 chars of error
        return False, 0

def migrate_scenarios():
    """Main migration function"""
    print("🚀 Starting ai_scenarios → llm_invocations migration")
    print(f"📊 Fetching from: {SOURCE_URL}")
    print(f"📥 Inserting to: {TARGET_URL}")
    print()
    
    offset = 0
    batch_size = 100
    total_migrated = 0
    total_errors = 0
    
    while True:
        # Fetch batch
        scenarios = fetch_ai_scenarios(offset, batch_size)
        if not scenarios:
            break
        
        print(f"📦 Processing batch: {offset}-{offset + len(scenarios)}")
        
        # Transform to invocations
        invocations = [transform_scenario_to_invocation(s) for s in scenarios]
        
        # Insert batch
        success, count = insert_llm_invocations(invocations)
        
        if success:
            total_migrated += count
            print(f"   ✅ Inserted {count} records")
        else:
            total_errors += len(invocations)
            print(f"   ❌ Failed to insert batch")
        
        # Move to next batch
        offset += len(scenarios)
        
        # Stop if we got fewer records than batch_size
        if len(scenarios) < batch_size:
            break
    
    print()
    print("=" * 60)
    print(f"✅ Migration Complete!")
    print(f"📊 Total migrated: {total_migrated}")
    print(f"❌ Total errors: {total_errors}")
    print("=" * 60)

if __name__ == "__main__":
    migrate_scenarios()

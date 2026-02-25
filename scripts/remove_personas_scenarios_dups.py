#!/usr/bin/env python3
"""
Remove duplicate records from llm_invocations for ai_personas and ai_scenarios
Keep first occurrence, remove subsequent duplicates
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

def find_duplicates_by_stage(stage):
    """Find duplicate invocation_ids for a specific pipeline stage"""
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}"
    }
    
    # Fetch all for this stage
    url = f"{TARGET_URL}/rest/v1/llm_invocations"
    params = {
        "pipeline_stage": f"eq.{stage}",
        "select": "id,invocation_id,created_at"
    }
    
    all_rows = []
    offset = 0
    batch_size = 1000
    
    print(f"📊 Fetching {stage} records...")
    while True:
        headers_copy = dict(headers)
        headers_copy["Range"] = f"{offset}-{offset + batch_size - 1}"
        response = requests.get(url, headers=headers_copy, params=params)
        
        if response.status_code == 200:
            rows = response.json()
            if not rows:
                break
            all_rows.extend(rows)
            offset += len(rows)
        elif response.status_code == 416:
            break
        else:
            print(f"❌ Error: {response.status_code}")
            return []
    
    print(f"✅ Total {stage} rows: {len(all_rows)}")
    
    # Find duplicates - keep first by created_at
    seen = {}
    duplicates = []
    
    # Sort by created_at to keep oldest
    all_rows_sorted = sorted(all_rows, key=lambda x: x.get("created_at", ""))
    
    for row in all_rows_sorted:
        inv_id = row["invocation_id"]
        if inv_id in seen:
            duplicates.append(row["id"])
        else:
            seen[inv_id] = row["id"]
    
    return duplicates

def delete_duplicates(row_ids, stage):
    """Delete duplicate rows"""
    if not row_ids:
        print(f"✅ No duplicates found for {stage}\n")
        return 0
    
    print(f"🗑️  Deleting {len(row_ids)} duplicate {stage} rows...")
    
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}",
        "Content-Type": "application/json"
    }
    
    url = f"{TARGET_URL}/rest/v1/llm_invocations"
    
    # Delete in batches
    batch_size = 100
    total_deleted = 0
    
    for i in range(0, len(row_ids), batch_size):
        batch_ids = row_ids[i:i+batch_size]
        
        # Build filter for these IDs: id=in.(id1,id2,id3)
        id_list = ",".join(batch_ids)
        
        response = requests.delete(f"{url}?id=in.({id_list})", headers=headers)
        
        if response.status_code == 204:
            total_deleted += len(batch_ids)
        else:
            print(f"   ❌ Error: {response.status_code}")
            print(response.text)
            return total_deleted
    
    print(f"✅ Deleted {total_deleted} {stage} duplicates\n")
    return total_deleted

def main():
    print("🔍 Finding duplicates in llm_invocations...\n")
    
    # Process ai_personas
    print("=" * 60)
    print("PERSONAS (pipeline_stage='persona_generation')")
    print("=" * 60)
    persona_dups = find_duplicates_by_stage("persona_generation")
    persona_deleted = delete_duplicates(persona_dups, "persona_generation")
    
    # Process ai_scenarios
    print("=" * 60)
    print("SCENARIOS (pipeline_stage='scenario_creation')")
    print("=" * 60)
    scenario_dups = find_duplicates_by_stage("scenario_creation")
    scenario_deleted = delete_duplicates(scenario_dups, "scenario_creation")
    
    print("=" * 60)
    print(f"✅ SUMMARY")
    print("=" * 60)
    print(f"Personas duplicates removed:  {persona_deleted}")
    print(f"Scenarios duplicates removed: {scenario_deleted}")
    print(f"Total duplicates removed:     {persona_deleted + scenario_deleted}")
    print("=" * 60)

if __name__ == "__main__":
    main()

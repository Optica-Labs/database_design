#!/usr/bin/env python3
"""
Migrate missing scenario_intents from SOURCE to TARGET
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

SOURCE_URL = "https://hxejcqyxkvqujbzjcpmk.supabase.co"
TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
SOURCE_KEY = os.getenv("SOURCE_SUPABASE_SERVICE_KEY")
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

def fetch_all(url, key, table):
    """Fetch all rows from a table"""
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}"
    }
    
    all_rows = []
    offset = 0
    batch_size = 1000
    
    while True:
        headers_copy = dict(headers)
        headers_copy["Range"] = f"{offset}-{offset + batch_size - 1}"
        response = requests.get(f"{url}/rest/v1/{table}", headers=headers_copy)
        
        if response.status_code == 200:
            rows = response.json()
            if not rows:
                break
            all_rows.extend(rows)
            offset += len(rows)
        elif response.status_code == 416:
            break
    
    return all_rows

def find_missing():
    """Find scenario_intents that exist in SOURCE but not in TARGET"""
    print("📊 Fetching source scenario_intents...")
    source_intents = fetch_all(SOURCE_URL, SOURCE_KEY, "scenario_intents")
    print(f"✅ Found {len(source_intents)} source records\n")
    
    print("📊 Fetching target scenario_intents...")
    target_intents = fetch_all(TARGET_URL, TARGET_KEY, "scenario_intents")
    print(f"✅ Found {len(target_intents)} target records\n")
    
    print("📊 Fetching target scenarios...")
    target_scenarios = fetch_all(TARGET_URL, TARGET_KEY, "scenarios")
    print(f"✅ Found {len(target_scenarios)} target scenarios\n")
    
    source_ids = {si["id"] for si in source_intents}
    target_ids = {ti["id"] for ti in target_intents}
    target_scenario_ids = {ts["id"] for ts in target_scenarios}
    
    missing_ids = source_ids - target_ids
    
    missing_records = [si for si in source_intents if si["id"] in missing_ids]
    
    # Sanitize scenario_id: if it doesn't exist in target, set to NULL
    for record in missing_records:
        if record.get("scenario_id") and record["scenario_id"] not in target_scenario_ids:
            record["scenario_id"] = None
    
    return missing_records

def insert_missing(records):
    """Insert missing records into TARGET"""
    if not records:
        print("✅ No missing records to migrate\n")
        return 0
    
    # Filter out records with NULL intent_name (required field)
    valid_records = [r for r in records if r.get("intent_name")]
    invalid_count = len(records) - len(valid_records)
    
    if invalid_count > 0:
        print(f"⚠️  Skipping {invalid_count} records with NULL intent_name (required field)\n")
    
    if not valid_records:
        print("✅ No valid records to migrate\n")
        return 0
    
    # Add product_id if missing (required field)
    AI_RANGE_PRODUCT_ID = "29e90830-dab0-422e-9c24-9ba2ba6bcad5"
    for record in valid_records:
        if not record.get("product_id"):
            record["product_id"] = AI_RANGE_PRODUCT_ID
    
    print(f"🚀 Migrating {len(valid_records)} missing scenario_intents...\n")
    
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates"
    }
    
    url = f"{TARGET_URL}/rest/v1/scenario_intents"
    
    # Insert in batches
    batch_size = 100
    total_inserted = 0
    
    for i in range(0, len(valid_records), batch_size):
        batch = valid_records[i:i+batch_size]
        
        response = requests.post(url, headers=headers, json=batch)
        
        if response.status_code in [200, 201]:
            total_inserted += len(batch)
            print(f"✅ Batch {i//batch_size + 1}: Inserted {len(batch)} records")
        else:
            print(f"❌ Batch {i//batch_size + 1} failed: {response.status_code}")
            print(response.text[:500])
    
    return total_inserted

def main():
    print("🔍 Finding missing scenario_intents...\n")
    
    missing = find_missing()
    
    if not missing:
        print("✅ No missing scenario_intents found!")
        return
    
    # Separate by scenario_id status
    with_scenario = [m for m in missing if m.get("scenario_id") is not None]
    without_scenario = [m for m in missing if m.get("scenario_id") is None]
    
    print(f"📋 Missing records ({len(missing)}):\n")
    print(f"   • Records with valid scenario_id: {len(with_scenario)}")
    print(f"   • Records with NULL scenario_id: {len(without_scenario)} (orphaned)\n")
    
    if with_scenario:
        print("   First few with scenario_id:")
        for intent in sorted(with_scenario[:3], key=lambda x: x.get("scenario_id", "")):
            intent_name = intent.get("intent_name", "N/A")
            print(f"     • Scenario: {intent.get('scenario_id')[:8]}..., Intent: {intent_name[:50]}")
    
    if without_scenario:
        print(f"\n   First few with NULL scenario_id:")
        for intent in sorted(without_scenario[:3], key=lambda x: x.get("intent_name", "")):
            intent_name = intent.get("intent_name", "N/A")
            print(f"     • Intent: {intent_name[:50]}")
    
    print()
    
    inserted = insert_missing(missing)
    
    print()
    print("=" * 60)
    print(f"✅ Migration Complete!")
    print(f"📊 Inserted {inserted} scenario_intents")
    print("=" * 60)

if __name__ == "__main__":
    main()

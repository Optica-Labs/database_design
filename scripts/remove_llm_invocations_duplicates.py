#!/usr/bin/env python3
"""
Remove duplicate records from llm_invocations by keeping first occurrence
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

def find_duplicates():
    """Find duplicate invocation_ids in llm_invocations"""
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}"
    }
    
    # Fetch all with minimal data
    url = f"{TARGET_URL}/rest/v1/llm_invocations"
    params = {"select": "id,invocation_id,created_at"}
    
    all_rows = []
    offset = 0
    batch_size = 1000
    
    print("📊 Fetching all llm_invocations...")
    while True:
        headers_copy = dict(headers)
        headers_copy["Range"] = f"{offset}-{offset + batch_size - 1}"
        response = requests.get(url, headers=headers_copy, params=params)
        
        if response.status_code == 200:
            rows = response.json()
            if not rows:
                break
            all_rows.extend(rows)
            print(f"   Fetched {len(all_rows)} rows...")
            offset += len(rows)
        elif response.status_code == 416:
            break
        else:
            print(f"❌ Error: {response.status_code}")
            return []
    
    print(f"✅ Total rows: {len(all_rows)}\n")
    
    # Find duplicates
    seen = {}
    duplicates = []
    
    for row in all_rows:
        inv_id = row["invocation_id"]
        if inv_id in seen:
            duplicates.append(row["id"])
        else:
            seen[inv_id] = row["id"]
    
    return duplicates

def delete_duplicates(row_ids):
    """Delete duplicate rows"""
    if not row_ids:
        print("✅ No duplicates found!")
        return 0
    
    print(f"🗑️  Deleting {len(row_ids)} duplicate rows...\n")
    
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
            print(f"   ✅ Deleted batch {i//batch_size + 1}: {len(batch_ids)} rows")
        else:
            print(f"   ❌ Error: {response.status_code}")
            print(response.text)
            return total_deleted
    
    return total_deleted

def main():
    print("🔍 Finding duplicates in llm_invocations...\n")
    
    duplicates = find_duplicates()
    
    if not duplicates:
        print("✅ No duplicates found!")
        return
    
    print(f"Found {len(duplicates)} duplicate rows\n")
    
    deleted = delete_duplicates(duplicates)
    
    print()
    print("=" * 60)
    print(f"✅ Removed {deleted} duplicate records")
    print("=" * 60)

if __name__ == "__main__":
    main()

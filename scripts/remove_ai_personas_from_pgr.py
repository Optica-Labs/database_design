#!/usr/bin/env python3
"""
Remove ai_personas rows from prompt_generator_responses in TARGET
Keep only the original 1,284 LLM invocation records
"""

import os
import requests
from dotenv import load_dotenv
import json

load_dotenv()

TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

def get_ai_persona_rows():
    """Get all rows that came from ai_personas migration"""
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}"
    }
    
    # Query for rows with model_id='ai-personas-generator'
    url = f"{TARGET_URL}/rest/v1/prompt_generator_responses"
    params = {
        "model_id": "eq.ai-personas-generator",
        "select": "id"
    }
    
    all_rows = []
    offset = 0
    batch_size = 1000
    
    while True:
        headers["Range"] = f"{offset}-{offset + batch_size - 1}"
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code == 200:
            rows = response.json()
            if not rows:
                break
            all_rows.extend(rows)
            offset += len(rows)
        elif response.status_code == 416:  # Range out of bounds
            break
        else:
            print(f"❌ Error fetching: {response.status_code}")
            print(response.text)
            return []
    
    return all_rows

def delete_rows(row_ids):
    """Delete rows from prompt_generator_responses"""
    headers = {
        "apikey": TARGET_KEY,
        "Authorization": f"Bearer {TARGET_KEY}",
        "Content-Type": "application/json"
    }
    
    url = f"{TARGET_URL}/rest/v1/prompt_generator_responses"
    
    # Delete by model_id directly - simpler approach
    params = {"model_id": "eq.ai-personas-generator"}
    
    response = requests.delete(f"{url}?model_id=eq.ai-personas-generator", headers=headers)
    
    if response.status_code == 204:
        print(f"✅ Deleted all ai_personas rows")
        return len(row_ids)
    else:
        print(f"❌ Error deleting: {response.status_code}")
        print(response.text)
        return 0

def main():
    print("🗑️  Removing ai_personas rows from prompt_generator_responses...\n")
    
    print("📊 Finding ai_personas rows (model_id='ai-personas-generator')...")
    rows = get_ai_persona_rows()
    
    if not rows:
        print("ℹ️  No ai_personas rows found to delete")
        return
    
    row_ids = [r["id"] for r in rows]
    print(f"📊 Found {len(row_ids)} rows to delete\n")
    
    print("🗑️  Deleting rows...")
    deleted = delete_rows(row_ids)
    
    print()
    print("=" * 60)
    print(f"✅ Deleted {deleted} ai_personas records")
    print(f"📊 prompt_generator_responses now contains ~1,284 original LLM invocations")
    print("=" * 60)

if __name__ == "__main__":
    main()

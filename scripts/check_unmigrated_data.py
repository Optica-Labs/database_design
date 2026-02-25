#!/usr/bin/env python3
"""
Check what data remains unmigrated from SOURCE to TARGET
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

SOURCE_URL = "https://hxejcqyxkvqujbzjcpmk.supabase.co"
TARGET_URL = "https://aayinvrvtumndpubwtui.supabase.co"
SOURCE_KEY = os.getenv("SOURCE_SUPABASE_SERVICE_KEY")
TARGET_KEY = os.getenv("TARGET_SUPABASE_SERVICE_KEY")

# Tables we know should be migrated
MIGRATION_TABLES = [
    "use_cases",
    "cohorts",
    "sub_cohorts",
    "personas",
    "persona_demographics",
    "persona_behavioral_traits",
    "persona_psychographic_traits",
    "persona_technographic_traits",
    "persona_linguistic_traits",
    "context_profiles",
    "risk_assessments",
    "threat_vectors",
    "threat_examples",
    "risks",
    "harms",
    "test_types",
    "scenarios",
    "scenario_intents",
    "scenario_threats",
    "scenario_scores",
    "scenario_test_types",
    "test_sessions",
    "prompt_generator_responses",
    "ai_personas",  # Migrated to llm_invocations
    "ai_scenarios",  # Migrated to llm_invocations
]

def count_rows(url, key, table):
    """Count rows in a table"""
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Prefer": "count=exact"
    }
    
    response = requests.get(f"{url}/rest/v1/{table}?limit=0", headers=headers)
    
    if response.status_code in [200, 206]:
        content_range = response.headers.get("content-range", "")
        # Format is "*/COUNT" or "OFFSET-LAST/COUNT"
        if "/" in content_range:
            count = content_range.split("/")[-1]
            try:
                return int(count)
            except ValueError:
                return 0
    elif response.status_code == 404:
        return 0  # Table doesn't exist
    return None

def main():
    print("📊 Checking unmigrated data...\n")
    print("=" * 80)
    
    unmigrated = []
    
    for table in MIGRATION_TABLES:
        source_count = count_rows(SOURCE_URL, SOURCE_KEY, table)
        target_count = count_rows(TARGET_URL, TARGET_KEY, table)
        
        # Handle special mappings for migrated tables
        if table == "ai_personas":
            # These were migrated to llm_invocations, so if they don't exist in target, mark as OK
            # (they've been replaced/migrated)
            if target_count == 0:
                # Check if llm_invocations exists as replacement
                llm_count = count_rows(TARGET_URL, TARGET_KEY, "llm_invocations")
                if llm_count is not None and llm_count > 0:
                    target_count = llm_count  # Use llm_invocations as proxy
        elif table == "ai_scenarios":
            # These were migrated to llm_invocations, so if they don't exist in target, mark as OK
            if target_count == 0:
                # Check if llm_invocations exists as replacement
                llm_count = count_rows(TARGET_URL, TARGET_KEY, "llm_invocations")
                if llm_count is not None and llm_count > 0:
                    target_count = llm_count  # Use llm_invocations as proxy
        
        if source_count is None or target_count is None:
            status = "❓ ERROR"
        elif source_count == 0:
            status = "✅ EMPTY"
        elif target_count == 0 and source_count > 0:
            status = "❌ UNMIGRATED"
            unmigrated.append((table, source_count, 0))
        elif target_count < source_count:
            status = f"⚠️  PARTIAL ({target_count}/{source_count})"
            unmigrated.append((table, source_count, target_count))
        else:
            status = "✅ OK"
        
        print(f"{table:40} | SOURCE: {str(source_count).rjust(6)} | TARGET: {str(target_count).rjust(6)} | {status}")
    
    print("=" * 80)
    
    if unmigrated:
        print(f"\n⚠️  UNMIGRATED DATA FOUND:\n")
        for table, source, target in unmigrated:
            remaining = source - target
            print(f"  • {table:40} {remaining:6} rows remaining ({target}/{source} migrated)")
    else:
        print("\n✅ All data migrated!")

if __name__ == "__main__":
    main()

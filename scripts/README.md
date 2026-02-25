# Migration & Utility Scripts

Complete documentation for database migration and verification scripts.

## Overview

Scripts organized by purpose:
- **Production Scripts**: Ready for production use
- **Verification Scripts**: Data quality & integrity checks
- **Utility Scripts**: Helper tools
- **Archive**: Historical/testing scripts

## Production Scripts

These scripts are used for the migration and cleanup operations.

### check_unmigrated_data.py
**Purpose**: Verify migration status across all tables  
**Usage**: `python3 check_unmigrated_data.py`  
**Output**: Table-by-table migration status report

### migrate_missing_scenario_intents.py
**Purpose**: Migrate remaining scenario_intents  
**Usage**: `python3 migrate_missing_scenario_intents.py`  
**Status**: Handles orphaned scenario_id references

### remove_ai_personas_from_pgr.py
**Purpose**: Remove synthetic ai_personas records  
**Removed**: 12,841 synthetic records

### remove_llm_invocations_duplicates.py
**Purpose**: Remove duplicates from llm_invocations  
**Removed**: 9,000 duplicate records

## Verification Scripts

### test_supabase_connection.py
**Purpose**: Verify database connectivity  
**Usage**: `python3 test_supabase_connection.py`

## Configuration

All scripts require `.env`:
```
SOURCE_SUPABASE_SERVICE_KEY=...
TARGET_SUPABASE_SERVICE_KEY=...
```

See `.env.example` for template.

## Quick Start

```bash
# 1. Verify connection
python3 test_supabase_connection.py

# 2. Check migration status
python3 check_unmigrated_data.py

# 3. Migrate remaining records (if needed)
python3 migrate_missing_scenario_intents.py
```

## Archive Scripts

Historical scripts used during development:
- Analysis scripts (check_*, analyze_*)
- Debug scripts (debug_*, compare_*)
- Migration scripts (migrate_*)
- Utility scripts (create_*, setup_*, upload_*)

---

**Status**: ✅ Production Ready  
**Last Updated**: February 25, 2026

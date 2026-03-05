# Cat-Astrophic Prompt Database Integration

**ARCHIVED SNAPSHOT** (Feb 22, 2026): Integration guide for the Cat-Astrophic (PromptGoblin v2) tables.  
For verification of live Cat-Astrophic tables, see `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md` and run `scripts/verify_live_alignment.py`.

## Overview

The Cat-Astrophic Prompt Database (PromptGoblin v2) has been fully integrated into the AI-Range Unified Architecture. This comprehensive system provides detailed tracking of prompt generation, execution, and quality metrics.

**Product**: AI-Range (all tables include `product_id` linking to AI-Range)

## Core Tables

### 1. generation_runs
**Purpose**: Stores batch/run-level metadata for prompt generation sessions

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| generation_run_id | UUID | Unique identifier for tracking generation batch |
| modality | VARCHAR(50) | Generation type: text, image, audio |
# Archived: Cat-Astrophic Prompt Database Integration

This file was archived and consolidated into the canonical documentation.

Archived copy (full content preserved): `docs/archive/CAT_ASTROPHIC_INTEGRATION.md`

See canonical references:
- `DOCUMENTATION.md`
- `MASTER_DOCUMENTATION_INDEX.md`
- `docs/NEXUS_ALPHA_ARCHITECTURE.md`

For the full preserved content, see `docs/archive/CAT_ASTROPHIC_INTEGRATION.md`.
- `idx_generation_runs_created` - Time-based queries

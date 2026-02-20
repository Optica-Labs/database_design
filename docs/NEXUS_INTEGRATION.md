# Nexus Prompt Integration

This document describes the **Nexus product integration** for prompt ingestion and curation.

## Overview

Nexus consumes two types of prompts:
1. **Completed, successful Stage 4 prompts** from the Cat-Astrophic agent (AI-Range pipeline).
2. **Client-provided prompts** submitted via UI/API/import.

Both sources are unified into a single Nexus prompt library for downstream persona and scenario testing.

## Core Tables

### 1) `client_prompt_submissions`
**Purpose**: Stores prompts provided directly by tenants.

**Key Fields**:
- `id` (UUID, PK)
- `product_id` (FK → products, must be `nexus`)
- `tenant_id` (FK → tenants)
- `model_id` (optional FK → client_models)
- `prompt_text` (TEXT)
- `submission_channel` (api, ui, import, other)
- `status` (submitted, approved, rejected, archived)
- `metadata` (JSONB)

### 2) `nexus_prompt_library`
**Purpose**: Unified Nexus prompt library (Cat-Astrophic Stage 4 + client submissions).

**Key Fields**:
- `id` (UUID, PK)
- `product_id` (FK → products, must be `nexus`)
- `tenant_id` (FK → tenants)
- `source_type` (cat-astrophic | client)
- `cat_turn_id` (FK → turns.id) **OR** `client_prompt_id` (FK → client_prompt_submissions.id)
- `prompt_text` (TEXT)
- `cat_stage` (INTEGER; expected 4 for Cat-Astrophic)
- `status` (active, inactive, archived, rejected)

**Source Integrity Rule**:
- If `source_type = 'cat-astrophic'` → `cat_turn_id` must be set.
- If `source_type = 'client'` → `client_prompt_id` must be set.

### 3) `product_prompt_lineage`
**Purpose**: Cross-product traceability between AI-Range prompts and Nexus library entries.

**Key Fields**:
- `ai_range_turn_id` (FK → turns.id)
- `nexus_prompt_id` (FK → nexus_prompt_library.id)
- `ai_range_product_id` (FK → products, `ai-range`)
- `nexus_product_id` (FK → products, `nexus`)
- `lineage_type` (stage4, other)

## Views

### `vw_nexus_stage4_prompt_candidates`
Filters Cat-Astrophic turns to **completed, Stage 4** prompts that are eligible for Nexus ingestion.

### `vw_nexus_prompt_library`
Unified view of Nexus prompt library records, joined with source metadata.

### `vw_cross_product_prompt_trace`
Trace AI-Range prompts through Nexus library entries (end-to-end lineage).

## Ingestion Pattern (Recommended)

1) Select Stage 4 candidates from `vw_nexus_stage4_prompt_candidates`.
2) Insert into `nexus_prompt_library` with `source_type = 'cat-astrophic'`.
3) `product_prompt_lineage` is created automatically via trigger on insert.
4) For client prompts, insert into `client_prompt_submissions`, then promote approved prompts into `nexus_prompt_library`.

## Notes

- Nexus is tracked via the `products` table (`product_code = 'nexus'`).
- Use `product_usage` for billing/usage tracking on prompt ingestion and runs.

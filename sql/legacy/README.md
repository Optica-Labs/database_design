# Legacy schema name mapping

This directory documents schemas and table names that the **canonical** create
pipeline (`sql/create/`) supersedes, and the naming transition it applies.

The canonical schema is generated from the live database snapshot and uses the
**`peregrine`** naming convention. Older schemas in this repository used the
`alpha` / `peregrine_alpha` convention and, before that, un-prefixed names.

## 1. `alpha_*` → `peregrine_*` (live tables → canonical)

The 13 live `alpha_*` tables are emitted with the `peregrine_*` prefix in
[sql/create/10_schema_canonical.sql](../create/10_schema_canonical.sql):

| Live name (legacy)            | Canonical name (peregrine)         |
| ----------------------------- | ---------------------------------- |
| `alpha_audit_logs`            | `peregrine_audit_logs`             |
| `alpha_benchmark_results`     | `peregrine_benchmark_results`      |
| `alpha_benchmark_runs`        | `peregrine_benchmark_runs`         |
| `alpha_consistency_results`   | `peregrine_consistency_results`    |
| `alpha_conversations`         | `peregrine_conversations`          |
| `alpha_embeddings`            | `peregrine_embeddings`             |
| `alpha_generation_runs`       | `peregrine_generation_runs`        |
| `alpha_pca_models`            | `peregrine_pca_models`             |
| `alpha_prompt_library`        | `peregrine_prompt_library`         |
| `alpha_prompt_submissions`    | `peregrine_prompt_submissions`     |
| `alpha_telemetry`             | `peregrine_telemetry`              |
| `alpha_turns`                 | `peregrine_turns`                  |
| `alpha_vectors_2d`            | `peregrine_vectors_2d`             |

## 2. Dropped authored-only tables (un-prefixed → renamed in live)

These names existed in the older hand-authored unified schema but were **renamed
in the live database**. They are intentionally **dropped** from the canonical
schema; use the peregrine name instead.

| Old authored name           | Renamed in live              | Canonical (peregrine)          |
| --------------------------- | ---------------------------- | ------------------------------ |
| `generation_runs`           | `alpha_generation_runs`      | `peregrine_generation_runs`    |
| `conversations`             | `alpha_conversations`        | `peregrine_conversations`      |
| `turns`                     | `alpha_turns`                | `peregrine_turns`              |
| `telemetry`                 | `alpha_telemetry`            | `peregrine_telemetry`          |
| `client_prompt_submissions` | `alpha_prompt_submissions`   | `peregrine_prompt_submissions` |
| `peregrine_prompt_library`      | `alpha_prompt_library`       | `peregrine_prompt_library`     |
| `audit_logs`                | `alpha_audit_logs`           | `peregrine_audit_logs`         |

## 3. `peregrine_alpha` → `peregrine` (product variant)

In the Peregrine product variant and modular Supabase schemas, the `peregrine_alpha`
schema name and the `peregrine_alpha_*` table prefix transition to `peregrine`
and `peregrine_*` respectively.

## 4. Display name

The `Peregrine Alpha` product/platform display name in active documentation becomes
`Peregrine`. Historical documents under `docs/archive/` are left untouched.

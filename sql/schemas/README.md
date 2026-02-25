# Complete Supabase Schema Upload

## Overview
This directory contains the complete, unified database schema ready for Supabase deployment.

## File Description

### `schema_complete.sql` (2520 lines)
**This is the complete, production-ready schema** that includes:

1. **Product Layer Architecture** - Products (ai-range, nexus) and subscriptions
2. **Core Entities** - Tenants, AI agents, client models
3. **Use Cases & Personas** - Cohorts, sub-cohorts, trait catalogs
4. **Personas & Traits** - Flexible persona attributes with demographic, behavioral, psychographic, technographic, and linguistic traits
5. **Context & Risk** - Context profiles, risk assessments, threat vectors, harms
6. **Test Framework** - Test categories, types, scenarios, intents
7. **Test Execution** - Test sessions, adversarial test cases, executions
8. **CAT-ASTROPHIC Integration** - Generation runs, conversations, turns, quality metrics, telemetry
9. **Agent Interaction Tracking** ⭐ NEW - Complete agent workflow tracking:
   - `agent_interactions` - Core agent participation tracking
   - `agent_interaction_libraries` - Library access tracking
   - `agent_interaction_inputs` - Input parameters
   - `agent_interaction_outputs` - Output results
   - `agent_interaction_flow` - Data flow between agents
   - `agent_interaction_decisions` - Decision points
   - `agent_interaction_metrics` - Performance metrics
10. **Nexus Prompt Library** - Stage 4 prompts and client submissions
11. **Model Outputs & Results** - Outputs, responses, safety assessments
12. **Nexus Alpha Platform** - Risk metrics, robustness analysis, fragility scores, sycophancy detection
13. **Compliance & Audit** - Alerts, compliance reports, audit logs
14. **Supporting Infrastructure** - Sources, caching, views

## How to Upload to Supabase

### Option 1: Direct Upload (Recommended)
1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the entire contents of `schema_complete.sql`
5. Paste into the SQL Editor
6. Click **Run** or press `Ctrl+Enter` / `Cmd+Enter`
7. Wait for completion (may take 1-2 minutes)

### Option 2: Python Script Upload
Use the provided Python script with your .env configuration:

```bash
python3 scripts/upload_schema_supabase.py
```

Make sure your `.env` file contains:
```
SUPABASE_HOST=your-project.supabase.co
SUPABASE_PORT=5432
SUPABASE_DB=postgres
SUPABASE_USER=postgres
SUPABASE_PASSWORD="your-password-here"
SCHEMA_PATH=sql/schemas/schema_complete.sql
```

## What's Included

### Total Tables: 100+
- Core product and tenant management
- AI agents and client models
- Persona management with flexible traits
- Comprehensive test framework
- Agent interaction tracking (NEW)
- CAT-ASTROPHIC prompt generation
- Nexus prompt library
- Nexus Alpha robustness analysis
- Full audit and compliance

### Views: 15+
- Cross-product prompt traceability
- Model performance summaries
- Risk trends and alerts
- Agent workflow analysis (NEW)
- Conversation summaries

### Indexes: 200+
Optimized for:
- Product and tenant isolation
- Time-based queries
- Status filtering
- Agent workflow lookups
- Cross-product relationships

## Notes

- ✅ PostgreSQL-compatible (Supabase ready)
- ✅ All foreign key constraints properly defined
- ✅ Comprehensive indexing for performance
- ✅ Product-level multi-tenancy
- ✅ JSONB for flexible metadata
- ✅ UUID primary keys where appropriate
- ✅ Timestamp tracking on all tables

## Verification

After upload, verify the schema:

```sql
-- Count tables
SELECT count(*) FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check key tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'products', 
    'tenants', 
    'personas', 
    'scenarios', 
    'agent_interactions',
    'generation_runs',
    'nexus_prompt_library'
)
ORDER BY table_name;
```

## Support Files

- `schema_integrated.sql` - Previous version (without agent interactions)
- `agent_interactions_schema.sql` - Agent tracking tables only
- `schema.sql` - Original SQL Server schema (203 lines)

## Migration Path

If you already have `schema_integrated.sql` deployed:
1. Run only `agent_interactions_schema.sql` to add the missing tables
2. Or drop the existing schema and run `schema_complete.sql` for a clean install

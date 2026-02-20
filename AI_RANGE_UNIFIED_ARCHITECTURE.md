# AI-Range Unified Platform - Final Architecture

## Executive Summary

**AI-Range now owns ALL functionality** - both testing/safety operations AND persona/scenario capabilities have been consolidated into a single unified product.

**✅ COMPLETE**: All 36 operational tables are now linked to the AI-Range UUID via `product_id` foreign key, ensuring complete audit trail and product ownership.

## What Changed

### Before
- **AI-Range**: Testing & Safety only
- **Nexus**: Personas & Scenarios

### After
- **AI-Range**: EVERYTHING (Testing, Safety, Personas, Scenarios)
- **Nexus**: Prompt ingestion + library (Stage 4 Cat-Astrophic + client prompts)

## Complete List of Tables with product_id

All the following tables now include `product_id UUID NOT NULL REFERENCES products(id)` linking to AI-Range or Nexus (38 tables total):

### Testing & Safety (9 tables)
1. ✅ `test_categories` - Test categorization framework
2. ✅ `test_sessions` - Testing sessions for tenants
3. ✅ `test_types` - Types of tests available
4. ✅ `adversarial_test_cases` - Individual adversarial test cases
5. ✅ `test_executions` - Test execution records
6. ✅ `safety_assessments` - Safety evaluation results
7. ✅ `compliance_reports` - Compliance assessment reports
8. ✅ `audit_logs` - System audit trail
9. ✅ `model_outputs` - Model responses from tests

### AI Agents (1 table)
10. ✅ `ai_agents` - Testing and evaluation agents

### Threats, Risks & Harms (5 tables)
11. ✅ `threat_vectors` - Threat intelligence vectors
12. ✅ `threat_examples` - Examples of threats
13. ✅ `risks` - Risk definitions
14. ✅ `harms` - Harm definitions
15. ✅ `context_profiles` - Customer context for testing

### Risk Assessment (1 table)
16. ✅ `risk_assessments` - Risk assessment results

### Personas & Scenarios (3 tables)
17. ✅ `use_cases` - Business use cases for testing
18. ✅ `personas` - AI personas for testing
19. ✅ `scenarios` - Test scenarios

### Persona Cognition & Memory (4 tables)
20. ✅ `persona_memories` - Persona memory storage
21. ✅ `persona_reflections` - Persona reflections
22. ✅ `persona_plans` - Persona plans and goals
23. ✅ `persona_actions` - Persona actions taken

### Scenario & Intent Framework (6 tables)
24. ✅ `scenario_intents` - Intents within scenarios
25. ✅ `scenario_intent_personas` - Personas for each intent
26. ✅ `scenario_personas` - Personas in scenarios
27. ✅ `scenario_threats` - Threats in scenarios
28. ✅ `scenario_scores` - Scenario evaluation scores
29. ✅ `scenario_test_types` - Test types for scenarios

### Prompt Generation (1 table - consolidated)
30. ✅ `prompt_generator_responses` - Generated responses with metadata (combined from prompt_generator_responses + prompt_response_metadata)

### Cat-Astrophic Prompt Generation (5 tables - consolidated)
31. ✅ `generation_runs` - Batch prompt generation sessions
32. ✅ `conversations` - Conversation threads
33. ✅ `turns` - Individual conversation turns
34. ✅ `quality_metrics` - Quality metrics for generation
35. ✅ `telemetry` - System telemetry data

### Product Tracking (1 table)
36. ✅ `product_usage` - Product usage audit trail

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                     AI-RANGE PRODUCT                       │
│                  (Unified Platform)                        │
│                                                            │
│  ┌──────────────────────────────────────────────┐        │
│  │         Testing Hub (with Use Cases)         │        │
│  ├──────────────────────────────────────────────┤        │
│  │ • use_cases (business context)               │        │
│  │ • test_categories                            │        │
│  │ • test_sessions                              │        │
│  │ • test_cases                                 │        │
│  │ • test_executions                            │        │
│  │ • safety_assessments                         │        │
│  │ • compliance_reports                         │        │
│  │ • safety_alerts                              │        │
│  │ • threat_vectors & harms (risk framework)    │        │
│  └──────────────────────────────────────────────┘        │
│                                                            │
│  ┌──────────────────────────────────────────────┐        │
│  │         Persona System                       │        │
│  ├──────────────────────────────────────────────┤        │
│  │ • personas (linked to use_cases)             │        │
│  │ • cohorts & sub_cohorts (classifiers)        │        │
│  │ • persona_memories                           │        │
│  │ • persona_reflections                        │        │
│  │ • persona_plans                              │        │
│  │ • persona_actions                            │        │
│  └──────────────────────────────────────────────┘        │
│                                                            │
│  ┌──────────────────────────────────────────────┐        │
│  │         Scenario & Intent Framework          │        │
│  ├──────────────────────────────────────────────┤        │
│  │ • scenarios                                  │        │
│  │ • scenario_intents                           │        │
│  │ • scenario_intent_personas                   │        │
│  │ • scenario_personas                          │        │
│  │ • scenario_threats                           │        │
│  │ • scenario_scores                            │        │
│  │ • scenario_test_types                        │        │
│  └──────────────────────────────────────────────┘        │
│                                                            │
│  ┌──────────────────────────────────────────────┐        │
│  │         Prompt Generation                    │        │
│  ├──────────────────────────────────────────────┤        │
│  │ • prompt_generator_responses                 │        │
│  │ • prompt_response_metadata                   │        │
│  └──────────────────────────────────────────────┘        │
│                                                            │
│  ┌──────────────────────────────────────────────┐        │
│  │    Cat-Astrophic Prompt Generation Hub       │        │
│  ├──────────────────────────────────────────────┤        │
│  │ • generation_runs (batch sessions)           │        │
│  │ • conversations (prompt-level metadata)      │        │
│  │ • turns (individual exchanges)               │        │
│  │ • quality_metrics (assessment data)          │        │
│  │ • telemetry (aggregated metrics)             │        │
│  │ • llm_invocations (API audit trail)          │        │
│  └──────────────────────────────────────────────┘        │
│                                                            │
│  ALL tables include: product_id → ai-range                │
└────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────┐
│                    CLIENT SUBSCRIPTIONS                     │
│            (Subscribe to AI-Range for everything)          │
└────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────┐
│                      CLIENT MODELS                         │
│              (Models tested with AI-Range)                 │
└────────────────────────────────────────────────────────────┘
```

---

## AI-Range Core Agents (7 Agents)

AI-Range is powered by 7 specialized agents that work in concert to orchestrate all testing operations:

| Agent | Type | Model | Purpose |
|-------|------|-------|---------|
| **Cat-Astrophic Prompt Agent** | Generator | Claude-3.5-Sonnet | Generates adversarial prompts and attack scenarios |
| **Evaluation Agent** | Evaluator | GPT-4-Turbo | Evaluates responses and safety outcomes |
| **Scenario Agent** | Generator | Claude-3-Opus | Creates realistic test scenarios and contexts |
| **Persona Agent** | Generator | GPT-4 | Generates personas with behavioral patterns |
| **Test Agent** | Classifier | BERT-Large | Orchestrates test execution and management |
| **Analysis Agent** | Evaluator | Claude-3-Sonnet | Analyzes results and generates reports |
| **Commander Agent** | Orchestration | GPT-4-Turbo | Master coordinator of all agents and workflows |

### Agent Workflow

```
        ┌─────────────────────┐
        │  Commander Agent    │ (Master Orchestrator)
        │  (GPS-4-Turbo)      │
        └──────────┬──────────┘
                   │
        ┌──────────┴──────────┬──────────────┬────────────┐
        │                     │              │            │
        ▼                     ▼              ▼            ▼
   ┌──────────┐         ┌──────────┐  ┌──────────┐ ┌──────────┐
   │ Cat-Astro│         │ Scenario │  │ Persona  │ │   Test   │
   │ Prompt   │         │ Agent    │  │ Agent    │ │ Agent    │
   │ Agent    │         │ (Claude) │  │ (GPT-4)  │ │ (BERT)   │
   └────┬─────┘         └────┬─────┘  └────┬─────┘ └────┬─────┘
        │                    │             │            │
        └────────┬───────────┴─────────────┴────────────┘
                 │
                 ▼
        ┌──────────────────┐
        │ Evaluation Agent │ (GPT-4-Turbo)
        │  Analysis Agent  │ (Claude-3-Sonnet)
        └──────────────────┘
```

---

## SQL Examples

### Creating a Test with Persona

```sql
-- Everything references ai-range product
INSERT INTO use_cases (product_id, name, slug)
SELECT id, 'Customer Support', 'customer-support'
FROM products WHERE product_code = 'ai-range';

INSERT INTO personas (product_id, tenant_id, use_case_id, name, persona_type)
SELECT 
    p.id,
    't-123',
    uc.id,
    'Angry Customer',
    'adversarial'
FROM products p
CROSS JOIN use_cases uc
WHERE p.product_code = 'ai-range'
  AND uc.slug = 'customer-support';

INSERT INTO scenarios (product_id, tenant_id, persona_id, title)
SELECT 
    p.id,
    't-123',
    per.id,
    'Escalated Complaint'
FROM products p
CROSS JOIN personas per
WHERE p.product_code = 'ai-range'
  AND per.name = 'Angry Customer';
```

### Get All AI-Range Operations

```sql
-- All operations are AI-Range operations
SELECT 'test_execution' as type, execution_id::text as id, execution_start as ts
FROM test_executions te
JOIN products p ON te.product_id = p.id
WHERE p.product_code = 'ai-range'

UNION ALL

SELECT 'persona', id, created_at
FROM personas per
JOIN products p ON per.product_id = p.id
WHERE p.product_code = 'ai-range'

UNION ALL

SELECT 'scenario', id, created_at
FROM scenarios s
JOIN products p ON s.product_id = p.id
WHERE p.product_code = 'ai-range'

ORDER BY ts DESC;
```

## Benefits of Unified Platform

### 1. **Simplified Architecture**
- One product to subscribe to
- One product to configure
- One set of features and quotas
- Use cases provide business context across testing and personas

### 2. **Integrated Testing Hub**
- Use cases anchor both testing and persona activities
- Threat vectors integrated directly with testing framework
- Cohorts and sub_cohorts classify personas as attributes
- Single product_id tracks all operations

### 3. **Unified Analytics**
```sql
-- Single query for all AI-Range usage across Testing Hub
SELECT 
    uc.name as use_case,
    COUNT(DISTINCT te.execution_id) as test_count,
    COUNT(DISTINCT p.id) as persona_count,
    COUNT(DISTINCT s.id) as scenario_count
FROM tenants t
JOIN client_models cm ON cm.tenant_id = t.id
LEFT JOIN use_cases uc ON uc.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
LEFT JOIN test_executions te ON te.model_id = cm.model_id
LEFT JOIN personas p ON p.tenant_id = t.id::text AND p.use_case_id = uc.id
LEFT JOIN scenarios s ON s.tenant_id = t.id::text
GROUP BY uc.name;
```

### 4. **Integrated Workflows**
- Use cases provide context for both testing and personas
- Use personas in adversarial tests
- Generate scenarios from test results
- Threat vectors integrated with testing framework
- Track everything under one product_id

### 5. **Simplified Billing**
- One subscription covers all features
- Single usage tracking
- Unified quota management

## Key Architectural Changes

### 1. **Testing Hub Integration**
- Use cases moved to Testing Hub as business context layer
- Threat & Risk Framework integrated into Testing Hub
- Use cases now anchor both testing activities and persona definitions

### 2. **Persona Classification**
- Cohorts and sub_cohorts are now attributes/classifiers of personas
- They reference personas via foreign keys (not hierarchical containers)
- Enables consistent categorization across persona definitions

### 3. **Unified Product Ownership**
- All 24 functional tables now have product_id → ai-range
- Testing, personas, scenarios, and prompts unified under one product
- Simplified subscription and access control model

## Cat-Astrophic Prompt Generation System Integration

The Cat-Astrophic Prompt (PromptGoblin v2) system has been fully integrated into AI-Range with 6 new tables:

### Core Tables

| Table | Purpose |
|-------|---------|
| `generation_runs` | Batch/run-level metadata for prompt generation sessions |
| `conversations` | Conversation-level metadata (one per prompt) |
| `turns` | Individual prompt-response exchanges (core generation data) |
| `quality_metrics` | Quality assessment metrics for conversations |
| `telemetry` | Aggregated metrics per generation run |
| `llm_invocations` | LLM API invocations for auditing, analysis, and cost tracking |

### Key Features

- **Full traceability**: Every prompt and response traceable to specific generation runs and LLM calls
- **Base model tracking**: Captures underlying LLM model IDs, versions, and parameters
- **Quality assessment**: Metrics for fit, diversity, policy risk, and length scoring
- **Aggregated telemetry**: Run-level statistics including token counts, latency, success rates
- **Audit trail**: Complete API invocation history for compliance and debugging
- **Pipeline metadata**: Captures agentic pipeline execution traces and strategy selection
- **Human-in-the-loop support**: Tracks human validation stages and feedback

### Integration Example

```sql
-- All Cat-Astrophic data is tracked under AI-Range product
INSERT INTO generation_runs (product_id, generation_run_id, modality, status)
SELECT p.id, gen_random_uuid(), 'text', 'in_progress'
FROM products WHERE product_code = 'ai-range';

-- Link conversations to generation runs
INSERT INTO conversations (product_id, generation_run_id, conversation_id, ai_range_enabled)
SELECT p.id, gr.id, 'conv-123', TRUE
FROM generation_runs gr
JOIN products p ON gr.product_id = p.id
WHERE p.product_code = 'ai-range';

-- Track individual turns with base model information
INSERT INTO turns (product_id, conversation_id, turn_id, model, base_model_id, base_model_name)
SELECT p.id, c.id, 'turn-1', 'agentic-pipeline-v1', 
       'anthropic.claude-3-5-sonnet-20241022-v2:0', 'claude-3-5-sonnet'
FROM conversations c
JOIN products p ON c.product_id = p.id
WHERE p.product_code = 'ai-range';

-- Record LLM API invocations for audit trail
INSERT INTO llm_invocations (product_id, invocation_id, model_id, status, prompt_tokens, completion_tokens)
SELECT p.id, gen_random_uuid(), 'anthropic.claude-3-5-sonnet-20241022-v2:0', 'success', 150, 250
FROM products p WHERE p.product_code = 'ai-range';
```

## Database Changes Summary

### Schema Updates
- Added `product_id` to 24 tables total
- Added 6 new Cat-Astrophic tables with comprehensive indexing
- Added indexes on all new `product_id` columns
- Added foreign key constraints with ON DELETE RESTRICT
- All core functional tables now link to AI-Range

### Documentation Updates
- ✅ README.md - Updated product architecture
- ✅ ER_DIAGRAM_INTEGRATED.md - Reorganized with integrated Testing Hub
- ✅ PRODUCT_LAYER_ARCHITECTURE.md - Consolidated features
- ✅ PRODUCT_OWNERSHIP.md - Updated ownership model
- ✅ AI_RANGE_UNIFIED_ARCHITECTURE.md - Updated architecture diagrams

## Migration Notes

If you have existing persona/scenario data:

```sql
-- Add product_id to use_cases
ALTER TABLE use_cases ADD COLUMN product_id UUID;
UPDATE use_cases SET product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
ALTER TABLE use_cases ALTER COLUMN product_id SET NOT NULL;
CREATE INDEX idx_use_cases_product ON use_cases(product_id);
ALTER TABLE personas ADD COLUMN product_id UUID;
UPDATE personas SET product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
ALTER TABLE personas ALTER COLUMN product_id SET NOT NULL;
CREATE INDEX idx_personas_product ON personas(product_id);

-- Add product_id to scenarios
ALTER TABLE scenarios ADD COLUMN product_id UUID;
UPDATE scenarios SET product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
ALTER TABLE scenarios ALTER COLUMN product_id SET NOT NULL;
CREATE INDEX idx_scenarios_product ON scenarios(product_id);
```

## Nexus Product Status

**Current Status**: Active (prompt ingestion + library)

**Assigned Tables**:
- `client_prompt_submissions`
- `nexus_prompt_library`
- `vw_nexus_stage4_prompt_candidates` (view)

**Sources**:
- Completed, successful Stage 4 Cat-Astrophic prompts
- Client-provided prompt submissions

## Key Takeaways

1. ✅ **AI-Range is the unified platform** - owns all testing, safety, persona, and scenario tables
2. ✅ **12 tables now have product_id** - all link to ai-range product
3. ✅ **Simpler subscription model** - clients subscribe to AI-Range for everything
4. ✅ **Nexus is active** - prompt ingestion and library integration
5. ✅ **Complete documentation** - all docs updated to reflect unified architecture

## Files to Review

1. [schema_integrated.sql](sql/schemas/schema_integrated.sql) - See all product_id columns
2. [PRODUCT_OWNERSHIP.md](docs/PRODUCT_OWNERSHIP.md) - Understand ownership model
3. [README.md](README.md) - Updated product architecture
4. [PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md) - Complete feature list

---

**Bottom Line**: AI-Range is now a comprehensive, unified platform for all AI testing, safety assessment, and persona-based analysis. Every operation traces back to the ai-range product via product_id.

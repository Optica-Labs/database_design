# Database Documentation - Master Reference

Complete consolidated documentation for the integrated adversarial AI safety and persona testing database.

**Version**: 2.0 (Integrated)  
**Platform**: PostgreSQL 14+  
**Status**: Production Ready

---

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Architecture Overview](#architecture-overview)
3. [Table Directory](#table-directory)
4. [Integration Summary](#integration-summary)
5. [Common Workflows](#common-workflows)
6. [Query Patterns](#query-patterns)
7. [Deployment Guide](#deployment-guide)
8. [Performance & Optimization](#performance--optimization)
9. [Security & Compliance](#security--compliance)
10. [Troubleshooting](#troubleshooting)

---

## Quick Reference

### Core Concepts

| Concept | Description | Location |
|---------|-------------|----------|
| **Tenant** | Client organization (isolation boundary) | `tenants` table |
| **Product** | AI-Range or Nexus product definition | `products` table |
| **Model** | Client AI model under test | `client_models` table |
| **Persona** | Simulated user for testing | `personas` table |
| **Scenario** | Test scenario with personas | `scenarios` table |
| **Test Case** | Adversarial prompt | `adversarial_test_cases` |
| **Test Execution** | Result of running a test | `test_executions` table |
| **Threat Vector** | Attack pattern/vulnerability | `threat_vectors` table |
| **Generation Run** | Batch prompt generation session | `generation_runs` table |

### File Quick Links

| File | Purpose | Read Time |
|------|---------|-----------|
| [README.md](README.md) | Main overview | 5 min |
| [docs/INDEX.md](docs/INDEX.md) | File guide | 5 min |
| [docs/PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md) | Product architecture | 10 min |
| [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) | Design decisions | 15 min |
| [docs/ER_DIAGRAM_INTEGRATED.md](docs/ER_DIAGRAM_INTEGRATED.md) | Visual schema | 10 min |
| [docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md) | Prompt generation | 10 min |
| [sql/schemas/schema_integrated.sql](sql/schemas/schema_integrated.sql) | Full DDL | Reference |
| [sql/queries/queries.sql](sql/queries/queries.sql) | Query examples | 20 min |

### Extension Requirements

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "vector";         -- Vector search (pgvector)
```

---

## Architecture Overview

### Two-Tier System

```
Layer 1: TENANTS (Client Organizations)
         ↓
Layer 2: MODELS (AI Models Under Test)
```

### AI-Range Platform (Unified)

All operational tables include `product_id` linking to AI-Range:

**Category** | **Table Groups** | **Count**
---|---|---
Testing | test_*, adversarial_test_* | 8 tables
Personas | personas*, trait* | 15 tables
Scenarios | scenarios*, intents | 8 tables
Safety | safety_*, compliance_* | 5 tables
Threats & Risk | threat_*, risks, harms | 5 tables
Prompts | generation_*, conversations, turns, quality_* | 6 tables
Results | model_outputs, test_results | 3 tables
Infrastructure | audit_logs, llm_invocations | 2 tables

### Multi-Tenancy Architecture

```
tenants (isolation boundary)
├── client_models (models for tenant)
├── personas (personas for tenant)
├── scenarios (scenarios for tenant)
└── test_sessions (testing for tenant)
```

---

## Table Directory

### Core Infrastructure Tables

#### `tenants`
**Purpose**: Client organization management  
**Key Fields**:
- `id` (UUID, PK) - Tenant identifier
- `tenant_name` (varchar) - Organization name
- `client_id` (varchar) - Legacy client identifier
- `industry` (varchar) - Industry classification
- `status` (varchar) - active, inactive, suspended
- `metadata` (jsonb) - Custom tenant data

**Common Queries**:
```sql
-- Get all active tenants
SELECT * FROM tenants WHERE status = 'active';

-- Get tenant with models
SELECT t.*, COUNT(cm.model_id) as model_count
FROM tenants t
LEFT JOIN client_models cm ON t.id = cm.tenant_id
GROUP BY t.id;
```

#### `products`
**Purpose**: Product definition with versioning  
**Key Fields**:
- `id` (UUID, PK) - Product ID
- `product_code` (varchar) - 'ai-range', 'nexus'
- `product_name` (varchar) - Display name
- `description` (text) - Product description
- `version` (varchar) - Product version (e.g., '2.0', '1.5.1')
- `created_at` (timestamp) - Product creation timestamp
- `updated_at` (timestamp) - Last update timestamp
- `status` (varchar) - active, inactive, retired

**Current Products**:
- `ai-range` - Unified testing and persona platform
- `nexus` - Advanced persona testing and risk analysis

#### `product_usage`
**Purpose**: Track every use of a product by a tenant (audit and billing trail)  
**Key Fields**:
- `id` (BIGSERIAL, PK) - Usage record ID
- `product_id` (UUID, FK) - Product used (ai-range-UUID or nexus-UUID)
- `tenant_id` (UUID, FK) - Tenant that used the product
- `usage_type` (varchar) - Type of usage (test_execution, persona_creation, scenario_run, prompt_generation, safety_assessment, compliance_report, etc.)
- `usage_metadata` (jsonb) - Additional context (test_id, persona_id, execution_time, result_summary, etc.)
- `created_at` (timestamp) - When usage occurred

**Use Cases**:
- Usage analytics and reporting
- Billing and metering
- Feature usage tracking
- Compliance auditing
- Product adoption analysis

**Common Queries**:
```sql
-- Get usage summary by type for a tenant
SELECT usage_type, COUNT(*) as count
FROM product_usage
WHERE tenant_id = $1 AND product_id = $2
GROUP BY usage_type;

-- Get daily usage trend
SELECT DATE(created_at) as date, COUNT(*) as usage_count
FROM product_usage
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Testing & Safety Tables

#### `test_sessions`
**Purpose**: Testing session management  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `tenant_id` (FK) - Owning tenant
- `product_id` (FK) - AI-Range
- `session_id` (varchar) - Unique identifier
- `customer_id` (varchar) - Customer reference
- `status` (varchar) - active, completed, failed
- `test_count` (int) - Number of tests in session

**Common Queries**:
```sql
-- Get active sessions for tenant
SELECT * FROM test_sessions 
WHERE tenant_id = $1 AND status = 'active';

-- Get session with test statistics
SELECT ts.*, COUNT(te.id) as test_count
FROM test_sessions ts
LEFT JOIN test_executions te ON ts.id = te.session_id
WHERE ts.id = $1
GROUP BY ts.id;
```

#### `test_executions`
**Purpose**: Individual test execution records  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `model_id` (int, FK) - Model tested
- `test_case_id` (int, FK) - Test case used
- `session_id` (BIGINT, FK) - Test session
- `executing_agent_id` (int, FK) - AI agent running test
- `status` (varchar) - completed, failed, pending
- `execution_start/end` (timestamp)
- `response_time_ms` (float)
- `result_summary` (jsonb)

**Common Queries**:
```sql
-- Get test results for model in time period
SELECT te.*, cm.model_name, atc.prompt
FROM test_executions te
JOIN client_models cm ON te.model_id = cm.model_id
JOIN adversarial_test_cases atc ON te.test_case_id = atc.id
WHERE cm.model_id = $1 
  AND te.execution_start >= NOW() - INTERVAL '30 days';

-- Get failures by test case
SELECT atc.id, atc.prompt, COUNT(*) as failure_count
FROM test_executions te
JOIN adversarial_test_cases atc ON te.test_case_id = atc.id
WHERE te.status = 'failed'
GROUP BY atc.id
ORDER BY failure_count DESC;
```

#### `safety_assessments`
**Purpose**: Safety evaluation records  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `test_execution_id` (FK) - Associated test
- `assessing_agent_id` (int, FK) - Evaluating agent
- `safety_score` (float, 0-100)
- `risk_level` (varchar) - low, medium, high, critical
- `categories_evaluated` (jsonb) - Array of safety categories
- `detailed_assessment` (jsonb) - Findings and details

**Safety Categories**:
- toxicity - Harmful/offensive content
- bias - Discriminatory responses
- jailbreak - Circumvention attempts
- injection - Prompt injection attacks
- privacy - Data leakage
- compliance - Regulatory violations

### Persona System Tables

#### `personas`
**Purpose**: Unified persona definitions  
**Key Fields**:
- `id` (UUID, PK)
- `tenant_id` (FK) - Owning tenant
- `product_id` (FK) - AI-Range
- `session_id` (BIGINT, FK) - Test session (optional)
- `name` (varchar) - Internal name
- `display_name` (varchar) - Display name
- `persona_type` (varchar) - regular, adversarial, internal
- `overview` (text) - Description
- `bio` (text) - Background
- `quote` (text) - Characteristic quote
- `language` (varchar) - Primary language
- `is_ai` (boolean)
- `status` (varchar) - active, inactive

**Persona Types**:
- **regular**: Standard user personas
- **adversarial**: Attack-focused personas
- **internal**: Internal testing personas

#### Trait Tables (5 types)
**Purpose**: Flexible persona characteristics

**Structure**:
- `persona_*_traits` - Junction table
- `*_traits_catalog` - Trait definitions

**Types**:
1. `demographic_traits` - Age, gender, location, education
2. `behavioral_traits` - Risk tolerance, tech savviness
3. `psychographic_traits` - Values, motivations, beliefs
4. `technographic_traits` - Device types, platforms
5. `linguistic_traits` - Language patterns, dialect

**Example - Trait Assignment**:
```sql
-- Add demographic trait to persona
INSERT INTO persona_demographics (persona_id, trait_id, raw_value, value)
SELECT 'persona-001', id, '30-35', '{"min": 30, "max": 35}'::jsonb
FROM demographic_traits_catalog 
WHERE key = 'age_range' AND persona_type = 'regular';
```

#### `persona_memories`
**Purpose**: Episodic memory for personas  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `persona_id` (FK) - Associated persona
- `memory_type` (varchar) - episodic, semantic
- `content` (text) - Memory content
- `created_at` (timestamp)

#### `persona_reflections`
**Purpose**: Higher-order reasoning about experiences  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `persona_id` (FK)
- `reflection_type` (varchar) - insight, pattern, concern
- `content` (text)

#### `persona_plans`
**Purpose**: Goal-oriented behavior planning  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `persona_id` (FK)
- `plan_description` (text)
- `intended_outcome` (text)
- `confidence_level` (float, 0-1)

#### `persona_actions`
**Purpose**: Interaction history  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `persona_id` (FK)
- `action_type` (varchar)
- `description` (text)
- `context` (jsonb)
- `timestamp` (timestamp)

### Scenario Tables

#### `scenarios`
**Purpose**: Test scenario definitions  
**Key Fields**:
- `id` (UUID, PK)
- `tenant_id` (FK)
- `product_id` (FK) - AI-Range
- `session_id` (BIGINT, FK) - Test session
- `persona_id` (FK, optional) - Associated persona
- `title` (varchar) - Scenario title
- `description` (text)
- `severity` (varchar) - low, medium, high, critical
- `status` (varchar) - active, completed
- `risk_vectors` (text[]) - Associated risk vectors
- `harm_categories` (text[]) - Associated harms
- `metadata` (jsonb)

#### `scenario_intents`
**Purpose**: Intent breakdown within scenarios  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `scenario_id` (FK)
- `product_id` (FK)
- `intent_id` (FK)
- `intent_description` (text)
- `intent_order` (int)
- `importance_score` (float)

#### `scenario_personas`
**Purpose**: Persona-scenario relationships  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `scenario_id` (FK)
- `persona_id` (FK)
- `product_id` (FK)
- `relevance_score` (float, 0-1)
- `notes` (text)

### Threat & Risk Tables

#### `threat_vectors`
**Purpose**: Threat categorization framework  
**Key Fields**:
- `id` (UUID, PK)
- `name` (varchar) - Threat name
- `description` (text)
- `category` (varchar) - jailbreak, injection, poison, etc.
- `severity` (varchar) - low, medium, high, critical
- `detection_methods` (jsonb)
- `mitigations` (jsonb)

**Common Threat Categories**:
- `jailbreak` - Circumvention attempts
- `injection` - Prompt/code injection
- `poison` - Training data poisoning
- `privacy` - Data leakage
- `bias` - Discriminatory behavior
- `compliance` - Regulatory violations

#### `threat_examples`
**Purpose**: Specific threat examples  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `threat_vector_id` (FK)
- `example_prompt` (text) - Example attack
- `expected_behavior` (text)
- `actual_behavior` (text)
- `mitigation` (text)

#### `risks`
**Purpose**: Risk definitions  
**Key Fields**:
- `id` (UUID, PK)
- `risk_name` (varchar)
- `risk_level` (varchar)
- `description` (text)
- `affected_domains` (text[])

#### `harms`
**Purpose**: Harm category definitions  
**Key Fields**:
- `id` (UUID, PK)
- `harm_category` (varchar)
- `description` (text)
- `harm_level` (varchar)

### Prompt Generation Tables (PromptGoblin v2)

#### `generation_runs`
**Purpose**: Batch prompt generation sessions  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `product_id` (FK) - AI-Range
- `generation_run_id` (UUID) - Tracking ID
- `modality` (varchar) - text, image, audio
- `tags` (jsonb) - Categorization
- `plan_metadata` (jsonb) - Pipeline metadata
- `coverage_map` (jsonb) - Strategy×topic coverage
- `status` (varchar) - in_progress, completed, failed
- `created_at` (timestamp)

#### `conversations`
**Purpose**: Conversation-level metadata  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `generation_run_id` (FK)
- `product_id` (FK)
- `conversation_id` (varchar)
- `industry` (jsonb)
- `model_version` (varchar)
- `ai_range_enabled` (boolean)
- `ai_range_model_name` (varchar)
- `human_in_loop` (boolean)
- `quality_methodology` (varchar)
- `diversity_score` (float, 0-1)
- `created_at` (timestamp)

#### `turns`
**Purpose**: Individual prompt-response exchanges  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `conversation_id` (FK)
- `product_id` (FK)
- `turn_id` (varchar)
- `stage` (int) - Pipeline stage
- `role` (varchar) - user, assistant, system
- `prompt` (text)
- `response` (text)
- `prompt_tokens` (int)
- `response_tokens` (int)
- `latency_ms` (float)
- `status` (varchar) - completed, failed

#### `quality_metrics`
**Purpose**: Quality assessment scores  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `conversation_id` (FK)
- `product_id` (FK)
- Metric columns for various quality dimensions

#### `llm_invocations`
**Purpose**: LLM API call auditing  
**Key Fields**:
- `id` (BIGSERIAL, PK)
- `product_id` (FK)
- `model_name` (varchar)
- `tokens_used` (int)
- `cost_estimate` (decimal)
- `latency_ms` (float)
- `status` (varchar)
- `timestamp` (timestamp)

---

## Integration Summary

### What Was Integrated

| System | Source | Tables | Status |
|--------|--------|--------|--------|
| **Adversarial AI Safety** | SQL Server | 11 core + extensions | ✅ Integrated |
| **AI Persona Testing** | PostgreSQL | 50+ tables | ✅ Integrated |
| **Cat-Astrophic Prompts** | PromptGoblin v2 | 6 tables | ✅ Integrated |
| **Multi-Tenancy** | NEW | 3 tables | ✅ Added |

### Key Integration Points

1. **Unified Persona System**
   - Merged `ai_personas` + `personas` → single `personas` table
   - Added `persona_type` field (regular, adversarial, internal)
   - Retained all original fields from both systems

2. **Test Execution Framework**
   - Unified via `test_sessions` table
   - Kept separate execution records for different test types
   - Cross-references enable holistic analysis

3. **Scenario System**
   - Merged scenario definitions
   - Added comprehensive intent mapping
   - Linked personas, threats, and test types

4. **Multi-Tenancy**
   - Added `tenants` table as isolation boundary
   - All operational tables include `tenant_id`
   - Product subscriptions manage access

5. **Cat-Astrophic Integration**
   - Full PromptGoblin v2 table structure
   - Generation runs → conversations → turns hierarchy
   - Quality metrics and LLM invocation tracking

---

## AI-Range Core Agents

AI-Range is powered by 7 specialized agents that orchestrate all testing, evaluation, and analysis operations:

### 1. **Cat-Astrophic Prompt Agent** (Generator)
- **Model**: Claude-3.5-Sonnet
- **Version**: 2.0.0
- **Purpose**: Generates adversarial prompts and attack scenarios for comprehensive AI testing
- **Capabilities**: 
  - Prompt generation and crafting
  - Jailbreak scenario creation
  - Attack pattern synthesis
  - Comprehensive scenario design

### 2. **Evaluation Agent** (Evaluator)
- **Model**: GPT-4-Turbo
- **Version**: 1.5.0
- **Purpose**: Evaluates model responses and safety outcomes from test executions
- **Capabilities**:
  - Response evaluation and scoring
  - Safety assessment
  - Harm detection
  - Bias analysis

### 3. **Scenario Agent** (Generator)
- **Model**: Claude-3-Opus
- **Version**: 1.0.0
- **Purpose**: Creates realistic test scenarios and contextual environments for persona-based testing
- **Capabilities**:
  - Scenario generation and design
  - Context creation
  - Environment setup
  - Complexity scaling

### 4. **Persona Agent** (Generator)
- **Model**: GPT-4
- **Version**: 1.2.0
- **Purpose**: Generates and manages AI personas with realistic behavioral patterns and psychological profiles
- **Capabilities**:
  - Persona creation and management
  - Behavior generation
  - Memory management
  - Trait synthesis

### 5. **Test Agent** (Classifier)
- **Model**: BERT-Large
- **Version**: 1.0.0
- **Purpose**: Orchestrates test case execution, management, and result collection
- **Capabilities**:
  - Test execution and orchestration
  - Test case management
  - Result collection and tracking
  - Test coordination

### 6. **Analysis Agent** (Evaluator)
- **Model**: Claude-3-Sonnet
- **Version**: 1.1.0
- **Purpose**: Analyzes test results, generates insights, and produces compliance reports
- **Capabilities**:
  - Result analysis and interpretation
  - Pattern recognition
  - Compliance reporting
  - Insight generation
  - Trend analysis

### 7. **Commander Agent** (Orchestration / Monitor)
- **Model**: GPT-4-Turbo
- **Version**: 2.0.0
- **Purpose**: Master orchestration agent that coordinates all other agents and manages test workflows
- **Capabilities**:
  - Workflow orchestration
  - Agent coordination
  - State management
  - Task distribution
  - Error handling
  - Pipeline management

---

## Common Workflows

### Workflow 1: New Client Onboarding

```sql
-- Step 1: Create tenant
INSERT INTO tenants (tenant_name, client_id, industry, status)
VALUES ('Acme Corp', 'acme-001', 'Technology', 'active');

-- Step 2: Register client model
INSERT INTO client_models 
  (tenant_id, client_id, model_name, model_version, model_type, endpoint_url)
SELECT id, 'acme-001', 'ChatBot-v1', '1.0.0', 'llm', 
       'https://api.acme.com/chat'
FROM tenants WHERE client_id = 'acme-001';

-- Step 3: Tenant is now ready to use AI-Range
SELECT * FROM client_models WHERE tenant_id = (SELECT id FROM tenants WHERE client_id = 'acme-001');
```

### Workflow 2: Create and Run Adversarial Test

```sql
-- Step 1: Create test session
INSERT INTO test_sessions 
  (tenant_id, product_id, session_id, customer_id, session_name, status)
VALUES ($1, $2, 'session-2024-001', 'cust-123', 'Q1 Safety Tests', 'active');

-- Step 2: Execute test
INSERT INTO test_executions 
  (model_id, test_case_id, session_id, executing_agent_id, status, execution_start)
VALUES ($1, $2, $3, $4, 'running', NOW());

-- Step 3: Capture model output
INSERT INTO model_outputs 
  (test_execution_id, model_id, output_text, tokens_used, latency_ms)
VALUES (LASTVAL(), $1, $5, $6, $7);

-- Step 4: Run safety assessment
INSERT INTO safety_assessments 
  (test_execution_id, assessing_agent_id, safety_score, risk_level)
VALUES (LASTVAL(), $4, $8, $9);
```

### Workflow 3: Create Persona-Based Scenario

```sql
-- Step 1: Create persona
INSERT INTO personas 
  (tenant_id, product_id, name, display_name, persona_type, bio, status)
VALUES ($1, $2, 'sarah-tech', 'Sarah Chen', 'regular', 
        'Tech-savvy professional...', 'active');

-- Step 2: Add traits
INSERT INTO persona_demographics (persona_id, trait_id, value)
SELECT $3, id, '{"min": 30, "max": 35}'::jsonb
FROM demographic_traits_catalog WHERE key = 'age_range';

-- Step 3: Create scenario
INSERT INTO scenarios 
  (tenant_id, product_id, session_id, persona_id, title, description, severity)
VALUES ($1, $2, $4, $3, 'Social Engineering', 'Test manipulation tactics', 'high');

-- Step 4: Link to threats
INSERT INTO scenario_threats (scenario_id, threat_vector_id, relevance_score)
SELECT $5, id, 0.9
FROM threat_vectors WHERE category = 'jailbreak';

-- Step 5: Link to intents
INSERT INTO scenario_intents (scenario_id, intent_id, importance_score)
SELECT $5, id, 0.8
FROM intents WHERE type = 'manipulation';
```

### Workflow 4: Generate Batch Prompts

```sql
-- Step 1: Start generation run
INSERT INTO generation_runs 
  (product_id, generation_run_id, modality, tags, status)
VALUES ($1, gen_random_uuid(), 'text', 
        '["adversarial", "jailbreak"]'::jsonb, 'in_progress');

-- Step 2: Create conversations (per prompt)
INSERT INTO conversations 
  (generation_run_id, product_id, conversation_id, model_version, quality_methodology)
VALUES (LASTVAL(), $1, 'conv-001', 'v2.1', 'automatic');

-- Step 3: Add turns (prompt-response pairs)
INSERT INTO turns 
  (conversation_id, product_id, turn_id, stage, role, prompt, response)
VALUES (LASTVAL(), $1, 'turn-1', 1, 'user', $2, $3);

-- Step 4: Record quality metrics
INSERT INTO quality_metrics (conversation_id, product_id, ...)
VALUES (LASTVAL(), $1, ...);

-- Step 5: Mark complete
UPDATE generation_runs SET status = 'completed' WHERE id = ...;
```

### Workflow 5: Generate Safety Reports

```sql
-- Get safety summary per model
SELECT 
  cm.model_name,
  COUNT(DISTINCT te.id) as total_tests,
  SUM(CASE WHEN sa.risk_level = 'critical' THEN 1 ELSE 0 END) as critical_count,
  ROUND(AVG(sa.safety_score), 2) as avg_safety_score,
  MAX(te.execution_end)::date as last_tested
FROM client_models cm
JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN safety_assessments sa ON te.id = sa.test_execution_id
WHERE cm.tenant_id = $1 
  AND te.execution_start >= NOW() - INTERVAL '30 days'
GROUP BY cm.model_id, cm.model_name
ORDER BY avg_safety_score ASC;
```

---

## Query Patterns

### Pattern 1: Multi-Tenant Data Isolation

```sql
-- Always include tenant_id filter
SELECT * FROM personas 
WHERE tenant_id = $1 AND status = 'active';

-- With joins
SELECT p.*, s.title
FROM personas p
JOIN scenarios s ON p.id = s.persona_id
WHERE p.tenant_id = $1;
```

### Pattern 2: Time-Based Analysis

```sql
-- Recent test results
SELECT *
FROM test_executions
WHERE execution_start >= NOW() - INTERVAL '7 days'
  AND tenant_id = $1;

-- Trend analysis
SELECT DATE(execution_start) as date,
       COUNT(*) as test_count,
       AVG(CASE WHEN status = 'passed' THEN 1 ELSE 0 END) as pass_rate
FROM test_executions
WHERE tenant_id = $1
GROUP BY DATE(execution_start)
ORDER BY date DESC;
```

### Pattern 3: Aggregations with JSONB

```sql
-- Extract from JSONB fields
SELECT id, 
       result_summary->>'verdict' as verdict,
       (result_summary->'metrics'->>'toxicity')::float as toxicity
FROM test_executions
WHERE result_summary @> '{"status": "completed"}';

-- Aggregate JSONB arrays
SELECT scenario_id,
       jsonb_agg(DISTINCT harm_category) as all_harms
FROM (
  SELECT scenario_id, jsonb_array_elements(harm_categories)::text as harm_category
  FROM scenarios
) t
GROUP BY scenario_id;
```

### Pattern 4: Persona-Scenario Matching

```sql
-- Find personas relevant to scenarios with threats
SELECT DISTINCT
  p.id, p.display_name,
  s.id, s.title,
  sp.relevance_score,
  string_agg(DISTINCT tv.name, ', ') as threats
FROM personas p
JOIN scenario_personas sp ON p.id = sp.persona_id
JOIN scenarios s ON sp.scenario_id = s.id
JOIN scenario_threats st ON s.id = st.scenario_id
JOIN threat_vectors tv ON st.threat_vector_id = tv.id
WHERE p.tenant_id = $1
  AND s.severity IN ('high', 'critical')
GROUP BY p.id, s.id
ORDER BY sp.relevance_score DESC;
```

### Pattern 5: Safety Metrics Over Time

```sql
-- Safety score trend by threat category
WITH category_scores AS (
  SELECT DATE(te.execution_start) as test_date,
         jsonb_array_elements(sa.categories_evaluated)::text as category,
         AVG(sa.safety_score) as avg_score
  FROM test_executions te
  JOIN safety_assessments sa ON te.id = sa.test_execution_id
  WHERE te.tenant_id = $1
    AND te.execution_start >= NOW() - INTERVAL '90 days'
  GROUP BY test_date, category
)
SELECT * FROM category_scores
ORDER BY test_date DESC, category;
```

---

## Deployment Guide

### Prerequisites

```bash
# PostgreSQL 14+ installation
psql --version

# Required extensions
psql -d your_database -c "CREATE EXTENSION IF NOT EXISTS uuid-ossp;"
psql -d your_database -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### Initial Setup

```bash
# 1. Create database
createdb ai_safety_integrated

# 2. Deploy schema
psql -d ai_safety_integrated -f sql/schemas/schema_integrated.sql

# 3. Verify installation
psql -d ai_safety_integrated -c "\dt"

# 4. Load sample data (optional)
psql -d ai_safety_integrated -f sql/sample_data/sample_data.sql

# 5. Test views
psql -d ai_safety_integrated << EOF
SELECT COUNT(*) as persona_count FROM vw_persona_with_traits;
SELECT COUNT(*) as assessment_count FROM vw_latest_model_assessments;
SELECT COUNT(*) as alert_count FROM vw_active_alerts;
EOF
```

### Data Migration

```bash
# Edit migration script with source database info
vim sql/migrations/migration_script.sql

# Run migration
psql -d ai_safety_integrated -f sql/migrations/migration_script.sql

# Verify data integrity
psql -d ai_safety_integrated -f sql/migrations/verify_migration.sql
```

### Configuration

**PostgreSQL Configuration** (`postgresql.conf`):
```ini
# Connection settings
max_connections = 200
shared_buffers = 4GB
effective_cache_size = 12GB

# Memory settings
work_mem = 64MB
maintenance_work_mem = 1GB

# Performance tuning
effective_io_concurrency = 200
random_page_cost = 1.1

# Logging
log_min_duration_statement = 1000  # Log queries > 1s
```

### Enable Row-Level Security (Optional)

```sql
-- Enable RLS on tenant-scoped tables
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_sessions ENABLE ROW LEVEL SECURITY;

-- Create isolation policies
CREATE POLICY tenant_isolation ON personas
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

CREATE POLICY tenant_isolation ON scenarios
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

---

## Performance & Optimization

### Index Strategy

The schema includes 50+ indexes optimized for:
- **Foreign key traversal** - Standard FK indexes
- **Common filters** - Status, tenant_id, product_id
- **Complex queries** - Composite indexes on join patterns
- **JSONB queries** - GIN indexes on jsonb columns
- **Array queries** - GIN indexes on array columns

### Query Optimization Tips

**Use efficient JSONB queries**:
```sql
-- ✅ GOOD - Uses GIN index
WHERE metadata @> '{"status": "active"}';

-- ❌ AVOID - Can't use index
WHERE metadata::text LIKE '%active%';
```

**Leverage views for complex aggregations**:
```sql
-- ✅ GOOD - Pre-aggregated view
SELECT * FROM vw_model_safety_summary WHERE tenant_id = $1;

-- ❌ AVOID - Complex aggregation on each query
SELECT model_id, AVG(safety_score), COUNT(*) FROM ... GROUP BY ...;
```

**Use CTEs for readability**:
```sql
WITH recent_tests AS (
  SELECT * FROM test_executions 
  WHERE execution_start >= NOW() - INTERVAL '7 days'
),
critical_failures AS (
  SELECT rt.* FROM recent_tests rt
  JOIN safety_assessments sa ON rt.id = sa.test_execution_id
  WHERE sa.risk_level = 'critical'
)
SELECT * FROM critical_failures;
```

### Maintenance Tasks

**Weekly**:
```sql
-- Update table statistics
ANALYZE;

-- Clean up dead tuples
VACUUM;
```

**Monthly**:
```sql
-- Full maintenance window
VACUUM FULL;
REINDEX DATABASE ai_safety_integrated;

-- Check index bloat
SELECT schemaname, tablename, indexname, 
       pg_size_pretty(pg_relation_size(indexrelid)) as size,
       idx_scan as scans
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Monitoring

**Monitor slow queries**:
```sql
-- Enable pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC LIMIT 10;
```

**Monitor table sizes**:
```sql
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Security & Compliance

### Data Protection

**Encryption at Rest**:
```bash
# Use PostgreSQL with encrypted partitions or disk-level encryption
# See PostgreSQL documentation for SSL certificate setup
```

**Encryption in Transit**:
```bash
# Enable SSL for client connections
# Edit postgresql.conf: ssl = on
# Provide SSL certificates: server.crt, server.key
```

### Access Control

**Role-Based Access**:
```sql
-- Create tenant-specific roles
CREATE ROLE tenant_001_user WITH LOGIN PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE ON personas TO tenant_001_user;

-- Grant on specific tables
GRANT SELECT ON vw_model_safety_summary TO tenant_001_user;
```

**Row-Level Security**:
```sql
-- Enforce tenant isolation
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY tenant_policy ON personas
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

### Audit & Compliance

**Audit Trail**:
- `audit_logs` table tracks all significant operations
- Includes user, timestamp, operation, old/new values
- Never deleted; retained per compliance requirements

**Compliance Reports**:
```sql
-- Generate compliance report
SELECT 
  t.tenant_name,
  COUNT(DISTINCT cm.model_id) as models_tested,
  COUNT(DISTINCT te.id) as tests_executed,
  SUM(CASE WHEN sa.risk_level = 'critical' THEN 1 ELSE 0 END) as critical_issues,
  MAX(te.execution_end) as last_tested,
  ROUND(AVG(sa.safety_score), 2) as avg_safety_score
FROM tenants t
LEFT JOIN client_models cm ON t.id = cm.tenant_id
LEFT JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN safety_assessments sa ON te.id = sa.test_execution_id
WHERE te.execution_start >= DATE_TRUNC('quarter', NOW())
GROUP BY t.id;
```

### Data Retention

**Define retention policies**:
```sql
-- Archive old test executions (configurable)
DELETE FROM test_executions 
WHERE execution_end < NOW() - INTERVAL '2 years'
  AND archived = TRUE;

-- Keep audit logs longer
DELETE FROM audit_logs 
WHERE created_at < NOW() - INTERVAL '7 years';
```

---

## Troubleshooting

### Issue: Foreign Key Constraint Violation

**Cause**: Referencing non-existent parent record  
**Solution**:
```sql
-- Check missing references
SELECT * FROM personas WHERE product_id NOT IN (SELECT id FROM products);

-- Fix: Insert missing product or update reference
INSERT INTO products (id, product_code, product_name, status)
VALUES (gen_random_uuid(), 'ai-range', 'AI-Range', 'active');
```

### Issue: Slow Queries

**Diagnosis**:
```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT * FROM test_executions te
JOIN safety_assessments sa ON te.id = sa.test_execution_id
WHERE te.tenant_id = $1 AND te.execution_start > NOW() - INTERVAL '30 days';

-- Add missing index if needed
CREATE INDEX idx_test_exec_tenant_date ON test_executions(tenant_id, execution_start);
```

### Issue: Index Bloat

**Diagnosis**:
```sql
-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan, pg_size_pretty(pg_relation_size(indexrelid))
FROM pg_stat_user_indexes
WHERE idx_scan = 0 ORDER BY pg_relation_size(indexrelid) DESC;

-- Remove unused indexes
DROP INDEX idx_unused;

-- Reindex bloated indexes
REINDEX INDEX idx_bloated;
```

### Issue: Tenant Isolation Bypass

**Prevention**:
```sql
-- Always verify tenant_id in queries
SELECT * FROM personas 
WHERE tenant_id = current_setting('app.tenant_id')::uuid;

-- Enable RLS for safety
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_policy ON personas
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

### Issue: Missing product_id in New Tables

**Cause**: Adding table without product_id reference  
**Solution**:
```sql
-- Ensure ALL operational tables include:
product_id UUID NOT NULL REFERENCES products(id),

-- Example constraint:
ALTER TABLE new_table 
ADD CONSTRAINT fk_product_id 
FOREIGN KEY (product_id) REFERENCES products(id);
```

---

## Additional Resources

### Related Files

- **[README.md](README.md)** - Project overview
- **[docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md)** - Design decisions
- **[docs/ER_DIAGRAM_INTEGRATED.md](docs/ER_DIAGRAM_INTEGRATED.md)** - Visual diagrams
- **[docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md)** - Prompt generation details
- **[sql/queries/queries.sql](sql/queries/queries.sql)** - Query examples

### PostgreSQL Resources

- [PostgreSQL Manual](https://www.postgresql.org/docs/)
- [JSONB Documentation](https://www.postgresql.org/docs/current/datatype-json.html)
- [pgvector Documentation](https://github.com/pgvector/pgvector)

---

**Version**: 2.0 (Integrated)  
**Last Updated**: 2024  
**Maintainer**: Optica Labs  
**Status**: Production Ready

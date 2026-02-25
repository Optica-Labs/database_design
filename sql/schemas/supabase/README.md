# 🗄️ Supabase Schema Setup

Complete database schema for LLM invocation tracking with conversation and turn management.

## 📋 Setup Order

Execute these SQL files **in order** in your Supabase SQL Editor:

### 1️⃣ Core Setup
**File:** `01_extensions_and_products.sql`  
**Creates:** Extensions, products, tenants, subscriptions  
**Run:** First

### 2️⃣ Conversations & Turns
**File:** `01_conversations_and_turns.sql`  
**Creates:** 
- `generation_runs` - Batch tracking
- `conversations` - Conversation metadata
- `turns` - Individual prompt/response exchanges
- `quality_metrics` - Quality assessments
**Run:** Second

### 3️⃣ LLM Invocations
**File:** `02_llm_invocations.sql`  
**Creates:** `llm_invocations` - Comprehensive invocation tracking  
**Run:** Third

## 🔗 Table Relationships

```
products (1) ─┬─> (many) generation_runs
              ├─> (many) conversations
              ├─> (many) turns
              └─> (many) llm_invocations

generation_runs (1) ──> (many) conversations

conversations (1) ─┬─> (many) turns
                   └─> (many) llm_invocations

turns (1) ←──→ (1) llm_invocations  [BIDIRECTIONAL]
   │
   └── llm_invocation_id → llm_invocations.id
   
llm_invocations
   ├── conversation_id → conversations.id
   ├── turn_id → turns.id
   ├── scenario_id → scenarios.id
   └── agent_id → (ai_personas or agents)
```

## 🎯 Key Features

### Conversations Table
- **Purpose:** Track multi-turn conversations
- **Links to:** Generation runs, scenarios, test sessions, agents
- **Includes:** Configuration, quality metrics, metadata
- **Auto-updates:** Turn count via trigger

### Turns Table
- **Purpose:** Individual prompt-response exchanges
- **Links to:** Conversations, LLM invocations
- **Includes:** Sequential ordering, performance metrics, quality scores
- **Role types:** `assistant`, `user`, `system`

### LLM Invocations Table
- **Purpose:** Comprehensive LLM call tracking
- **Links to:** Conversations, turns, scenarios, agents, sessions
- **Tracks:**
  - Agent attribution (ID, name, type, metadata)
  - Pipeline stage (persona_generation, prompt_generation, etc.)
  - Model details (name, version, provider)
  - Performance (latency, tokens, cost)
  - Quality scores (confidence, safety, coherence)
  - Error handling (codes, messages, retries)
  - Distributed tracing (trace_id, parent links)

### Quality Metrics Table
- **Purpose:** Detailed conversation assessment
- **Includes:** Overall scores, safety assessment, bias detection, human review

## 📊 Data Flow

1. **Create generation_run** → Tracks batch
2. **Create conversation** → Links to run, scenario, agent
3. **Create turn(s)** → Prompt/response in conversation
4. **Create llm_invocation** → Detailed invocation data
5. **Link turn ↔ invocation** → Bidirectional reference
6. **Create quality_metrics** → Assessment results

## 🔍 Example Queries

### Get conversation with all turns and invocations
```sql
SELECT 
    c.conversation_id,
    c.agent_name,
    t.stage,
    t.prompt,
    t.response,
    i.pipeline_stage,
    i.latency_ms,
    i.total_tokens
FROM conversations c
LEFT JOIN turns t ON c.id = t.conversation_id
LEFT JOIN llm_invocations i ON t.id = i.turn_id
WHERE c.conversation_id = '<conversation_id>'
ORDER BY t.stage;
```

### Pipeline stage performance
```sql
SELECT 
    pipeline_stage,
    COUNT(*) AS invocations,
    AVG(latency_ms) AS avg_latency,
    AVG(total_tokens) AS avg_tokens,
    SUM(cost_usd) AS total_cost
FROM llm_invocations
WHERE product_id = '<product_id>'
  AND created_at >= NOW() - INTERVAL '7 days'
GROUP BY pipeline_stage;
```

### Agent usage statistics
```sql
SELECT 
    agent_name,
    agent_type,
    COUNT(DISTINCT conversation_id) AS conversations,
    COUNT(*) AS invocations,
    AVG(latency_ms) AS avg_latency
FROM llm_invocations
WHERE agent_id IS NOT NULL
GROUP BY agent_name, agent_type
ORDER BY conversations DESC;
```

## 🎨 Pipeline Stages

Use these values in `llm_invocations.pipeline_stage`:
- `persona_generation` - Creating AI personas
- `scenario_creation` - Generating test scenarios
- `prompt_generation` - Building prompts
- `response_evaluation` - Analyzing responses
- `safety_assessment` - Safety checks
- `report_generation` - Creating reports

## 📦 Migration Path

### From `ai_personas` → `llm_invocations`
```python
{
    'agent_id': persona.id,
    'agent_name': persona.name,
    'agent_type': 'persona',
    'agent_metadata': persona_full_json,
    'pipeline_stage': 'persona_generation'
}
```

### From `prompt_generator_responses` → `llm_invocations`
- Preserve existing `invocation_id`
- Link `conversation_id` and `turn_id` if available
- Set `pipeline_stage` appropriately

## ✅ Verification

After setup, run:
```sql
-- Check all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'generation_runs', 'conversations', 'turns', 
    'quality_metrics', 'llm_invocations'
  );

-- Check foreign keys
SELECT tc.table_name, kcu.column_name, 
       ccu.table_name AS references_table
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('conversations', 'turns', 'llm_invocations');
```

## 🚀 Ready to Migrate!

Once tables are created, use the migration scripts in `/scripts` to populate data from SOURCE database.

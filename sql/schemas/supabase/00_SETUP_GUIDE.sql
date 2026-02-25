-- ============================================================================
-- COMPLETE SUPABASE SETUP GUIDE
-- Execute these files in order to create all tables
-- ============================================================================

-- STEP 1: Core Products and Extensions
-- File: sql/schemas/supabase/01_extensions_and_products.sql
-- Creates: products, tenants, subscriptions
-- Run this first!

-- STEP 2: Conversations and Turns Tables  
-- File: sql/schemas/supabase/01_conversations_and_turns.sql
-- Creates: generation_runs, conversations, turns, quality_metrics
-- Includes automatic turn counting trigger
-- Run this second!

-- STEP 3: LLM Invocations Table
-- File: sql/schemas/supabase/02_llm_invocations.sql
-- Creates: llm_invocations
-- Links to conversations and turns for complete traceability
-- Run this third!

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check all tables exist
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'products', 'tenants', 'subscriptions',
    'generation_runs', 'conversations', 'turns', 'quality_metrics',
    'llm_invocations'
  )
ORDER BY table_name;

-- Check foreign key relationships
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name IN ('conversations', 'turns', 'llm_invocations')
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================================
-- DATA FLOW ARCHITECTURE
-- ============================================================================

/*
CONVERSATION FLOW:
1. generation_run created → tracks batch
2. conversations created → linked to run, scenario, agent
3. turns created → linked to conversation, contains prompt/response
4. llm_invocations created → detailed invocation data
5. turns.llm_invocation_id updated → links turn to invocation
6. quality_metrics created → assessment of conversation

RELATIONSHIPS:
generation_runs (1) → (many) conversations
conversations (1) → (many) turns
conversations (1) → (many) llm_invocations
turns (1) → (1) llm_invocations (via llm_invocation_id)
llm_invocations (many) → (1) conversations (via conversation_id)
llm_invocations (many) → (1) turns (via turn_id)

BIDIRECTIONAL LINKING:
- turns.llm_invocation_id → llm_invocations.id
- llm_invocations.turn_id → turns.id
- llm_invocations.conversation_id → conversations.id

This allows queries in both directions:
- From conversation → find all invocations
- From invocation → find parent conversation and turn
- From turn → find detailed invocation data
*/

-- ============================================================================
-- EXAMPLE QUERIES
-- ============================================================================

-- Get all invocations for a conversation
/*
SELECT 
    i.id,
    i.invocation_id,
    i.agent_name,
    i.pipeline_stage,
    i.model_name,
    i.status,
    i.latency_ms,
    i.total_tokens,
    t.stage AS turn_number,
    t.prompt,
    t.response
FROM llm_invocations i
LEFT JOIN turns t ON i.turn_id = t.id
WHERE i.conversation_id = <conversation_id>
ORDER BY t.stage;
*/

-- Get conversation with all turns and invocations
/*
SELECT 
    c.conversation_id,
    c.agent_name,
    c.turn_count,
    t.stage,
    t.role,
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
*/

-- Get performance metrics by pipeline stage
/*
SELECT 
    i.pipeline_stage,
    COUNT(*) AS invocation_count,
    AVG(i.latency_ms) AS avg_latency,
    AVG(i.total_tokens) AS avg_tokens,
    SUM(i.cost_usd) AS total_cost
FROM llm_invocations i
WHERE i.product_id = '<product_id>'
  AND i.created_at >= NOW() - INTERVAL '7 days'
GROUP BY i.pipeline_stage
ORDER BY invocation_count DESC;
*/

-- Get agent usage statistics
/*
SELECT 
    i.agent_name,
    i.agent_type,
    COUNT(DISTINCT i.conversation_id) AS conversation_count,
    COUNT(*) AS invocation_count,
    AVG(i.latency_ms) AS avg_latency,
    SUM(i.total_tokens) AS total_tokens
FROM llm_invocations i
WHERE i.agent_id IS NOT NULL
GROUP BY i.agent_name, i.agent_type
ORDER BY conversation_count DESC;
*/

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================

/*
When migrating data from SOURCE:

1. ai_personas → llm_invocations
   - agent_id = persona.id
   - agent_name = persona.name
   - agent_type = 'persona'
   - agent_metadata = full persona JSONB
   - pipeline_stage = 'persona_generation'

2. prompt_generator_responses → llm_invocations
   - Keep existing invocation_id
   - Link to conversation_id and turn_id if available
   - pipeline_stage = 'prompt_generation' or 'response_evaluation'

3. ai_scenarios → conversations
   - Create conversation for each scenario
   - Link to agent via agent_id
   - Set scenario_id

4. Create corresponding turns for each prompt/response pair
   - Link to conversation
   - Link to llm_invocation
   - Set stage sequentially
*/

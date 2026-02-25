-- ============================================================================
-- LLM INVOCATIONS TABLE FOR SUPABASE
-- Comprehensive tracking of all LLM invocations with agent linking and telemetry
-- ============================================================================
-- Execute this in Supabase SQL Editor
-- ============================================================================

CREATE TABLE IF NOT EXISTS llm_invocations (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invocation_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    
    -- Product & Context
    product_id UUID REFERENCES products(id),
    session_id UUID REFERENCES test_sessions(id),
    conversation_id BIGINT REFERENCES conversations(id),  -- Links to conversation
    turn_id BIGINT REFERENCES turns(id),  -- Links to specific turn
    
    -- Agent/Persona Attribution
    agent_id UUID,  -- Links to ai_personas or other agent sources
    agent_name TEXT,
    agent_type TEXT,  -- 'persona', 'test_agent', 'system', 'adversarial'
    agent_cohort TEXT,
    agent_sub_cohort TEXT,
    agent_metadata JSONB,  -- Full agent details (demographics, traits, etc.)
    
    -- Scenario & Testing Context
    scenario_id TEXT REFERENCES scenarios(id),
    test_type_id TEXT REFERENCES test_types(id),
    threat_vector_id TEXT REFERENCES threat_vectors(id),
    test_execution_id BIGINT,  -- Optional link to test_executions
    
    -- AI-Range Architecture Stage
    pipeline_stage TEXT,  -- 'persona_generation', 'scenario_creation', 'prompt_generation', 'response_evaluation', 'safety_assessment', 'report_generation'
    process_phase TEXT,   -- 'setup', 'execution', 'analysis', 'reporting'
    workflow_step TEXT,
    
    -- LLM Request Details
    model_id TEXT,
    model_name TEXT,
    model_version TEXT,
    provider TEXT,
    
    -- Prompts & Responses
    system_prompt TEXT,
    user_prompt TEXT,
    final_prompt TEXT NOT NULL,
    final_response TEXT,
    generated_text TEXT,
    raw_output JSONB,
    
    -- Request/Response Payloads
    request_payload JSONB,
    response_data JSONB,
    sanitized_response JSONB,
    
    -- Execution Status
    status TEXT DEFAULT 'pending',  -- 'pending', 'success', 'error', 'timeout', 'cancelled'
    invocation_type TEXT,  -- 'generation', 'completion', 'chat', 'embedding'
    
    -- Performance Telemetry
    latency_ms INTEGER,
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    total_tokens INTEGER,
    cost_usd DECIMAL(10, 6),
    
    -- Quality Metrics
    confidence_score DECIMAL(5, 4),
    safety_score DECIMAL(5, 4),
    coherence_score DECIMAL(5, 4),
    
    -- Error Handling
    error_code TEXT,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER,
    
    -- Caching & Optimization
    cache_hit BOOLEAN DEFAULT false,
    cached_from UUID,  -- Reference to cached invocation
    
    -- Context & Tracing
    caller_context JSONB,
    trace_id TEXT,
    parent_invocation_id UUID,
    
    -- Metadata
    tags TEXT[],
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_llm_invocations_product ON llm_invocations(product_id);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_session ON llm_invocations(session_id);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_agent ON llm_invocations(agent_id);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_scenario ON llm_invocations(scenario_id);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_stage ON llm_invocations(pipeline_stage);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_status ON llm_invocations(status);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_created ON llm_invocations(created_at);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_model ON llm_invocations(model_name);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_trace ON llm_invocations(trace_id);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_llm_invocations_agent_stage ON llm_invocations(agent_id, pipeline_stage);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_session_status ON llm_invocations(session_id, status);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_product_created ON llm_invocations(product_id, created_at);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_conversation ON llm_invocations(conversation_id);
CREATE INDEX IF NOT EXISTS idx_llm_invocations_turn ON llm_invocations(turn_id);

-- ============================================================================
-- FOREIGN KEY TO TURNS (Bidirectional Link)
-- Add this after turns table is created to enable reverse lookup
-- ============================================================================

-- Uncomment after turns table exists:
-- ALTER TABLE turns ADD COLUMN IF NOT EXISTS llm_invocation_id UUID REFERENCES llm_invocations(id);
-- CREATE INDEX IF NOT EXISTS idx_turns_llm_invocation ON turns(llm_invocation_id);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE llm_invocations IS 'Comprehensive tracking of all LLM invocations with agent attribution, telemetry, and AI-Range pipeline context';
COMMENT ON COLUMN llm_invocations.agent_id IS 'Links to the agent (persona, test agent, etc.) that triggered this invocation';
COMMENT ON COLUMN llm_invocations.pipeline_stage IS 'Stage in the AI-Range architecture: persona_generation, scenario_creation, prompt_generation, response_evaluation, safety_assessment, report_generation';
COMMENT ON COLUMN llm_invocations.agent_metadata IS 'Full agent details including demographics, traits, and configuration stored as JSONB';
COMMENT ON COLUMN llm_invocations.cost_usd IS 'Estimated cost in USD based on token usage and model pricing';
COMMENT ON COLUMN llm_invocations.trace_id IS 'Distributed tracing ID for linking related invocations across services';
COMMENT ON COLUMN llm_invocations.parent_invocation_id IS 'References parent invocation for chained/nested LLM calls';

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'llm_invocations table created successfully!' AS status;
SELECT COUNT(*) AS column_count FROM information_schema.columns WHERE table_name = 'llm_invocations';
SELECT COUNT(*) AS index_count FROM pg_indexes WHERE tablename = 'llm_invocations';

-- ============================================================================
-- CONVERSATIONS & TURNS TABLES FOR SUPABASE
-- Multi-turn conversation tracking with LLM invocation integration
-- ============================================================================
-- Execute this BEFORE creating llm_invocations table
-- ============================================================================

-- ============================================================================
-- GENERATION RUNS TABLE
-- Tracks batches of conversation generation
-- ============================================================================

CREATE TABLE IF NOT EXISTS generation_runs (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    run_name TEXT,
    run_description TEXT,
    configuration JSONB,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
    total_conversations INTEGER DEFAULT 0,
    completed_conversations INTEGER DEFAULT 0,
    failed_conversations INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_generation_runs_product ON generation_runs(product_id);
CREATE INDEX IF NOT EXISTS idx_generation_runs_status ON generation_runs(status);
CREATE INDEX IF NOT EXISTS idx_generation_runs_created ON generation_runs(created_at);

-- ============================================================================
-- CONVERSATIONS TABLE
-- Tracks conversation-level metadata and links to generation runs
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversations (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    generation_run_id BIGINT REFERENCES generation_runs(id),
    conversation_id TEXT NOT NULL UNIQUE,
    
    -- Scenario & Test Context
    scenario_id UUID REFERENCES scenarios(id),
    test_session_id UUID REFERENCES test_sessions(id),
    
    -- Agent/Persona Attribution
    agent_id UUID,  -- Links to ai_personas or similar
    agent_name TEXT,
    agent_type TEXT,
    agent_metadata JSONB,
    
    -- Configuration
    industry JSONB DEFAULT '[]'::jsonb,
    model_version TEXT DEFAULT 'unknown',
    ai_range_enabled BOOLEAN DEFAULT FALSE,
    ai_range_model_name TEXT,
    ai_range_temperature FLOAT DEFAULT 0.7,
    ai_range_category TEXT,
    ai_range_target TEXT,
    
    -- Quality & Metrics
    human_in_loop BOOLEAN DEFAULT FALSE,
    human_in_loop_stage JSONB DEFAULT '[]'::jsonb,
    human_in_loop_details TEXT DEFAULT '',
    quality_methodology TEXT DEFAULT '',
    diversity_score FLOAT,
    coverage_contribution JSONB,
    
    -- Status
    status TEXT DEFAULT 'active',
    turn_count INTEGER DEFAULT 0,
    
    -- Metadata
    tags TEXT[],
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conversations_product ON conversations(product_id);
CREATE INDEX IF NOT EXISTS idx_conversations_id ON conversations(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversations_generation_run ON conversations(generation_run_id);
CREATE INDEX IF NOT EXISTS idx_conversations_scenario ON conversations(scenario_id);
CREATE INDEX IF NOT EXISTS idx_conversations_session ON conversations(test_session_id);
CREATE INDEX IF NOT EXISTS idx_conversations_agent ON conversations(agent_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created ON conversations(created_at);

-- ============================================================================
-- TURNS TABLE
-- Stores individual prompt-response exchanges with LLM invocation links
-- ============================================================================

CREATE TABLE IF NOT EXISTS turns (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    turn_id TEXT NOT NULL UNIQUE,
    
    -- Turn Sequencing
    stage INTEGER NOT NULL,  -- Turn number within conversation (1, 2, 3, ...)
    role TEXT DEFAULT 'assistant' CHECK (role IN ('assistant', 'user', 'system')),
    
    -- Content
    prompt TEXT NOT NULL,
    response TEXT NOT NULL,
    response_preview TEXT,
    
    -- LLM Invocation Link
    llm_invocation_id UUID,  -- Will link to llm_invocations table
    
    -- Model Info
    model TEXT NOT NULL,
    model_version TEXT DEFAULT 'unknown',
    base_model_id TEXT,
    base_model_name TEXT,
    base_model_version TEXT,
    base_model_temperature FLOAT,
    
    -- Performance Metrics
    prompt_tokens INTEGER DEFAULT 0,
    response_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    latency_ms FLOAT DEFAULT 0.0,
    
    -- Status & Quality
    status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'pending', 'timeout')),
    finish_reason TEXT,
    auto_quality_score FLOAT DEFAULT 0.0,
    human_reviewed BOOLEAN DEFAULT FALSE,
    
    -- Quality Scores
    r_n FLOAT DEFAULT 0.0,  -- Relevance
    v_n FLOAT DEFAULT 0.0,  -- Validity
    a_n FLOAT DEFAULT 0.0,  -- Accuracy
    rho FLOAT DEFAULT 0.0,  -- Overall quality
    
    -- Metadata
    pipeline_metadata JSONB,
    tags TEXT[],
    metadata JSONB,
    
    -- Timestamps
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_turns_product ON turns(product_id);
CREATE INDEX IF NOT EXISTS idx_turns_id ON turns(turn_id);
CREATE INDEX IF NOT EXISTS idx_turns_conversation ON turns(conversation_id);
CREATE INDEX IF NOT EXISTS idx_turns_stage ON turns(stage);
CREATE INDEX IF NOT EXISTS idx_turns_timestamp ON turns(timestamp);
CREATE INDEX IF NOT EXISTS idx_turns_conversation_timestamp ON turns(conversation_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_turns_llm_invocation ON turns(llm_invocation_id);

-- ============================================================================
-- QUALITY METRICS TABLE
-- Stores detailed quality assessment for conversations
-- ============================================================================

CREATE TABLE IF NOT EXISTS quality_metrics (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    
    -- Overall Scores
    overall_score FLOAT,
    coherence_score FLOAT,
    relevance_score FLOAT,
    safety_score FLOAT,
    
    -- Detailed Metrics
    response_quality JSONB,
    safety_assessment JSONB,
    bias_detection JSONB,
    
    -- Human Review
    human_reviewed BOOLEAN DEFAULT FALSE,
    reviewer_id UUID,
    review_notes TEXT,
    
    -- Timestamps
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_quality_metrics_product ON quality_metrics(product_id);
CREATE INDEX IF NOT EXISTS idx_quality_metrics_conversation ON quality_metrics(conversation_id);
CREATE INDEX IF NOT EXISTS idx_quality_metrics_created ON quality_metrics(created_at);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE generation_runs IS 'Tracks batches of conversation generation for organized processing';
COMMENT ON TABLE conversations IS 'Stores conversation-level metadata with agent attribution and scenario context';
COMMENT ON TABLE turns IS 'Individual prompt-response exchanges within conversations, linked to LLM invocations';
COMMENT ON TABLE quality_metrics IS 'Detailed quality assessment and safety metrics for conversations';

COMMENT ON COLUMN turns.stage IS 'Sequential turn number within conversation (1, 2, 3, ...)';
COMMENT ON COLUMN turns.llm_invocation_id IS 'Links to llm_invocations table for full invocation details';
COMMENT ON COLUMN conversations.conversation_id IS 'Unique conversation identifier (can be external ID)';
COMMENT ON COLUMN conversations.turn_count IS 'Total number of turns in this conversation';

-- ============================================================================
-- TRIGGERS FOR TURN COUNT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_conversation_turn_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET turn_count = (
        SELECT COUNT(*) FROM turns WHERE conversation_id = NEW.conversation_id
    ),
    updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_turn_count
    AFTER INSERT ON turns
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_turn_count();

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'Conversations & Turns tables created successfully!' AS status;
SELECT 
    'generation_runs' AS table_name, 
    COUNT(*) AS column_count 
FROM information_schema.columns 
WHERE table_name = 'generation_runs'
UNION ALL
SELECT 
    'conversations' AS table_name, 
    COUNT(*) AS column_count 
FROM information_schema.columns 
WHERE table_name = 'conversations'
UNION ALL
SELECT 
    'turns' AS table_name, 
    COUNT(*) AS column_count 
FROM information_schema.columns 
WHERE table_name = 'turns'
UNION ALL
SELECT 
    'quality_metrics' AS table_name, 
    COUNT(*) AS column_count 
FROM information_schema.columns 
WHERE table_name = 'quality_metrics';

-- ============================================================================
-- NEXUS PRODUCT SCHEMA (WITH ALL PARENT/SHARED TABLES)
-- ============================================================================
-- This schema contains ALL Peregrine (AI Assurance Platform) specific tables PLUS 
-- all parent/shared tables that Peregrine depends on. This is a complete deployable 
-- schema for Peregrine.
--
-- Includes:
-- - Product metadata (products table with peregrine entry)
-- - Tenant & subscription management
-- - AI agents and models
-- - Peregrine prompt library with client submissions
-- - Peregrine Alpha analysis (risk metrics, robustness analysis, fragility scores, sycophancy detection)
-- - Embeddings and vector analysis
-- - PCA models and configuration snapshots
-- - API usage tracking and benchmark tests
-- - Audit and compliance
--
-- EXCLUDES: AI-Range specific tables (personas, scenarios, testing, safety assessments)
-- NOTE: Includes product_prompt_lineage for traceability to AI-Range Stage 4 prompts
--
-- Target: PostgreSQL 14+
-- File: schema_peregrine_only.sql
-- Generated: March 4, 2026
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ============================================================================
-- PRODUCT LAYER (Shared - but filtered to peregrine)
-- ============================================================================

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_code TEXT NOT NULL UNIQUE CHECK (product_code IN ('peregrine')),
    product_name TEXT NOT NULL,
    description TEXT,
    features JSONB DEFAULT '{}'::jsonb,
    pricing_tier TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'beta', 'deprecated', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_products_code_status ON products(product_code, status);

INSERT INTO products (product_code, product_name, description, status) VALUES
('peregrine', 'Peregrine', 'AI Assurance and Analysis Platform for model risk assessment', 'active');

-- ============================================================================
-- PRODUCT USAGE TRACKING
-- ============================================================================

CREATE TABLE product_usage (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    usage_type TEXT NOT NULL,
    usage_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_product_usage_product ON product_usage(product_id);
CREATE INDEX idx_product_usage_tenant ON product_usage(tenant_id);
CREATE INDEX idx_product_usage_created ON product_usage(created_at);
CREATE INDEX idx_product_usage_type ON product_usage(usage_type);

-- ============================================================================
-- CORE TENANT & CLIENT MANAGEMENT (Parent)
-- ============================================================================

CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_name TEXT NOT NULL UNIQUE,
    client_id TEXT UNIQUE,
    industry TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE client_product_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    subscription_tier TEXT,
    subscription_status TEXT NOT NULL DEFAULT 'active' CHECK (subscription_status IN ('active', 'trial', 'suspended', 'expired', 'cancelled')),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    usage_limits JSONB DEFAULT '{}'::jsonb,
    features_enabled JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    UNIQUE(tenant_id, product_id)
);

CREATE INDEX idx_client_subscriptions_tenant ON client_product_subscriptions(tenant_id);
CREATE INDEX idx_client_subscriptions_product ON client_product_subscriptions(product_id);
CREATE INDEX idx_client_subscriptions_status ON client_product_subscriptions(subscription_status);

-- ============================================================================
-- AI AGENTS & MODELS (Parent)
-- ============================================================================

CREATE TABLE ai_agents (
    agent_id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    agent_name TEXT NOT NULL,
    agent_type TEXT NOT NULL CHECK (agent_type IN ('adversarial', 'evaluator', 'classifier', 'monitor', 'generator', 'other')),
    model_architecture TEXT,
    version TEXT NOT NULL,
    description TEXT,
    capabilities JSONB,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'deprecated')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by TEXT,
    metadata JSONB
);

CREATE INDEX idx_ai_agents_product ON ai_agents(product_id);
CREATE INDEX idx_ai_agents_type_status ON ai_agents(agent_type, status);

CREATE TABLE client_models (
    model_id BIGSERIAL PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    client_id TEXT NOT NULL,
    model_name TEXT NOT NULL,
    model_version TEXT NOT NULL,
    model_type TEXT,
    endpoint_url TEXT,
    api_key_hash TEXT,
    deployment_environment TEXT,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_tested TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'active', 'suspended', 'deactivated')),
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    metadata JSONB
);

CREATE INDEX idx_client_models_tenant ON client_models(tenant_id);
CREATE INDEX idx_client_models_client_status ON client_models(client_id, status);

CREATE TABLE client_model_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_id BIGINT NOT NULL REFERENCES client_models(model_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    enabled BOOLEAN DEFAULT TRUE,
    configuration JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(model_id, product_id)
);

CREATE INDEX idx_client_model_products_model ON client_model_products(model_id);
CREATE INDEX idx_client_model_products_product ON client_model_products(product_id);
CREATE INDEX idx_client_model_products_tenant ON client_model_products(tenant_id);

-- ============================================================================
-- TRAIT CATALOGS (Shared infrastructure for analysis context)
-- ============================================================================

CREATE TABLE demographic_traits_catalog (
    id BIGSERIAL PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    data_type TEXT NOT NULL DEFAULT 'text' CHECK (data_type IN ('text', 'number', 'boolean', 'date', 'enum', 'json')),
    allowed_values JSONB,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    applicable_sub_cohorts JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE behavioral_traits_catalog (
    id BIGSERIAL PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    data_type TEXT NOT NULL DEFAULT 'text' CHECK (data_type IN ('text', 'number', 'boolean', 'date', 'enum', 'json')),
    allowed_values JSONB,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    applicable_sub_cohorts JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE psychographic_traits_catalog (
    id BIGSERIAL PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    data_type TEXT NOT NULL DEFAULT 'text' CHECK (data_type IN ('text', 'number', 'boolean', 'date', 'enum', 'json')),
    allowed_values JSONB,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    applicable_sub_cohorts JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE technographic_traits_catalog (
    id BIGSERIAL PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    data_type TEXT NOT NULL DEFAULT 'text' CHECK (data_type IN ('text', 'number', 'boolean', 'date', 'enum', 'json')),
    allowed_values JSONB,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    applicable_sub_cohorts JSONB DEFAULT '[]'::jsonb
);

CREATE TABLE linguistic_traits_catalog (
    id BIGSERIAL PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    data_type TEXT NOT NULL DEFAULT 'text' CHECK (data_type IN ('text', 'number', 'boolean', 'date', 'enum', 'json')),
    allowed_values JSONB,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal'))
);

-- ============================================================================
-- NEXUS PROMPT LIBRARY (Peregrine specific)
-- ============================================================================

CREATE TABLE peregrine_prompt_library (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    prompt_name TEXT NOT NULL,
    category TEXT NOT NULL,
    stage INTEGER NOT NULL DEFAULT 4 CHECK (stage >= 1 AND stage <= 4),
    prompt_text TEXT NOT NULL,
    prompt_template TEXT,
    description TEXT,
    author_id TEXT,
    tags TEXT[] DEFAULT ARRAY[]::text[],
    use_cases TEXT[] DEFAULT ARRAY[]::text[],
    expected_outputs TEXT,
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    difficulty_level TEXT CHECK (difficulty_level IN ('easy', 'medium', 'hard', 'expert')),
    is_public BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1,
    status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'archived', 'deprecated')),
    performance_metrics JSONB,
    embedded_text TEXT,
    embedding vector,
    source_ai_range_turn_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_peregrine_prompt_library_product ON peregrine_prompt_library(product_id);
CREATE INDEX idx_peregrine_prompt_library_category ON peregrine_prompt_library(category);
CREATE INDEX idx_peregrine_prompt_library_stage ON peregrine_prompt_library(stage);
CREATE INDEX idx_peregrine_prompt_library_status ON peregrine_prompt_library(status);

-- ============================================================================
-- CLIENT PROMPT SUBMISSIONS (Peregrine specific)
-- ============================================================================

CREATE TABLE client_prompt_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    tenant_id UUID REFERENCES tenants(id),
    model_id BIGINT REFERENCES client_models(model_id),
    submitted_by_user_id TEXT,
    prompt_text TEXT NOT NULL,
    prompt_description TEXT,
    submission_context JSONB,
    intended_use_case TEXT,
    expected_behavior TEXT,
    tags TEXT[] DEFAULT ARRAY[]::text[],
    submission_status TEXT DEFAULT 'pending' CHECK (submission_status IN ('pending', 'approved', 'rejected', 'under_review')),
    risk_assessment_status TEXT DEFAULT 'pending' CHECK (risk_assessment_status IN ('pending', 'completed', 'flagged')),
    risk_level TEXT CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    review_notes TEXT,
    reviewed_by_user_id TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_client_submissions_product ON client_prompt_submissions(product_id);
CREATE INDEX idx_client_submissions_tenant ON client_prompt_submissions(tenant_id);
CREATE INDEX idx_client_submissions_model ON client_prompt_submissions(model_id);
CREATE INDEX idx_client_submissions_status ON client_prompt_submissions(submission_status);
CREATE INDEX idx_client_submissions_risk ON client_prompt_submissions(risk_level);

-- ============================================================================
-- PRODUCT PROMPT LINEAGE (Links AI-Range Stage 4 to Peregrine)
-- ============================================================================

CREATE TABLE product_prompt_lineage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    peregrine_prompt_id BIGINT REFERENCES peregrine_prompt_library(id),
    ai_range_turn_id VARCHAR(100),
    ai_range_conversation_id VARCHAR(100),
    ai_range_session_id TEXT,
    lineage_type TEXT NOT NULL DEFAULT 'stage4_derivation' CHECK (lineage_type IN ('stage4_derivation', 'refinement', 'variant', 'adaptation')),
    transformation_notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_product_lineage_product ON product_prompt_lineage(product_id);
CREATE INDEX idx_product_lineage_peregrine ON product_prompt_lineage(peregrine_prompt_id);
CREATE INDEX idx_product_lineage_ai_range ON product_prompt_lineage(ai_range_turn_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - CONVERSATIONS & TURNS
-- ============================================================================

CREATE TABLE peregrine_alpha_conversations (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT NOT NULL REFERENCES client_models(model_id),
    conversation_id VARCHAR(100) NOT NULL UNIQUE,
    session_id UUID,
    conversation_type TEXT DEFAULT 'standard' CHECK (conversation_type IN ('standard', 'adversarial', 'benchmark', 'custom')),
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    turn_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'failed', 'paused')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_conversations_product ON peregrine_alpha_conversations(product_id);
CREATE INDEX idx_peregrine_conversations_model ON peregrine_alpha_conversations(model_id);
CREATE INDEX idx_peregrine_conversations_id ON peregrine_alpha_conversations(conversation_id);

CREATE TABLE peregrine_alpha_turns (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT NOT NULL REFERENCES peregrine_alpha_conversations(id),
    turn_number INTEGER NOT NULL,
    turn_id VARCHAR(100) NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    tokens_used INTEGER,
    latency_ms FLOAT,
    model_response JSONB,
    status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'pending')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_turns_product ON peregrine_alpha_turns(product_id);
CREATE INDEX idx_peregrine_turns_conversation ON peregrine_alpha_turns(conversation_id);
CREATE INDEX idx_peregrine_turns_id ON peregrine_alpha_turns(turn_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - EMBEDDINGS & VECTORS
-- ============================================================================

CREATE TABLE peregrine_alpha_embeddings (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    turn_id BIGINT NOT NULL REFERENCES peregrine_alpha_turns(id),
    embedding_type TEXT NOT NULL DEFAULT 'response' CHECK (embedding_type IN ('prompt', 'response', 'combined')),
    embedding_text TEXT NOT NULL,
    embedding vector NOT NULL,
    model_used TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_embeddings_product ON peregrine_alpha_embeddings(product_id);
CREATE INDEX idx_peregrine_embeddings_turn ON peregrine_alpha_embeddings(turn_id);

CREATE TABLE peregrine_alpha_vectors_2d (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    embedding_id BIGINT NOT NULL REFERENCES peregrine_alpha_embeddings(id),
    x_coordinate FLOAT NOT NULL,
    y_coordinate FLOAT NOT NULL,
    principal_component_1 FLOAT,
    principal_component_2 FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_vectors_product ON peregrine_alpha_vectors_2d(product_id);
CREATE INDEX idx_peregrine_vectors_embedding ON peregrine_alpha_vectors_2d(embedding_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - RISK METRICS
-- ============================================================================

CREATE TABLE peregrine_alpha_risk_metrics (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT REFERENCES peregrine_alpha_conversations(id),
    turn_id BIGINT REFERENCES peregrine_alpha_turns(id),
    risk_category TEXT NOT NULL,
    risk_score FLOAT NOT NULL CHECK (risk_score >= 0.0 AND risk_score <= 1.0),
    confidence_level FLOAT CHECK (confidence_level >= 0.0 AND confidence_level <= 1.0),
    risk_factors JSONB DEFAULT '{}'::jsonb,
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_risk_metrics_product ON peregrine_alpha_risk_metrics(product_id);
CREATE INDEX idx_peregrine_risk_metrics_conversation ON peregrine_alpha_risk_metrics(conversation_id);
CREATE INDEX idx_peregrine_risk_metrics_category ON peregrine_alpha_risk_metrics(risk_category);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - ROBUSTNESS ANALYSIS
-- ============================================================================

CREATE TABLE peregrine_alpha_robustness_analysis (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    analysis_type TEXT NOT NULL,
    test_parameters JSONB,
    perturbation_magnitude FLOAT,
    input_variation TEXT,
    robustness_score FLOAT NOT NULL CHECK (robustness_score >= 0.0 AND robustness_score <= 1.0),
    failure_count INTEGER DEFAULT 0,
    total_tests INTEGER DEFAULT 0,
    failure_rate FLOAT,
    analysis_results JSONB,
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_robustness_product ON peregrine_alpha_robustness_analysis(product_id);
CREATE INDEX idx_peregrine_robustness_model ON peregrine_alpha_robustness_analysis(model_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - FRAGILITY SCORES
-- ============================================================================

CREATE TABLE peregrine_alpha_fragility_scores (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    fragility_category TEXT NOT NULL CHECK (fragility_category IN ('distribution_shift', 'adversarial_input', 'constraint_violation', 'performance_degradation', 'other')),
    fragility_score FLOAT NOT NULL CHECK (fragility_score >= 0.0 AND fragility_score <= 1.0),
    triggering_conditions JSONB,
    impact_assessment JSONB,
    mitigation_strategies JSONB,
    status TEXT DEFAULT 'identified' CHECK (status IN ('identified', 'acknowledged', 'addressed', 'monitoring')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_fragility_product ON peregrine_alpha_fragility_scores(product_id);
CREATE INDEX idx_peregrine_fragility_model ON peregrine_alpha_fragility_scores(model_id);
CREATE INDEX idx_peregrine_fragility_category ON peregrine_alpha_fragility_scores(fragility_category);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - SYCOPHANCY DETECTION
-- ============================================================================

CREATE TABLE peregrine_alpha_sycophancy_events (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    conversation_id BIGINT REFERENCES peregrine_alpha_conversations(id),
    turn_id BIGINT REFERENCES peregrine_alpha_turns(id),
    event_description TEXT NOT NULL,
    sycophancy_type TEXT NOT NULL CHECK (sycophancy_type IN ('agreement_bias', 'authority_deference', 'flattery_response', 'opinion_mirroring', 'other')),
    confidence_score FLOAT CHECK (confidence_score >= 0.0 AND confidence_score <= 1.0),
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_sycophancy_events_product ON peregrine_alpha_sycophancy_events(product_id);
CREATE INDEX idx_peregrine_sycophancy_events_model ON peregrine_alpha_sycophancy_events(model_id);
CREATE INDEX idx_peregrine_sycophancy_events_turn ON peregrine_alpha_sycophancy_events(turn_id);

CREATE TABLE peregrine_alpha_sycophancy_analysis (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    analysis_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    analysis_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    total_events INTEGER DEFAULT 0,
    event_distribution JSONB,
    sycophancy_score FLOAT NOT NULL CHECK (sycophancy_score >= 0.0 AND sycophancy_score <= 1.0),
    trend_analysis JSONB,
    risk_assessment JSONB,
    recommendations JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_sycophancy_analysis_product ON peregrine_alpha_sycophancy_analysis(product_id);
CREATE INDEX idx_peregrine_sycophancy_analysis_model ON peregrine_alpha_sycophancy_analysis(model_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - PCA MODELS & CONFIGURATION
-- ============================================================================

CREATE TABLE peregrine_alpha_pca_models (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    pca_name TEXT NOT NULL,
    components_count INTEGER NOT NULL,
    explained_variance_ratio JSONB,
    mean_vector vector,
    principal_components JSONB,
    scaler_params JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_pca_product ON peregrine_alpha_pca_models(product_id);
CREATE INDEX idx_peregrine_pca_model ON peregrine_alpha_pca_models(model_id);

CREATE TABLE peregrine_alpha_configuration_snapshots (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    snapshot_name TEXT NOT NULL,
    configuration JSONB NOT NULL,
    parameters JSONB NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    description TEXT,
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_config_snapshots_product ON peregrine_alpha_configuration_snapshots(product_id);
CREATE INDEX idx_peregrine_config_snapshots_model ON peregrine_alpha_configuration_snapshots(model_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - API USAGE & BENCHMARKS
-- ============================================================================

CREATE TABLE peregrine_alpha_api_usage (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    usage_date DATE NOT NULL,
    requests_count INTEGER DEFAULT 0,
    total_tokens_used INTEGER DEFAULT 0,
    total_latency_ms FLOAT DEFAULT 0.0,
    success_rate FLOAT CHECK (success_rate >= 0.0 AND success_rate <= 1.0),
    error_count INTEGER DEFAULT 0,
    error_breakdown JSONB,
    usage_metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_api_usage_product ON peregrine_alpha_api_usage(product_id);
CREATE INDEX idx_peregrine_api_usage_model ON peregrine_alpha_api_usage(model_id);
CREATE INDEX idx_peregrine_api_usage_date ON peregrine_alpha_api_usage(usage_date);

CREATE TABLE peregrine_alpha_benchmark_tests (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    benchmark_name TEXT NOT NULL,
    benchmark_type TEXT NOT NULL,
    test_dataset TEXT,
    dataset_size INTEGER,
    num_runs INTEGER DEFAULT 1,
    metrics_results JSONB NOT NULL,
    overall_score FLOAT CHECK (overall_score >= 0.0 AND overall_score <= 1.0),
    percentile_ranking FLOAT CHECK (percentile_ranking >= 0.0 AND percentile_ranking <= 1.0),
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_benchmark_product ON peregrine_alpha_benchmark_tests(product_id);
CREATE INDEX idx_peregrine_benchmark_model ON peregrine_alpha_benchmark_tests(model_id);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - MODEL RECOMMENDATIONS & EXPORTS
-- ============================================================================

CREATE TABLE peregrine_alpha_model_recommendations (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    recommendation_type TEXT NOT NULL CHECK (recommendation_type IN ('improvement', 'risk_mitigation', 'optimization', 'deployment', 'monitoring')),
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    implementation_effort TEXT CHECK (implementation_effort IN ('minimal', 'low', 'medium', 'high')),
    expected_impact FLOAT CHECK (expected_impact >= 0.0 AND expected_impact <= 1.0),
    supporting_evidence JSONB,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'implemented', 'rejected', 'deferred')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_recommendations_product ON peregrine_alpha_model_recommendations(product_id);
CREATE INDEX idx_peregrine_recommendations_model ON peregrine_alpha_model_recommendations(model_id);

CREATE TABLE peregrine_alpha_exports (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    export_type TEXT NOT NULL CHECK (export_type IN ('pdf_report', 'json', 'csv', 'visualization', 'dashboard_link')),
    export_name TEXT NOT NULL,
    export_location TEXT,
    export_format TEXT,
    included_data JSONB,
    export_metadata JSONB,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'generating', 'completed', 'failed')),
    requested_by_user_id TEXT,
    requested_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_exports_product ON peregrine_alpha_exports(product_id);
CREATE INDEX idx_peregrine_exports_model ON peregrine_alpha_exports(model_id);
CREATE INDEX idx_peregrine_exports_status ON peregrine_alpha_exports(status);

-- ============================================================================
-- NEXUS ALPHA ANALYSIS - AUDIT LOG
-- ============================================================================

CREATE TABLE peregrine_alpha_audit_log (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    user_id TEXT,
    action_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id BIGINT,
    details JSONB,
    changes JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_peregrine_audit_log_product ON peregrine_alpha_audit_log(product_id);
CREATE INDEX idx_peregrine_audit_log_action ON peregrine_alpha_audit_log(action_type);
CREATE INDEX idx_peregrine_audit_log_entity ON peregrine_alpha_audit_log(entity_type);
CREATE INDEX idx_peregrine_audit_log_timestamp ON peregrine_alpha_audit_log(timestamp);

-- ============================================================================
-- AUDIT & LOGGING (Shared - but relevant to Peregrine)
-- ============================================================================

CREATE TABLE audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id BIGINT NOT NULL,
    actor_type TEXT,
    actor_id TEXT,
    action TEXT NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB
);

CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_actor ON audit_logs(actor_type, actor_id);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_event ON audit_logs(event_type);

-- ============================================================================
-- COMPOSITE INDEXES
-- ============================================================================

CREATE INDEX idx_peregrine_conversations_model_status ON peregrine_alpha_conversations(model_id, status);
CREATE INDEX idx_peregrine_turns_conversation_role ON peregrine_alpha_turns(conversation_id, role);
CREATE INDEX idx_peregrine_risk_metrics_score ON peregrine_alpha_risk_metrics(product_id, risk_score DESC);
CREATE INDEX idx_peregrine_client_models_status_risk ON client_models(status, risk_level);
CREATE INDEX idx_peregrine_embeddings_product_type ON peregrine_alpha_embeddings(product_id, embedding_type);

-- ============================================================================
-- END NEXUS COMPLETE SCHEMA
-- ============================================================================

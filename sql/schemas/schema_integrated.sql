-- ============================================================================
-- INTEGRATED ADVERSARIAL AI SAFETY & PERSONA TESTING DATABASE SCHEMA
-- ============================================================================
-- This schema integrates two complementary systems:
-- 1. Adversarial AI Safety Testing (original SQL Server schema)
-- 2. AI Persona Testing & Risk Assessment (PostgreSQL schema)
-- 
-- Target: PostgreSQL (unified platform)
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ============================================================================
-- PRODUCT LAYER - TOP TIER ARCHITECTURE
-- ============================================================================

-- Table: products
-- Defines the products available in the platform (ai-range, nexus)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_code TEXT NOT NULL UNIQUE CHECK (product_code IN ('ai-range', 'nexus')),
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

-- Insert default products
INSERT INTO products (product_code, product_name, description, status) VALUES
('ai-range', 'AI Range', 'Comprehensive AI testing and safety assessment platform', 'active'),
('nexus', 'Nexus', 'Advanced AI persona testing and risk analysis system', 'active');

-- ============================================================================
-- PRODUCT USAGE TRACKING
-- ============================================================================

-- Table: product_usage
-- Tracks every use of a product by a tenant (for auditing, billing, analytics)
CREATE TABLE product_usage (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    usage_type TEXT NOT NULL,  -- e.g., 'test_execution', 'persona_creation', 'scenario_run', 'report_generation'
    usage_metadata JSONB DEFAULT '{}'::jsonb,  -- Flexible metadata (model_id, test_count, parameters, etc.)
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_product_usage_product ON product_usage(product_id);
CREATE INDEX idx_product_usage_tenant ON product_usage(tenant_id);
CREATE INDEX idx_product_usage_created ON product_usage(created_at);
CREATE INDEX idx_product_usage_type ON product_usage(usage_type);
CREATE INDEX idx_product_usage_product_tenant_date ON product_usage(product_id, tenant_id, created_at);

-- ============================================================================
-- CORE TENANT & CLIENT MANAGEMENT
-- ============================================================================

-- Table: tenants
-- Central tenant/client management
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

-- Table: client_product_subscriptions
-- Manages which clients have access to which products
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
-- AI AGENTS & MODELS
-- ============================================================================

-- Table: ai_agents
-- Stores adversarial, evaluator, and testing AI agents
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
    metadata JSONB,
    CONSTRAINT fk_ai_agents_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_ai_agents_product ON ai_agents(product_id);
CREATE INDEX idx_ai_agents_type_status ON ai_agents(agent_type, status);

-- Table: client_models
-- Client AI models under test
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

-- Table: client_model_products
-- Junction table linking client models to products they use
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
-- USE CASES, COHORTS & SUB-COHORTS
-- ============================================================================

-- Table: use_cases
-- Business use cases for AI systems (AI-Range product)
CREATE TABLE use_cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    slug TEXT UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_use_cases_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_use_cases_product ON use_cases(product_id);

-- Table: cohorts
-- User cohorts within use cases
CREATE TABLE cohorts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    use_case_id UUID REFERENCES use_cases(id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: sub_cohorts
-- Sub-segments within cohorts
CREATE TABLE sub_cohorts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cohort_id UUID REFERENCES cohorts(id),
    name TEXT NOT NULL,
    description TEXT,
    persona_type TEXT DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- TRAIT CATALOGS (for flexible persona attributes)
-- ============================================================================

-- Table: demographic_traits_catalog
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

-- Table: behavioral_traits_catalog
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

-- Table: psychographic_traits_catalog
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

-- Table: technographic_traits_catalog
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

-- Table: linguistic_traits_catalog
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
-- PERSONAS (unified ai_personas and personas tables)
-- ============================================================================

-- Table: personas
-- Unified persona table combining regular and AI-generated personas (AI-Range product)
CREATE TABLE personas (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    tenant_id TEXT NOT NULL,
    session_id TEXT,
    use_case_id UUID REFERENCES use_cases(id),
    cohort_id UUID REFERENCES cohorts(id),
    sub_cohort_id UUID REFERENCES sub_cohorts(id),
    
    -- Identity
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    slug TEXT,
    archetype TEXT,
    persona_type TEXT NOT NULL DEFAULT 'regular' CHECK (persona_type IN ('regular', 'adversarial', 'internal')),
    
    -- Classification
    actor_type TEXT,
    domain TEXT,
    intent TEXT,
    skill_level TEXT,
    
    -- Content
    overview TEXT,
    description TEXT,
    bio TEXT,
    quote TEXT,
    
    -- Attributes (flexible storage)
    traits JSONB,
    constraints JSONB,
    attributes JSONB DEFAULT '{}'::jsonb,
    
    -- Metadata
    source TEXT,
    is_ai BOOLEAN DEFAULT true,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('draft', 'active', 'archived')),
    version INTEGER NOT NULL DEFAULT 1,
    language TEXT DEFAULT 'English',
    
    -- Vector search
    embedding vector,
    
    -- Audit
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_personas_product ON personas(product_id);
CREATE INDEX idx_personas_tenant ON personas(tenant_id);
CREATE INDEX idx_personas_session ON personas(session_id);
CREATE INDEX idx_personas_type_status ON personas(persona_type, status);
CREATE INDEX idx_personas_use_case ON personas(use_case_id);

-- ============================================================================
-- PERSONA TRAITS (linking personas to trait catalogs)
-- ============================================================================

-- Table: persona_demographics
CREATE TABLE persona_demographics (
    persona_id TEXT REFERENCES personas(id),
    trait_id BIGINT REFERENCES demographic_traits_catalog(id),
    raw_value TEXT,
    value JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (persona_id, trait_id)
);

-- Table: persona_behavioral_traits
CREATE TABLE persona_behavioral_traits (
    persona_id TEXT REFERENCES personas(id),
    trait_id BIGINT REFERENCES behavioral_traits_catalog(id),
    raw_value TEXT,
    value JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (persona_id, trait_id)
);

-- Table: persona_psychographic_traits
CREATE TABLE persona_psychographic_traits (
    persona_id TEXT REFERENCES personas(id),
    trait_id BIGINT REFERENCES psychographic_traits_catalog(id),
    raw_value TEXT,
    value JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (persona_id, trait_id)
);

-- Table: persona_technographic_traits
CREATE TABLE persona_technographic_traits (
    persona_id TEXT REFERENCES personas(id),
    trait_id BIGINT REFERENCES technographic_traits_catalog(id),
    raw_value TEXT,
    value JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (persona_id, trait_id)
);

-- Table: persona_linguistic_traits
CREATE TABLE persona_linguistic_traits (
    persona_id TEXT REFERENCES personas(id),
    trait_id BIGINT REFERENCES linguistic_traits_catalog(id),
    raw_value TEXT,
    value JSONB,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (persona_id, trait_id)
);

-- ============================================================================
-- PERSONA MEMORY & COGNITION
-- ============================================================================

-- Table: persona_memories
CREATE TABLE persona_memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    persona_id TEXT REFERENCES personas(id),
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type TEXT,
    content TEXT NOT NULL,
    metadata JSONB,
    embedding vector,
    CONSTRAINT fk_persona_memories_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_persona_memories_persona ON persona_memories(persona_id);
CREATE INDEX idx_persona_memories_product ON persona_memories(product_id);

-- Table: persona_reflections
CREATE TABLE persona_reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    persona_id TEXT REFERENCES personas(id),
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    summary TEXT NOT NULL,
    embedding vector,
    CONSTRAINT fk_persona_reflections_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_persona_reflections_product ON persona_reflections(product_id);

-- Table: persona_plans
CREATE TABLE persona_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    persona_id TEXT REFERENCES personas(id),
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    plan TEXT NOT NULL,
    horizon INTEGER DEFAULT 3,
    status TEXT DEFAULT 'active',
    CONSTRAINT fk_persona_plans_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_persona_plans_product ON persona_plans(product_id);

-- Table: persona_actions
CREATE TABLE persona_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    persona_id TEXT REFERENCES personas(id),
    ts TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    input TEXT,
    output TEXT,
    metadata JSONB,
    CONSTRAINT fk_persona_actions_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_persona_actions_product ON persona_actions(product_id);

-- ============================================================================
-- CONTEXT PROFILES & RISK ASSESSMENT
-- ============================================================================

-- Table: context_profiles
-- Customer context and intake information
CREATE TABLE context_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    source_intake_id TEXT NOT NULL UNIQUE,
    tenant_id UUID REFERENCES tenants(id),
    
    -- Business context
    industry TEXT NOT NULL,
    primary_use_case TEXT NOT NULL,
    objectives TEXT[] DEFAULT '{}',
    goals TEXT,
    
    -- Compliance & governance
    guardrails TEXT[] DEFAULT '{}',
    frameworks TEXT[] DEFAULT '{}',
    policies TEXT[] DEFAULT '{}',
    legal_regulatory TEXT[] DEFAULT '{}',
    
    -- Technical details
    api_endpoints TEXT[] DEFAULT '{}',
    endpoint_url TEXT,
    model_stack TEXT[] DEFAULT '{}',
    ml_stack TEXT,
    custom_models TEXT,
    guardrails_endpoint TEXT,
    guardrails_auth TEXT,
    api_access_level TEXT,
    integration_scan TEXT,
    
    -- Seeds for generation
    personas_seed TEXT[] DEFAULT '{}',
    risks_seed TEXT[] DEFAULT '{}',
    
    -- User types
    regular_users_type TEXT[] DEFAULT '{}',
    regular_users TEXT,
    attackers_type TEXT[] DEFAULT '{}',
    attackers TEXT,
    ai_agents_type TEXT[] DEFAULT '{}',
    ai_agents TEXT,
    user_distribution TEXT,
    
    -- Plans
    plans JSONB DEFAULT '{}'::jsonb,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_context_profiles_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_context_profiles_product ON context_profiles(product_id);

-- Table: risk_assessments
CREATE TABLE risk_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    context_profile_id UUID REFERENCES context_profiles(id),
    source_intake_id TEXT NOT NULL,
    assessment_mode TEXT DEFAULT 'agentic' CHECK (assessment_mode IN ('agentic', 'mock')),
    
    threats JSONB DEFAULT '[]'::jsonb,
    scenarios JSONB DEFAULT '[]'::jsonb,
    summary JSONB DEFAULT '{}'::jsonb,
    
    agent_endpoint TEXT,
    generation_time_ms INTEGER,
    api_response_status INTEGER,
    error_message TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_risk_assessments_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_risk_assessments_product ON risk_assessments(product_id);

-- ============================================================================
-- THREATS, RISKS & HARMS
-- ============================================================================

-- Table: threat_vectors
CREATE TABLE threat_vectors (
    id TEXT PRIMARY KEY,
    id_uuid UUID,
    product_id UUID NOT NULL REFERENCES products(id),
    source TEXT NOT NULL,
    name TEXT,
    description TEXT,
    category TEXT,
    
    threat_categories TEXT[],
    harm_categories TEXT[],
    modalities TEXT[],
    tags TEXT[] DEFAULT ARRAY[]::text[],
    
    framework_alignment JSONB,
    metadata JSONB,
    
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    mitigation TEXT,
    
    raw_json JSONB,
    embedding vector,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_threat_vectors_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_threat_vectors_product ON threat_vectors(product_id);
CREATE INDEX idx_threat_vectors_severity ON threat_vectors(severity);
CREATE INDEX idx_threat_vectors_category ON threat_vectors(category);

-- Table: threat_examples
CREATE TABLE threat_examples (
    id TEXT PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    vector_id TEXT REFERENCES threat_vectors(id),
    source TEXT,
    raw_json JSONB,
    
    example_text TEXT,
    persona_samples JSONB,
    scenario_text TEXT,
    expected_system_response TEXT,
    evidence_refs JSONB,
    
    severity TEXT,
    detection_methods TEXT[],
    mitigation TEXT[],
    lifecycle_phase TEXT,
    exploitation_complexity TEXT,
    modalities TEXT[],
    
    embedding vector,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_threat_examples_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_threat_examples_product ON threat_examples(product_id);

-- Table: risks
CREATE TABLE risks (
    id TEXT PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    name TEXT NOT NULL,
    description TEXT,
    embedding vector,
    CONSTRAINT fk_risks_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_risks_product ON risks(product_id);

-- Table: harms
CREATE TABLE harms (
    id TEXT PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    name TEXT NOT NULL,
    description TEXT,
    embedding vector,
    CONSTRAINT fk_harms_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_harms_product ON harms(product_id);

-- ============================================================================
-- TEST CATEGORIES & TEST TYPES
-- ============================================================================

-- Table: test_categories
-- High-level test categorization (AI-Range product)
CREATE TABLE test_categories (
    category_id SERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    category_name TEXT NOT NULL UNIQUE,
    description TEXT,
    severity_level TEXT NOT NULL CHECK (severity_level IN ('low', 'medium', 'high', 'critical')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_test_categories_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_test_categories_product ON test_categories(product_id);

-- Table: test_types
-- Specific types of tests (unified from both schemas)
CREATE TABLE test_types (
    id TEXT PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    category_id INTEGER REFERENCES test_categories(category_id),
    session_id TEXT,
    embedding vector,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_test_types_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_test_types_product ON test_types(product_id);

-- ============================================================================
-- SCENARIOS & INTENTS
-- ============================================================================

-- Table: scenarios
-- Test scenarios (unified from ai_scenarios and scenarios tables) (AI-Range product)
CREATE TABLE scenarios (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    tenant_id TEXT NOT NULL,
    session_id TEXT,
    persona_id TEXT REFERENCES personas(id),
    
    -- Identity
    title TEXT NOT NULL,
    name TEXT,
    scenario_id TEXT,
    
    -- Description
    description TEXT,
    context TEXT,
    constraints TEXT,
    expected_behaviors TEXT,
    
    -- Classification
    risk_vectors TEXT[] DEFAULT '{}',
    harm_categories TEXT[] DEFAULT '{}',
    stack_tags TEXT[] DEFAULT '{}',
    tags TEXT,
    
    -- Scoring
    relevance_score DOUBLE PRECISION,
    severity TEXT,
    likelihood TEXT,
    
    -- Objectives and generation
    objectives JSONB DEFAULT '[]'::jsonb,
    generated_prompt JSONB,
    
    -- Status
    status TEXT DEFAULT 'created',
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    raw_data JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_scenarios_product ON scenarios(product_id);
CREATE INDEX idx_scenarios_tenant ON scenarios(tenant_id);
CREATE INDEX idx_scenarios_session ON scenarios(session_id);
CREATE INDEX idx_scenarios_persona ON scenarios(persona_id);

-- Table: scenario_intents
-- Detailed intent breakdown for scenarios
CREATE TABLE scenario_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    scenario_id TEXT REFERENCES scenarios(id),
    
    intent_name TEXT NOT NULL,
    description TEXT,
    
    -- Triggers
    temporal_trigger TEXT,
    spatial_trigger TEXT,
    event_trigger TEXT,
    
    -- Context
    social_context TEXT,
    environmental_context TEXT,
    
    -- Actions
    steps TEXT,
    available_actions TEXT,
    decision_points TEXT,
    
    -- Objects
    objects_involved TEXT,
    object_states JSONB,
    
    -- Goals
    scenario_goal TEXT,
    success_criteria TEXT,
    failure_conditions TEXT,
    constraints TEXT,
    
    -- Information
    information_channels TEXT,
    visibility_rules TEXT,
    
    -- Metadata
    frequency TEXT,
    relevance_score NUMERIC CHECK (relevance_score >= 0 AND relevance_score <= 1),
    status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'archived')),
    priority TEXT CHECK (priority IN ('critical', 'high', 'medium', 'low')),
    tags JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_scenario_intents_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_intents_product ON scenario_intents(product_id);

-- Table: scenario_intent_personas
CREATE TABLE scenario_intent_personas (
    product_id UUID NOT NULL REFERENCES products(id),
    intent_id UUID REFERENCES scenario_intents(id),
    persona_id TEXT REFERENCES personas(id),
    relevance_score NUMERIC CHECK (relevance_score >= 0 AND relevance_score <= 1),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (intent_id, persona_id),
    CONSTRAINT fk_scenario_intent_personas_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_intent_personas_product ON scenario_intent_personas(product_id);

-- Table: scenario_personas
CREATE TABLE scenario_personas (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    scenario_id TEXT REFERENCES scenarios(id),
    persona_id TEXT REFERENCES personas(id),
    relevance_score DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_scenario_personas_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_personas_product ON scenario_personas(product_id);

-- Table: scenario_threats
CREATE TABLE scenario_threats (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    scenario_id TEXT REFERENCES scenarios(id),
    threat_vector_id TEXT REFERENCES threat_vectors(id),
    relevance_score DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_scenario_threats_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_threats_product ON scenario_threats(product_id);

-- Table: scenario_scores
CREATE TABLE scenario_scores (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    scenario_id TEXT REFERENCES scenarios(id),
    score_type TEXT NOT NULL,
    score_value DOUBLE PRECISION NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_scenario_scores_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_scores_product ON scenario_scores(product_id);

-- Table: scenario_test_types
CREATE TABLE scenario_test_types (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product_id UUID NOT NULL REFERENCES products(id),
    scenario_id TEXT REFERENCES scenarios(id),
    test_type_id TEXT REFERENCES test_types(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_scenario_test_types_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_scenario_test_types_product ON scenario_test_types(product_id);

-- ============================================================================
-- TEST SESSIONS & EXECUTION
-- ============================================================================

-- Table: test_sessions
-- AI-Range testing sessions
CREATE TABLE test_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT NOT NULL UNIQUE,
    product_id UUID NOT NULL REFERENCES products(id),
    customer_id TEXT NOT NULL,
    tenant_id UUID REFERENCES tenants(id),
    
    session_name TEXT NOT NULL,
    description TEXT,
    customer_data JSONB,
    
    status TEXT DEFAULT 'active',
    tags TEXT[] DEFAULT ARRAY[]::text[],
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_test_sessions_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_test_sessions_product ON test_sessions(product_id);
CREATE INDEX idx_test_sessions_tenant ON test_sessions(tenant_id);
CREATE INDEX idx_test_sessions_customer ON test_sessions(customer_id);

-- Table: adversarial_test_cases
-- Individual test cases for adversarial testing (AI-Range product)
CREATE TABLE adversarial_test_cases (
    test_case_id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    category_id INTEGER REFERENCES test_categories(category_id),
    
    test_name TEXT NOT NULL,
    test_prompt TEXT NOT NULL,
    expected_behavior TEXT,
    
    attack_type TEXT,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    created_by_agent_id BIGINT REFERENCES ai_agents(agent_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    metadata JSONB
);

CREATE INDEX idx_test_cases_product ON adversarial_test_cases(product_id);
CREATE INDEX idx_test_cases_category ON adversarial_test_cases(category_id);
CREATE INDEX idx_test_cases_active ON adversarial_test_cases(is_active);

-- Table: test_executions
-- Records each execution of a test (AI-Range product)
CREATE TABLE test_executions (
    execution_id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    model_id BIGINT REFERENCES client_models(model_id),
    test_case_id BIGINT REFERENCES adversarial_test_cases(test_case_id),
    executing_agent_id BIGINT REFERENCES ai_agents(agent_id),
    session_id UUID REFERENCES test_sessions(id),
    
    execution_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    execution_end TIMESTAMP WITH TIME ZONE,
    
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed', 'timeout')),
    
    error_message TEXT,
    execution_context JSONB,
    
    CONSTRAINT fk_test_executions_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_executions_product ON test_executions(product_id);
CREATE INDEX idx_executions_model ON test_executions(model_id);
CREATE INDEX idx_executions_test ON test_executions(test_case_id);
CREATE INDEX idx_executions_status ON test_executions(status);
CREATE INDEX idx_executions_start ON test_executions(execution_start);

-- ============================================================================
-- TEST SETS & TEST UNITS (structured test organization)
-- ============================================================================

-- Table: test_sets
CREATE TABLE test_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id TEXT NOT NULL,
    created_by TEXT NOT NULL,
    
    scenario TEXT,
    persona JSONB,
    risks TEXT[] NOT NULL,
    harms TEXT[] NOT NULL,
    test_type TEXT REFERENCES test_types(id),
    
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: test_units
CREATE TABLE test_units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_set_id UUID REFERENCES test_sets(id),
    label TEXT,
    ord INTEGER NOT NULL
);

-- Table: test_turns
CREATE TABLE test_turns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    unit_id UUID REFERENCES test_units(id),
    
    role TEXT CHECK (role IN ('user', 'assistant', 'assistant_expected', 'system', 'tool')),
    content TEXT,
    expected_behavior TEXT,
    
    scoring JSONB,
    ord INTEGER NOT NULL,
    source TEXT DEFAULT 'user',
    
    embedding vector
);

-- ============================================================================
-- MODEL OUTPUTS & RESPONSES
-- ============================================================================

-- Table: model_outputs
-- Stores outputs from client models during testing
CREATE TABLE model_outputs (
    output_id BIGSERIAL PRIMARY KEY,
    execution_id BIGINT REFERENCES test_executions(execution_id),
    
    output_text TEXT NOT NULL,
    output_tokens INTEGER,
    generation_time_ms INTEGER,
    temperature DOUBLE PRECISION,
    other_parameters JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_outputs_execution ON model_outputs(execution_id);

-- Table: prompt_generator_responses
-- Combined response and LLM invocation tracking - stores both generated content and API execution details
CREATE TABLE prompt_generator_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Session and context
    generation_run_id UUID REFERENCES generation_runs(id),
    session_id UUID REFERENCES test_sessions(id),
    conversation_id VARCHAR(100),
    turn_id VARCHAR(100),
    
    -- Persona and scenario context
    persona_id TEXT REFERENCES personas(id),
    persona_name TEXT,
    scenario_id TEXT REFERENCES scenarios(id),
    test_type_id TEXT REFERENCES test_types(id),
    threat_vector_id TEXT REFERENCES threat_vectors(id),
    
    -- Generated content
    final_prompt TEXT NOT NULL,
    final_response JSONB NOT NULL,
    generated_text TEXT,
    test_types JSONB,
    raw_output JSONB,
    
    -- LLM API Invocation Details
    invocation_id UUID NOT NULL UNIQUE,
    model_id VARCHAR(255) NOT NULL,
    model_name TEXT,
    model_version TEXT,
    provider TEXT,
    
    -- Request/Response tracking
    request_payload JSONB,
    response_data JSONB,
    sanitized_response JSONB,
    
    -- Execution metrics
    status VARCHAR(50) DEFAULT 'success' CHECK (status IN ('success', 'failed', 'error')),
    latency_ms FLOAT,
    prompt_tokens INTEGER DEFAULT 0,
    completion_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    
    -- Error handling
    error_code VARCHAR(100),
    error_message TEXT,
    
    -- Caching and retry
    cache_hit BOOLEAN DEFAULT FALSE,
    retry_count INTEGER DEFAULT 0,
    invocation_type VARCHAR(50) DEFAULT 'async' CHECK (invocation_type IN ('async', 'sync')),
    
    -- Additional metadata
    caller_context JSONB,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_prompt_generator_responses_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_prompt_generator_responses_product ON prompt_generator_responses(product_id);
CREATE INDEX idx_prompt_generator_responses_session ON prompt_generator_responses(session_id);
CREATE INDEX idx_prompt_generator_responses_persona ON prompt_generator_responses(persona_id);
CREATE INDEX idx_prompt_generator_responses_scenario ON prompt_generator_responses(scenario_id);
CREATE INDEX idx_prompt_generator_responses_model ON prompt_generator_responses(model_id);
CREATE INDEX idx_prompt_generator_responses_invocation ON prompt_generator_responses(invocation_id);

-- ============================================================================
-- GENERATION METRICS & TELEMETRY
-- ============================================================================

-- ============================================================================
-- CAT-ASTROPHIC PROMPT DATABASE (PromptGoblin v2) INTEGRATION
-- ============================================================================
-- Tables for comprehensive prompt generation, execution tracking, and telemetry

-- Table: generation_runs
-- Stores batch/run-level metadata for prompt generation sessions
CREATE TABLE generation_runs (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    generation_run_id UUID NOT NULL UNIQUE,
    modality VARCHAR(50) DEFAULT 'text' CHECK (modality IN ('text', 'image', 'audio')),
    tags JSONB DEFAULT '[]'::jsonb,
    plan_metadata JSONB,
    coverage_map JSONB,
    adaptive_weights JSONB,
    status VARCHAR(50) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_generation_runs_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_generation_runs_product ON generation_runs(product_id);
CREATE INDEX idx_generation_runs_id ON generation_runs(generation_run_id);
CREATE INDEX idx_generation_runs_status ON generation_runs(status);
CREATE INDEX idx_generation_runs_created ON generation_runs(created_at);

-- Table: conversations
-- Stores conversation-level metadata (one per prompt in PromptGoblin format)
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    generation_run_id BIGINT NOT NULL REFERENCES generation_runs(id),
    conversation_id VARCHAR(100) NOT NULL UNIQUE,
    industry JSONB DEFAULT '[]'::jsonb,
    model_version VARCHAR(50) DEFAULT 'unknown',
    ai_range_enabled BOOLEAN DEFAULT FALSE,
    ai_range_model_name VARCHAR(255),
    ai_range_temperature FLOAT DEFAULT 0.7,
    ai_range_category VARCHAR(100),
    ai_range_target VARCHAR(100),
    human_in_loop BOOLEAN DEFAULT FALSE,
    human_in_loop_stage JSONB DEFAULT '[]'::jsonb,
    human_in_loop_details TEXT DEFAULT '',
    quality_methodology VARCHAR(255) DEFAULT '',
    diversity_score FLOAT,
    coverage_contribution JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_conversations_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_conversations_product ON conversations(product_id);
CREATE INDEX idx_conversations_id ON conversations(conversation_id);
CREATE INDEX idx_conversations_generation_run ON conversations(generation_run_id);
CREATE INDEX idx_conversations_created ON conversations(created_at);

-- Table: turns
-- Stores individual prompt-response exchanges (the core generation data)
CREATE TABLE turns (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT NOT NULL REFERENCES conversations(id),
    turn_id VARCHAR(100) NOT NULL UNIQUE,
    stage INTEGER,
    role VARCHAR(50) DEFAULT 'assistant' CHECK (role IN ('assistant', 'user', 'system')),
    prompt TEXT NOT NULL,
    response TEXT NOT NULL,
    response_preview TEXT,
    prompt_tokens INTEGER DEFAULT 0,
    response_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    latency_ms FLOAT DEFAULT 0.0,
    status VARCHAR(50) DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'pending')),
    finish_reason VARCHAR(50),
    model VARCHAR(255) NOT NULL,
    model_version VARCHAR(50) DEFAULT 'unknown',
    base_model_id VARCHAR(255),
    base_model_name VARCHAR(255),
    base_model_version VARCHAR(50),
    base_model_temperature FLOAT,
    auto_quality_score FLOAT DEFAULT 0.0,
    human_reviewed BOOLEAN DEFAULT FALSE,
    r_n FLOAT DEFAULT 0.0,
    v_n FLOAT DEFAULT 0.0,
    a_n FLOAT DEFAULT 0.0,
    rho FLOAT DEFAULT 0.0,
    pipeline_metadata JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_turns_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_turns_product ON turns(product_id);
CREATE INDEX idx_turns_id ON turns(turn_id);
CREATE INDEX idx_turns_conversation ON turns(conversation_id);
CREATE INDEX idx_turns_stage ON turns(stage);
CREATE INDEX idx_turns_timestamp ON turns(timestamp);
CREATE INDEX idx_turns_conversation_timestamp ON turns(conversation_id, timestamp);

-- Table: quality_metrics
-- Stores quality assessment metrics for conversations
CREATE TABLE quality_metrics (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    conversation_id BIGINT NOT NULL REFERENCES conversations(id),
    methodology VARCHAR(255) DEFAULT '',
    metrics JSONB DEFAULT '{}'::jsonb,
    fit_score FLOAT,
    diversity_score FLOAT,
    policy_risk_score FLOAT,
    length_score FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_quality_metrics_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_quality_metrics_product ON quality_metrics(product_id);
CREATE INDEX idx_quality_metrics_conversation ON quality_metrics(conversation_id);

-- Table: telemetry
-- Stores aggregated metrics per generation run
CREATE TABLE telemetry (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    generation_run_id BIGINT NOT NULL UNIQUE REFERENCES generation_runs(id),
    ingression_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    egression_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_entries INTEGER DEFAULT 0,
    total_prompt_tokens INTEGER DEFAULT 0,
    total_response_tokens INTEGER DEFAULT 0,
    total_tokens INTEGER DEFAULT 0,
    average_latency_ms FLOAT DEFAULT 0.0,
    success_rate FLOAT,
    repair_rate FLOAT,
    reject_rate FLOAT,
    avg_iterations FLOAT,
    strategy_coverage JSONB,
    topic_coverage JSONB,
    models_used JSONB DEFAULT '{}'::jsonb,
    feature_flags JSONB DEFAULT '[]'::jsonb,
    audit_trail_ids JSONB DEFAULT '[]'::jsonb,
    retention_policy VARCHAR(255) DEFAULT '',
    deletion_date TIMESTAMP WITH TIME ZONE,
    errors JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_telemetry_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_telemetry_product ON telemetry(product_id);
CREATE INDEX idx_telemetry_generation_run ON telemetry(generation_run_id);

-- ============================================================================
-- AUDIT & LOGGING
-- ============================================================================CREATE INDEX idx_llm_invocations_product ON llm_invocations(product_id);
CREATE INDEX idx_llm_invocations_id ON llm_invocations(invocation_id);
CREATE INDEX idx_llm_invocations_model ON llm_invocations(model_id);
CREATE INDEX idx_llm_invocations_status ON llm_invocations(status);
CREATE INDEX idx_llm_invocations_conversation ON llm_invocations(conversation_id);
CREATE INDEX idx_llm_invocations_turn ON llm_invocations(turn_id);
CREATE INDEX idx_llm_invocations_generation_run ON llm_invocations(generation_run_id);
CREATE INDEX idx_llm_invocations_created ON llm_invocations(created_at);
CREATE INDEX idx_llm_invocations_model_created ON llm_invocations(model_id, created_at);
CREATE INDEX idx_llm_invocations_status_created ON llm_invocations(status, created_at);

-- ============================================================================
-- SAFETY ASSESSMENTS & RESULTS
-- ============================================================================

-- Table: safety_assessments
-- Safety evaluations of model outputs (AI-Range product)
CREATE TABLE safety_assessments (
    assessment_id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    output_id BIGINT REFERENCES model_outputs(output_id),
    evaluator_agent_id BIGINT REFERENCES ai_agents(agent_id),
    
    safety_score NUMERIC(5,2) CHECK (safety_score >= 0 AND safety_score <= 100),
    is_safe BOOLEAN NOT NULL,
    risk_level TEXT NOT NULL CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    
    violation_types JSONB,
    reasoning TEXT,
    
    confidence_score NUMERIC(5,2) CHECK (confidence_score >= 0 AND confidence_score <= 100),
    
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB,
    
    CONSTRAINT fk_safety_assessments_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_assessments_product ON safety_assessments(product_id);
CREATE INDEX idx_assessments_output ON safety_assessments(output_id);
CREATE INDEX idx_assessments_safe ON safety_assessments(is_safe);
CREATE INDEX idx_assessments_risk ON safety_assessments(risk_level);

-- Table: safety_metrics
-- Detailed metrics for safety assessments
CREATE TABLE safety_metrics (
    metric_id BIGSERIAL PRIMARY KEY,
    assessment_id BIGINT REFERENCES safety_assessments(assessment_id),
    
    metric_name TEXT NOT NULL,
    metric_value NUMERIC(10,4) NOT NULL,
    metric_unit TEXT,
    threshold_exceeded BOOLEAN NOT NULL DEFAULT false,
    
    metadata JSONB
);

CREATE INDEX idx_metrics_assessment ON safety_metrics(assessment_id);
CREATE INDEX idx_metrics_name ON safety_metrics(metric_name);

-- Table: ai_test_results
-- Test results for AI testing scenarios
CREATE TABLE ai_test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES test_sessions(id),
    test_type_id TEXT REFERENCES test_types(id),
    persona_id TEXT REFERENCES personas(id),
    scenario_id TEXT REFERENCES scenarios(id),
    
    status TEXT CHECK (status IN ('passed', 'failed', 'blocked', 'unknown')),
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    
    findings TEXT[] DEFAULT ARRAY[]::text[],
    evidence TEXT,
    recommendations TEXT[] DEFAULT ARRAY[]::text[],
    tags TEXT[] DEFAULT ARRAY[]::text[],
    
    executed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_ms INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_test_results_session ON ai_test_results(session_id);
CREATE INDEX idx_test_results_status ON ai_test_results(status);

-- Table: nyc_test_results
CREATE TABLE nyc_test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_response_id UUID REFERENCES prompt_generator_responses(id),
    session_id TEXT,
    persona_id TEXT,
    persona_name TEXT,
    
    test_type TEXT,
    prompt TEXT,
    response JSONB,
    
    execution_time_ms INTEGER,
    success BOOLEAN,
    error_message TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- ALERTS & COMPLIANCE
-- ============================================================================

-- Table: safety_alerts
-- Safety alerts and incidents
CREATE TABLE safety_alerts (
    alert_id BIGSERIAL PRIMARY KEY,
    model_id BIGINT REFERENCES client_models(model_id),
    assessment_id BIGINT REFERENCES safety_assessments(assessment_id),
    
    alert_type TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    
    title TEXT NOT NULL,
    description TEXT,
    
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'false_positive')),
    
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by TEXT,
    resolution_notes TEXT
);

CREATE INDEX idx_alerts_model ON safety_alerts(model_id);
CREATE INDEX idx_alerts_status ON safety_alerts(status);
CREATE INDEX idx_alerts_severity ON safety_alerts(severity);

-- Table: compliance_reports
-- Compliance and safety reports (AI-Range product)
CREATE TABLE compliance_reports (
    report_id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    report_type TEXT NOT NULL,
    model_id BIGINT REFERENCES client_models(model_id),
    
    report_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
    report_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    
    total_tests INTEGER,
    passed_tests INTEGER,
    failed_tests INTEGER,
    critical_issues INTEGER,
    high_issues INTEGER,
    medium_issues INTEGER,
    low_issues INTEGER,
    
    overall_safety_score NUMERIC(5,2),
    report_data JSONB,
    
    generated_by_agent_id BIGINT REFERENCES ai_agents(agent_id),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_compliance_reports_product FOREIGN KEY (product_id) 
        REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_reports_product ON compliance_reports(product_id);
CREATE INDEX idx_reports_model ON compliance_reports(model_id);
CREATE INDEX idx_reports_period ON compliance_reports(report_period_start, report_period_end);

-- ============================================================================
-- AUDIT & LOGGING
-- ============================================================================

-- Table: audit_logs
-- Comprehensive audit trail
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
-- KNOWLEDGE BASE & SOURCES
-- ============================================================================

-- Table: sources
CREATE TABLE sources (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    source_type TEXT NOT NULL CHECK (source_type IN ('github', 'http', 'file')),
    location TEXT NOT NULL,
    config JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    inserted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: crawls
CREATE TABLE crawls (
    id BIGSERIAL PRIMARY KEY,
    source_id BIGINT REFERENCES sources(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    finished_at TIMESTAMP WITH TIME ZONE,
    status TEXT,
    stats JSONB
);

-- Table: raw_items
CREATE TABLE raw_items (
    id BIGSERIAL PRIMARY KEY,
    source_id BIGINT REFERENCES sources(id),
    external_id TEXT,
    title TEXT,
    raw_text TEXT,
    metadata JSONB,
    content_type TEXT,
    sha256 TEXT,
    inserted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: scenario_seeds
CREATE TABLE scenario_seeds (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    summary TEXT,
    persona_hint JSONB,
    scenario_context TEXT,
    linked_techniques BIGINT[],
    risk_vector TEXT,
    harm_category TEXT,
    tags TEXT[] DEFAULT '{}',
    embedding vector,
    provenance JSONB,
    inserted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- CACHING
-- ============================================================================

-- Table: model_response_cache
CREATE TABLE model_response_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cache_key TEXT NOT NULL,
    model_type TEXT NOT NULL,
    request_input JSONB NOT NULL,
    response_output JSONB NOT NULL,
    request_hash TEXT NOT NULL,
    
    hit_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '1 hour')
);

CREATE INDEX idx_cache_key ON model_response_cache(cache_key);
CREATE INDEX idx_cache_expires ON model_response_cache(expires_at);

-- ============================================================================
-- COMPOSITE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_test_executions_model_status ON test_executions(model_id, status);
CREATE INDEX idx_safety_assessments_risk_date ON safety_assessments(risk_level, assessed_at);
CREATE INDEX idx_client_models_status_risk ON client_models(status, risk_level);
CREATE INDEX idx_personas_tenant_type ON personas(tenant_id, persona_type);
CREATE INDEX idx_scenarios_tenant_status ON scenarios(tenant_id, status);

-- ============================================================================
-- VIEWS FOR REPORTING & ANALYSIS
-- ============================================================================

-- View: vw_latest_model_assessments
CREATE OR REPLACE VIEW vw_latest_model_assessments AS
SELECT 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status AS model_status,
    cm.risk_level AS model_risk_level,
    sa.assessment_id,
    sa.safety_score,
    sa.is_safe,
    sa.risk_level AS assessment_risk_level,
    sa.assessed_at,
    sa.confidence_score,
    mo.output_text,
    atc.test_name,
    atc.attack_type
FROM client_models cm
LEFT JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN model_outputs mo ON te.execution_id = mo.execution_id
LEFT JOIN safety_assessments sa ON mo.output_id = sa.output_id
LEFT JOIN adversarial_test_cases atc ON te.test_case_id = atc.test_case_id
WHERE sa.assessed_at = (
    SELECT MAX(sa2.assessed_at)
    FROM test_executions te2
    JOIN model_outputs mo2 ON te2.execution_id = mo2.execution_id
    JOIN safety_assessments sa2 ON mo2.output_id = sa2.output_id
    WHERE te2.model_id = cm.model_id
);

-- View: vw_model_safety_summary
CREATE OR REPLACE VIEW vw_model_safety_summary AS
SELECT 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status,
    COUNT(DISTINCT te.execution_id) AS total_tests,
    COUNT(DISTINCT CASE WHEN sa.is_safe = true THEN te.execution_id END) AS safe_tests,
    COUNT(DISTINCT CASE WHEN sa.is_safe = false THEN te.execution_id END) AS unsafe_tests,
    COUNT(DISTINCT CASE WHEN sa.risk_level = 'critical' THEN te.execution_id END) AS critical_risks,
    COUNT(DISTINCT CASE WHEN sa.risk_level = 'high' THEN te.execution_id END) AS high_risks,
    AVG(sa.safety_score) AS avg_safety_score,
    MAX(te.execution_start) AS last_test_date
FROM client_models cm
LEFT JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN model_outputs mo ON te.execution_id = mo.execution_id
LEFT JOIN safety_assessments sa ON mo.output_id = sa.output_id
GROUP BY 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status;

-- View: vw_active_alerts
CREATE OR REPLACE VIEW vw_active_alerts AS
SELECT 
    sa.alert_id,
    sa.alert_type,
    sa.severity,
    sa.title,
    sa.status,
    sa.detected_at,
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    ass.safety_score,
    ass.risk_level,
    EXTRACT(EPOCH FROM (NOW() - sa.detected_at))/3600 AS hours_open
FROM safety_alerts sa
JOIN client_models cm ON sa.model_id = cm.model_id
LEFT JOIN safety_assessments ass ON sa.assessment_id = ass.assessment_id
WHERE sa.status IN ('open', 'investigating');

-- View: vw_persona_with_traits
CREATE OR REPLACE VIEW vw_persona_with_traits AS
SELECT 
    p.id,
    p.display_name,
    p.name,
    p.persona_type,
    p.archetype,
    p.status,
    p.use_case_id,
    p.cohort_id,
    p.sub_cohort_id,
    
    jsonb_object_agg(
        DISTINCT dtc.key, 
        jsonb_build_object('raw_value', pd.raw_value, 'value', pd.value)
    ) FILTER (WHERE pd.persona_id IS NOT NULL) AS demographics,
    
    jsonb_object_agg(
        DISTINCT btc.key, 
        jsonb_build_object('raw_value', pbt.raw_value, 'value', pbt.value)
    ) FILTER (WHERE pbt.persona_id IS NOT NULL) AS behavioral_traits,
    
    jsonb_object_agg(
        DISTINCT ptc.key, 
        jsonb_build_object('raw_value', ppt.raw_value, 'value', ppt.value)
    ) FILTER (WHERE ppt.persona_id IS NOT NULL) AS psychographic_traits,
    
    jsonb_object_agg(
        DISTINCT ttc.key, 
        jsonb_build_object('raw_value', ptt.raw_value, 'value', ptt.value)
    ) FILTER (WHERE ptt.persona_id IS NOT NULL) AS technographic_traits,
    
    jsonb_object_agg(
        DISTINCT ltc.key, 
        jsonb_build_object('raw_value', plt.raw_value, 'value', plt.value)
    ) FILTER (WHERE plt.persona_id IS NOT NULL) AS linguistic_traits
    
FROM personas p
LEFT JOIN persona_demographics pd ON p.id = pd.persona_id
LEFT JOIN demographic_traits_catalog dtc ON pd.trait_id = dtc.id
LEFT JOIN persona_behavioral_traits pbt ON p.id = pbt.persona_id
LEFT JOIN behavioral_traits_catalog btc ON pbt.trait_id = btc.id
LEFT JOIN persona_psychographic_traits ppt ON p.id = ppt.persona_id
LEFT JOIN psychographic_traits_catalog ptc ON ppt.trait_id = ptc.id
LEFT JOIN persona_technographic_traits ptt ON p.id = ptt.persona_id
LEFT JOIN technographic_traits_catalog ttc ON ptt.trait_id = ttc.id
LEFT JOIN persona_linguistic_traits plt ON p.id = plt.persona_id
LEFT JOIN linguistic_traits_catalog ltc ON plt.trait_id = ltc.id
GROUP BY p.id;

-- ============================================================================
-- COMMENTS & DOCUMENTATION
-- ============================================================================

COMMENT ON DATABASE CURRENT_DATABASE IS 'Integrated Adversarial AI Safety & Persona Testing Database';

COMMENT ON TABLE tenants IS 'Central tenant/client management for multi-tenancy';
COMMENT ON TABLE personas IS 'Unified personas including regular users, adversarial actors, and internal testers';
COMMENT ON TABLE scenarios IS 'Test scenarios combining adversarial and persona-based testing';
COMMENT ON TABLE test_executions IS 'Records of test executions against client AI models';
COMMENT ON TABLE safety_assessments IS 'Safety evaluations of model outputs';
COMMENT ON TABLE ai_test_results IS 'Results from AI persona testing scenarios';
COMMENT ON TABLE threat_vectors IS 'Known threat vectors and attack patterns';
COMMENT ON TABLE context_profiles IS 'Customer context and intake information for risk assessment';

-- ============================================================================
-- END OF INTEGRATED SCHEMA
-- ============================================================================

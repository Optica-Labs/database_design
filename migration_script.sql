-- ============================================================================
-- DATABASE INTEGRATION MIGRATION SCRIPT
-- ============================================================================
-- Purpose: Migrate data from separate schemas to integrated schema
-- Prerequisites: 
--   1. Integrated schema (schema_integrated.sql) has been created
--   2. Original data is accessible (either in same DB or via foreign data wrapper)
-- ============================================================================

-- ============================================================================
-- STEP 1: TENANT MIGRATION
-- ============================================================================

-- Create tenants from unique client_ids in existing data
INSERT INTO tenants (id, tenant_name, client_id, industry, status)
SELECT 
    gen_random_uuid() AS id,
    client_id AS tenant_name,
    client_id,
    NULL AS industry,
    'active' AS status
FROM (
    SELECT DISTINCT client_id FROM old_schema.client_models
    UNION
    SELECT DISTINCT tenant_id FROM old_schema.personas WHERE tenant_id IS NOT NULL
) AS unique_clients
ON CONFLICT (client_id) DO NOTHING;

-- ============================================================================
-- STEP 2: USE CASE, COHORT, SUB-COHORT MIGRATION
-- ============================================================================

-- Migrate use_cases (if exists in source)
INSERT INTO use_cases (id, slug, name, description, created_at, updated_at)
SELECT 
    id,
    slug,
    name,
    description,
    created_at,
    updated_at
FROM old_schema.use_cases
ON CONFLICT (id) DO NOTHING;

-- Migrate cohorts (if exists in source)
INSERT INTO cohorts (id, use_case_id, name, description, created_at, updated_at)
SELECT 
    id,
    use_case_id,
    name,
    description,
    created_at,
    updated_at
FROM old_schema.cohorts
ON CONFLICT (id) DO NOTHING;

-- Migrate sub_cohorts (if exists in source)
INSERT INTO sub_cohorts (id, cohort_id, name, description, persona_type, created_at, updated_at)
SELECT 
    id,
    cohort_id,
    name,
    description,
    COALESCE(persona_type, 'regular')::text,
    created_at,
    updated_at
FROM old_schema.sub_cohorts
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 3: TRAIT CATALOG MIGRATION
-- ============================================================================

-- Migrate demographic traits catalog
INSERT INTO demographic_traits_catalog (id, key, label, data_type, allowed_values, description, persona_type, applicable_sub_cohorts)
SELECT 
    id,
    key,
    label,
    data_type,
    allowed_values,
    description,
    COALESCE(persona_type, 'regular')::text,
    COALESCE(applicable_sub_cohorts, '[]'::jsonb)
FROM old_schema.demographic_traits_catalog
ON CONFLICT (key) DO NOTHING;

-- Update sequence
SELECT setval('demographic_traits_catalog_id_seq', 
    (SELECT MAX(id) FROM demographic_traits_catalog), true);

-- Migrate behavioral traits catalog
INSERT INTO behavioral_traits_catalog (id, key, label, data_type, allowed_values, description, persona_type, applicable_sub_cohorts)
SELECT 
    id,
    key,
    label,
    data_type,
    allowed_values,
    description,
    COALESCE(persona_type, 'regular')::text,
    COALESCE(applicable_sub_cohorts, '[]'::jsonb)
FROM old_schema.behavioral_traits_catalog
ON CONFLICT (key) DO NOTHING;

SELECT setval('behavioral_traits_catalog_id_seq', 
    (SELECT MAX(id) FROM behavioral_traits_catalog), true);

-- Migrate psychographic traits catalog
INSERT INTO psychographic_traits_catalog (id, key, label, data_type, allowed_values, description, persona_type, applicable_sub_cohorts)
SELECT 
    id,
    key,
    label,
    data_type,
    allowed_values,
    description,
    COALESCE(persona_type, 'regular')::text,
    COALESCE(applicable_sub_cohorts, '[]'::jsonb)
FROM old_schema.psychographic_traits_catalog
ON CONFLICT (key) DO NOTHING;

SELECT setval('psychographic_traits_catalog_id_seq', 
    (SELECT MAX(id) FROM psychographic_traits_catalog), true);

-- Migrate technographic traits catalog
INSERT INTO technographic_traits_catalog (id, key, label, data_type, allowed_values, description, persona_type, applicable_sub_cohorts)
SELECT 
    id,
    key,
    label,
    data_type,
    allowed_values,
    description,
    COALESCE(persona_type, 'regular')::text,
    COALESCE(applicable_sub_cohorts, '[]'::jsonb)
FROM old_schema.technographic_traits_catalog
ON CONFLICT (key) DO NOTHING;

SELECT setval('technographic_traits_catalog_id_seq', 
    (SELECT MAX(id) FROM technographic_traits_catalog), true);

-- Migrate linguistic traits catalog
INSERT INTO linguistic_traits_catalog (id, key, label, data_type, allowed_values, description, persona_type)
SELECT 
    id,
    key,
    label,
    data_type,
    allowed_values,
    description,
    COALESCE(persona_type, 'regular')::text
FROM old_schema.linguistic_traits_catalog
ON CONFLICT (key) DO NOTHING;

SELECT setval('linguistic_traits_catalog_id_seq', 
    (SELECT MAX(id) FROM linguistic_traits_catalog), true);

-- ============================================================================
-- STEP 4: PERSONA MIGRATION
-- ============================================================================

-- Migrate from old ai_personas table
INSERT INTO personas (
    id, tenant_id, session_id, use_case_id, cohort_id, sub_cohort_id,
    name, display_name, slug, archetype, persona_type,
    overview, description, bio, quote,
    traits, constraints, attributes,
    source, is_ai, status, version, language,
    embedding, created_by, created_at, updated_at
)
SELECT 
    id::text,
    session_id AS tenant_id,  -- Using session_id as tenant_id for ai_personas
    session_id,
    NULL AS use_case_id,
    NULL AS cohort_id,
    NULL AS sub_cohort_id,
    COALESCE(name, 'Unknown'),
    name AS display_name,
    NULL AS slug,
    NULL AS archetype,
    CASE 
        WHEN cohort IN ('adversarial', 'internal') THEN cohort
        ELSE 'regular'
    END AS persona_type,
    NULL AS overview,
    NULL AS description,
    bio,
    quote,
    NULL AS traits,
    NULL AS constraints,
    jsonb_build_object(
        'cohort', cohort,
        'sub_cohort', sub_cohort,
        'tab', tab,
        'age', age,
        'sex', sex,
        'marital', marital,
        'children', children,
        'income', income,
        'education', education,
        'occupation', occupation,
        'primary_use', primary_use,
        'frequency', frequency,
        'motivations', motivations,
        'frustrations', frustrations,
        'devices', devices,
        'digital_skills', digital_skills
    ) AS attributes,
    'ai_generated' AS source,
    COALESCE(is_ai, true),
    'active' AS status,
    1 AS version,
    COALESCE(language, 'English'),
    NULL AS embedding,
    NULL AS created_by,
    created_at,
    created_at AS updated_at
FROM old_schema.ai_personas
ON CONFLICT (id) DO NOTHING;

-- Migrate from old personas table
INSERT INTO personas (
    id, tenant_id, session_id, use_case_id, cohort_id, sub_cohort_id,
    name, display_name, slug, archetype, persona_type,
    actor_type, domain, intent, skill_level,
    overview, description,
    traits, constraints, attributes,
    source, is_ai, status, version,
    embedding, created_by, created_at, updated_at
)
SELECT 
    id,
    tenant_id,
    NULL AS session_id,
    use_case_id,
    cohort_id,
    sub_cohort_id,
    name,
    display_name,
    slug,
    archetype,
    COALESCE(persona_type, 'regular')::text,
    actor_type,
    domain,
    intent,
    skill_level,
    overview,
    description,
    traits,
    constraints,
    COALESCE(attributes, '{}'::jsonb),
    source,
    true AS is_ai,
    COALESCE(status, 'active')::text,
    COALESCE(version, 1),
    embedding,
    created_by,
    created_at,
    updated_at
FROM old_schema.personas
ON CONFLICT (id) DO UPDATE SET
    -- Update if the record from personas table is more complete
    display_name = EXCLUDED.display_name,
    use_case_id = EXCLUDED.use_case_id,
    cohort_id = EXCLUDED.cohort_id,
    sub_cohort_id = EXCLUDED.sub_cohort_id;

-- Migrate persona traits
INSERT INTO persona_demographics (persona_id, trait_id, raw_value, value, updated_at)
SELECT persona_id, trait_id, raw_value, value, updated_at
FROM old_schema.persona_demographics
ON CONFLICT (persona_id, trait_id) DO UPDATE SET
    raw_value = EXCLUDED.raw_value,
    value = EXCLUDED.value,
    updated_at = EXCLUDED.updated_at;

INSERT INTO persona_behavioral_traits (persona_id, trait_id, raw_value, value, updated_at)
SELECT persona_id, trait_id, raw_value, value, updated_at
FROM old_schema.persona_behavioral_traits
ON CONFLICT (persona_id, trait_id) DO UPDATE SET
    raw_value = EXCLUDED.raw_value,
    value = EXCLUDED.value,
    updated_at = EXCLUDED.updated_at;

INSERT INTO persona_psychographic_traits (persona_id, trait_id, raw_value, value, updated_at)
SELECT persona_id, trait_id, raw_value, value, updated_at
FROM old_schema.persona_psychographic_traits
ON CONFLICT (persona_id, trait_id) DO UPDATE SET
    raw_value = EXCLUDED.raw_value,
    value = EXCLUDED.value,
    updated_at = EXCLUDED.updated_at;

INSERT INTO persona_technographic_traits (persona_id, trait_id, raw_value, value, updated_at)
SELECT persona_id, trait_id, raw_value, value, updated_at
FROM old_schema.persona_technographic_traits
ON CONFLICT (persona_id, trait_id) DO UPDATE SET
    raw_value = EXCLUDED.raw_value,
    value = EXCLUDED.value,
    updated_at = EXCLUDED.updated_at;

INSERT INTO persona_linguistic_traits (persona_id, trait_id, raw_value, value, updated_at)
SELECT persona_id, trait_id, raw_value, value, updated_at
FROM old_schema.persona_linguistic_traits
ON CONFLICT (persona_id, trait_id) DO UPDATE SET
    raw_value = EXCLUDED.raw_value,
    value = EXCLUDED.value,
    updated_at = EXCLUDED.updated_at;

-- ============================================================================
-- STEP 5: PERSONA COGNITION MIGRATION
-- ============================================================================

INSERT INTO persona_memories (id, persona_id, ts, type, content, metadata, embedding)
SELECT id, persona_id, ts, type, content, metadata, embedding
FROM old_schema.persona_memories
ON CONFLICT (id) DO NOTHING;

INSERT INTO persona_reflections (id, persona_id, ts, summary, embedding)
SELECT id, persona_id, ts, summary, embedding
FROM old_schema.persona_reflections
ON CONFLICT (id) DO NOTHING;

INSERT INTO persona_plans (id, persona_id, ts, plan, horizon, status)
SELECT id, persona_id, ts, plan, horizon, status
FROM old_schema.persona_plans
ON CONFLICT (id) DO NOTHING;

INSERT INTO persona_actions (id, persona_id, ts, input, output, metadata)
SELECT id, persona_id, ts, input, output, metadata
FROM old_schema.persona_actions
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 6: CONTEXT PROFILES & RISK ASSESSMENT
-- ============================================================================

INSERT INTO context_profiles (
    id, source_intake_id, tenant_id, industry, primary_use_case,
    objectives, goals, guardrails, frameworks, policies,
    api_endpoints, endpoint_url, model_stack, ml_stack, custom_models,
    guardrails_endpoint, guardrails_auth, api_access_level, integration_scan,
    legal_regulatory, regular_users_type, regular_users,
    attackers_type, attackers, ai_agents_type, ai_agents,
    user_distribution, personas_seed, risks_seed, plans, notes,
    created_at, updated_at
)
SELECT 
    cp.id,
    cp.source_intake_id,
    t.id AS tenant_id,
    cp.industry,
    cp.primary_use_case,
    cp.objectives,
    cp.goals,
    cp.guardrails,
    cp.frameworks,
    cp.policies,
    cp.api_endpoints,
    cp.endpoint_url,
    cp.model_stack,
    cp.ml_stack,
    cp.custom_models,
    cp.guardrails_endpoint,
    cp.guardrails_auth,
    cp.api_access_level,
    cp.integration_scan,
    cp.legal_regulatory,
    cp.regular_users_type,
    cp.regular_users,
    cp.attackers_type,
    cp.attackers,
    cp.ai_agents_type,
    cp.ai_agents,
    cp.user_distribution,
    cp.personas_seed,
    cp.risks_seed,
    cp.plans,
    cp.notes,
    cp.created_at,
    cp.updated_at
FROM old_schema.context_profiles cp
LEFT JOIN tenants t ON t.client_id = cp.source_intake_id
ON CONFLICT (source_intake_id) DO NOTHING;

INSERT INTO risk_assessments (
    id, context_profile_id, source_intake_id, assessment_mode,
    threats, scenarios, summary,
    agent_endpoint, generation_time_ms, api_response_status, error_message,
    created_at, updated_at
)
SELECT 
    id, context_profile_id, source_intake_id, assessment_mode::text,
    threats, scenarios, summary,
    agent_endpoint, generation_time_ms, api_response_status, error_message,
    created_at, updated_at
FROM old_schema.risk_assessments
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 7: THREAT VECTORS, RISKS, HARMS
-- ============================================================================

INSERT INTO threat_vectors (
    id, id_uuid, source, name, description, category,
    threat_categories, harm_categories, modalities, tags,
    framework_alignment, metadata, severity, mitigation,
    raw_json, embedding, created_at, updated_at
)
SELECT 
    id, id_uuid, source, name, description, category,
    threat_categories, harm_categories, modalities, 
    COALESCE(tags, ARRAY[]::text[]),
    framework_alignment, metadata, severity, mitigation,
    raw_json, embedding, created_at, updated_at
FROM old_schema.threat_vectors
ON CONFLICT (id) DO NOTHING;

INSERT INTO threat_examples (
    id, vector_id, source, raw_json,
    example_text, persona_samples, scenario_text, expected_system_response, evidence_refs,
    severity, detection_methods, mitigation, lifecycle_phase, exploitation_complexity, modalities,
    embedding, created_at
)
SELECT 
    id, vector_id, source, raw_json,
    example_text, persona_samples, scenario_text, expected_system_response, evidence_refs,
    severity, detection_methods, mitigation, lifecycle_phase, exploitation_complexity, modalities,
    embedding, created_at
FROM old_schema.threat_examples
ON CONFLICT (id) DO NOTHING;

INSERT INTO risks (id, name, description, embedding)
SELECT id, name, description, embedding
FROM old_schema.risks
ON CONFLICT (id) DO NOTHING;

INSERT INTO harms (id, name, description, embedding)
SELECT id, name, description, embedding
FROM old_schema.harms
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 8: TEST CATEGORIES & TYPES
-- ============================================================================

-- Migrate test_categories (if exists in SQL Server schema)
-- This assumes you have a way to access the SQL Server data
-- Adjust based on your migration strategy (foreign data wrapper, exported CSV, etc.)

-- For new installations, insert default categories:
INSERT INTO test_categories (category_name, description, severity_level)
VALUES 
    ('Adversarial Attacks', 'Tests for adversarial robustness', 'high'),
    ('Bias & Fairness', 'Tests for bias and fairness issues', 'high'),
    ('Privacy & Security', 'Tests for privacy and security vulnerabilities', 'critical'),
    ('Reliability', 'Tests for reliability and consistency', 'medium'),
    ('Safety & Ethics', 'Tests for safety and ethical concerns', 'critical')
ON CONFLICT (category_name) DO NOTHING;

-- Migrate test_types
INSERT INTO test_types (id, name, description, category, category_id, session_id, embedding, created_at)
SELECT 
    id,
    name,
    description,
    category,
    (SELECT category_id FROM test_categories WHERE category_name = 'Adversarial Attacks' LIMIT 1) AS category_id,
    session_id,
    embedding,
    created_at
FROM old_schema.test_types
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 9: SCENARIOS
-- ============================================================================

-- Migrate from ai_scenarios
INSERT INTO scenarios (
    id, tenant_id, session_id, persona_id,
    title, name, scenario_id,
    description, context, constraints, expected_behaviors,
    risk_vectors, harm_categories, stack_tags, tags,
    relevance_score, severity, likelihood,
    objectives, generated_prompt,
    status, metadata, raw_data,
    created_at, updated_at
)
SELECT 
    id::text,
    session_id AS tenant_id,
    session_id,
    persona_id,
    COALESCE(scenario_name, title, 'Untitled'),
    name,
    scenario_id,
    COALESCE(scenario_description, description),
    context,
    constraints::text,
    expected_behaviors::text,
    ARRAY[risk_vector]::text[],
    ARRAY[harm_category]::text[],
    ARRAY[]::text[],
    tags::text,
    relevance_score,
    severity,
    likelihood,
    COALESCE(objectives, '[]'::jsonb),
    generated_prompt,
    'created' AS status,
    jsonb_build_object(
        'kb_pattern_id', kb_pattern_id,
        'kb_pattern_title', kb_pattern_title,
        'sub_vector', sub_vector
    ),
    raw_data,
    created_at,
    COALESCE(updated_at, created_at)
FROM old_schema.ai_scenarios
ON CONFLICT (id) DO NOTHING;

-- Migrate from scenarios table
INSERT INTO scenarios (
    id, tenant_id, session_id, persona_id,
    title, name,
    description, context, constraints, expected_behaviors,
    risk_vectors, harm_categories, stack_tags, tags,
    objectives, generated_prompt,
    status, metadata,
    created_at, updated_at
)
SELECT 
    id,
    tenant_id,
    session_id,
    persona_id::text,
    title,
    name,
    description,
    context,
    constraints,
    expected_behaviors,
    COALESCE(risk_vectors, ARRAY[]::text[]),
    COALESCE(harm_categories, ARRAY[]::text[]),
    COALESCE(stack_tags, ARRAY[]::text[]),
    tags,
    COALESCE(objectives, '[]'::jsonb),
    generated_prompt,
    COALESCE(status, 'created'),
    COALESCE(metadata, '{}'::jsonb),
    created_at,
    updated_at
FROM old_schema.scenarios
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    updated_at = EXCLUDED.updated_at;

-- Migrate scenario relationships
INSERT INTO scenario_intents (
    id, scenario_id, intent_name, description,
    temporal_trigger, spatial_trigger, event_trigger,
    social_context, environmental_context,
    steps, available_actions, decision_points,
    objects_involved, object_states,
    scenario_goal, success_criteria, failure_conditions, constraints,
    information_channels, visibility_rules,
    frequency, relevance_score, status, priority, tags,
    created_at, updated_at
)
SELECT 
    id, scenario_id::text, intent_name, description,
    temporal_trigger, spatial_trigger, event_trigger,
    social_context, environmental_context,
    steps, available_actions, decision_points,
    objects_involved, object_states,
    scenario_goal, success_criteria, failure_conditions, constraints,
    information_channels, visibility_rules,
    frequency, relevance_score, status, priority, tags,
    created_at, updated_at
FROM old_schema.scenario_intents
ON CONFLICT (id) DO NOTHING;

INSERT INTO scenario_intent_personas (intent_id, persona_id, relevance_score, notes, created_at)
SELECT intent_id, persona_id, relevance_score, notes, created_at
FROM old_schema.scenario_intent_personas
ON CONFLICT (intent_id, persona_id) DO NOTHING;

INSERT INTO scenario_personas (id, scenario_id, persona_id, relevance_score, created_at)
SELECT id, scenario_id, persona_id, relevance_score, created_at
FROM old_schema.scenario_personas
ON CONFLICT (id) DO NOTHING;

INSERT INTO scenario_threats (id, scenario_id, threat_vector_id, relevance_score, created_at)
SELECT id, scenario_id, threat_vector_id, relevance_score, created_at
FROM old_schema.scenario_threats
ON CONFLICT (id) DO NOTHING;

INSERT INTO scenario_scores (id, scenario_id, score_type, score_value, metadata, created_at)
SELECT id, scenario_id, score_type, score_value, metadata, created_at
FROM old_schema.scenario_scores
ON CONFLICT (id) DO NOTHING;

INSERT INTO scenario_test_types (id, scenario_id, test_type_id, created_at)
SELECT id, scenario_id, test_type_id, created_at
FROM old_schema.scenario_test_types
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 10: TEST SESSIONS
-- ============================================================================

INSERT INTO test_sessions (
    id, session_id, customer_id, tenant_id,
    session_name, description, customer_data,
    status, tags, metadata,
    created_at, updated_at
)
SELECT 
    id,
    session_id,
    customer_id,
    (SELECT id FROM tenants WHERE client_id = customer_id LIMIT 1) AS tenant_id,
    session_name,
    description,
    customer_data,
    status,
    COALESCE(tags, ARRAY[]::text[]),
    COALESCE(metadata, '{}'::jsonb),
    created_at,
    updated_at
FROM old_schema.test_sessions
ON CONFLICT (session_id) DO NOTHING;

-- ============================================================================
-- STEP 11: TEST SETS, UNITS, TURNS
-- ============================================================================

INSERT INTO test_sets (id, tenant_id, created_by, scenario, persona, risks, harms, test_type, status, created_at)
SELECT id, tenant_id, created_by, scenario, persona, risks, harms, test_type, status, created_at
FROM old_schema.test_sets
ON CONFLICT (id) DO NOTHING;

INSERT INTO test_units (id, test_set_id, label, ord)
SELECT id, test_set_id, label, ord
FROM old_schema.test_units
ON CONFLICT (id) DO NOTHING;

INSERT INTO test_turns (id, unit_id, role, content, expected_behavior, scoring, ord, source, embedding)
SELECT id, unit_id, role::text, content, expected_behavior, scoring, ord, source, embedding
FROM old_schema.test_turns
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 12: AI AGENTS (if migrating from SQL Server)
-- ============================================================================

-- Note: This section assumes you have exported SQL Server data to a temporary table
-- or are using a foreign data wrapper. Adjust the source accordingly.

-- Example using a temporary staging table:
-- INSERT INTO ai_agents (agent_name, agent_type, model_architecture, version, ...)
-- SELECT agent_name, agent_type, ... FROM staging.sql_server_ai_agents;

-- ============================================================================
-- STEP 13: CLIENT MODELS
-- ============================================================================

-- Migrate client_models from SQL Server
-- INSERT INTO client_models (...)
-- SELECT ... FROM staging.sql_server_client_models scm
-- JOIN tenants t ON t.client_id = scm.client_id;

-- ============================================================================
-- STEP 14: TEST EXECUTION & RESULTS
-- ============================================================================

-- Migrate adversarial_test_cases
-- INSERT INTO adversarial_test_cases (...)
-- SELECT ... FROM staging.sql_server_test_cases;

-- Migrate test_executions
-- INSERT INTO test_executions (...)
-- SELECT ... FROM staging.sql_server_test_executions;

-- Migrate model_outputs
-- INSERT INTO model_outputs (...)
-- SELECT ... FROM staging.sql_server_model_outputs;

-- Migrate safety_assessments
-- INSERT INTO safety_assessments (...)
-- SELECT ... FROM staging.sql_server_safety_assessments;

-- Migrate safety_metrics
-- INSERT INTO safety_metrics (...)
-- SELECT ... FROM staging.sql_server_safety_metrics;

-- Migrate ai_test_results
INSERT INTO ai_test_results (
    id, session_id, test_type_id, persona_id, scenario_id,
    status, severity, findings, evidence, recommendations, tags,
    executed_at, completed_at, duration_ms, created_at
)
SELECT 
    id,
    session_id,
    test_type_id,
    persona_id,
    scenario_id,
    status::text,
    severity::text,
    COALESCE(findings, ARRAY[]::text[]),
    evidence,
    COALESCE(recommendations, ARRAY[]::text[]),
    COALESCE(tags, ARRAY[]::text[]),
    executed_at,
    completed_at,
    duration_ms,
    created_at
FROM old_schema.ai_test_results
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 15: PROMPT GENERATION & RESPONSES
-- ============================================================================

INSERT INTO prompt_generator_responses (id, session_id, persona_id, persona_name, test_types, prompts, raw_output, created_at)
SELECT id, session_id, persona_id, persona_name, test_types, prompts, raw_output, created_at
FROM old_schema.prompt_generator_responses
ON CONFLICT (id) DO NOTHING;

INSERT INTO prompt_response_metadata (
    id, prompt_response_id, session_id, persona_id, test_type_id, scenario_id, threat_vector_id,
    final_prompt, final_response, model_name, model_version, provider,
    latency_ms, token_input, token_output, metadata, created_at
)
SELECT 
    id, prompt_response_id, session_id, persona_id, test_type_id, scenario_id, threat_vector_id,
    final_prompt, final_response, model_name, model_version, provider,
    latency_ms, token_input, token_output, metadata, created_at
FROM old_schema.prompt_response_metadata
ON CONFLICT (id) DO NOTHING;

INSERT INTO nyc_test_results (
    id, prompt_response_id, session_id, persona_id, persona_name,
    test_type, prompt, response, execution_time_ms, success, error_message, created_at
)
SELECT 
    id, prompt_response_id, session_id, persona_id, persona_name,
    test_type, prompt, response, execution_time_ms, success, error_message, created_at
FROM old_schema.nyc_test_results
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 16: KNOWLEDGE BASE
-- ============================================================================

INSERT INTO sources (id, name, source_type, location, config, is_active, inserted_at)
SELECT id, name, source_type::text, location, config, is_active, inserted_at
FROM old_schema.sources
ON CONFLICT (id) DO NOTHING;

SELECT setval('sources_id_seq', (SELECT MAX(id) FROM sources), true);

INSERT INTO crawls (id, source_id, started_at, finished_at, status, stats)
SELECT id, source_id, started_at, finished_at, status, stats
FROM old_schema.crawls
ON CONFLICT (id) DO NOTHING;

SELECT setval('crawls_id_seq', (SELECT MAX(id) FROM crawls), true);

INSERT INTO raw_items (id, source_id, external_id, title, raw_text, metadata, content_type, sha256, inserted_at)
SELECT id, source_id, external_id, title, raw_text, metadata, content_type, sha256, inserted_at
FROM old_schema.raw_items
ON CONFLICT (id) DO NOTHING;

SELECT setval('raw_items_id_seq', (SELECT MAX(id) FROM raw_items), true);

INSERT INTO scenario_seeds (id, title, summary, persona_hint, scenario_context, linked_techniques, risk_vector, harm_category, tags, embedding, provenance, inserted_at)
SELECT id, title, summary, persona_hint, scenario_context, linked_techniques, risk_vector, harm_category, tags, embedding, provenance, inserted_at
FROM old_schema.scenario_seeds
ON CONFLICT (id) DO NOTHING;

SELECT setval('scenario_seeds_id_seq', (SELECT MAX(id) FROM scenario_seeds), true);

-- ============================================================================
-- STEP 17: CACHING
-- ============================================================================

-- Note: Cache data is typically not migrated as it's ephemeral
-- If needed, you can migrate recent cache entries:
INSERT INTO model_response_cache (
    id, cache_key, model_type, request_input, response_output, request_hash,
    hit_count, created_at, updated_at, expires_at
)
SELECT 
    id, cache_key, model_type, request_input, response_output, request_hash,
    hit_count, created_at, updated_at, expires_at
FROM old_schema.model_response_cache
WHERE expires_at > NOW()
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 18: ALERTS & COMPLIANCE (SQL Server data)
-- ============================================================================

-- Migrate safety_alerts
-- INSERT INTO safety_alerts (...)
-- SELECT ... FROM staging.sql_server_safety_alerts;

-- Migrate compliance_reports
-- INSERT INTO compliance_reports (...)
-- SELECT ... FROM staging.sql_server_compliance_reports;

-- ============================================================================
-- STEP 19: AUDIT LOGS
-- ============================================================================

-- Note: Audit logs can be large. Consider:
-- 1. Only migrating recent logs (last 90 days)
-- 2. Archiving old logs separately
-- 3. Starting fresh with integrated system

-- Example: Migrate recent audit logs only
-- INSERT INTO audit_logs (...)
-- SELECT ... FROM staging.sql_server_audit_logs
-- WHERE timestamp >= NOW() - INTERVAL '90 days';

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Run these queries to validate the migration

-- Check record counts
SELECT 'tenants' AS table_name, COUNT(*) AS count FROM tenants
UNION ALL SELECT 'personas', COUNT(*) FROM personas
UNION ALL SELECT 'scenarios', COUNT(*) FROM scenarios
UNION ALL SELECT 'test_sessions', COUNT(*) FROM test_sessions
UNION ALL SELECT 'threat_vectors', COUNT(*) FROM threat_vectors
UNION ALL SELECT 'context_profiles', COUNT(*) FROM context_profiles
UNION ALL SELECT 'test_types', COUNT(*) FROM test_types
ORDER BY table_name;

-- Check for orphaned records (records with invalid foreign keys)
SELECT 'personas_without_tenant' AS issue, COUNT(*) AS count
FROM personas p
WHERE NOT EXISTS (SELECT 1 FROM tenants t WHERE t.tenant_id = p.tenant_id)

UNION ALL

SELECT 'scenarios_without_persona', COUNT(*)
FROM scenarios s
WHERE s.persona_id IS NOT NULL 
  AND NOT EXISTS (SELECT 1 FROM personas p WHERE p.id = s.persona_id)

UNION ALL

SELECT 'test_sessions_without_tenant', COUNT(*)
FROM test_sessions ts
WHERE ts.tenant_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM tenants t WHERE t.id = ts.tenant_id);

-- Check persona trait linkages
SELECT 
    'persona_demographics' AS trait_type,
    COUNT(DISTINCT persona_id) AS personas_with_traits,
    COUNT(*) AS total_trait_values
FROM persona_demographics
UNION ALL
SELECT 'persona_behavioral_traits', COUNT(DISTINCT persona_id), COUNT(*)
FROM persona_behavioral_traits
UNION ALL
SELECT 'persona_psychographic_traits', COUNT(DISTINCT persona_id), COUNT(*)
FROM persona_psychographic_traits
UNION ALL
SELECT 'persona_technographic_traits', COUNT(DISTINCT persona_id), COUNT(*)
FROM persona_technographic_traits
UNION ALL
SELECT 'persona_linguistic_traits', COUNT(DISTINCT persona_id), COUNT(*)
FROM persona_linguistic_traits;

-- Verify views work correctly
SELECT COUNT(*) AS persona_with_traits_view_count FROM vw_persona_with_traits;

-- ============================================================================
-- POST-MIGRATION TASKS
-- ============================================================================

-- 1. Update statistics
ANALYZE;

-- 2. Refresh materialized views (if any were created)
-- REFRESH MATERIALIZED VIEW mv_persona_summary;

-- 3. Verify indexes
SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 4. Check for missing indexes on foreign keys
SELECT
    tc.table_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE tablename = tc.table_name 
      AND indexdef LIKE '%' || kcu.column_name || '%'
  )
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================================
-- END OF MIGRATION SCRIPT
-- ============================================================================

-- Migration completed!
-- Next steps:
-- 1. Run validation queries above
-- 2. Test application connectivity
-- 3. Perform smoke tests on key features
-- 4. Monitor performance and optimize as needed
-- 5. Set up regular backups
-- 6. Document any custom post-migration adjustments

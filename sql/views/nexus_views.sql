-- ============================================================================
-- NEXUS INTEGRATION VIEWS
-- ============================================================================
-- Views for Nexus prompt ingestion and library monitoring

-- 1. View: vw_nexus_prompt_library
-- Unified Nexus prompt library with source context
CREATE OR REPLACE VIEW vw_nexus_prompt_library AS
SELECT 
    npl.id AS nexus_prompt_id,
    npl.tenant_id,
    npl.source_type,
    npl.prompt_text,
    npl.status,
    npl.quality_score,
    npl.created_at,
    npl.updated_at,

    cps.id AS client_prompt_id,
    cps.submitted_by,
    cps.submission_channel,
    cps.status AS client_submission_status,

    t.id AS cat_turn_id,
    t.turn_id AS cat_turn_ref,
    t.stage AS cat_stage,
    t.auto_quality_score AS cat_auto_quality_score,
    t.base_model_name AS cat_base_model_name,
    t.base_model_version AS cat_base_model_version
FROM nexus_prompt_library npl
LEFT JOIN client_prompt_submissions cps ON npl.client_prompt_id = cps.id
LEFT JOIN turns t ON npl.cat_turn_id = t.id
WHERE npl.product_id = (SELECT id FROM products WHERE product_code = 'nexus');

-- 2. View: vw_nexus_stage4_candidates
-- Re-expose Stage 4 Cat-Astrophic prompt candidates (for Nexus ingestion)
CREATE OR REPLACE VIEW vw_nexus_stage4_candidates AS
SELECT 
    t.id AS cat_turn_id,
    c.conversation_id AS cat_conversation_ref,
    c.generation_run_id,
    t.turn_id AS cat_turn_ref,
    t.response AS prompt_text,
    t.prompt AS stage4_input,
    t.auto_quality_score,
    t.base_model_name,
    t.base_model_version,
    t.status,
    t.created_at
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
  AND t.stage = 4
  AND t.status = 'completed';

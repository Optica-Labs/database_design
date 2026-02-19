-- ============================================================================
-- CAT-ASTROPHIC INTEGRATION VIEWS
-- ============================================================================
-- Materialized views for Cat-Astrophic analysis in AI-Range
-- All views are filtered by AI-Range product

-- ============================================================================
-- 1. VIEW: vw_generation_run_summary
-- Overview of each generation run with aggregated metrics
-- ============================================================================

CREATE OR REPLACE VIEW vw_generation_run_summary AS
SELECT 
    gr.generation_run_id,
    gr.modality,
    gr.status,
    COUNT(DISTINCT c.id) as num_conversations,
    COUNT(DISTINCT t.id) as num_turns,
    COALESCE(SUM(t.total_tokens), 0) as total_tokens,
    COALESCE(AVG(t.latency_ms), 0) as avg_latency_ms,
    COALESCE(AVG(t.auto_quality_score), 0) as avg_quality_score,
    COUNT(DISTINCT t.base_model_name) as num_models_used,
    COUNT(CASE WHEN c.human_in_loop = TRUE THEN 1 END) as conversations_with_human_feedback,
    (t_meta.egression_time - t_meta.ingression_time) as duration,
    gr.created_at,
    gr.updated_at
FROM generation_runs gr
LEFT JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
LEFT JOIN telemetry t_meta ON gr.id = t_meta.generation_run_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY 
    gr.id, gr.generation_run_id, gr.modality, gr.status, 
    t_meta.egression_time, t_meta.ingression_time,
    gr.created_at, gr.updated_at;

-- ============================================================================
-- 2. VIEW: vw_model_performance
-- Performance metrics by base model
-- ============================================================================

CREATE OR REPLACE VIEW vw_model_performance AS
SELECT 
    t.base_model_id,
    t.base_model_name,
    t.base_model_version,
    COUNT(*) as num_turns,
    COUNT(DISTINCT c.conversation_id) as num_conversations,
    ROUND(AVG(t.prompt_tokens)::numeric, 2) as avg_prompt_tokens,
    ROUND(AVG(t.response_tokens)::numeric, 2) as avg_response_tokens,
    ROUND(AVG(t.total_tokens)::numeric, 2) as avg_total_tokens,
    ROUND(AVG(t.latency_ms)::numeric, 2) as avg_latency_ms,
    MAX(t.latency_ms) as max_latency_ms,
    MIN(t.latency_ms) as min_latency_ms,
    ROUND(AVG(t.auto_quality_score)::numeric, 4) as avg_quality_score,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as successful_turns,
    COUNT(CASE WHEN t.status = 'failed' THEN 1 END) as failed_turns,
    ROUND((COUNT(CASE WHEN t.status = 'completed' THEN 1 END)::numeric / COUNT(*) * 100), 2) as success_rate_pct
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND t.base_model_name IS NOT NULL
GROUP BY t.base_model_id, t.base_model_name, t.base_model_version;

-- ============================================================================
-- 3. VIEW: vw_quality_assessment_summary
-- Quality metrics aggregated by methodology
-- ============================================================================

CREATE OR REPLACE VIEW vw_quality_assessment_summary AS
SELECT 
    qm.methodology,
    COUNT(*) as num_assessments,
    COUNT(DISTINCT qm.conversation_id) as num_conversations,
    ROUND(AVG(qm.fit_score)::numeric, 4) as avg_fit_score,
    ROUND(AVG(qm.diversity_score)::numeric, 4) as avg_diversity_score,
    ROUND(AVG(qm.policy_risk_score)::numeric, 4) as avg_policy_risk_score,
    ROUND(AVG(qm.length_score)::numeric, 4) as avg_length_score,
    ROUND(MIN(qm.fit_score)::numeric, 4) as min_fit_score,
    ROUND(MAX(qm.fit_score)::numeric, 4) as max_fit_score,
    ROUND(STDDEV(qm.fit_score)::numeric, 4) as stddev_fit_score,
    COUNT(CASE WHEN qm.policy_risk_score >= 0.7 THEN 1 END) as high_risk_count,
    MIN(qm.created_at) as first_assessment,
    MAX(qm.created_at) as last_assessment
FROM quality_metrics qm
WHERE qm.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND qm.methodology IS NOT NULL AND qm.methodology != ''
GROUP BY qm.methodology;

-- ============================================================================
-- 4. VIEW: vw_conversation_quality
-- Per-conversation quality and health metrics
-- ============================================================================

CREATE OR REPLACE VIEW vw_conversation_quality AS
SELECT 
    c.conversation_id,
    c.ai_range_model_name,
    c.human_in_loop,
    COUNT(DISTINCT t.id) as num_turns,
    ROUND(AVG(t.auto_quality_score)::numeric, 4) as avg_turn_quality,
    c.diversity_score,
    COALESCE(qm.fit_score, 0) as quality_fit_score,
    COALESCE(qm.policy_risk_score, 0) as quality_policy_risk,
    COALESCE(SUM(t.total_tokens), 0) as total_tokens,
    COALESCE(AVG(t.latency_ms), 0) as avg_latency_ms,
    c.created_at,
    c.updated_at
FROM conversations c
LEFT JOIN turns t ON c.id = t.conversation_id
LEFT JOIN quality_metrics qm ON c.id = qm.conversation_id
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY 
    c.id, c.conversation_id, c.ai_range_model_name, c.human_in_loop,
    c.diversity_score, qm.fit_score, qm.policy_risk_score,
    c.created_at, c.updated_at;

-- ============================================================================
-- 5. VIEW: vw_api_performance
-- LLM API invocation performance and reliability
-- ============================================================================

CREATE OR REPLACE VIEW vw_api_performance AS
SELECT 
    li.model_id,
    COUNT(*) as num_calls,
    COUNT(CASE WHEN li.status = 'success' THEN 1 END) as successful_calls,
    COUNT(CASE WHEN li.status = 'failed' THEN 1 END) as failed_calls,
    COUNT(CASE WHEN li.status = 'error' THEN 1 END) as error_calls,
    ROUND((COUNT(CASE WHEN li.status = 'success' THEN 1 END)::numeric / COUNT(*) * 100), 2) as success_rate_pct,
    ROUND(AVG(li.latency_ms)::numeric, 2) as avg_latency_ms,
    ROUND(MAX(li.latency_ms)::numeric, 2) as max_latency_ms,
    ROUND(MIN(li.latency_ms)::numeric, 2) as min_latency_ms,
    ROUND(STDDEV(li.latency_ms)::numeric, 2) as stddev_latency_ms,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    SUM(li.prompt_tokens + li.completion_tokens) as total_tokens,
    COUNT(CASE WHEN li.cache_hit = TRUE THEN 1 END) as cache_hits,
    ROUND((COUNT(CASE WHEN li.cache_hit = TRUE THEN 1 END)::numeric / COUNT(*) * 100), 2) as cache_hit_rate_pct,
    ROUND(AVG(li.retry_count)::numeric, 2) as avg_retry_count,
    MIN(li.created_at) as first_call,
    MAX(li.created_at) as last_call
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY li.model_id;

-- ============================================================================
-- 6. VIEW: vw_pipeline_stage_metrics
-- Performance by pipeline stage
-- ============================================================================

CREATE OR REPLACE VIEW vw_pipeline_stage_metrics AS
SELECT 
    t.stage,
    COUNT(*) as num_turns,
    COUNT(DISTINCT c.conversation_id) as num_conversations,
    ROUND(AVG(t.latency_ms)::numeric, 2) as avg_latency_ms,
    ROUND(MAX(t.latency_ms)::numeric, 2) as max_latency_ms,
    ROUND(AVG(t.prompt_tokens)::numeric, 2) as avg_prompt_tokens,
    ROUND(AVG(t.response_tokens)::numeric, 2) as avg_response_tokens,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as successful,
    COUNT(CASE WHEN t.status = 'failed' THEN 1 END) as failed,
    ROUND((COUNT(CASE WHEN t.status = 'completed' THEN 1 END)::numeric / COUNT(*) * 100), 2) as success_rate_pct,
    ROUND(AVG(t.auto_quality_score)::numeric, 4) as avg_quality_score
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND t.stage IS NOT NULL
GROUP BY t.stage
ORDER BY t.stage;

-- ============================================================================
-- 7. VIEW: vw_human_feedback_impact
-- Analysis of human-in-the-loop feedback effectiveness
-- ============================================================================

CREATE OR REPLACE VIEW vw_human_feedback_impact AS
SELECT 
    COUNT(DISTINCT CASE WHEN c.human_in_loop = FALSE THEN c.id END) as conversations_without_feedback,
    COUNT(DISTINCT CASE WHEN c.human_in_loop = TRUE THEN c.id END) as conversations_with_feedback,
    ROUND(AVG(CASE WHEN c.human_in_loop = FALSE THEN c.diversity_score ELSE NULL END)::numeric, 4) 
        as avg_diversity_no_feedback,
    ROUND(AVG(CASE WHEN c.human_in_loop = TRUE THEN c.diversity_score ELSE NULL END)::numeric, 4) 
        as avg_diversity_with_feedback,
    ROUND(AVG(CASE WHEN c.human_in_loop = FALSE THEN t.auto_quality_score ELSE NULL END)::numeric, 4) 
        as avg_quality_no_feedback,
    ROUND(AVG(CASE WHEN c.human_in_loop = TRUE THEN t.auto_quality_score ELSE NULL END)::numeric, 4) 
        as avg_quality_with_feedback,
    COUNT(DISTINCT CASE WHEN c.human_in_loop = TRUE AND c.human_in_loop_details != '' THEN c.id END) 
        as conversations_with_detailed_feedback
FROM conversations c
LEFT JOIN turns t ON c.id = t.conversation_id
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range');

-- ============================================================================
-- 8. VIEW: vw_error_analysis
-- API errors and failure analysis
-- ============================================================================

CREATE OR REPLACE VIEW vw_error_analysis AS
SELECT 
    li.error_code,
    li.error_message,
    COUNT(*) as num_occurrences,
    COUNT(DISTINCT li.model_id) as num_models,
    ROUND(AVG(li.retry_count)::numeric, 2) as avg_retries,
    MAX(li.created_at) as last_occurrence,
    MIN(li.created_at) as first_occurrence,
    (MAX(li.created_at) - MIN(li.created_at)) as time_span
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.status IN ('failed', 'error')
AND li.error_code IS NOT NULL
GROUP BY li.error_code, li.error_message
ORDER BY num_occurrences DESC;

-- ============================================================================
-- 9. VIEW: vw_token_usage_trends
-- Token consumption patterns and trends
-- ============================================================================

CREATE OR REPLACE VIEW vw_token_usage_trends AS
SELECT 
    DATE_TRUNC('day', li.created_at)::DATE as date,
    COUNT(DISTINCT li.model_id) as num_models,
    COUNT(*) as num_api_calls,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    SUM(li.prompt_tokens + li.completion_tokens) as total_tokens,
    ROUND(AVG(li.latency_ms)::numeric, 2) as avg_latency_ms,
    COUNT(CASE WHEN li.status = 'success' THEN 1 END) as successful_calls,
    COUNT(CASE WHEN li.status = 'failed' THEN 1 END) as failed_calls
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY DATE_TRUNC('day', li.created_at)
ORDER BY date DESC;

-- ============================================================================
-- 10. VIEW: vw_conversation_lineage
-- Complete lineage of conversations with their run context
-- ============================================================================

CREATE OR REPLACE VIEW vw_conversation_lineage AS
SELECT 
    gr.generation_run_id as run_id,
    c.conversation_id,
    c.ai_range_model_name,
    c.ai_range_temperature,
    COUNT(DISTINCT t.id) as num_turns,
    COALESCE(SUM(t.total_tokens), 0) as total_tokens,
    COALESCE(AVG(t.auto_quality_score), 0) as avg_quality,
    c.human_in_loop,
    ARRAY_AGG(DISTINCT qm.methodology) FILTER (WHERE qm.methodology IS NOT NULL) as quality_methodologies,
    ARRAY_AGG(DISTINCT t.base_model_name) FILTER (WHERE t.base_model_name IS NOT NULL) as models_used,
    gr.created_at as run_created_at,
    c.created_at as conversation_created_at
FROM generation_runs gr
JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
LEFT JOIN quality_metrics qm ON c.id = qm.conversation_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY 
    gr.id, gr.generation_run_id, 
    c.id, c.conversation_id, c.ai_range_model_name, c.ai_range_temperature,
    c.human_in_loop, gr.created_at, c.created_at;

-- ============================================================================
-- 11. VIEW: vw_data_quality_metrics
-- Monitor data integrity and quality
-- ============================================================================

CREATE OR REPLACE VIEW vw_data_quality_metrics AS
SELECT 
    'generation_runs' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN status IS NULL THEN 1 END) as null_status,
    COUNT(CASE WHEN status NOT IN ('in_progress', 'completed', 'failed') THEN 1 END) as invalid_status
FROM generation_runs
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')

UNION ALL

SELECT 
    'conversations' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN generation_run_id IS NULL THEN 1 END) as null_generation_run,
    COUNT(CASE WHEN conversation_id IS NULL THEN 1 END) as null_conversation_id
FROM conversations
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')

UNION ALL

SELECT 
    'turns' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN conversation_id IS NULL THEN 1 END) as null_conversation_id,
    COUNT(CASE WHEN total_tokens <= 0 THEN 1 END) as invalid_tokens
FROM turns
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')

UNION ALL

SELECT 
    'quality_metrics' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN conversation_id IS NULL THEN 1 END) as null_conversation_id,
    COUNT(CASE WHEN fit_score < 0 OR fit_score > 1 THEN 1 END) as invalid_scores
FROM quality_metrics
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')

UNION ALL

SELECT 
    'llm_invocations' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN invocation_id IS NULL THEN 1 END) as null_invocation_id,
    COUNT(CASE WHEN status NOT IN ('success', 'failed', 'error') THEN 1 END) as invalid_status
FROM llm_invocations
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range');

-- ============================================================================
-- 12. VIEW: vw_cost_estimation
-- Estimate costs based on token usage
-- ============================================================================

CREATE OR REPLACE VIEW vw_cost_estimation AS
SELECT 
    li.model_id,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    SUM(li.prompt_tokens + li.completion_tokens) as total_tokens,
    COUNT(*) as num_calls,
    CASE 
        WHEN li.model_id LIKE '%claude-3-5-sonnet%' THEN 'Claude 3.5 Sonnet'
        WHEN li.model_id LIKE '%claude-3-opus%' THEN 'Claude 3 Opus'
        WHEN li.model_id LIKE '%gpt-4%' THEN 'GPT-4'
        WHEN li.model_id LIKE '%gpt-3.5%' THEN 'GPT-3.5'
        ELSE 'Other'
    END as model_family,
    DATE_TRUNC('day', li.created_at)::DATE as date
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.created_at >= NOW() - INTERVAL '30 days'
GROUP BY li.model_id, DATE_TRUNC('day', li.created_at);

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- These views provide:
-- 1. Run-level summaries and overviews
-- 2. Model performance comparisons
-- 3. Quality assessment analysis
-- 4. Per-conversation metrics
-- 5. API performance tracking
-- 6. Pipeline stage metrics
-- 7. Human feedback impact analysis
-- 8. Error tracking and debugging
-- 9. Token usage trends
-- 10. Complete conversation lineage
-- 11. Data quality monitoring
-- 12. Cost estimation
--
-- All views are filtered to AI-Range product (product_code = 'ai-range')
-- and can be used for dashboards, reporting, and analytics
-- ============================================================================

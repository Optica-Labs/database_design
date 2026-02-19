-- ============================================================================
-- CAT-ASTROPHIC INTEGRATION SAMPLE QUERIES
-- ============================================================================
-- Useful queries for working with the Cat-Astrophic tables in AI-Range
-- All queries filter by AI-Range product (product_code = 'ai-range')

-- ============================================================================
-- 1. GENERATION RUN ANALYSIS
-- ============================================================================

-- Get all generation runs with summary statistics
SELECT 
    gr.generation_run_id,
    gr.modality,
    gr.status,
    COUNT(DISTINCT c.id) as num_conversations,
    COUNT(DISTINCT t.id) as num_turns,
    SUM(t.total_tokens) as total_tokens,
    AVG(t.latency_ms) as avg_latency_ms,
    gr.created_at
FROM generation_runs gr
LEFT JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY gr.generation_run_id, gr.modality, gr.status, gr.created_at
ORDER BY gr.created_at DESC;

-- Get active/in-progress generation runs
SELECT 
    gr.generation_run_id,
    COUNT(DISTINCT c.id) as num_conversations,
    COUNT(DISTINCT t.id) as num_turns,
    gr.created_at,
    NOW() - gr.created_at as duration
FROM generation_runs gr
LEFT JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND gr.status = 'in_progress'
GROUP BY gr.generation_run_id, gr.created_at;

-- ============================================================================
-- 2. CONVERSATION ANALYSIS
-- ============================================================================

-- Find conversations with human feedback
SELECT 
    c.conversation_id,
    c.human_in_loop,
    c.human_in_loop_stage,
    c.human_in_loop_details,
    COUNT(DISTINCT t.id) as num_turns,
    AVG(t.auto_quality_score) as avg_quality,
    c.diversity_score
FROM conversations c
LEFT JOIN turns t ON c.id = t.conversation_id
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND c.human_in_loop = TRUE
GROUP BY c.conversation_id, c.human_in_loop, c.human_in_loop_stage, 
         c.human_in_loop_details, c.diversity_score
ORDER BY c.created_at DESC;

-- Track conversations by AI model used
SELECT 
    c.ai_range_model_name,
    c.ai_range_temperature,
    COUNT(*) as num_conversations,
    AVG(c.diversity_score) as avg_diversity,
    COUNT(DISTINCT CASE WHEN c.human_in_loop = TRUE THEN 1 END) as with_human_feedback
FROM conversations c
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND c.ai_range_enabled = TRUE
GROUP BY c.ai_range_model_name, c.ai_range_temperature
ORDER BY num_conversations DESC;

-- ============================================================================
-- 3. TURN/EXCHANGE ANALYSIS
-- ============================================================================

-- Model usage and performance comparison
SELECT 
    t.base_model_name,
    t.base_model_version,
    COUNT(*) as num_turns,
    AVG(t.latency_ms) as avg_latency_ms,
    AVG(t.prompt_tokens) as avg_prompt_tokens,
    AVG(t.response_tokens) as avg_response_tokens,
    AVG(t.auto_quality_score) as avg_quality_score
FROM turns t
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY t.base_model_name, t.base_model_version
ORDER BY num_turns DESC;

-- Pipeline stage analysis
SELECT 
    t.stage,
    COUNT(*) as num_turns,
    AVG(t.latency_ms) as avg_latency_ms,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as successful,
    COUNT(CASE WHEN t.status = 'failed' THEN 1 END) as failed
FROM turns t
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND t.stage IS NOT NULL
GROUP BY t.stage
ORDER BY t.stage;

-- Find high-quality turns
SELECT 
    t.turn_id,
    t.base_model_name,
    t.auto_quality_score,
    t.r_n,
    t.v_n,
    t.a_n,
    t.rho,
    t.latency_ms,
    t.created_at
FROM turns t
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND t.auto_quality_score >= 0.8
ORDER BY t.auto_quality_score DESC
LIMIT 100;

-- ============================================================================
-- 4. QUALITY METRICS ANALYSIS
-- ============================================================================

-- Quality metrics summary by methodology
SELECT 
    qm.methodology,
    COUNT(*) as num_assessments,
    AVG(qm.fit_score) as avg_fit_score,
    AVG(qm.diversity_score) as avg_diversity,
    AVG(qm.policy_risk_score) as avg_policy_risk,
    AVG(qm.length_score) as avg_length,
    MIN(qm.fit_score) as min_fit,
    MAX(qm.fit_score) as max_fit
FROM quality_metrics qm
WHERE qm.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY qm.methodology
ORDER BY num_assessments DESC;

-- Conversations with quality concerns (high policy risk)
SELECT 
    c.conversation_id,
    qm.fit_score,
    qm.diversity_score,
    qm.policy_risk_score,
    qm.length_score,
    qm.methodology,
    qm.created_at
FROM conversations c
JOIN quality_metrics qm ON c.id = qm.conversation_id
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND qm.policy_risk_score >= 0.7
ORDER BY qm.policy_risk_score DESC;

-- ============================================================================
-- 5. TELEMETRY & AGGREGATION
-- ============================================================================

-- Run telemetry summary
SELECT 
    gr.generation_run_id,
    t.total_entries,
    t.total_tokens,
    t.average_latency_ms,
    t.success_rate,
    t.strategy_coverage,
    t.topic_coverage,
    t.models_used,
    (t.egression_time - t.ingression_time) as duration
FROM telemetry t
JOIN generation_runs gr ON t.generation_run_id = gr.id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
ORDER BY gr.created_at DESC;

-- Daily telemetry trend
SELECT 
    DATE(t.created_at) as date,
    COUNT(DISTINCT t.generation_run_id) as num_runs,
    SUM(t.total_entries) as total_turns,
    SUM(t.total_tokens) as total_tokens,
    AVG(t.average_latency_ms) as avg_latency_ms,
    AVG(t.success_rate) as avg_success_rate
FROM telemetry t
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY DATE(t.created_at)
ORDER BY date DESC;

-- ============================================================================
-- 6. LLM INVOCATIONS & API TRACKING
-- ============================================================================

-- API call summary by model
SELECT 
    li.model_id,
    COUNT(*) as num_calls,
    COUNT(CASE WHEN li.status = 'success' THEN 1 END) as successful,
    COUNT(CASE WHEN li.status = 'failed' THEN 1 END) as failed,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    AVG(li.latency_ms) as avg_latency_ms,
    COUNT(CASE WHEN li.cache_hit = TRUE THEN 1 END) as cache_hits
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY li.model_id
ORDER BY num_calls DESC;

-- Failed API calls with error details
SELECT 
    li.invocation_id,
    li.model_id,
    li.status,
    li.error_code,
    li.error_message,
    li.retry_count,
    li.created_at,
    li.latency_ms
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.status IN ('failed', 'error')
ORDER BY li.created_at DESC
LIMIT 100;

-- API performance by time of day
SELECT 
    EXTRACT(HOUR FROM li.created_at) as hour,
    COUNT(*) as num_calls,
    AVG(li.latency_ms) as avg_latency_ms,
    MAX(li.latency_ms) as max_latency_ms,
    COUNT(CASE WHEN li.status = 'success' THEN 1 END) as successful,
    COUNT(CASE WHEN li.status = 'failed' THEN 1 END) as failed
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.created_at >= NOW() - INTERVAL '7 days'
GROUP BY EXTRACT(HOUR FROM li.created_at)
ORDER BY hour;

-- Token usage and cost estimation
SELECT 
    li.model_id,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    SUM(li.prompt_tokens + li.completion_tokens) as total_tokens,
    COUNT(*) as num_calls,
    AVG(li.latency_ms) as avg_latency_ms
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.created_at >= NOW() - INTERVAL '30 days'
GROUP BY li.model_id
ORDER BY total_tokens DESC;

-- ============================================================================
-- 7. CROSS-TABLE ANALYSIS
-- ============================================================================

-- Complete turn execution trace
SELECT 
    gr.generation_run_id,
    c.conversation_id,
    t.turn_id,
    t.base_model_name,
    t.prompt_tokens,
    t.response_tokens,
    t.latency_ms,
    t.auto_quality_score,
    qm.fit_score,
    qm.policy_risk_score,
    t.created_at
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
JOIN generation_runs gr ON c.generation_run_id = gr.id
LEFT JOIN quality_metrics qm ON c.id = qm.conversation_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND gr.generation_run_id = $1  -- parameterized: generation run ID
ORDER BY t.created_at;

-- Correlation between quality scores and model performance
SELECT 
    t.base_model_name,
    AVG(t.auto_quality_score) as avg_auto_quality,
    AVG(qm.fit_score) as avg_fit,
    AVG(qm.diversity_score) as avg_diversity,
    AVG(t.latency_ms) as avg_latency,
    COUNT(*) as num_samples
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
LEFT JOIN quality_metrics qm ON c.id = qm.conversation_id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY t.base_model_name
HAVING COUNT(*) >= 10;

-- ============================================================================
-- 8. PERFORMANCE & DEBUGGING
-- ============================================================================

-- Slow turns (performance outliers)
SELECT 
    t.turn_id,
    c.conversation_id,
    t.base_model_name,
    t.latency_ms,
    t.prompt_tokens,
    t.response_tokens,
    t.total_tokens,
    t.created_at
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND t.latency_ms > (
    SELECT PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms)
    FROM turns WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
)
ORDER BY t.latency_ms DESC;

-- Retry analysis
SELECT 
    li.model_id,
    li.retry_count,
    COUNT(*) as num_invocations,
    AVG(li.latency_ms) as avg_latency_ms
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.retry_count > 0
GROUP BY li.model_id, li.retry_count
ORDER BY li.model_id, li.retry_count DESC;

-- ============================================================================
-- 9. DATA QUALITY CHECKS
-- ============================================================================

-- Check for orphaned records
SELECT 
    'conversations without generation_run' as issue,
    COUNT(*) as count
FROM conversations c
LEFT JOIN generation_runs gr ON c.generation_run_id = gr.id
WHERE c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND gr.id IS NULL

UNION ALL

SELECT 
    'turns without conversation' as issue,
    COUNT(*) as count
FROM turns t
LEFT JOIN conversations c ON t.conversation_id = c.id
WHERE t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND c.id IS NULL

UNION ALL

SELECT 
    'quality_metrics without conversation' as issue,
    COUNT(*) as count
FROM quality_metrics qm
LEFT JOIN conversations c ON qm.conversation_id = c.id
WHERE qm.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND c.id IS NULL;

-- Check for null/invalid values
SELECT 
    COUNT(CASE WHEN product_id IS NULL THEN 1 END) as null_product_ids,
    COUNT(CASE WHEN base_model_name IS NULL THEN 1 END) as null_models,
    COUNT(CASE WHEN total_tokens <= 0 THEN 1 END) as invalid_tokens,
    COUNT(CASE WHEN latency_ms < 0 THEN 1 END) as negative_latency
FROM turns
WHERE product_id = (SELECT id FROM products WHERE product_code = 'ai-range');

-- ============================================================================
-- 10. REPORTING & DASHBOARDS
-- ============================================================================

-- Executive summary
SELECT 
    'AI-Range Cat-Astrophic' as system,
    COUNT(DISTINCT gr.id) as total_runs,
    COUNT(DISTINCT c.id) as total_conversations,
    COUNT(DISTINCT t.id) as total_turns,
    SUM(t.total_tokens) as total_tokens,
    AVG(t.auto_quality_score) as avg_quality,
    COUNT(DISTINCT li.model_id) as unique_models,
    (SELECT COUNT(*) FROM llm_invocations li 
     WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')) as total_api_calls
FROM generation_runs gr
LEFT JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND gr.created_at >= NOW() - INTERVAL '30 days';

-- Monthly statistics
SELECT 
    DATE_TRUNC('month', gr.created_at)::DATE as month,
    COUNT(DISTINCT gr.id) as num_runs,
    COUNT(DISTINCT c.id) as num_conversations,
    COUNT(DISTINCT t.id) as num_turns,
    SUM(t.total_tokens) as total_tokens,
    AVG(t.auto_quality_score) as avg_quality_score,
    COUNT(CASE WHEN li.status = 'success' THEN 1 END) as successful_api_calls,
    COUNT(CASE WHEN li.status = 'failed' THEN 1 END) as failed_api_calls
FROM generation_runs gr
LEFT JOIN conversations c ON gr.id = c.generation_run_id
LEFT JOIN turns t ON c.id = t.conversation_id
LEFT JOIN llm_invocations li ON t.product_id = li.product_id
WHERE gr.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY DATE_TRUNC('month', gr.created_at)
ORDER BY month DESC;

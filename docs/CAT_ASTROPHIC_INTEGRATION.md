# Cat-Astrophic Prompt Database Integration

## Overview

The Cat-Astrophic Prompt Database (PromptGoblin v2) has been fully integrated into the AI-Range Unified Architecture. This comprehensive system provides detailed tracking of prompt generation, execution, and quality metrics.

**Product**: AI-Range (all tables include `product_id` linking to AI-Range)

## Core Tables

### 1. generation_runs
**Purpose**: Stores batch/run-level metadata for prompt generation sessions

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| generation_run_id | UUID | Unique identifier for tracking generation batch |
| modality | VARCHAR(50) | Generation type: text, image, audio |
| tags | JSONB | Categorization tags (e.g., ["agentic", "adversarial"]) |
| plan_metadata | JSONB | Pipeline planning metadata |
| coverage_map | JSONB | Strategy×topic coverage tracking |
| adaptive_weights | JSONB | Strategy selection weights |
| status | VARCHAR(50) | in_progress, completed, failed |
| created_at | TIMESTAMP | Run creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes**:
- `idx_generation_runs_product` - Fast lookups by product
- `idx_generation_runs_id` - Unique run tracking
- `idx_generation_runs_status` - Filter by status
- `idx_generation_runs_created` - Time-based queries

**Use Cases**:
- Track batch prompt generation sessions
- Monitor run progress and status
- Analyze generation strategies and coverage
- Manage computational resources

### 2. conversations
**Purpose**: Stores conversation-level metadata (one per prompt in PromptGoblin format)

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| generation_run_id | BIGINT FK | Reference to generation_runs |
| conversation_id | VARCHAR(100) | Unique conversation identifier |
| industry | JSONB | Industry/category tags |
| model_version | VARCHAR(50) | Application model version |
| ai_range_enabled | BOOLEAN | Whether AI generation was used |
| ai_range_model_name | VARCHAR(255) | AI model name used |
| ai_range_temperature | FLOAT | Temperature for AI generation |
| ai_range_category | VARCHAR(100) | Generation category |
| ai_range_target | VARCHAR(100) | Generation target |
| human_in_loop | BOOLEAN | Human validation involved |
| human_in_loop_stage | JSONB | Stages with human involvement |
| human_in_loop_details | TEXT | Human feedback details |
| quality_methodology | VARCHAR(255) | Quality assessment method |
| diversity_score | FLOAT | Prompt uniqueness score (0.0-1.0) |
| coverage_contribution | JSONB | Strategies/topics covered |
| created_at | TIMESTAMP | Record creation |
| updated_at | TIMESTAMP | Last update |

**Indexes**:
- `idx_conversations_product` - Product-scoped queries
- `idx_conversations_id` - Conversation lookup
- `idx_conversations_generation_run` - Run correlation
- `idx_conversations_created` - Time-based analysis

**Relationships**:
- References `generation_runs(id)` - Each conversation belongs to one generation run
- Links to `turns` table - Multiple turns per conversation

**Use Cases**:
- Track individual prompt conversations
- Monitor human-in-the-loop validation stages
- Analyze diversity and coverage contribution
- Correlate prompts to AI models used

### 3. turns
**Purpose**: Stores individual prompt-response exchanges (the core generation data)

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| conversation_id | BIGINT FK | Reference to conversations |
| turn_id | VARCHAR(100) | Unique turn identifier |
| stage | INTEGER | Pipeline stage number (1-5) |
| role | VARCHAR(50) | assistant, user, system |
| prompt | TEXT | Input prompt text |
| response | TEXT | Generated response text |
| response_preview | TEXT | Truncated preview (200 chars) |
| prompt_tokens | INTEGER | Tokens in prompt |
| response_tokens | INTEGER | Tokens in response |
| total_tokens | INTEGER | Sum of prompt + response |
| latency_ms | FLOAT | Generation latency (milliseconds) |
| status | VARCHAR(50) | completed, failed, pending |
| finish_reason | VARCHAR(50) | stop, length, error |
| **model** | **VARCHAR(255)** | **Application model** (e.g., "agentic-pipeline") |
| **model_version** | **VARCHAR(50)** | **Application version** (e.g., "v1") |
| **base_model_id** | **VARCHAR(255)** | **Base LLM model ID** (e.g., "anthropic.claude-3-5-sonnet-20241022-v2:0") |
| **base_model_name** | **VARCHAR(255)** | **Extracted model name** (e.g., "claude-3-5-sonnet") |
| **base_model_version** | **VARCHAR(50)** | **Extracted model version** (e.g., "20241022-v2") |
| **base_model_temperature** | **FLOAT** | **Temperature used for generation** |
| auto_quality_score | FLOAT | Automated quality score |
| human_reviewed | BOOLEAN | Human review flag |
| r_n | FLOAT | Internal metric R_N |
| v_n | FLOAT | Internal metric v_N |
| a_n | FLOAT | Internal metric a_N |
| rho | FLOAT | Internal metric rho |
| pipeline_metadata | JSONB | Agentic pipeline execution trace |
| timestamp | TIMESTAMP | Turn execution time |
| created_at | TIMESTAMP | Record creation |

**Indexes**:
- `idx_turns_product` - Product filtering
- `idx_turns_id` - Individual turn lookup
- `idx_turns_conversation` - Conversation correlation
- `idx_turns_stage` - Pipeline stage analysis
- `idx_turns_timestamp` - Time-based queries
- `idx_turns_conversation_timestamp` - Conversation + time composite

**Key Insight - Application vs Base Model**:
```
Application Model: agentic-pipeline v1
Base Model:        anthropic.claude-3-5-sonnet-20241022-v2:0
                   ↓ parsed to ↓
                   claude-3-5-sonnet v20241022-v2:0 @ temp=0.7
```

This separation enables:
- Full attribution to specific foundation models
- Version tracking across model updates
- Reproducibility with precise parameters
- Multi-model support comparison
- Cost analysis by model

**Example Pipeline Metadata**:
```json
{
  "stage": 4,
  "stage_name": "COMPOSE",
  "total_stages": 5,
  "selected_strategy": "stepwise_refinement",
  "selected_topic": "bypass content filters",
  "adaptive_selection": true,
  "is_intermediate": true
}
```

**Use Cases**:
- Track individual prompt-response pairs
- Correlate model performance
- Analyze token usage patterns
- Monitor generation latency
- Trace agentic pipeline execution

### 4. quality_metrics
**Purpose**: Stores quality assessment metrics for conversations

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| conversation_id | BIGINT FK | Reference to conversations |
| methodology | VARCHAR(255) | Assessment methodology |
| metrics | JSONB | Quality scores (coherence, relevance, etc.) |
| fit_score | FLOAT | Fit score (0.0-1.0) |
| diversity_score | FLOAT | Diversity score (0.0-1.0) |
| policy_risk_score | FLOAT | Policy risk score (0.0-1.0) |
| length_score | FLOAT | Length score (0.0-1.0) |
| created_at | TIMESTAMP | Record creation |

**Indexes**:
- `idx_quality_metrics_product` - Product-scoped analysis
- `idx_quality_metrics_conversation` - Conversation lookup

**Example Metrics**:
```json
{
  "coherence": 0.95,
  "relevance": 0.87,
  "completeness": 0.92,
  "grammatical_correctness": 0.98,
  "semantic_richness": 0.79
}
```

**Use Cases**:
- Quality assessment and scoring
- Risk evaluation
- Diversity measurement
- Content policy compliance

### 5. telemetry
**Purpose**: Stores aggregated metrics per generation run

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| generation_run_id | BIGINT FK | Unique reference to generation_runs |
| ingression_time | TIMESTAMP | Run start time |
| egression_time | TIMESTAMP | Run end time |
| total_entries | INTEGER | Total turns in run |
| total_prompt_tokens | INTEGER | Sum of all prompt tokens |
| total_response_tokens | INTEGER | Sum of all response tokens |
| total_tokens | INTEGER | Sum of all tokens |
| average_latency_ms | FLOAT | Average generation latency |
| success_rate | FLOAT | Success rate (0.0-1.0) |
| repair_rate | FLOAT | Repair rate (0.0-1.0) |
| reject_rate | FLOAT | Reject rate (0.0-1.0) |
| avg_iterations | FLOAT | Average repair iterations |
| strategy_coverage | JSONB | Strategy coverage metrics |
| topic_coverage | JSONB | Topic coverage metrics |
| models_used | JSONB | Models used with counts |
| feature_flags | JSONB | Features enabled during run |
| audit_trail_ids | JSONB | Audit record references |
| retention_policy | VARCHAR(255) | Data retention policy |
| deletion_date | TIMESTAMP | Scheduled deletion date |
| errors | JSONB | Errors encountered during run |
| created_at | TIMESTAMP | Record creation |
| updated_at | TIMESTAMP | Last update |

**Indexes**:
- `idx_telemetry_product` - Product-level aggregation
- `idx_telemetry_generation_run` - Run-specific lookup

**Example Coverage Metrics**:
```json
{
  "strategy_coverage": {
    "stepwise_refinement": 0.85,
    "adversarial_input": 0.92,
    "edge_case": 0.78
  },
  "topic_coverage": {
    "bypass_filters": 0.88,
    "misinformation": 0.82,
    "harmful_content": 0.91
  },
  "models_used": {
    "claude-3-5-sonnet": 450,
    "gpt-4-turbo": 320
  }
}
```

**Use Cases**:
- High-level run statistics
- Performance tracking
- Coverage analysis
- Cost aggregation (token counts)
- Error tracking

### 6. llm_invocations
**Purpose**: Stores all LLM API invocations for auditing, analysis, and cost tracking

| Column | Type | Key Features |
|--------|------|--------------|
| id | BIGSERIAL | Primary key |
| product_id | UUID FK | Links to AI-Range product |
| invocation_id | UUID | Unique invocation tracker |
| model_id | VARCHAR(255) | Bedrock model ID (e.g., "anthropic.claude-3-5-sonnet-20241022-v2:0") |
| request_payload | JSONB | Full request payload sent to API |
| response_data | JSONB | Raw response from API |
| sanitized_response | JSONB | Sanitized/filtered response |
| generated_text | TEXT | Extracted generated text |
| status | VARCHAR(50) | success, failed, error |
| error_code | VARCHAR(100) | Error code if failed |
| error_message | TEXT | Human-readable error message |
| latency_ms | FLOAT | API call latency in milliseconds |
| prompt_tokens | INTEGER | Prompt tokens used |
| completion_tokens | INTEGER | Completion tokens generated |
| total_tokens | INTEGER | Sum of prompt + completion |
| conversation_id | VARCHAR(100) | Link to conversations (if available) |
| turn_id | VARCHAR(100) | Link to turns (if available) |
| generation_run_id | UUID | Link to generation_runs (if available) |
| cache_hit | BOOLEAN | Whether Bedrock cache was hit |
| retry_count | INTEGER | Number of retries needed |
| invocation_type | VARCHAR(50) | async, sync |
| caller_context | JSONB | Additional context from caller (feature flags, experiment info) |
| created_at | TIMESTAMP | Invocation start time |
| completed_at | TIMESTAMP | Invocation completion time |

**Indexes**:
- `idx_llm_invocations_product` - Product filtering
- `idx_llm_invocations_id` - Individual invocation lookup
- `idx_llm_invocations_model` - Model-specific analysis
- `idx_llm_invocations_status` - Status filtering
- `idx_llm_invocations_conversation` - Conversation correlation
- `idx_llm_invocations_turn` - Turn correlation
- `idx_llm_invocations_generation_run` - Run correlation
- `idx_llm_invocations_created` - Time-based queries
- `idx_llm_invocations_model_created` - Model + time composite
- `idx_llm_invocations_status_created` - Status + time composite

**Example Caller Context**:
```json
{
  "feature_flags": ["human_in_loop", "caching_enabled"],
  "experiment_id": "exp-001-stepwise-refinement",
  "user_id": "user-123",
  "session_id": "session-456"
}
```

**Use Cases**:
- Complete API invocation audit trail
- Cost tracking and analysis
- Error debugging and monitoring
- Model usage patterns
- Performance analytics
- Compliance and regulatory audit

## Integration Points

### Hierarchical Relationships

```
generation_runs (batch level)
    ↓
    └─ conversations (prompt level)
        ↓
        └─ turns (exchange level)
            ├─ quality_metrics (quality assessment)
            └─ llm_invocations (API calls)

telemetry (aggregated from all)
    └─ aggregates data from all turns in a generation_run
```

### Query Examples

#### Get all turns for a generation run
```sql
SELECT t.* 
FROM turns t
JOIN conversations c ON t.conversation_id = c.id
JOIN generation_runs gr ON c.generation_run_id = gr.id
WHERE gr.generation_run_id = 'run-uuid-123'
AND t.product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
```

#### Analyze model usage by run
```sql
SELECT 
    t.base_model_name,
    COUNT(*) as num_turns,
    AVG(t.latency_ms) as avg_latency,
    SUM(t.total_tokens) as total_tokens
FROM turns t
WHERE t.generation_run_id = (
    SELECT id FROM generation_runs 
    WHERE generation_run_id = 'run-uuid-123'
)
GROUP BY t.base_model_name;
```

#### Track API costs
```sql
SELECT 
    li.model_id,
    COUNT(*) as num_calls,
    SUM(li.prompt_tokens) as total_prompt_tokens,
    SUM(li.completion_tokens) as total_completion_tokens,
    SUM(li.latency_ms) as total_latency_ms
FROM llm_invocations li
WHERE li.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND li.created_at >= NOW() - INTERVAL '1 day'
GROUP BY li.model_id;
```

#### Find conversations with human feedback
```sql
SELECT 
    c.conversation_id,
    c.human_in_loop_details,
    COUNT(DISTINCT t.id) as num_turns,
    AVG(t.auto_quality_score) as avg_quality
FROM conversations c
JOIN turns t ON c.id = t.conversation_id
WHERE c.human_in_loop = TRUE
AND c.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
GROUP BY c.conversation_id, c.human_in_loop_details;
```

#### Quality assessment analysis
```sql
SELECT 
    qm.methodology,
    AVG(qm.fit_score) as avg_fit,
    AVG(qm.diversity_score) as avg_diversity,
    AVG(qm.policy_risk_score) as avg_risk,
    COUNT(*) as num_assessments
FROM quality_metrics qm
WHERE qm.product_id = (SELECT id FROM products WHERE product_code = 'ai-range')
AND qm.created_at >= NOW() - INTERVAL '7 days'
GROUP BY qm.methodology;
```

## Migration from Standalone Cat-Astrophic Schema

If migrating from a standalone Cat-Astrophic database:

1. **Add product_id column** to all tables:
```sql
ALTER TABLE generation_runs ADD COLUMN product_id UUID NOT NULL DEFAULT (
    SELECT id FROM products WHERE product_code = 'ai-range'
);
ALTER TABLE generation_runs DROP DEFAULT;
```

2. **Create foreign key constraints**:
```sql
ALTER TABLE generation_runs 
ADD CONSTRAINT fk_generation_runs_product 
FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
```

3. **Create indexes** for performance:
```sql
CREATE INDEX idx_generation_runs_product ON generation_runs(product_id);
-- ... (repeat for all tables)
```

4. **Verify data integrity**:
```sql
SELECT table_name, COUNT(*) 
FROM information_schema.columns 
WHERE table_name IN ('generation_runs', 'conversations', 'turns', 'quality_metrics', 'telemetry', 'llm_invocations')
AND column_name = 'product_id'
GROUP BY table_name;
```

## Backups & Retention

### Retention Policy Patterns
- **Development**: 7 days retention
- **Staging**: 30 days retention  
- **Production**: 90-180 days retention

### Archival Considerations
```json
{
  "retention_policy": "production_90",
  "creation_time": "2025-02-18T10:00:00Z",
  "archive_candidate_after": "2025-05-19",
  "deletion_scheduled": null
}
```

## Performance Optimization

### Key Indexes for Common Queries
- Time-range queries: Use `created_at` indexes
- Product filtering: Use `product_id` indexes
- Correlation queries: Use composite indexes
- Status filtering: Use `status` indexes

### Partitioning Strategy (for large deployments)
Consider range partitioning on `created_at` for:
- `turns` (high volume table)
- `llm_invocations` (extensive audit trail)
- `telemetry` (historical analysis)

## Related Documentation

- [AI_RANGE_UNIFIED_ARCHITECTURE.md](AI_RANGE_UNIFIED_ARCHITECTURE.md) - Overall product architecture
- [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Product layer design
- [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Entity relationship diagrams
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Integration patterns

## Support & Questions

For questions about Cat-Astrophic integration:
1. Review the [AI_RANGE_UNIFIED_ARCHITECTURE.md](AI_RANGE_UNIFIED_ARCHITECTURE.md)
2. Check the [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
3. Examine the [schema_integrated.sql](../sql/schemas/schema_integrated.sql) for current schema

---

**Last Updated**: February 18, 2026  
**Schema Version**: 1.0  
**Status**: Production Ready

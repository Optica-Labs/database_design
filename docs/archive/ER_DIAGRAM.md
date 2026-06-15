# Archived: Entity Relationship Diagram

**ARCHIVED SNAPSHOT**: Historical ER diagrams.  
For current schema validation, see `docs/verification/LIVE_SUPABASE_ALIGNMENT_REPORT.md`.

This ER diagram document was archived and consolidated into the canonical ER diagrams and `DOCUMENTATION.md`.

Archived copy (full content preserved): `docs/archive/ER_DIAGRAM.md`

## Adversarial AI Safety Database

### Core Entity Relationships

```
┌─────────────────┐
│   ai_agents     │
│─────────────────│
│ agent_id (PK)   │
│ agent_name      │
│ agent_type      │
│ model_arch      │
│ version         │
│ capabilities    │
│ status          │
└─────────────────┘
         │
         │ creates/executes/evaluates
         ├──────────────────────┐
         │                      │
         ▼                      ▼
┌────────────────────┐   ┌──────────────────────┐
│ adversarial_test   │   │  test_executions     │
│     _cases         │   │──────────────────────│
│────────────────────│   │ execution_id (PK)    │
│ test_case_id (PK)  │   │ model_id (FK)        │
│ category_id (FK)   │───│ test_case_id (FK)    │
│ test_name          │   │ executing_agent (FK) │
│ test_prompt        │   │ execution_start      │
│ attack_type        │   │ execution_end        │
│ severity           │   │ status               │
│ created_by_agent   │   └──────────────────────┘
└────────────────────┘            │
         │                        │ produces
         │                        ▼
         │                 ┌──────────────────┐
         │                 │  model_outputs   │
         │                 │──────────────────│
         │                 │ output_id (PK)   │
         │                 │ execution_id (FK)│
         │                 │ output_text      │
         │                 │ output_tokens    │
         │                 │ generation_time  │
         │                 └──────────────────┘
         │                        │
         │                        │ assessed by
         │                        ▼
         │                 ┌─────────────────────┐
         │                 │ safety_assessments  │
         │                 │─────────────────────│
         │                 │ assessment_id (PK)  │
         │                 │ output_id (FK)      │
         │                 │ evaluator_agent (FK)│
         │                 │ safety_score        │
         │                 │ is_safe             │
         │                 │ risk_level          │
         │                 │ violation_types     │
         │                 │ reasoning           │
         │                 └─────────────────────┘
         │                        │
         │                        │ generates
         │                        ▼
         │                 ┌──────────────────┐
         │                 │ safety_metrics   │
         │                 │──────────────────│
         │                 │ metric_id (PK)   │
         │                 │ assessment_id(FK)│
         │                 │ metric_name      │
         │                 │ metric_value     │
         │                 │ threshold_exceed │
         │                 └──────────────────┘
         │
         ▼
┌──────────────────┐
│ test_categories  │
│──────────────────│
│ category_id (PK) │
│ category_name    │
│ description      │
│ severity_level   │
└──────────────────┘


┌─────────────────────┐
│  client_models      │
│─────────────────────│
│ model_id (PK)       │
│ client_id           │
│ model_name          │
│ model_version       │
│ model_type          │
│ endpoint_url        │
│ api_key_hash        │
│ risk_level          │
│ status              │
└─────────────────────┘
         │
         │ subject of
         ├────────────────┬──────────────────┐
         ▼                ▼                  ▼
┌──────────────────┐  ┌──────────────────┐  ┌────────────────────┐
│ test_executions  │  │ safety_alerts    │  │ compliance_reports │
│──────────────────│  │──────────────────│  │────────────────────│
│ (shown above)    │  │ alert_id (PK)    │  │ report_id (PK)     │
└──────────────────┘  │ model_id (FK)    │  │ model_id (FK)      │
                      │ assessment_id(FK)│  │ report_type        │
                      │ alert_type       │  │ period_start       │
                      │ severity         │  │ period_end         │
                      │ title            │  │ total_tests        │
                      │ status           │  │ passed_tests       │
                      │ detected_at      │  │ failed_tests       │
                      │ resolved_at      │  │ safety_score       │
                      └──────────────────┘  │ generated_by (FK)  │
                                            └────────────────────┘


┌───────────────────────┐
│     audit_logs        │
│───────────────────────│
│ log_id (PK)           │
│ event_type            │
│ entity_type           │
│ entity_id             │
│ actor_type            │
│ actor_id              │
│ action                │
│ old_values (JSON)     │
│ new_values (JSON)     │
│ timestamp             │
│ metadata (JSON)       │
└───────────────────────┘
```

## Relationship Types

### One-to-Many Relationships

1. **ai_agents → adversarial_test_cases**
   - One agent can create many test cases
   - Field: `created_by_agent_id`

2. **ai_agents → test_executions**
   - One agent can execute many tests
   - Field: `executing_agent_id`

3. **ai_agents → safety_assessments**
   - One agent can perform many assessments
   - Field: `evaluator_agent_id`

4. **client_models → test_executions**
   - One model can have many test executions
   - Field: `model_id`

5. **client_models → safety_alerts**
   - One model can have many alerts
   - Field: `model_id`

6. **client_models → compliance_reports**
   - One model can have many compliance reports
   - Field: `model_id`

7. **test_categories → adversarial_test_cases**
   - One category contains many test cases
   - Field: `category_id`

8. **adversarial_test_cases → test_executions**
   - One test case can be executed many times
   - Field: `test_case_id`

9. **test_executions → model_outputs**
   - One execution produces one output (1:1 in practice)
   - Field: `execution_id`

10. **model_outputs → safety_assessments**
    - One output can have multiple assessments (from different agents)
    - Field: `output_id`

11. **safety_assessments → safety_metrics**
    - One assessment has many detailed metrics
    - Field: `assessment_id`

12. **safety_assessments → safety_alerts** (optional)
    - One assessment may trigger one alert
    - Field: `assessment_id`

### Key Cardinalities

```
ai_agents (1) ──creates──> (M) adversarial_test_cases
ai_agents (1) ──executes──> (M) test_executions
ai_agents (1) ──evaluates──> (M) safety_assessments
ai_agents (1) ──generates──> (M) compliance_reports

client_models (1) ──tested_by──> (M) test_executions
client_models (1) ──has──> (M) safety_alerts
client_models (1) ──has──> (M) compliance_reports

test_categories (1) ──contains──> (M) adversarial_test_cases

adversarial_test_cases (1) ──executed_in──> (M) test_executions

test_executions (1) ──produces──> (1) model_outputs

model_outputs (1) ──assessed_by──> (M) safety_assessments

safety_assessments (1) ──has──> (M) safety_metrics
safety_assessments (1) ──triggers──> (0..1) safety_alerts
```

## Data Flow

### Test Execution Flow
```
1. Client Model Registration
   └─> INSERT INTO client_models

2. Test Case Selection
   └─> SELECT FROM adversarial_test_cases

3. Test Execution
   ├─> INSERT INTO test_executions (status='running')
   ├─> Call Model API
   └─> INSERT INTO model_outputs

4. Safety Assessment
   ├─> INSERT INTO safety_assessments
   └─> INSERT INTO safety_metrics (multiple rows)

5. Alert Generation (if needed)
   └─> INSERT INTO safety_alerts

6. Audit Logging (all steps)
   └─> INSERT INTO audit_logs
```

### Assessment Flow
```
model_outputs
    │
    ├──> Evaluated by multiple evaluator agents
    │
    ├──> safety_assessments (multiple rows, one per evaluator)
    │       │
    │       └──> safety_metrics (multiple rows per assessment)
    │
    └──> May trigger safety_alerts (if thresholds exceeded)
```

## Key Design Patterns

### 1. Agent-based Architecture
- All operations are performed by registered agents
- Agents have types, capabilities, and versions
- Enables tracking "who did what"

### 2. Temporal Tracking
- All major entities have timestamps
- Enables time-series analysis
- Supports compliance reporting

### 3. Hierarchical Severity
- Test cases have severity
- Assessments have risk levels
- Alerts have severity
- Enables prioritization

### 4. Flexible JSON Fields
- `metadata` fields for extensibility
- `capabilities` for agent features
- `violation_types` for assessment details
- Avoids schema changes for new attributes

### 5. Complete Audit Trail
- `audit_logs` captures all changes
- Old and new values stored as JSON
- Timestamp and actor tracking
- Supports compliance and forensics

## Indexes Strategy

### Primary Keys
- All tables have surrogate key (IDENTITY)
- Simple, numeric, auto-incrementing

### Foreign Key Indexes
- All FK fields are indexed
- Improves join performance

### Query-Specific Indexes
- Status fields (for filtering)
- Timestamp fields (for time ranges)
- Composite indexes for common queries

### Performance Considerations
- Covering indexes for views
- Filtered indexes for active records
- Consider columnstore for large fact tables

## Peregrine Ground Truth Integration (NEW)

The integrated schema now includes **Peregrine ground truth** for unified prompt management:

```
┌─────────────────────────────┐
│  NEXUS_PROMPT_LIBRARY       │
│─────────────────────────────│
│ id (PK)                     │
│ product_id (FK → peregrine)     │
│ tenant_id (FK)              │
│ source_type (cat-astro|cli) │
│ cat_turn_id (FK) or         │
│ client_prompt_id (FK)       │
│ prompt_text                 │
│ status                      │
└─────────────────────────────┘
         │
         │ linked by trigger
         ▼
┌────────────────────────────────────┐
│  PRODUCT_PROMPT_LINEAGE (AUTO)     │
│────────────────────────────────────│
│ id (PK)                            │
│ ai_range_turn_id (FK)              │
│ peregrine_prompt_id (FK)               │
│ ai_range_product_id (FK)           │
│ peregrine_product_id (FK)              │
│ lineage_type (stage4|other)        │
│ created_at (auto-maintained)       │
└────────────────────────────────────┘
         │
         │ allows bidirectional tracing
         ├──────────────┬───────────────┐
         ▼              ▼               ▼
   AI-Range       Peregrine Library   Cross-Product
   Turn           Entry            Visibility
```

### Automatic Lineage

When a Stage 4 prompt is ingested into Peregrine:
1. Insert row in `peregrine_prompt_library` with `source_type = 'cat-astrophic'`
2. Trigger automatically creates `product_prompt_lineage` entry
3. Both products now have bidirectional visibility

## Normalization Level

The schema is in **3rd Normal Form (3NF)** with some denormalization:

**Normalized:**
- No repeating groups
- All non-key attributes depend on primary key
- No transitive dependencies

**Strategic Denormalization:**
- `risk_level` in both `client_models` and `safety_assessments`
  - Allows quick filtering without joins
  - Updated periodically based on recent assessments
- JSON fields for complex data
  - Reduces need for many-to-many tables
  - Flexible for evolving requirements

## Security & Privacy

### Data Classification
- **Highly Sensitive**: `api_key_hash`, model outputs (may contain PII)
- **Sensitive**: Client identifiers, assessment reasoning
- **Public**: Test case definitions, categories

### Access Control (Application Layer)
- Clients can only see their own models
- Admins can see all data
- Agents have programmatic access
- Auditors have read-only access

### Data Retention
- Active data: Last 6 months online
- Archive: 6 months - 2 years
- Compliance: 2 years+ or per regulation
- PII: Minimize and anonymize where possible

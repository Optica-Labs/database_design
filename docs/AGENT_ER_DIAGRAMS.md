# AI-Range Agent Entity Relationship Diagrams

Each of the 7 AI-Range agents works with specific tables. Below are the ER diagrams for each agent's operational domain.

**Ground Truth Note**: All AI-Range outputs (especially Stage 4 prompts) are automatically traceable through Nexus integration via `product_prompt_lineage`, enabling cross-product lineage tracking.

---

## 1. Cat-Astrophic Prompt Agent (Generator)

**Purpose**: Generates adversarial prompts and attack scenarios
**Model**: Claude-3.5-Sonnet v2.0.0

```mermaid
erDiagram
    PRODUCTS ||--o{ GENERATION_RUNS : "owns"
    
    GENERATION_RUNS ||--o{ CONVERSATIONS : "initiates"
    CONVERSATIONS ||--o{ TURNS : "contains"
    
    TURNS ||--o{ PROMPT_GENERATOR_RESPONSES : "produces"
    
    LLM_INVOCATIONS ||--o{ TURNS : "invokes"
    TELEMETRY ||--o{ TURNS : "tracks"
    QUALITY_METRICS ||--o{ GENERATION_RUNS : "measures"
    
    PRODUCTS {
        uuid id PK
        text product_code
        text product_name
    }
    
    GENERATION_RUNS {
        uuid id PK
        uuid product_id FK
        uuid generation_run_id
        text modality
        text status
        timestamp created_at
    }
    
    CONVERSATIONS {
        uuid id PK
        uuid product_id FK
        uuid generation_run_id FK
        text conversation_id
        boolean ai_range_enabled
    }
    
    TURNS {
        uuid id PK
        uuid product_id FK
        uuid conversation_id FK
        text turn_id
        text model
        text base_model_id
    }
    
    PROMPT_GENERATOR_RESPONSES {
        uuid id PK
        uuid product_id FK
        uuid generation_run_id FK
        uuid session_id FK
        uuid conversation_id FK
        uuid turn_id FK
        text persona_id FK
        text persona_name
        text scenario_id FK
        text test_type_id FK
        text threat_vector_id FK
        text final_prompt
        jsonb final_response
        text model_name
        text model_version
        text provider
        integer latency_ms
        integer token_input
        integer token_output
    }
    
    PROMPT_RESPONSE_METADATA {
        uuid id PK
        uuid product_id FK
        uuid response_id FK
        text metadata_type
        jsonb data
    }
    
    LLM_INVOCATIONS {
        uuid id PK
        uuid product_id FK
        text model_id
        text status
        bigint prompt_tokens
        bigint completion_tokens
    }
    
    TELEMETRY {
        uuid id PK
        uuid product_id FK
        text event_type
        jsonb event_data
    }
    
    QUALITY_METRICS {
        uuid id PK
        uuid product_id FK
        uuid generation_run_id FK
        text metric_name
        numeric score
    }
```

---

## 2. Evaluation Agent (Evaluator)

**Purpose**: Evaluates model responses and safety outcomes
**Model**: GPT-4-Turbo v1.5.0

```mermaid
erDiagram
    PRODUCTS ||--o{ TEST_EXECUTIONS : "owns"
    TEST_EXECUTIONS ||--o{ MODEL_OUTPUTS : "produces"
    MODEL_OUTPUTS ||--o{ SAFETY_ASSESSMENTS : "triggers"
    SAFETY_ASSESSMENTS ||--o{ SAFETY_METRICS : "contains"
    SAFETY_ASSESSMENTS ||--o{ SAFETY_ALERTS : "generates"
    
    PRODUCTS {
        uuid id PK
        text product_code
        text product_name
    }
    
    TEST_EXECUTIONS {
        uuid id PK
        uuid product_id FK
        bigint model_id FK
        bigint test_case_id FK
        timestamp execution_start
        text status
    }
    
    MODEL_OUTPUTS {
        uuid id PK
        uuid product_id FK
        uuid execution_id FK
        text output_text
        numeric confidence_score
        timestamp created_at
    }
    
    SAFETY_ASSESSMENTS {
        uuid id PK
        uuid product_id FK
        uuid output_id FK
        numeric safety_score
        boolean is_safe
        text risk_level
    }
    
    SAFETY_METRICS {
        uuid id PK
        uuid product_id FK
        uuid assessment_id FK
        text metric_type
        numeric value
    }
    
    SAFETY_ALERTS {
        uuid id PK
        uuid product_id FK
        uuid assessment_id FK
        text alert_type
        text severity
        text title
    }
```

---

## 3. Scenario Agent (Generator)

**Purpose**: Creates realistic test scenarios and contextual environments
**Model**: Claude-3-Opus v1.0.0

```mermaid
erDiagram
    PRODUCTS ||--o{ SCENARIOS : "owns"
    SCENARIOS ||--o{ SCENARIO_INTENTS : "contains"
    SCENARIO_INTENTS ||--o{ SCENARIO_INTENT_PERSONAS : "uses"
    SCENARIOS ||--o{ SCENARIO_PERSONAS : "involves"
    SCENARIOS ||--o{ SCENARIO_THREATS : "includes"
    SCENARIOS ||--o{ SCENARIO_SCORES : "evaluates"
    SCENARIOS ||--o{ SCENARIO_TEST_TYPES : "uses"
    
    THREAT_VECTORS ||--o{ SCENARIO_THREATS : "defines"
    
    PRODUCTS {
        uuid id PK
        text product_code
        text product_name
    }
    
    SCENARIOS {
        text id PK
        uuid product_id FK
        text title
        text description
        jsonb scenario_data
    }
    
    SCENARIO_INTENTS {
        uuid id PK
        uuid product_id FK
        text intent_id
        text intent_name
        numeric relevance_score
    }
    
    SCENARIO_INTENT_PERSONAS {
        uuid product_id FK
        text intent_id FK
        text persona_id FK
        numeric relevance_score
    }
    
    SCENARIO_PERSONAS {
        uuid id PK
        uuid product_id FK
        text scenario_id FK
        text persona_id FK
        text role
    }
    
    SCENARIO_THREATS {
        uuid id PK
        uuid product_id FK
        text scenario_id FK
        text threat_vector_id FK
        text threat_name
    }
    
    SCENARIO_SCORES {
        uuid id PK
        uuid product_id FK
        text scenario_id FK
        text score_type
        numeric score
    }
    
    SCENARIO_TEST_TYPES {
        text id PK
        uuid product_id FK
        text scenario_id FK
        text test_type_id FK
    }
    
    THREAT_VECTORS {
        text id PK
        uuid product_id FK
        text name
        text severity
    }
```

---

## 4. Persona Agent (Generator)

**Purpose**: Generates and manages AI personas with behavioral patterns
**Model**: GPT-4 v1.2.0

```mermaid
erDiagram
    PRODUCTS ||--o{ PERSONAS : "owns"
    USE_CASES ||--o{ PERSONAS : "provides-context"
    
    PERSONAS ||--o{ PERSONA_DEMOGRAPHICS : "has"
    PERSONAS ||--o{ PERSONA_BEHAVIORAL_TRAITS : "has"
    PERSONAS ||--o{ PERSONA_PSYCHOGRAPHIC_TRAITS : "has"
    PERSONAS ||--o{ PERSONA_TECHNOGRAPHIC_TRAITS : "has"
    PERSONAS ||--o{ PERSONA_LINGUISTIC_TRAITS : "has"
    
    PERSONAS ||--o{ PERSONA_MEMORIES : "maintains"
    PERSONAS ||--o{ PERSONA_REFLECTIONS : "reflects"
    PERSONAS ||--o{ PERSONA_PLANS : "plans"
    PERSONAS ||--o{ PERSONA_ACTIONS : "executes"
    
    DEMOGRAPHIC_TRAITS_CATALOG ||--o{ PERSONA_DEMOGRAPHICS : "defines"
    BEHAVIORAL_TRAITS_CATALOG ||--o{ PERSONA_BEHAVIORAL_TRAITS : "defines"
    PSYCHOGRAPHIC_TRAITS_CATALOG ||--o{ PERSONA_PSYCHOGRAPHIC_TRAITS : "defines"
    TECHNOGRAPHIC_TRAITS_CATALOG ||--o{ PERSONA_TECHNOGRAPHIC_TRAITS : "defines"
    LINGUISTIC_TRAITS_CATALOG ||--o{ PERSONA_LINGUISTIC_TRAITS : "defines"
    
    PRODUCTS {
        uuid id PK
        text product_code
    }
    
    USE_CASES {
        uuid id PK
        uuid product_id FK
        text name
    }
    
    PERSONAS {
        text id PK
        uuid product_id FK
        uuid use_case_id FK
        text name
        text persona_type
        jsonb behavioral_profile
    }
    
    PERSONA_DEMOGRAPHICS {
        uuid id PK
        text persona_id FK
        bigint trait_id FK
        text value
    }
    
    PERSONA_BEHAVIORAL_TRAITS {
        uuid id PK
        text persona_id FK
        bigint trait_id FK
        text raw_value
        text value
    }
    
    PERSONA_PSYCHOGRAPHIC_TRAITS {
        uuid id PK
        text persona_id FK
        bigint trait_id FK
        text value
    }
    
    PERSONA_TECHNOGRAPHIC_TRAITS {
        uuid id PK
        text persona_id FK
        bigint trait_id FK
        text value
    }
    
    PERSONA_LINGUISTIC_TRAITS {
        uuid id PK
        text persona_id FK
        bigint trait_id FK
        text value
    }
    
    PERSONA_MEMORIES {
        uuid id PK
        uuid product_id FK
        text persona_id FK
        text memory_type
        jsonb memory_content
    }
    
    PERSONA_REFLECTIONS {
        uuid id PK
        uuid product_id FK
        text persona_id FK
        text reflection_text
        timestamp created_at
    }
    
    PERSONA_PLANS {
        uuid id PK
        uuid product_id FK
        text persona_id FK
        text plan_text
        jsonb plan_details
    }
    
    PERSONA_ACTIONS {
        uuid id PK
        uuid product_id FK
        text persona_id FK
        text action_type
        jsonb action_details
    }
    
    DEMOGRAPHIC_TRAITS_CATALOG {
        bigint id PK
        text key UK
        text label
    }
    
    BEHAVIORAL_TRAITS_CATALOG {
        bigint id PK
        text key UK
        text label
    }
    
    PSYCHOGRAPHIC_TRAITS_CATALOG {
        bigint id PK
        text key UK
        text label
    }
    
    TECHNOGRAPHIC_TRAITS_CATALOG {
        bigint id PK
        text key UK
        text label
    }
    
    LINGUISTIC_TRAITS_CATALOG {
        bigint id PK
        text key UK
        text label
    }
```

---

## 5. Test Agent (Classifier)

**Purpose**: Orchestrates test case execution and management
**Model**: BERT-Large v1.0.0

```mermaid
erDiagram
    PRODUCTS ||--o{ TEST_CATEGORIES : "owns"
    TEST_CATEGORIES ||--o{ TEST_TYPES : "contains"
    TEST_CATEGORIES ||--o{ ADVERSARIAL_TEST_CASES : "groups"
    
    PRODUCTS ||--o{ TEST_SESSIONS : "owns"
    TEST_SESSIONS ||--o{ TEST_EXECUTIONS : "runs"
    
    ADVERSARIAL_TEST_CASES ||--o{ TEST_EXECUTIONS : "executes"
    TEST_EXECUTIONS ||--o{ TEST_SETS : "organizes"
    TEST_SETS ||--o{ TEST_UNITS : "contains"
    TEST_UNITS ||--o{ TEST_TURNS : "steps"
    
    CLIENT_MODELS ||--o{ TEST_SESSIONS : "tested"
    
    PRODUCTS {
        uuid id PK
        text product_code
    }
    
    TEST_CATEGORIES {
        serial id PK
        uuid product_id FK
        text category_name
        text severity_level
    }
    
    TEST_TYPES {
        text id PK
        uuid product_id FK
        text name
        text category
        serial category_id FK
    }
    
    ADVERSARIAL_TEST_CASES {
        bigserial id PK
        uuid product_id FK
        serial category_id FK
        text test_name
        text test_prompt
        text attack_type
    }
    
    TEST_SESSIONS {
        uuid id PK
        uuid product_id FK
        text session_id UK
        text customer_id
        uuid tenant_id FK
        text status
    }
    
    TEST_EXECUTIONS {
        uuid id PK
        uuid product_id FK
        bigint test_case_id FK
        bigint model_id FK
        uuid session_id FK
        timestamp execution_start
        text status
    }
    
    TEST_SETS {
        uuid id PK
        uuid product_id FK
        uuid execution_id FK
        text test_set_name
        integer test_count
    }
    
    TEST_UNITS {
        uuid id PK
        uuid product_id FK
        uuid test_set_id FK
        text unit_name
        integer turn_count
    }
    
    TEST_TURNS {
        uuid id PK
        uuid product_id FK
        uuid unit_id FK
        integer turn_number
        text prompt
        text response
    }
    
    CLIENT_MODELS {
        bigserial id PK
        uuid tenant_id FK
        text model_name
        text status
    }
```

---

## 6. Analysis Agent (Evaluator)

**Purpose**: Analyzes results and generates compliance reports
**Model**: Claude-3-Sonnet v1.1.0

```mermaid
erDiagram
    PRODUCTS ||--o{ TEST_EXECUTIONS : "owns"
    TEST_EXECUTIONS ||--o{ MODEL_OUTPUTS : "produces"
    MODEL_OUTPUTS ||--o{ SAFETY_ASSESSMENTS : "evaluates"
    
    PRODUCTS ||--o{ COMPLIANCE_REPORTS : "owns"
    SAFETY_ASSESSMENTS ||--o{ COMPLIANCE_REPORTS : "feeds"
    
    PRODUCTS ||--o{ SAFETY_ALERTS : "owns"
    SAFETY_ASSESSMENTS ||--o{ SAFETY_ALERTS : "generates"
    
    PRODUCTS ||--o{ AUDIT_LOGS : "owns"
    
    PRODUCTS {
        uuid id PK
        text product_code
    }
    
    TEST_EXECUTIONS {
        uuid id PK
        uuid product_id FK
        bigint model_id FK
        timestamp execution_start
        text status
        numeric safety_score
    }
    
    MODEL_OUTPUTS {
        uuid id PK
        uuid product_id FK
        uuid execution_id FK
        text output_text
        jsonb output_metadata
    }
    
    SAFETY_ASSESSMENTS {
        uuid id PK
        uuid product_id FK
        uuid output_id FK
        numeric safety_score
        text risk_level
        text is_safe
    }
    
    COMPLIANCE_REPORTS {
        uuid id PK
        uuid product_id FK
        bigint model_id FK
        text report_type
        numeric overall_safety_score
        jsonb findings
        timestamp created_at
    }
    
    SAFETY_ALERTS {
        uuid id PK
        uuid product_id FK
        uuid assessment_id FK
        text alert_type
        text severity
        text title
        text description
    }
    
    AUDIT_LOGS {
        uuid id PK
        uuid product_id FK
        text event_type
        text entity_type
        uuid entity_id
        jsonb new_values
        timestamp created_at
    }
```

---

## 7. Commander Agent (Orchestration/Monitor)

**Purpose**: Master coordinator of all agents and workflows
**Model**: GPT-4-Turbo v2.0.0

```mermaid
erDiagram
    COMMANDER_ORCHESTRATION ||--o{ PROMPT_AGENT : "directs"
    COMMANDER_ORCHESTRATION ||--o{ EVALUATION_AGENT : "directs"
    COMMANDER_ORCHESTRATION ||--o{ SCENARIO_AGENT : "directs"
    COMMANDER_ORCHESTRATION ||--o{ PERSONA_AGENT : "directs"
    COMMANDER_ORCHESTRATION ||--o{ TEST_AGENT : "directs"
    COMMANDER_ORCHESTRATION ||--o{ ANALYSIS_AGENT : "directs"
    
    COMMANDER_ORCHESTRATION ||--o{ WORKFLOW_STATES : "tracks"
    COMMANDER_ORCHESTRATION ||--o{ TASK_QUEUE : "manages"
    COMMANDER_ORCHESTRATION ||--o{ ERROR_HANDLING : "monitors"
    
    PRODUCTS {
        uuid id PK
        text product_code
        text product_name
    }
    
    COMMANDER_ORCHESTRATION {
        uuid id PK
        uuid product_id FK
        text workflow_id
        text current_state
        jsonb workflow_config
        timestamp started_at
        timestamp updated_at
    }
    
    PROMPT_AGENT {
        text name
        text type
        text model
        text status
    }
    
    EVALUATION_AGENT {
        text name
        text type
        text model
        text status
    }
    
    SCENARIO_AGENT {
        text name
        text type
        text model
        text status
    }
    
    PERSONA_AGENT {
        text name
        text type
        text model
        text status
    }
    
    TEST_AGENT {
        text name
        text type
        text model
        text status
    }
    
    ANALYSIS_AGENT {
        text name
        text type
        text model
        text status
    }
    
    WORKFLOW_STATES {
        uuid id PK
        uuid orchestration_id FK
        text state_name
        jsonb state_data
        timestamp recorded_at
    }
    
    TASK_QUEUE {
        uuid id PK
        uuid orchestration_id FK
        text task_id
        text agent_id
        text task_type
        text status
        integer priority
    }
    
    ERROR_HANDLING {
        uuid id PK
        uuid orchestration_id FK
        text error_type
        text error_message
        text resolution_status
        timestamp occurred_at
    }
```

---

## Agent Interaction Map

```mermaid
graph TB
    subgraph "Agent Coordination"
        Commander["Commander Agent<br/>(Orchestration Master)"]
    end
    
    subgraph "Generation Agents"
        Prompt["Cat-Astrophic Prompt<br/>(Generator)"]
        Scenario["Scenario Agent<br/>(Generator)"]
        Persona["Persona Agent<br/>(Generator)"]
    end
    
    subgraph "Execution Agents"
        Test["Test Agent<br/>(Classifier)"]
    end
    
    subgraph "Evaluation Agents"
        Eval["Evaluation Agent<br/>(Evaluator)"]
        Analysis["Analysis Agent<br/>(Evaluator)"]
    end
    
    Commander -->|Instructs| Prompt
    Commander -->|Instructs| Scenario
    Commander -->|Instructs| Persona
    Commander -->|Instructs| Test
    Commander -->|Instructs| Eval
    Commander -->|Instructs| Analysis
    
    Prompt -->|Creates| Generation["Generation Runs<br/>Conversations<br/>Turns"]
    Scenario -->|Creates| Scenarios["Scenarios<br/>Intents<br/>Threats"]
    Persona -->|Creates| Personas["Personas<br/>Traits<br/>Memory"]
    
    Test -->|Executes| TestExec["Test Sessions<br/>Test Executions<br/>Test Cases"]
    
    TestExec -->|Produces| Outputs["Model Outputs"]
    Outputs -->|Evaluates| Eval
    
    Eval -->|Safety Results| Analysis
    Analysis -->|Generates| Reports["Reports<br/>Alerts<br/>Audit Logs"]
    
    Reports -->|Completes| Commander
```

---

## Summary Table

| Agent | Type | Model | Primary Tables | Output |
|-------|------|-------|-----------------|--------|
| **Cat-Astrophic Prompt** | Generator | Claude-3.5-Sonnet | generation_runs, conversations, turns, prompt_generator_responses, quality_metrics | Prompt variations, attack scenarios |
| **Evaluation** | Evaluator | GPT-4-Turbo | test_executions, model_outputs, safety_assessments | Safety scores, alerts, metrics |
| **Scenario** | Generator | Claude-3-Opus | scenarios, scenario_intents, scenario_threats | Test scenarios, contexts, threat mappings |
| **Persona** | Generator | GPT-4 | personas, persona_traits, persona_memories | AI personas, behavioral profiles, memories |
| **Test** | Classifier | BERT-Large | test_categories, test_sessions, test_executions | Test runs, execution results |
| **Analysis** | Evaluator | Claude-3-Sonnet | safety_assessments, compliance_reports, audit_logs | Reports, insights, compliance data |
| **Commander** | Orchestration | GPT-4-Turbo | All tables (coordinator) | Workflow coordination, state management |

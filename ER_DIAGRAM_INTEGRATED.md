# Integrated Entity Relationship Diagram

## Adversarial AI Safety & Persona Testing Database

### Overview

This integrated database combines two complementary systems:
1. **Adversarial AI Safety Testing** - Model testing, safety assessments, and compliance
2. **AI Persona Testing & Risk Assessment** - Persona-based testing, scenario generation, and risk analysis

---

## Core Architecture

### 1. Tenant & Client Management

```
┌─────────────────┐
│    tenants      │
│─────────────────│
│ id (PK)         │
│ tenant_name     │
│ client_id       │
│ industry        │
│ status          │
└─────────────────┘
         │
         │ owns
         ├──────────────┐
         ▼              ▼
┌─────────────────┐   ┌──────────────────┐
│ client_models   │   │ test_sessions    │
│─────────────────│   │──────────────────│
│ model_id (PK)   │   │ id (PK)          │
│ tenant_id (FK)  │   │ session_id       │
│ model_name      │   │ tenant_id (FK)   │
│ model_version   │   │ customer_id      │
│ endpoint_url    │   │ session_name     │
│ status          │   │ status           │
│ risk_level      │   └──────────────────┘
└─────────────────┘
```

---

## 2. Persona Management System

### Persona Core

```
┌───────────────────────┐
│   use_cases           │
│───────────────────────│
│ id (PK)               │
│ slug                  │
│ name                  │
│ description           │
└───────────────────────┘
         │
         │ contains
         ▼
┌───────────────────────┐
│   cohorts             │
│───────────────────────│
│ id (PK)               │
│ use_case_id (FK)      │
│ name                  │
│ description           │
└───────────────────────┘
         │
         │ contains
         ▼
┌───────────────────────┐
│   sub_cohorts         │
│───────────────────────│
│ id (PK)               │
│ cohort_id (FK)        │
│ name                  │
│ persona_type          │
└───────────────────────┘
         │
         │ categorizes
         ▼
┌───────────────────────┐
│   personas            │
│───────────────────────│
│ id (PK)               │
│ tenant_id             │
│ use_case_id (FK)      │
│ cohort_id (FK)        │
│ sub_cohort_id (FK)    │
│ name                  │
│ display_name          │
│ persona_type          │◄─────┐
│ actor_type            │      │
│ overview              │      │
│ traits (JSONB)        │      │
│ status                │      │
│ embedding (vector)    │      │
└───────────────────────┘      │
         │                     │
         │ has traits          │
         ├─────────────────────┼───────────────────┐
         ▼                     ▼                   ▼
┌───────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ persona_          │  │ persona_         │  │ persona_         │
│ demographics      │  │ behavioral_      │  │ psychographic_   │
│───────────────────│  │ traits           │  │ traits           │
│ persona_id (FK)   │  │──────────────────│  │──────────────────│
│ trait_id (FK)     │  │ persona_id (FK)  │  │ persona_id (FK)  │
│ raw_value         │  │ trait_id (FK)    │  │ trait_id (FK)    │
│ value (JSONB)     │  │ value (JSONB)    │  │ value (JSONB)    │
└───────────────────┘  └──────────────────┘  └──────────────────┘
         │                     │                     │
         │ references          │                     │
         ▼                     ▼                     ▼
┌───────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ demographic_      │  │ behavioral_      │  │ psychographic_   │
│ traits_catalog    │  │ traits_catalog   │  │ traits_catalog   │
│───────────────────│  │──────────────────│  │──────────────────│
│ id (PK)           │  │ id (PK)          │  │ id (PK)          │
│ key               │  │ key              │  │ key              │
│ label             │  │ label            │  │ label            │
│ data_type         │  │ data_type        │  │ data_type        │
│ allowed_values    │  │ allowed_values   │  │ allowed_values   │
│ persona_type      │  │ persona_type     │  │ persona_type     │
└───────────────────┘  └──────────────────┘  └──────────────────┘
```

### Persona Cognition & Memory

```
┌───────────────────┐
│   personas        │
└───────────────────┘
         │
         │ has
         ├────────────────┬──────────────────┬─────────────────┐
         ▼                ▼                  ▼                 ▼
┌───────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐
│ persona_      │  │ persona_     │  │ persona_     │  │ persona_    │
│ memories      │  │ reflections  │  │ plans        │  │ actions     │
│───────────────│  │──────────────│  │──────────────│  │─────────────│
│ id (PK)       │  │ id (PK)      │  │ id (PK)      │  │ id (PK)     │
│ persona_id    │  │ persona_id   │  │ persona_id   │  │ persona_id  │
│ type          │  │ summary      │  │ plan         │  │ input       │
│ content       │  │ embedding    │  │ horizon      │  │ output      │
│ embedding     │  │ ts           │  │ status       │  │ metadata    │
└───────────────┘  └──────────────┘  └──────────────┘  └─────────────┘
```

---

## 3. Threat & Risk Framework

```
┌──────────────────┐
│ threat_vectors   │
│──────────────────│
│ id (PK)          │
│ name             │
│ description      │
│ category         │
│ severity         │
│ harm_categories  │
│ modalities       │
│ embedding        │
└──────────────────┘
         │
         │ has examples
         ▼
┌──────────────────┐
│ threat_examples  │
│──────────────────│
│ id (PK)          │
│ vector_id (FK)   │
│ example_text     │
│ scenario_text    │
│ severity         │
│ mitigation       │
└──────────────────┘

┌──────────────────┐       ┌──────────────────┐
│ risks            │       │ harms            │
│──────────────────│       │──────────────────│
│ id (PK)          │       │ id (PK)          │
│ name             │       │ name             │
│ description      │       │ description      │
│ embedding        │       │ embedding        │
└──────────────────┘       └──────────────────┘
```

---

## 4. Scenario & Intent Framework

```
┌───────────────────┐
│   scenarios       │
│───────────────────│
│ id (PK)           │
│ tenant_id         │
│ session_id        │
│ persona_id (FK)   │◄──────────┐
│ title             │           │
│ description       │           │
│ context           │           │
│ risk_vectors      │           │
│ harm_categories   │           │
│ severity          │           │
│ status            │           │
└───────────────────┘           │
         │                      │
         │ has intents          │
         ▼                      │
┌───────────────────────┐       │
│  scenario_intents     │       │
│───────────────────────│       │
│ id (PK)               │       │
│ scenario_id (FK)      │       │
│ intent_name           │       │
│ description           │       │
│ temporal_trigger      │       │
│ steps                 │       │
│ success_criteria      │       │
│ priority              │       │
└───────────────────────┘       │
         │                      │
         │ relevant to          │
         ▼                      │
┌───────────────────────┐       │
│ scenario_intent_      │       │
│ personas              │       │
│───────────────────────│       │
│ intent_id (FK)        │       │
│ persona_id (FK)       │───────┘
│ relevance_score       │
└───────────────────────┘

┌───────────────────┐
│   scenarios       │
└───────────────────┘
         │
         │ relationships
         ├──────────────┬────────────────┬──────────────────┐
         ▼              ▼                ▼                  ▼
┌──────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐
│ scenario_    │  │ scenario_   │  │ scenario_   │  │ scenario_    │
│ personas     │  │ threats     │  │ scores      │  │ test_types   │
│──────────────│  │─────────────│  │─────────────│  │──────────────│
│ scenario_id  │  │ scenario_id │  │ scenario_id │  │ scenario_id  │
│ persona_id   │  │ threat_id   │  │ score_type  │  │ test_type_id │
└──────────────┘  └─────────────┘  └─────────────┘  └──────────────┘
```

---

## 5. Context & Risk Assessment

```
┌──────────────────────┐
│  context_profiles    │
│──────────────────────│
│ id (PK)              │
│ tenant_id (FK)       │
│ source_intake_id     │
│ industry             │
│ primary_use_case     │
│ objectives           │
│ guardrails           │
│ frameworks           │
│ api_endpoints        │
│ model_stack          │
└──────────────────────┘
         │
         │ generates
         ▼
┌──────────────────────┐
│  risk_assessments    │
│──────────────────────│
│ id (PK)              │
│ context_profile_id   │
│ assessment_mode      │
│ threats (JSONB)      │
│ scenarios (JSONB)    │
│ summary (JSONB)      │
└──────────────────────┘
```

---

## 6. Testing Framework

### Test Categories & Types

```
┌──────────────────┐
│ test_categories  │
│──────────────────│
│ category_id (PK) │
│ category_name    │
│ description      │
│ severity_level   │
└──────────────────┘
         │
         │ contains
         ├──────────────┬─────────────────┐
         ▼              ▼                 ▼
┌──────────────────┐  ┌────────────┐  ┌──────────────────┐
│ adversarial_     │  │ test_types │  │ test_sets        │
│ test_cases       │  │────────────│  │──────────────────│
│──────────────────│  │ id (PK)    │  │ id (PK)          │
│ test_case_id(PK) │  │ name       │  │ tenant_id        │
│ category_id (FK) │  │ category   │  │ scenario         │
│ test_name        │  │ embedding  │  │ persona (JSONB)  │
│ test_prompt      │  └────────────┘  │ test_type (FK)   │
│ attack_type      │                  │ risks[]          │
│ severity         │                  │ harms[]          │
│ is_active        │                  │ status           │
└──────────────────┘                  └──────────────────┘
                                               │
                                               │ contains
                                               ▼
                                      ┌──────────────────┐
                                      │ test_units       │
                                      │──────────────────│
                                      │ id (PK)          │
                                      │ test_set_id (FK) │
                                      │ label            │
                                      │ ord              │
                                      └──────────────────┘
                                               │
                                               │ contains
                                               ▼
                                      ┌──────────────────┐
                                      │ test_turns       │
                                      │──────────────────│
                                      │ id (PK)          │
                                      │ unit_id (FK)     │
                                      │ role             │
                                      │ content          │
                                      │ expected_behavior│
                                      │ scoring (JSONB)  │
                                      │ embedding        │
                                      └──────────────────┘
```

### AI Agents

```
┌──────────────────┐
│   ai_agents      │
│──────────────────│
│ agent_id (PK)    │
│ agent_name       │
│ agent_type       │◄────────────────────────────┐
│ model_arch       │                             │
│ capabilities     │                             │
│ status           │                             │
└──────────────────┘                             │
         │                                       │
         │ creates/executes/evaluates            │
         │                                       │
         └───────────┬───────────────┬───────────┴──────────────┐
                     ▼               ▼                          ▼
         ┌──────────────────┐  ┌────────────────┐  ┌──────────────────────┐
         │ adversarial_     │  │ test_          │  │ safety_              │
         │ test_cases       │  │ executions     │  │ assessments          │
         │──────────────────│  │────────────────│  │──────────────────────│
         │ created_by_      │  │ executing_     │  │ evaluator_agent_id   │
         │ agent_id (FK)    │  │ agent_id (FK)  │  └──────────────────────┘
         └──────────────────┘  └────────────────┘
```

---

## 7. Test Execution & Results Flow

```
┌──────────────────┐       ┌──────────────────┐
│ client_models    │       │ adversarial_     │
│──────────────────│       │ test_cases       │
│ model_id (PK)    │       │──────────────────│
│ model_name       │       │ test_case_id(PK) │
│ endpoint_url     │       │ test_prompt      │
│ status           │       │ attack_type      │
└──────────────────┘       └──────────────────┘
         │                          │
         │                          │
         └──────┬───────────────────┘
                │ tested in
                ▼
┌──────────────────────────┐
│  test_executions         │
│──────────────────────────│
│ execution_id (PK)        │
│ model_id (FK)            │
│ test_case_id (FK)        │
│ executing_agent_id (FK)  │
│ session_id (FK)          │
│ execution_start          │
│ execution_end            │
│ status                   │
└──────────────────────────┘
         │
         │ produces
         ▼
┌──────────────────────────┐
│  model_outputs           │
│──────────────────────────│
│ output_id (PK)           │
│ execution_id (FK)        │
│ output_text              │
│ output_tokens            │
│ generation_time_ms       │
└──────────────────────────┘
         │
         │ assessed by
         ▼
┌──────────────────────────┐
│  safety_assessments      │
│──────────────────────────│
│ assessment_id (PK)       │
│ output_id (FK)           │
│ evaluator_agent_id (FK)  │
│ safety_score             │
│ is_safe                  │
│ risk_level               │
│ violation_types (JSONB)  │
│ confidence_score         │
└──────────────────────────┘
         │
         ├──────────────┬─────────────────┐
         │              │                 │
         ▼              ▼                 ▼
┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│ safety_     │  │ safety_      │  │ ai_test_     │
│ metrics     │  │ alerts       │  │ results      │
│─────────────│  │──────────────│  │──────────────│
│ metric_id   │  │ alert_id(PK) │  │ id (PK)      │
│ assessment  │  │ model_id(FK) │  │ session_id   │
│ _id (FK)    │  │ assessment   │  │ persona_id   │
│ metric_name │  │ _id (FK)     │  │ scenario_id  │
│ metric_value│  │ severity     │  │ status       │
│ threshold   │  │ status       │  │ findings[]   │
└─────────────┘  └──────────────┘  └──────────────┘
```

---

## 8. Prompt Generation & Metadata

```
┌──────────────────────────┐
│ prompt_generator_        │
│ responses                │
│──────────────────────────│
│ id (PK)                  │
│ session_id               │
│ persona_id (FK)          │
│ persona_name             │
│ test_types (JSONB)       │
│ prompts (JSONB)          │
│ raw_output (JSONB)       │
└──────────────────────────┘
         │
         │ has metadata
         ▼
┌──────────────────────────┐
│ prompt_response_         │
│ metadata                 │
│──────────────────────────│
│ id (PK)                  │
│ prompt_response_id (FK)  │
│ session_id (FK)          │
│ persona_id (FK)          │
│ test_type_id (FK)        │
│ scenario_id (FK)         │
│ threat_vector_id (FK)    │
│ final_prompt             │
│ final_response (JSONB)   │
│ model_name               │
│ latency_ms               │
│ token_input              │
│ token_output             │
└──────────────────────────┘
```

---

## 9. Compliance & Reporting

```
┌──────────────────┐
│ client_models    │
└──────────────────┘
         │
         │ generates
         ▼
┌──────────────────────────┐
│ compliance_reports       │
│──────────────────────────│
│ report_id (PK)           │
│ model_id (FK)            │
│ report_type              │
│ report_period_start      │
│ report_period_end        │
│ total_tests              │
│ passed_tests             │
│ failed_tests             │
│ critical_issues          │
│ overall_safety_score     │
│ report_data (JSONB)      │
└──────────────────────────┘
```

---

## 10. Knowledge Base & Sources

```
┌──────────────────┐
│   sources        │
│──────────────────│
│ id (PK)          │
│ name             │
│ source_type      │
│ location         │
│ is_active        │
└──────────────────┘
         │
         │ crawled by
         ▼
┌──────────────────┐
│   crawls         │
│──────────────────│
│ id (PK)          │
│ source_id (FK)   │
│ started_at       │
│ status           │
│ stats (JSONB)    │
└──────────────────┘
         │
         │ produces
         ▼
┌──────────────────┐       ┌──────────────────┐
│  raw_items       │       │ scenario_seeds   │
│──────────────────│       │──────────────────│
│ id (PK)          │       │ id (PK)          │
│ source_id (FK)   │       │ title            │
│ raw_text         │       │ summary          │
│ metadata (JSONB) │       │ scenario_context │
│ content_type     │       │ risk_vector      │
└──────────────────┘       │ harm_category    │
                           │ embedding        │
                           └──────────────────┘
```

---

## 11. Audit & Logging

```
┌──────────────────────────┐
│  audit_logs              │
│──────────────────────────│
│ log_id (PK)              │
│ event_type               │
│ entity_type              │
│ entity_id                │
│ actor_type               │
│ actor_id                 │
│ action                   │
│ old_values (JSONB)       │
│ new_values (JSONB)       │
│ timestamp                │
└──────────────────────────┘
```

---

## 12. Caching

```
┌──────────────────────────┐
│ model_response_cache     │
│──────────────────────────│
│ id (PK)                  │
│ cache_key                │
│ model_type               │
│ request_input (JSONB)    │
│ response_output (JSONB)  │
│ request_hash             │
│ hit_count                │
│ expires_at               │
└──────────────────────────┘
```

---

## Key Integration Points

### 1. **Unified Persona System**
- Merges `ai_personas` and `personas` tables
- Supports regular, adversarial, and internal persona types
- Flexible trait system via catalog tables

### 2. **Test Execution Flow**
- Links client models → test executions → outputs → assessments
- Supports both adversarial test cases and persona-driven scenarios

### 3. **Risk & Threat Framework**
- Threat vectors linked to scenarios
- Risk assessments generated from context profiles
- Harm categories tracked across the system

### 4. **Multi-tenancy**
- Central tenant management
- Tenant isolation at model, session, and persona levels

### 5. **Flexible Metadata**
- JSONB fields throughout for extensibility
- Vector embeddings for semantic search
- Comprehensive audit logging

---

## Views Summary

### Key Views

1. **vw_latest_model_assessments** - Latest safety assessment per model
2. **vw_model_safety_summary** - Aggregate safety statistics
3. **vw_active_alerts** - Open safety alerts with context
4. **vw_persona_with_traits** - Personas with all trait data aggregated

---

## Performance Optimization

### Key Indexes

- Composite indexes on frequently joined columns
- Status and temporal indexes for filtering
- Vector indexes for embedding search (when using pgvector)
- Foreign key indexes for referential integrity

---

## Data Flow Summary

```
Context Profile → Risk Assessment → Threat Vectors
                                         ↓
Personas ← ← ← ← ← ← ← ← Scenarios ← ← ← ┘
   ↓                       ↓
   └→ Test Sessions → Test Executions → Model Outputs
                           ↓
                   Safety Assessments → Safety Metrics
                           ↓
                   Safety Alerts & Compliance Reports
```

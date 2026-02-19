# Integrated Entity Relationship Diagram

## Adversarial AI Safety & Persona Testing Database

### Overview

This integrated database combines two complementary systems:
1. **Adversarial AI Safety Testing** - Model testing, safety assessments, and compliance
2. **AI Persona Testing & Risk Assessment** - Persona-based testing, scenario generation, and risk analysis

---

## Core Architecture

### 0. Product Layer (Top Tier)

```
┌──────────────────────────────┐
│        products              │
│──────────────────────────────│
│ id (PK)                      │
│ product_code                 │ ◄─── ['ai-range', 'nexus']
│   - ai-range                 │
│   - nexus                    │
│ product_name                 │
│ description                  │
│ features (JSONB)             │
│ status                       │
└──────────────────────────────┘
         │                 
         │ enables
         ▼
┌──────────────────────────────────────┐
│  client_product_subscriptions        │
│──────────────────────────────────────│
│ id (PK)                              │
│ tenant_id (FK) ──┐                   │
│ product_id (FK)  │                   │
│ subscription_tier│                   │
│ subscription_status                  │
│ start_date       │                   │
│ end_date         │                   │
│ usage_limits (JSONB)                 │
│ features_enabled (JSONB)             │
└──────────────────┬───────────────────┘
                   │
                   │ connects to
                   ▼
```

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
         ├──────────────┬───────────────────────┐
         ▼              ▼                       ▼
┌─────────────────┐   ┌──────────────────┐   ┌─────────────────────────────┐
│ client_models   │   │ test_sessions    │   │ client_product_subscriptions│
│─────────────────│   │──────────────────│   │─────────────────────────────│
│ model_id (PK)   │   │ id (PK)          │   │ id (PK)                     │
│ tenant_id (FK)  │   │ session_id       │   │ tenant_id (FK)              │
│ model_name      │   │ tenant_id (FK)   │   │ product_id (FK)             │
│ model_version   │   │ customer_id      │   │ subscription_status         │
│ endpoint_url    │   │ session_name     │   └─────────────────────────────┘
│ status          │   │ status           │
│ risk_level      │   └──────────────────┘
└────────┬────────┘
         │
         │ uses
         ▼
┌──────────────────────────────┐
│  client_model_products       │
│──────────────────────────────│
│ id (PK)                      │
│ model_id (FK)                │
│ product_id (FK)              │
│ tenant_id (FK)               │
│ enabled                      │
│ configuration (JSONB)        │
└──────────────────────────────┘
```

---

## 2. AI-Range Testing System (Product-Owned Tables)

### Test Management & Framework

```
┌──────────────────────────────┐
│       products               │
│      (ai-range)              │
└──────────────┬───────────────┘
               │ owns all testing tables
               │
               ├─────────────── Use Cases & Context ───────────────┐
               ▼                                                    │
┌───────────────────────┐                                          │
│   use_cases           │                                          │
│───────────────────────│                                          │
│ id (PK)               │                                          │
│ product_id (FK)       │                                          │
│ slug                  │                                          │
│ name                  │                                          │
│ description           │                                          │
└───────────────────────┘                                          │
         │                                                          │
         │ provides context for                                    │
         ├──────────────────────┬──────────────────┐              │
         ▼                      ▼                  ▼              ▼
┌──────────────────────┐   ┌──────────────────┐   ┌────────────┐   ┌────────────────┐
│  test_categories     │   │  test_sessions   │   │ test_cases │   │ test_executions│
│──────────────────────│   │──────────────────│   │────────────│   │────────────────│
│ category_id (PK)     │   │ id (PK)          │   │ test_id    │   │ execution_id   │
│ product_id (FK) ─────┼───│ product_id (FK)  │   │ product_id │   │ product_id (FK)│
│ category_name        │   │ session_id       │   │ test_name  │   │ test_case_id   │
│ severity_level       │   │ tenant_id (FK)   │   │ category_id│   │ model_id (FK)  │
└──────────────────────┘   └──────────────────┘   └────────────┘   └────────────────┘
                                                                              │
                                                                              ▼
┌──────────────────────┐   ┌──────────────────────┐   ┌──────────────────────────┐
│  safety_assessments  │   │  compliance_reports  │   │     safety_alerts        │
│──────────────────────│   │──────────────────────│   │──────────────────────────│
│ assessment_id (PK)   │   │ report_id (PK)       │   │ alert_id (PK)            │
│ product_id (FK) ─────┤   │ product_id (FK)      │   │ execution_id (FK)        │
│ output_id (FK)       │   │ model_id (FK)        │   │ assessment_id (FK)       │
│ safety_score         │   │ report_type          │   │ severity                 │
│ is_safe              │   │ overall_safety_score │   │ status                   │
│ risk_level           │   └──────────────────────┘   └──────────────────────────┘
└──────────────────────┘
```

**Key Point**: All testing, safety assessment, and compliance tables include `product_id` 
and are owned by the **AI-Range** product. This ensures all testing operations are tracked 
and scoped to the ai-range product. **Use cases** provide business context for tests, linking 
testing activities to specific application domains and scenarios.

### Test Categories & Types

```
┌──────────────────┐
│ test_categories  │
│──────────────────│
│ category_id (PK) │
│ product_id (FK)  │
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
│ product_id (FK)  │  │ category   │  │ scenario         │
│ category_id (FK) │  │ embedding  │  │ persona (JSONB)  │
│ test_name        │  └────────────┘  │ test_type (FK)   │
│ test_prompt      │                  │ risks[]          │
│ attack_type      │                  │ harms[]          │
│ severity         │                  │ status           │
│ is_active        │                  └──────────────────┘
└──────────────────┘                           │
         │                                     │ contains
         │                                     ▼
         │                            ┌──────────────────┐
         │                            │ test_units       │
         │                            │──────────────────│
         │                            │ id (PK)          │
         │                            │ test_set_id (FK) │
         │                            │ label            │
         │                            │ ord              │
         │                            └──────────────────┘
         │                                     │
         │                                     │ contains
         │                                     ▼
         │                            ┌──────────────────┐
         │                            │ test_turns       │
         │                            │──────────────────│
         │                            │ id (PK)          │
         │                            │ unit_id (FK)     │
         │                            │ role             │
         │                            │ content          │
         │                            │ expected_behavior│
         │                            │ scoring (JSONB)  │
         │                            │ embedding        │
         │                            └──────────────────┘
         │
         │ created/executed/evaluated by
         ▼
┌──────────────────┐
│   ai_agents      │
│──────────────────│
│ agent_id (PK)    │
│ agent_name       │
│ agent_type       │
│ model_arch       │
│ capabilities     │
│ status           │
└──────────────────┘
         │
         │ performs
         ├───────────────────┬──────────────────┐
         ▼                   ▼                  ▼
┌────────────────┐  ┌────────────────┐  ┌──────────────────────┐
│ test_          │  │ adversarial_   │  │ safety_              │
│ executions     │  │ test_cases     │  │ assessments          │
│────────────────│  │────────────────│  │──────────────────────│
│ executing_     │  │ created_by_    │  │ evaluator_agent_id   │
│ agent_id (FK)  │  │ agent_id (FK)  │  └──────────────────────┘
└────────────────┘  └────────────────┘
```

### Test Execution & Results Flow

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
│ product_id (FK)          │
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
│ product_id (FK)          │
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

### Threat & Risk Framework

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

**Integration Note**: Threat vectors and harm categories are referenced throughout the testing system, particularly in:
- Test case categorization and severity levels
- Safety assessments for violation detection
- Scenario-threat relationships (scenario_threats table)
- Compliance reporting for regulatory alignment

---

## 3. AI-Range Persona System (Product-Owned Tables)

### Persona Core

```
┌──────────────────────────────┐
│       products               │
│      (ai-range)              │
└──────────────┬───────────────┘
               │ owns persona/scenario tables
               │
               │ (use_cases integrated in Test Hub - Section 2)
               │
               ▼
┌───────────────────────┐
│   personas            │
│───────────────────────│
│ id (PK)               │
│ product_id (FK)       │
│ tenant_id             │
│ use_case_id (FK)      │◄────── Links to use_case in Test Hub
│ cohort_id (FK)        │◄────── Cohort (organizational attribute)
│ sub_cohort_id (FK)    │◄────── Sub-cohort (classification attribute)
│ name                  │
│ display_name          │
│ persona_type          │
│ actor_type            │
│ overview              │
│ traits (JSONB)        │
│ status                │
│ embedding (vector)    │
└───────────────────────┘
         │
         │ references
         ├────────────────────────┬──────────────────────────┐
         ▼                        ▼                          ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│   cohorts         │    │   sub_cohorts     │    │   Trait Tables    │
│───────────────────│    │───────────────────│    │───────────────────│
│ id (PK)           │    │ id (PK)           │    │ persona_          │
│ use_case_id (FK)  │    │ cohort_id (FK)    │    │ demographics      │
│ name              │    │ name              │    │ persona_          │
│ description       │    │ persona_type      │    │ behavioral_traits │
└───────────────────┘    └───────────────────┘    │ persona_          │
                                                   │ psychographic_    │
                                                   │ traits            │
                                                   └───────────────────┘
         │                     │                     │
         │ reference catalogs  │                     │
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

**Note**: Cohorts and sub-cohorts are organizational attributes that classify personas. They are referenced by personas through foreign keys (cohort_id, sub_cohort_id) but exist as lookup/reference tables to enable consistent categorization across personas.

### Persona Cognition & Memory

```
┌──────────────────────────────┐
│       products               │
│      (ai-range)              │
└──────────────┬───────────────┘
               │ owns persona cognition tables
               │
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
│ product_id    │  │ product_id   │  │ product_id   │  │ product_id  │
│ persona_id    │  │ persona_id   │  │ persona_id   │  │ persona_id  │
│ type          │  │ summary      │  │ plan         │  │ input       │
│ content       │  │ embedding    │  │ horizon      │  │ output      │
│ embedding     │  │ ts           │  │ status       │  │ metadata    │
└───────────────┘  └──────────────┘  └──────────────┘  └─────────────┘
```

---

## 3. Scenario & Intent Framework

```
┌──────────────────────────────┐
│       products               │
│      (ai-range)              │
└──────────────┬───────────────┘
               │ owns scenario & intent tables
               │
┌───────────────────┐
│   scenarios       │
│───────────────────│
│ id (PK)           │
│ product_id (FK)   │
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
│ product_id (FK)       │       │
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
│ product_id (FK)       │       │
│ intent_id (FK)        │       │
│ persona_id (FK)       │───────┘
│ relevance_score       │
└───────────────────────┘

┌───────────────────┐
│   scenarios       │
└───────────────────┘
         │
         │ relationships (all with product_id)
         ├──────────────┬────────────────┬──────────────────┐
         ▼              ▼                ▼                  ▼
┌──────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐
│ scenario_    │  │ scenario_   │  │ scenario_   │  │ scenario_    │
│ personas     │  │ threats     │  │ scores      │  │ test_types   │
│──────────────│  │─────────────│  │─────────────│  │──────────────│
│ product_id   │  │ product_id  │  │ product_id  │  │ product_id   │
│ scenario_id  │  │ scenario_id │  │ scenario_id │  │ scenario_id  │
│ persona_id   │  │ threat_id   │  │ score_type  │  │ test_type_id │
└──────────────┘  └─────────────┘  └─────────────┘  └──────────────┘
```

---

## 4. Context & Risk Assessment

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

## 5. Prompt Generation & Metadata

```
┌──────────────────────────────┐
│       products               │
│      (ai-range)              │
└──────────────┬───────────────┘
               │ owns prompt generation
               ▼
┌──────────────────────────┐
│ prompt_generator_        │
│ responses                │
│──────────────────────────│
│ id (PK)                  │
│ product_id (FK)          │
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
│ product_id (FK)          │
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

## 6. Compliance & Reporting

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

## 7. Knowledge Base & Sources

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

## 8. Audit & Logging

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

## 9. Caching

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

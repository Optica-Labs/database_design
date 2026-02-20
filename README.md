# Integrated Adversarial AI Safety & Persona Testing Database

A unified PostgreSQL database schema integrating adversarial AI safety testing with persona-driven risk assessment across multiple products.

## 🎯 Overview

This repository contains a **comprehensive integrated database** serving as the single source of truth for:

- **Adversarial AI Safety Testing** - Traditional model testing, safety assessments, and compliance tracking
- **AI Persona Testing** - Persona-driven testing, scenario generation, and cognitive risk analysis
- **Cat-Astrophic Integration** - Full PromptGoblin v2 prompt generation tracking
- **Multi-tenant Operations** - Enterprise-grade client and subscription management
- **Risk & Threat Framework** - Comprehensive threat vectors and harm category modeling

## 🏗️ Two-Tier Architecture

**Clients (Tenants)** → **Models**

### Layer 1: Client Layer 🏢
- **Tenants**: Organizations using AI-Range (testing, personas, risk analysis) and Nexus (reserved for future use)
- **Central management** for all client operations

### Layer 2: Model Layer 🤖
- **Client Models**: AI models under test
- **AI Agents**: ML models performing safety assessments

## 🚀 What's Integrated

### ✅ Unified Persona System
- Single `personas` table supporting regular, adversarial, and internal persona types
- Flexible trait system via catalog tables (demographic, behavioral, psychographic, technographic, linguistic)
- Cognitive modeling: memories, reflections, plans, and actions

### ✅ Dual Testing Paradigms
- Traditional adversarial test cases with execution tracking
- Persona-driven scenario testing with intent modeling
- Test sessions unified across both approaches
- Structured test organization via test sets, units, and turns

### ✅ Cat-Astrophic Prompt Generation (PromptGoblin v2)
- Generation runs for batch prompt creation tracking
- Conversation-level metadata with human-in-the-loop support
- Turn-level prompt-response exchanges with token counting
- Quality metrics and telemetry aggregation
- LLM invocation auditing and cost tracking

### ✅ Comprehensive Risk & Threat Framework
- Threat vectors with examples and detection methods
- Risk-scenario-persona linkages for holistic analysis
- Context profiles for customer intake and assessment
- Harm category definitions and taxonomy

### ✅ Multi-Tenancy & Security
- Central tenant management for enterprise deployments
- Consistent data isolation across all entities
- Flexible client identification (UUID or legacy client_id)
- Complete audit trail of all operations

## 📁 Repository Structure

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **🎯 Unified Testing Hub** | Traditional adversarial + persona-driven testing in one platform |
| **👥 Advanced Personas** | Trait-based personas with cognitive modeling (memory, reflection, planning) |
| **🎬 Scenario Generation** | Dynamic scenario creation with intent mapping and persona relevance |
| **⚠️ Threat Framework** | Comprehensive threat vectors, examples, and harm categories |
| **📊 Risk Assessment** | Multi-dimensional risk analysis linked to personas and scenarios |
| **🔄 Prompt Generation** | Cat-Astrophic/PromptGoblin v2 integration with full generation tracking |
| **🛡️ Safety Assessment** | Multi-agent evaluation with detailed metrics and compliance tracking |
| **🚨 Alert Management** | Real-time critical safety incident tracking and escalation |
| **📋 Compliance Reports** | Automated compliance reporting and trend analysis |
| **🔐 Multi-Tenancy** | Enterprise-grade tenant isolation and subscription management |
| **📝 Audit Trail** | Complete immutable audit log of all system activities |
| **📈 Performance** | Optimized indexes and views for complex analytical queries |  

## 🗄️ Database Structure

### Multi-Tenancy Infrastructure
| Table | Purpose |
|-------|---------|
| `tenants` | Client organizations (primary isolation boundary) |
| `products` | AI-Range and Nexus product definitions with versioning |
| `product_usage` | Tracks each product use event (audit and billing) |

### AI-Range Platform Tables (60+ tables)

**Testing Hub (Use Cases, Categories, Types):**
- `use_cases` - Business context for testing activities
- `test_categories` - Safety test categorization
- `test_types` - Test type definitions
- `test_sessions` - Testing session management
- `adversarial_test_cases` - Adversarial prompt library
- `test_executions` - Test execution records
- `test_sets`, `test_units`, `test_turns` - Structured test organization

**Personas & Cognition System:**
- `personas` - Unified persona definitions (all types)
- `cohorts`, `sub_cohorts` - Persona classification hierarchy
- `persona_memories` - Episodic memory storage
- `persona_reflections` - Higher-order reasoning
- `persona_plans` - Goal-oriented behavior planning
- `persona_actions` - Action history tracking
- `*_traits_catalog` tables - Trait definitions (5 types)
- `persona_*_traits` tables - Persona trait assignments (5 types)

**Scenarios & Intent Modeling:**
- `scenarios` - Test scenario definitions
- `scenario_intents` - Intent breakdown by scenario
- `scenario_personas` - Persona-scenario relevance
- `scenario_intent_personas` - Intent-persona mapping
- `scenario_threats` - Threat-scenario relationships
- `scenario_scores` - Scenario scoring
- `intents` - Intent definitions

**Safety & Compliance:**
- `safety_assessments` - Safety evaluation records
- `safety_metrics` - Detailed safety metrics
- `safety_alerts` - Critical safety incidents
- `compliance_reports` - Compliance documentation
- `model_outputs` - Model response capture

**Risk & Threat Framework:**
- `threat_vectors` - Threat categorization
- `threat_examples` - Threat examples and mitigations
- `risks` - Risk definitions
- `harms` - Harm category taxonomy
- `context_profiles` - Customer context for risk assessment
- `risk_assessments` - Risk evaluation records

**Prompt Generation (Cat-Astrophic/PromptGoblin v2):**
- `generation_runs` - Batch prompt generation sessions
- `conversations` - Conversation-level tracking
- `turns` - Individual prompt-response exchanges
- `quality_metrics` - Quality assessment scores
- `telemetry` - Aggregated run metrics
- `llm_invocations` - LLM API call audit trail
- `prompt_generator_responses` - Generated prompt storage
- `prompt_response_metadata` - Execution metadata

**Knowledge Base & Sources:**
- `sources` - Information sources
- `crawls` - Web crawl records
- `raw_items` - Raw content items

**Core Entities:**
- `ai_agents` - AI agents and ML models
- `client_models` - Client models under test
- `audit_logs` - Complete system audit trail

### Analytical Views
- `vw_persona_with_traits` - Personas with aggregated traits
- `vw_latest_model_assessments` - Most recent assessment per model
- `vw_model_safety_summary` - Aggregate safety statistics
- `vw_active_alerts` - Open safety alerts with context

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 14+ (recommended: 15+)
- Extensions: `uuid-ossp`, `vector` (pgvector)

### Installation

**1. Deploy the Schema**
```bash
psql -d your_database -f sql/schemas/schema_integrated.sql
```

**2. Create a Tenant**
```sql
INSERT INTO tenants (tenant_name, client_id, industry)
VALUES ('Acme Corp', 'acme-001', 'Technology');
```

**3. Subscribe to AI-Range**
```sql
INSERT INTO client_product_subscriptions (tenant_id, product_id, subscription_tier, subscription_status)
SELECT 
    t.id,
    p.id,
    'enterprise',
    'active'
FROM tenants t
CROSS JOIN products p
WHERE t.tenant_name = 'Acme Corp'
  AND p.product_code = 'ai-range';
```

**4. Register a Client Model**
```sql
INSERT INTO client_models (tenant_id, client_id, model_name, model_version, model_type, endpoint_url)
SELECT 
    id,
    'acme-001',
    'SafetyTester-v1',
    '1.0.0',
    'llm',
    'https://api.acme.com/models/tester'
FROM tenants
WHERE tenant_name = 'Acme Corp';
```

**5. Link Model to Products**
```sql
INSERT INTO client_model_products (model_id, product_id, tenant_id, enabled)
SELECT 
    cm.model_id,
    p.id,
    cm.tenant_id,
    TRUE
FROM client_models cm
CROSS JOIN products p
WHERE cm.model_name = 'SafetyTester-v1'
  AND p.product_code = 'ai-range';
```

## 📖 Documentation & Examples

See [queries.sql](sql/queries/queries.sql) for comprehensive examples including:
- Safety assessment queries
- Persona-scenario relevance analysis
- Threat vector analytics
- Compliance reporting
- Alert management

## 🎯 Common Use Cases

### 1. Adversarial Testing
Execute adversarial tests against client models and capture outputs for evaluation.

### 2. Persona-Driven Risk Assessment
Use personas with specific traits to test model behavior against simulated user profiles and attack vectors.

### 3. Prompt Generation & Optimization
Generate diverse, targeted prompts at scale using PromptGoblin v2 with quality metrics and human-in-the-loop review.

### 4. Safety Assessment
Multi-agent evaluation assesses model outputs for:
- Toxicity and harmful content
- Bias and discrimination
- Jailbreak attempts
- Prompt injection attacks
- Data privacy violations
- Compliance violations

### 5. Risk Analytics
Multi-dimensional risk analysis across:
- Threat vectors and attack patterns
- Persona-specific vulnerabilities
- Scenario-based risk modeling
- Trend analysis and prediction

### 6. Compliance & Reporting
Automated compliance documentation including:
- Test execution summaries
- Pass/fail rates and trends
- Critical issues and remediation
- Safety scores and metrics
- Audit trail verification

## 📚 Documentation Resources

### Getting Started
- **[docs/INDEX.md](docs/INDEX.md)** - Quick reference guide and file index
- **[docs/README_INTEGRATED.md](docs/README_INTEGRATED.md)** - Detailed integrated system overview
- **[docs/INTEGRATION_SUMMARY.md](docs/INTEGRATION_SUMMARY.md)** - Executive summary of what was integrated

### Architecture & Design
- **[docs/PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md)** - Product layer and multi-tenancy design
- **[docs/PRODUCT_LAYER_ER_DIAGRAM.md](docs/PRODUCT_LAYER_ER_DIAGRAM.md)** - Product architecture diagrams
- **[docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md)** - Detailed integration strategy and design decisions
- **[AI_RANGE_UNIFIED_ARCHITECTURE.md](AI_RANGE_UNIFIED_ARCHITECTURE.md)** - AI-Range product ownership model

### Schema & Entities
- **[docs/ER_DIAGRAM_INTEGRATED.md](docs/ER_DIAGRAM_INTEGRATED.md)** - Complete entity relationship diagrams (12+ diagrams)
- **[docs/ER_DIAGRAM.md](docs/ER_DIAGRAM.md)** - Original system diagrams (reference)
- **[sql/schemas/schema_integrated.sql](sql/schemas/schema_integrated.sql)** - Complete DDL schema

### Specialized Systems
- **[docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md)** - PromptGoblin v2 prompt generation system
- **[sql/queries/cat_astrophic_queries.sql](sql/queries/cat_astrophic_queries.sql)** - Cat-Astrophic query examples
- **[sql/views/cat_astrophic_views.sql](sql/views/cat_astrophic_views.sql)** - Pre-built analytical views

### Code & Examples
- **[sql/queries/queries.sql](sql/queries/queries.sql)** - Comprehensive query examples
- **[sql/sample_data/sample_data.sql](sql/sample_data/sample_data.sql)** - Sample data for testing
- **[sql/migrations/migration_script.sql](sql/migrations/migration_script.sql)** - Data migration from legacy systems

## 🔧 Technology Stack

- **Database**: PostgreSQL 14+ (with pgvector, uuid-ossp extensions)
- **Schema**: 60+ tables optimized for complex analytical queries
- **Data Types**: JSONB (flexible metadata), UUID (multi-tenancy), Arrays, Vectors
- **Features**: Row-level security, Views, Indexes, Foreign keys, Triggers

## 🏗️ Architecture Principles

1. **Single Source of Truth** - Unified integrated database
2. **Multi-Tenancy** - Enterprise-grade tenant isolation
3. **Product-Scoped** - All operational tables link to AI-Range product
4. **Auditable** - Complete immutable audit trail
5. **Extensible** - JSONB fields for future requirements
6. **Performant** - 50+ indexes optimized for common queries
7. **Flexible** - Supports multiple testing paradigms and trait systems

## 📊 Data Flow Example

```
Tenant → Product Subscription → Client Models → Test Sessions
   ↓                ↓                 ↓              ↓
Personas → Trait Assignments → Scenarios → Test Executions
   ↓                ↓                 ↓              ↓
Memories  Threat Vectors    Intent Mapping    Safety Assessments
Reflections Risk Factors     Personas Linked    Alerts Generated
```

## 🔑 Key Metrics Tracked

- **Safety Score** (0-100) - Composite safety rating
- **Risk Level** - Low, Medium, High, Critical classifications
- **Pass Rate** - Percentage of tests passed/failed
- **Threat Coverage** - Proportion of threat vectors tested
- **Persona Relevance** - Relevance scores for persona-scenario pairs
- **Prompt Quality** - Diversity, coverage, and quality metrics
- **Compliance Status** - Regulatory requirement fulfillment
- **Incident Trends** - Safety incident patterns over time

## ⚡ Performance Optimization

The schema includes:
- **Comprehensive indexing** - Foreign keys, composite indexes, GIN indexes for JSONB
- **Analytical views** - Pre-aggregated data for common analyses
- **Query optimization** - CTEs, window functions, efficient joins
- **Maintenance tools** - VACUUM, ANALYZE, REINDEX procedures

See [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md#performance-considerations) for optimization details.

## 🔐 Security Features

- **Multi-tenancy isolation** - Row-level security via tenant_id
- **Audit logging** - Complete tracking of all modifications
- **Referential integrity** - Foreign key constraints
- **Data validation** - Check constraints and triggers
- **Access control** - PostgreSQL role-based security

## 📝 Maintenance

Regular maintenance tasks:
```sql
ANALYZE;                    -- Update statistics (weekly)
VACUUM;                     -- Reclaim space (weekly)
REINDEX DATABASE ...;       -- Rebuild indexes (monthly)
```

See [docs/README_INTEGRATED.md](docs/README_INTEGRATED.md#-maintenance) for full maintenance procedures.

## 🤝 Contributing

To extend or modify the database:

1. Update `sql/schemas/schema_integrated.sql` with table changes
2. Document changes in relevant `docs/` files
3. Add example queries to `sql/queries/queries.sql`
4. Update ER diagrams in `docs/ER_DIAGRAM_INTEGRATED.md`
5. Add migration steps if needed to `sql/migrations/migration_script.sql`
6. Update this README if architecture changes

## 📄 License

This database design is provided as-is for use in AI safety and security testing systems.

## 🙋 Support & Questions

- **Schema questions?** → See [docs/ER_DIAGRAM_INTEGRATED.md](docs/ER_DIAGRAM_INTEGRATED.md)
- **Integration questions?** → See [docs/INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md)
- **Deployment questions?** → See [docs/README_INTEGRATED.md](docs/README_INTEGRATED.md)
- **Query examples?** → See [sql/queries/queries.sql](sql/queries/queries.sql)
- **Architecture questions?** → See [docs/PRODUCT_LAYER_ARCHITECTURE.md](docs/PRODUCT_LAYER_ARCHITECTURE.md)
- **Prompt generation?** → See [docs/CAT_ASTROPHIC_INTEGRATION.md](docs/CAT_ASTROPHIC_INTEGRATION.md)

---

**Version**: 2.0 (Integrated)  
**Status**: Production Ready  
**Last Updated**: 2024  
**Database**: PostgreSQL 14+ 

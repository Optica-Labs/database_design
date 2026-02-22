# Archived: README (moved to canonical documentation)

This README was archived. The canonical project overview and onboarding guidance now live in `DOCUMENTATION.md` and `MASTER_DOCUMENTATION_INDEX.md`.

Archived copy (full content preserved): `docs/archive/README.md`

## 🎯 Overview

This repository contains a **comprehensive integrated database** serving as the single source of truth for:

- **Adversarial AI Safety Testing** - Traditional model testing, safety assessments, and compliance tracking
- **AI Persona Testing** - Persona-driven testing, scenario generation, and cognitive risk analysis
- **Cat-Astrophic Integration** - Full PromptGoblin v2 prompt generation tracking (AI-Range)
- **Nexus Ground Truth** - Unified prompt library with automatic cross-product lineage (NEW)
- **Multi-tenant Operations** - Enterprise-grade client and subscription management
- **Risk & Threat Framework** - Comprehensive threat vectors and harm category modeling

## 🏗️ Three-Tier Architecture

**Products** → **Clients (Tenants)** → **Models**

### Layer 1: Product Layer 🎁
- **AI-Range**: Comprehensive testing, personas, scenarios, and prompt generation
- **Nexus**: Ground truth for prompt ingestion, curation, and cross-product lineage

### Layer 2: Client Layer 🏢
- **Tenants**: Organizations using AI-Range and/or Nexus
- **Central management** for all client operations

### Layer 3: Model Layer 🤖
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
- **Stage 4 prompts automatically surface in Nexus ground truth**

### ✅ Nexus Ground Truth (NEW)
- Unified prompt library ingesting AI-Range Stage 4 prompts + client submissions
- Automatic cross-product lineage via `product_prompt_lineage` (trigger-maintained)
- **All AI-Range prompts are traceable through both products**
- Client submission workflow with approval pipeline
- Query views for both forward (AI-Range → Nexus) and reverse tracing

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

## � Documentation & Navigation

**👉 Start with [MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)** for complete navigation and role-based guides.

### Quick Links by Role
- **Database Administrators**: [NEXUS_ALPHA_INTEGRATION_REPORT.md](NEXUS_ALPHA_INTEGRATION_REPORT.md)
- **Backend Developers**: [NEXUS_ALPHA_QUICK_REFERENCE.md](NEXUS_ALPHA_QUICK_REFERENCE.md)
- **Data Scientists**: [docs/NEXUS_ALPHA_ARCHITECTURE.md](docs/NEXUS_ALPHA_ARCHITECTURE.md)
- **Product Managers**: [DOCUMENTATION.md](DOCUMENTATION.md)
- **DevOps/SRE**: [NEXUS_ALPHA_INTEGRATION_REPORT.md](NEXUS_ALPHA_INTEGRATION_REPORT.md)

## �📁 Repository Structure
See [DIRECTORY_STRUCTURE.md](DIRECTORY_STRUCTURE.md) for a full, up-to-date tree and file map.
## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **🎯 Unified Testing Hub** | Traditional adversarial + persona-driven testing in one platform |
| **👥 Advanced Personas** | Trait-based personas with cognitive modeling (memory, reflection, planning) |
| **🎬 Scenario Generation** | Dynamic scenario creation with intent mapping and persona relevance |
| **⚠️ Threat Framework** | Comprehensive threat vectors, examples, and harm categories |
| **📊 Risk Assessment** | Multi-dimensional risk analysis linked to personas and scenarios |
| **🔄 Prompt Generation** | Cat-Astrophic/PromptGoblin v2 integration with full generation tracking (AI-Range) |
| **🏆 Nexus Ground Truth** | Unified prompt library with automatic AI-Range → Nexus lineage (NEW) |
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

### Nexus Platform Tables (NEW - Ground Truth)

**Prompt Ingestion & Curation:**
- `client_prompt_submissions` - Client-provided prompts with review pipeline
- `nexus_prompt_library` - Unified prompt library (Stage 4 + client prompts)
- `product_prompt_lineage` - Cross-product traceability (auto-maintained by trigger)

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

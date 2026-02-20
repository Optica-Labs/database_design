# Product Layer Architecture

## Overview

The Product Layer defines the two core products available on the platform: AI-Range (primary) and Nexus (reserved). Clients (tenants) use AI-Range for comprehensive AI testing, safety assessment, and persona-based analysis.

## Architecture

### Two-Tier Structure

```
Products (AI-Range, Nexus)    ↓ (tracked via product_usage)
Product Usage Events (Audit Trail)    ↓
Tenants (Client Organizations)
    ↓
Client Models (AI Models Under Test)
```

## Products

The platform currently supports two products:

### 1. **AI-Range** (Comprehensive AI Testing & Safety Platform)
- **Product Code**: `ai-range`
- **Version**: Tracked in products table with timestamp history
- **Description**: Unified AI testing, safety assessment, persona-based testing, advanced risk analysis, and threat intelligence platform
- **Purpose**: Provides integrated testing operations, threat-informed safety evaluations, compliance assessments, and persona-based behavioral analysis

**Core Features**:
- **Testing Hub with use_cases as business context anchor**
- Test categories and test types linked to threat vectors
- Adversarial test case library
- Test execution engine
- Integrated threat and harm framework
- Safety assessments and metrics
- Compliance reporting with threat awareness
- Alert management
- Audit logging
- **Persona system with cognitive memory**
- **Advanced persona classification via cohorts and sub_cohorts**
- **Scenario creation and testing**
- **Behavioral analysis and long-term learning**
- **Prompt generation for testing**
- **Risk analysis and threat modeling**

**Database Tables Owned by AI-Range** (all operational tables include references):

*Testing Hub (with Use Cases & Threats):*
- `use_cases` - Business context anchor (links to personas and tests)
- `test_categories` - Test categorization (linked to threat_vectors)
- `test_sessions` - Testing sessions (optionally linked to use_cases)
- `adversarial_test_cases` - Test case library
- `test_executions` - Test execution records
- `model_outputs` - Model responses
- `threat_vectors` - Threat intelligence framework
- `threat_harms` - Harm definitions
- `threat_test_categories` - Threat-test category mapping
- `safety_assessments` - Safety evaluations (threat-aware)
- `safety_metrics` - Detailed safety metrics
- `safety_alerts` - Safety alerts
- `compliance_reports` - Compliance reports
- `audit_logs` - System audit trail
- `ai_agents` - Testing agents

*Persona System (with Cognition & Memory):*
- `cohorts` - Persona classifiers (dimensional attributes)
- `sub_cohorts` - Persona sub-classifiers
- `personas` - Persona definitions (linked to use_cases)
- `persona_memories` - Long-term memory storage
- `persona_reflections` - Cognitive reflections
- `persona_plans` - Strategic plans
- `persona_actions` - Action history
- Trait catalogs (demographic, behavioral, psychographic, etc.)

*Scenario Framework:*
- `scenarios` - Test scenarios
- `scenario_intents` - Scenario intent breakdown
- `scenario_intent_personas` - Intent-persona relationships
- `scenario_personas` - Scenario-persona relationships
- `scenario_threats` - Scenario-threat relationships
- `scenario_scores` - Scenario scoring
- `scenario_test_types` - Scenario-test type relationships
- `intents` - User intents

*Prompt Generation:*
- `prompt_generator_responses` - Generated prompts for testing
- `prompt_response_metadata` - Prompt execution metadata

### 2. **Nexus** (Reserved Product)
- **Product Code**: `nexus`
- **Status**: Reserved for future use
- **Note**: Currently, all functionality is consolidated under AI-Range

## Multi-Tenancy Architecture

### Two-Tier Connection Model

```
┌──────────────────────────────────────────────────────────────┐
│                    PRODUCTS (Top Tier)                        │
│              AI-Range | Nexus (Reserved)                      │
└──────────────────────────────────────────────────────────────┘
                          │
┌──────────────────────────────────────────────────────────────┐
│              TENANTS (Middle Tier - Clients)                  │
│        Organizations subscribing to AI-Range                 │
└──────────────────────────────────────────────────────────────┘
                          │
┌──────────────────────────────────────────────────────────────┐
│           CLIENT_MODELS (Bottom Tier - Models)                │
│         AI Models registered for testing on AI-Range         │
└──────────────────────────────────────────────────────────────┘
```
│                                                               │
│  ┌──────────┐                              ┌──────────┐      │
│  │ AI-Range │                              │  Nexus   │      │
│  └────┬─────┘                              └────┬─────┘      │
│       └────────────────┬─────────────────────────┘           │
└───────────────────────┼──────────────────────────────────────┘
                        │
                        │ Client Subscriptions
                        │
┌───────────────────────┼──────────────────────────────────────┐
│                       ▼                                       │
│              ┌─────────────────┐                             │
│              │    TENANTS      │                             │
│              │   (Clients)     │                             │
│              └────────┬────────┘                             │
│                       │                                       │
└───────────────────────┼──────────────────────────────────────┘
                        │
                        │ Model Ownership
                        │
┌───────────────────────┼──────────────────────────────────────┐
│                       ▼                                       │
│              ┌─────────────────┐                             │
│              │  CLIENT MODELS  │                             │
│              │ (AI Models Under Test)                        │
│              └─────────────────┘                             │
│                       │                                       │
└───────────────────────┼──────────────────────────────────────┘
                        │
                        └──► Links to Products via
                             client_model_products table
```

## Database Tables

### 1. `products`

Defines the available products in the platform.

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY,
    product_code TEXT UNIQUE,           -- 'ai-range' or 'nexus'
    product_name TEXT,
    description TEXT,
    features JSONB,                     -- Product-specific features
    pricing_tier TEXT,
    status TEXT,                        -- active, beta, deprecated, inactive
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    metadata JSONB
);
```

**Key Fields:**
- `product_code`: Unique identifier ('ai-range', 'nexus')
- `features`: JSON object describing available features
- `status`: Product lifecycle status

### 2. `client_product_subscriptions`

Manages which clients have access to which products.

```sql
CREATE TABLE client_product_subscriptions (
    id UUID PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    product_id UUID REFERENCES products(id),
    subscription_tier TEXT,             -- e.g., 'basic', 'premium', 'enterprise'
    subscription_status TEXT,           -- active, trial, suspended, expired, cancelled
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    usage_limits JSONB,                 -- API rate limits, test quotas, etc.
    features_enabled JSONB,             -- Granular feature access control
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    metadata JSONB
);
```

**Key Features:**
- **Subscription Management**: Track active, trial, and expired subscriptions
- **Usage Controls**: Define limits and quotas per subscription
- **Feature Flags**: Enable/disable specific features per client
- **Multi-Product Support**: Clients can subscribe to both AI-Range and Nexus

### 3. `client_model_products`

Junction table linking client models to the products they use.

```sql
CREATE TABLE client_model_products (
    id UUID PRIMARY KEY,
    model_id BIGINT REFERENCES client_models(model_id),
    product_id UUID REFERENCES products(id),
    tenant_id UUID REFERENCES tenants(id),
    enabled BOOLEAN,
    configuration JSONB,                -- Model-specific product configuration
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

**Purpose:**
- Links a specific AI model to one or more products
- Allows models to be tested with AI-Range, Nexus, or both
- Stores product-specific configuration per model

## Use Cases

### Use Case 1: Client Onboarding

1. **Create Tenant**: New client is registered in `tenants` table
2. **Subscribe to Products**: Create entries in `client_product_subscriptions` for AI-Range and/or Nexus
3. **Register Model**: Client's AI model added to `client_models`
4. **Link to Products**: Create entries in `client_model_products` to enable testing

```sql
-- Example: Subscribe client to both products
INSERT INTO client_product_subscriptions (tenant_id, product_id, subscription_tier, subscription_status)
VALUES 
  ('tenant-uuid', (SELECT id FROM products WHERE product_code = 'ai-range'), 'enterprise', 'active'),
  ('tenant-uuid', (SELECT id FROM products WHERE product_code = 'nexus'), 'premium', 'active');
```

### Use Case 2: Unified AI-Range Testing Flow

AI-Range provides integrated testing with business context:

```sql
-- 1. Create use_case as business context anchor
INSERT INTO use_cases (product_id, use_case_id, tenant_id, title, description)
VALUES (
  (SELECT id FROM products WHERE product_code = 'ai-range'),
  'uc-medical-diagnosis',
  'tenant-uuid',
  'Medical Diagnosis Assistant',
  'AI chatbot helping patients understand symptoms'
);

-- 2. Create persona linked to use_case
INSERT INTO personas (product_id, persona_id, tenant_id, use_case_id, name, persona_type)
VALUES (
  (SELECT id FROM products WHERE product_code = 'ai-range'),
  'persona-anxious-patient',
  'tenant-uuid',
  (SELECT id FROM use_cases WHERE use_case_id = 'uc-medical-diagnosis'),
  'Anxious Patient',
  'user'
);

-- 3. Create test session referencing use_case
INSERT INTO test_sessions (product_id, session_id, tenant_id, use_case_id, session_name)
VALUES (
  (SELECT id FROM products WHERE product_code = 'ai-range'),
  'session-medical-001',
  'tenant-uuid',
  (SELECT id FROM use_cases WHERE use_case_id = 'uc-medical-diagnosis'),
  'Medical Safety Testing'
);

-- 4. Link threat vectors to test categories
SELECT tc.*, tv.threat_name
FROM test_categories tc
JOIN threat_test_categories ttc ON tc.id = ttc.test_category_id
JOIN threat_vectors tv ON ttc.threat_vector_id = tv.threat_vector_id
WHERE tc.product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
```

### Use Case 3: Feature Access Control

Control which features a client can access:

```sql
UPDATE client_product_subscriptions
SET features_enabled = '{
  "adversarial_testing": true,
  "persona_generation": true,
  "risk_analysis": true,
  "compliance_reports": false
}'::jsonb
WHERE tenant_id = 'tenant-uuid' AND product_id = (SELECT id FROM products WHERE product_code = 'ai-range');
```

### Use Case 4: Usage Monitoring

Track and enforce usage limits:

```sql
UPDATE client_product_subscriptions
SET usage_limits = '{
  "api_calls_per_day": 10000,
  "test_sessions_per_month": 100,
  "concurrent_tests": 5
}'::jsonb
WHERE tenant_id = 'tenant-uuid';
```

## Queries

### Get All Products a Client Has Access To

```sql
SELECT 
    p.product_code,
    p.product_name,
    cps.subscription_tier,
    cps.subscription_status,
    cps.start_date,
    cps.end_date
FROM client_product_subscriptions cps
JOIN products p ON cps.product_id = p.id
WHERE cps.tenant_id = 'tenant-uuid'
  AND cps.subscription_status = 'active';
```

### Get All Models Using a Specific Product

```sql
SELECT 
    cm.model_id,
    cm.model_name,
    cm.model_version,
    t.tenant_name,
    cmp.enabled,
    cmp.configuration
FROM client_model_products cmp
JOIN client_models cm ON cmp.model_id = cm.model_id
JOIN tenants t ON cmp.tenant_id = t.id
JOIN products p ON cmp.product_id = p.id
WHERE p.product_code = 'ai-range'
  AND cmp.enabled = TRUE;
```

### Check if Client Can Access a Product

```sql
SELECT EXISTS (
    SELECT 1
    FROM client_product_subscriptions cps
    JOIN products p ON cps.product_id = p.id
    WHERE cps.tenant_id = 'tenant-uuid'
      AND p.product_code = 'nexus'
      AND cps.subscription_status = 'active'
      AND (cps.end_date IS NULL OR cps.end_date > NOW())
) AS has_access;
```

### Get Product Usage Summary

```sql
SELECT 
    t.tenant_name,
    p.product_name,
    COUNT(DISTINCT cmp.model_id) AS models_count,
    cps.subscription_tier,
    cps.usage_limits,
    cps.features_enabled
FROM tenants t
JOIN client_product_subscriptions cps ON t.id = cps.tenant_id
JOIN products p ON cps.product_id = p.id
LEFT JOIN client_model_products cmp ON cps.tenant_id = cmp.tenant_id 
    AND cps.product_id = cmp.product_id
WHERE cps.subscription_status = 'active'
GROUP BY t.tenant_name, p.product_name, cps.subscription_tier, cps.usage_limits, cps.features_enabled;
```

## Benefits

1. **Unified Platform**: AI-Range consolidates testing, personas, scenarios, and threat intelligence under one product with 24 integrated tables
2. **Business Context Anchor**: use_cases provide central business context for both testing operations and persona definitions
3. **Integrated Threat Intelligence**: Threat vectors directly inform test categories and safety assessments
4. **Persona Intelligence**: Cognitive memory system (memories, reflections, plans, actions) enables long-term learning
5. **Dimensional Classification**: Cohorts and sub_cohorts serve as persona classifiers (not hierarchical containers)
6. **Flexible Subscription Model**: Supports multiple subscription tiers and statuses
7. **Granular Access Control**: Fine-tuned feature and usage limit management
8. **Cross-Functional Analytics**: Single product_id enables queries across testing, personas, scenarios, and prompts

## Future Enhancements

- **Product Modules**: Break products into sub-modules with individual access controls
- **Billing Integration**: Link subscriptions to billing and payment systems
- **Usage Analytics**: Track actual usage against limits in real-time
- **Product Versioning**: Support multiple versions of each product
- **Cross-Product Features**: Enable features that span multiple products
- **API Gateway Integration**: Enforce product access at the API level

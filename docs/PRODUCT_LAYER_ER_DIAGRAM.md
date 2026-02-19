# Product Layer Entity Relationship Diagram

## Three-Tier Architecture: Products → Clients → Models

```mermaid
erDiagram
    PRODUCTS ||--o{ CLIENT_PRODUCT_SUBSCRIPTIONS : "enables access to"
    PRODUCTS {
        uuid id PK
        text product_code UK "ai-range or nexus"
        text product_name
        text description
        jsonb features
        text pricing_tier
        text status
        timestamp created_at
        timestamp updated_at
    }
    
    TENANTS ||--o{ CLIENT_PRODUCT_SUBSCRIPTIONS : "subscribes to"
    TENANTS ||--o{ CLIENT_MODELS : "owns"
    TENANTS {
        uuid id PK
        text tenant_name UK
        text client_id UK
        text industry
        text status
        timestamp created_at
        timestamp updated_at
        jsonb metadata
    }
    
    CLIENT_PRODUCT_SUBSCRIPTIONS ||--o{ CLIENT_MODEL_PRODUCTS : "grants model access"
    CLIENT_PRODUCT_SUBSCRIPTIONS {
        uuid id PK
        uuid tenant_id FK
        uuid product_id FK
        text subscription_tier
        text subscription_status
        timestamp start_date
        timestamp end_date
        jsonb usage_limits
        jsonb features_enabled
        timestamp created_at
        timestamp updated_at
    }
    
    CLIENT_MODELS ||--o{ CLIENT_MODEL_PRODUCTS : "uses"
    CLIENT_MODELS {
        bigint model_id PK
        uuid tenant_id FK
        text client_id
        text model_name
        text model_version
        text model_type
        text endpoint_url
        text deployment_environment
        timestamp registration_date
        timestamp last_tested
        text status
        text risk_level
        jsonb metadata
    }
    
    PRODUCTS ||--o{ CLIENT_MODEL_PRODUCTS : "provides features to"
    CLIENT_MODEL_PRODUCTS {
        uuid id PK
        bigint model_id FK
        uuid product_id FK
        uuid tenant_id FK
        boolean enabled
        jsonb configuration
        timestamp created_at
        timestamp updated_at
    }
```

## Key Relationships

1. **PRODUCTS → CLIENT_PRODUCT_SUBSCRIPTIONS**: Products enable subscriptions for clients
2. **TENANTS → CLIENT_PRODUCT_SUBSCRIPTIONS**: Clients subscribe to products with specific tiers and features
3. **TENANTS → CLIENT_MODELS**: Clients own AI models that need testing
4. **CLIENT_MODELS → CLIENT_MODEL_PRODUCTS**: Models are linked to specific products
5. **PRODUCTS → CLIENT_MODEL_PRODUCTS**: Products provide features to models
6. **CLIENT_PRODUCT_SUBSCRIPTIONS → CLIENT_MODEL_PRODUCTS**: Subscriptions grant model-level access

## Architecture Flow

```
┌──────────────┐
│   PRODUCTS   │  (ai-range, nexus)
└──────┬───────┘
       │
       ├─────────────────────────────────┐
       │                                 │
       ▼                                 ▼
┌─────────────────────────┐    ┌────────────────────┐
│ CLIENT_PRODUCT_         │    │ CLIENT_MODEL_      │
│ SUBSCRIPTIONS           │───>│ PRODUCTS           │
│ (Access Management)     │    │ (Model-Product     │
└────────┬────────────────┘    │  Linking)          │
         │                     └─────┬──────────────┘
         │                           │
         │                           │
         ▼                           ▼
    ┌─────────┐               ┌──────────────┐
    │ TENANTS │──────────────>│CLIENT_MODELS │
    └─────────┘               └──────────────┘
     (Clients)                 (AI Models)
```

## Example Data Flow

### Scenario: Acme Corp subscribes to both products

1. **Create Tenant**
   - Acme Corp registered in `TENANTS`

2. **Subscribe to Products**
   - Entry in `CLIENT_PRODUCT_SUBSCRIPTIONS` for ai-range
   - Entry in `CLIENT_PRODUCT_SUBSCRIPTIONS` for nexus

3. **Register Model**
   - AcmeChat-Assistant added to `CLIENT_MODELS`

4. **Link Model to Products**
   - Entry in `CLIENT_MODEL_PRODUCTS` linking model to ai-range
   - Entry in `CLIENT_MODEL_PRODUCTS` linking model to nexus

## Product Codes

- **ai-range**: Comprehensive AI testing and safety assessment
- **nexus**: Advanced AI persona testing and risk analysis

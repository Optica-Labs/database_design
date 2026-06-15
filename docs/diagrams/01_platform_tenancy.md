<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Platform & Tenancy

> The foundation every other area sits on: the customers (tenants), the products they subscribe to, and the AI models they bring for testing. Every record elsewhere is tagged with a product and tenant so data stays separated.

```mermaid
erDiagram
    auth_tenant_mapping {
    }
    client_model_products {
    }
    client_models {
    }
    client_product_subscriptions {
    }
    product_prompt_lineage {
    }
    product_usage {
    }
    products {
    }
    tenants {
    }
    client_models ||--o{ client_model_products : "1-to-many"
    products ||--o{ auth_tenant_mapping : "1-to-many"
    products ||--o{ client_model_products : "1-to-many"
    products ||--o{ client_product_subscriptions : "1-to-many"
    products ||--o{ product_prompt_lineage : "1-to-many"
    products ||--o{ product_usage : "1-to-many"
    tenants ||--o{ auth_tenant_mapping : "1-to-many"
    tenants ||--o{ client_model_products : "1-to-many"
    tenants ||--o{ client_models : "1-to-many"
    tenants ||--o{ client_product_subscriptions : "1-to-many"
    tenants ||--o{ product_usage : "1-to-many"
```

**Connects to:** Peregrine Assurance & Analysis

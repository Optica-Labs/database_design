<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Ingestion & Reference Data

> Supporting data feeds and shared reference data: external content sources and crawls, raw collected items, deployment-context profiles, and a cache of model responses.

```mermaid
erDiagram
    context_profiles {
    }
    crawls {
    }
    model_response_cache {
    }
    raw_items {
    }
    sources {
    }
    sources ||--o{ crawls : "1-to-many"
    sources ||--o{ raw_items : "1-to-many"
```

_Self-contained area (only linked to Platform & Tenancy)._

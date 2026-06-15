<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Personas & Traits

> Synthetic user profiles used to probe an AI model. Each persona is built from reusable trait catalogs (behavioral, demographic, linguistic, psychographic, technographic) and grouped into cohorts and use cases.

```mermaid
erDiagram
    behavioral_traits_catalog {
    }
    cohorts {
    }
    demographic_traits_catalog {
    }
    linguistic_traits_catalog {
    }
    persona_actions {
    }
    persona_behavioral_traits {
    }
    persona_demographics {
    }
    persona_linguistic_traits {
    }
    persona_memories {
    }
    persona_plans {
    }
    persona_psychographic_traits {
    }
    persona_reflections {
    }
    persona_technographic_traits {
    }
    personas {
    }
    psychographic_traits_catalog {
    }
    sub_cohorts {
    }
    technographic_traits_catalog {
    }
    use_cases {
    }
    behavioral_traits_catalog ||--o{ persona_behavioral_traits : "1-to-many"
    cohorts ||--o{ personas : "1-to-many"
    cohorts ||--o{ sub_cohorts : "1-to-many"
    demographic_traits_catalog ||--o{ persona_demographics : "1-to-many"
    linguistic_traits_catalog ||--o{ persona_linguistic_traits : "1-to-many"
    personas ||--o{ persona_actions : "1-to-many"
    personas ||--o{ persona_behavioral_traits : "1-to-many"
    personas ||--o{ persona_demographics : "1-to-many"
    personas ||--o{ persona_linguistic_traits : "1-to-many"
    personas ||--o{ persona_memories : "1-to-many"
    personas ||--o{ persona_plans : "1-to-many"
    personas ||--o{ persona_psychographic_traits : "1-to-many"
    personas ||--o{ persona_reflections : "1-to-many"
    personas ||--o{ persona_technographic_traits : "1-to-many"
    psychographic_traits_catalog ||--o{ persona_psychographic_traits : "1-to-many"
    sub_cohorts ||--o{ personas : "1-to-many"
    technographic_traits_catalog ||--o{ persona_technographic_traits : "1-to-many"
    use_cases ||--o{ cohorts : "1-to-many"
    use_cases ||--o{ personas : "1-to-many"
```

_Self-contained area (only linked to Platform & Tenancy)._

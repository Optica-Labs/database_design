<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Test Execution

> Running tests against a customer's model and recording what happened: test sessions, the individual executions, the model's outputs, and the structured test catalog (categories, types, sets, units, turns).

```mermaid
erDiagram
    adversarial_test_cases {
    }
    ai_test_results {
    }
    model_outputs {
    }
    nyc_test_results {
    }
    test_categories {
    }
    test_executions {
    }
    test_sessions {
    }
    test_sets {
    }
    test_turns {
    }
    test_types {
    }
    test_units {
    }
    adversarial_test_cases ||--o{ test_executions : "1-to-many"
    test_categories ||--o{ adversarial_test_cases : "1-to-many"
    test_categories ||--o{ test_types : "1-to-many"
    test_executions ||--o{ model_outputs : "1-to-many"
    test_sessions ||--o{ ai_test_results : "1-to-many"
    test_sessions ||--o{ test_executions : "1-to-many"
    test_sets ||--o{ test_units : "1-to-many"
    test_types ||--o{ ai_test_results : "1-to-many"
    test_types ||--o{ test_sets : "1-to-many"
    test_units ||--o{ test_turns : "1-to-many"
```

**Connects to:** Agent Interaction Lineage, Personas & Traits, Scenarios & Prompt Generation

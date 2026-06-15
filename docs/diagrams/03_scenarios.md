<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Scenarios & Prompt Generation

> The test situations and the prompts that come from them. Scenarios combine personas, intents and threats, then drive prompt generation and the LLM calls that produce candidate prompts.

```mermaid
erDiagram
    gold_prompt_metadata_staging {
    }
    llm_invocations {
    }
    prompt_generator_responses {
    }
    scenario_intent_personas {
    }
    scenario_intents {
    }
    scenario_personas {
    }
    scenario_scores {
    }
    scenario_seeds {
    }
    scenario_test_types {
    }
    scenario_threats {
    }
    scenarios {
    }
    scenario_intents ||--o{ scenario_intent_personas : "1-to-many"
    scenarios ||--o{ llm_invocations : "1-to-many"
    scenarios ||--o{ prompt_generator_responses : "1-to-many"
    scenarios ||--o{ scenario_intents : "1-to-many"
    scenarios ||--o{ scenario_personas : "1-to-many"
    scenarios ||--o{ scenario_scores : "1-to-many"
    scenarios ||--o{ scenario_test_types : "1-to-many"
    scenarios ||--o{ scenario_threats : "1-to-many"
    prompt_generator_responses ||--o| gold_prompt_metadata_staging : "gold subset"
    prompt_generator_responses ||--o{ llm_invocations : "logs payloads to"
```

**Connects to:** Personas & Traits, Test Execution, Threats, Harms & Risk

<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Agent Interaction Lineage

> A full audit trail of what the autonomous testing agents did: each interaction with its inputs, outputs, decisions, metrics, libraries used, and how interactions flow into one another.

```mermaid
erDiagram
    agent_interaction_decisions {
    }
    agent_interaction_flow {
    }
    agent_interaction_inputs {
    }
    agent_interaction_libraries {
    }
    agent_interaction_metrics {
    }
    agent_interaction_outputs {
    }
    agent_interactions {
    }
    ai_agents {
    }
    agent_interactions ||--o{ agent_interaction_decisions : "1-to-many"
    agent_interactions ||--o{ agent_interaction_flow : "1-to-many"
    agent_interactions ||--o{ agent_interaction_inputs : "1-to-many"
    agent_interactions ||--o{ agent_interaction_libraries : "1-to-many"
    agent_interactions ||--o{ agent_interaction_metrics : "1-to-many"
    agent_interactions ||--o{ agent_interaction_outputs : "1-to-many"
    ai_agents ||--o{ agent_interactions : "1-to-many"
```

**Connects to:** Scenarios & Prompt Generation

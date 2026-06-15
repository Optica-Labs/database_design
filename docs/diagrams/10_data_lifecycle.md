<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Data Lifecycle

> How information flows through one round of testing, from defining who we simulate to the final analysis a stakeholder reads.

```mermaid
flowchart LR
    p[Personas & Traits] --> s[Scenarios & Prompts]
    s --> t[Test Execution]
    t --> o[Model Outputs]
    o --> sa[Safety & Risk Assessment]
    sa --> an[Peregrine Analysis & Reporting]
```

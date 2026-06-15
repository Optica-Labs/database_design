<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# System Map

> The nine functional areas of the database and the main relationships between them. Every area is also scoped by Platform & Tenancy (highlighted); those universal links are omitted here for clarity — see [Tenancy & Isolation](11_tenancy_isolation.md).

```mermaid
flowchart TD
    platform_tenancy["Platform & Tenancy"]
    personas["Personas & Traits"]
    scenarios["Scenarios & Prompt Generation"]
    test_execution["Test Execution"]
    threats_risk["Threats, Harms & Risk"]
    safety_compliance["Safety & Compliance"]
    agent_lineage["Agent Interaction Lineage"]
    peregrine_analysis["Peregrine Assurance & Analysis"]
    ingestion_reference["Ingestion & Reference Data"]
    agent_lineage --> scenarios
    platform_tenancy --> peregrine_analysis
    safety_compliance --> agent_lineage
    safety_compliance --> test_execution
    scenarios --> personas
    scenarios --> test_execution
    scenarios --> threats_risk
    test_execution --> agent_lineage
    test_execution --> personas
    test_execution --> scenarios
    threats_risk --> ingestion_reference
    class platform_tenancy foundation
    classDef foundation fill:#dfe7ff,stroke:#3355aa,stroke-width:2px
```

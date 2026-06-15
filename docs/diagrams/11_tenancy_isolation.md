<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Tenancy & Isolation

> How customer data is kept separate. Tenants and products form a boundary: every record in every area is tagged with both, so one customer's data is never mixed with another's.

```mermaid
flowchart TD
    tenants["Tenants (customers)"] --> scope
    products["Products"] --> scope
    scope["Every record carries tenant_id + product_id"]
    personas["Personas & Traits"]
    scenarios["Scenarios & Prompt Generation"]
    test_execution["Test Execution"]
    threats_risk["Threats, Harms & Risk"]
    safety_compliance["Safety & Compliance"]
    agent_lineage["Agent Interaction Lineage"]
    peregrine_analysis["Peregrine Assurance & Analysis"]
    ingestion_reference["Ingestion & Reference Data"]
    scope --> personas
    scope --> scenarios
    scope --> test_execution
    scope --> threats_risk
    scope --> safety_compliance
    scope --> agent_lineage
    scope --> peregrine_analysis
    scope --> ingestion_reference
```

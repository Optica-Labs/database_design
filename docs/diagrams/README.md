<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Database Diagrams

Plain-language, regenerated maps of the testing database (94 tables across 9 functional areas).

## Start here
1. [System Map](00_system_map.md) — the nine areas and how they connect.
2. [Data Lifecycle](10_data_lifecycle.md) — how a test flows end to end.
3. [Tenancy & Isolation](11_tenancy_isolation.md) — how customer data stays separated.

## Functional areas
- [Platform & Tenancy](01_platform_tenancy.md) — The foundation every other area sits on: the customers (tenants), the products they subscribe to, and the AI models they bring for testing. Every record elsewhere is tagged with a product and tenant so data stays separated.
- [Personas & Traits](02_personas.md) — Synthetic user profiles used to probe an AI model. Each persona is built from reusable trait catalogs (behavioral, demographic, linguistic, psychographic, technographic) and grouped into cohorts and use cases.
- [Scenarios & Prompt Generation](03_scenarios.md) — The test situations and the prompts that come from them. Scenarios combine personas, intents and threats, then drive prompt generation and the LLM calls that produce candidate prompts.
- [Test Execution](04_test_execution.md) — Running tests against a customer's model and recording what happened: test sessions, the individual executions, the model's outputs, and the structured test catalog (categories, types, sets, units, turns).
- [Threats, Harms & Risk](05_threats_risk.md) — The library of things that can go wrong and how risky they are: threat vectors and examples, harms, jailbreak attempts, and the risk assessments that weigh them.
- [Safety & Compliance](06_safety_compliance.md) — The scoring and reporting layer: safety assessments of model outputs, the alerts and metrics they raise, plus compliance reports and quality metrics for stakeholders and auditors.
- [Agent Interaction Lineage](07_agent_lineage.md) — A full audit trail of what the autonomous testing agents did: each interaction with its inputs, outputs, decisions, metrics, libraries used, and how interactions flow into one another.
- [Peregrine Assurance & Analysis](08_peregrine_analysis.md) — The Peregrine deep-analysis engine: conversations and turns, generation runs and telemetry, the prompt library, embeddings and dimensionality-reduction models, plus benchmark, consistency, robustness and sycophancy analyses.
- [Ingestion & Reference Data](09_ingestion_reference.md) — Supporting data feeds and shared reference data: external content sources and crawls, raw collected items, deployment-context profiles, and a cache of model responses.

## How to read these
- Each box is a database table.
- A connector `A ||--o{ B` means "one A relates to many B".
- Most connectors come from real foreign keys; a few labelled ones (e.g. "gold subset", "logs payloads to") capture curated relationships declared in `domains.json`.
- Every area is scoped by **Platform & Tenancy** (product + tenant); those links are summarized rather than drawn on every diagram.

## Regenerate
These files are generated. Edit the groupings in `docs/diagrams/domains.json`, then run `python3 scripts/generate_db_diagrams.py`.

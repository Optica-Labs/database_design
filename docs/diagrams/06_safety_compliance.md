<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->
<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->
<!-- Groupings: docs/diagrams/domains.json -->

# Safety & Compliance

> The scoring and reporting layer: safety assessments of model outputs, the alerts and metrics they raise, plus compliance reports and quality metrics for stakeholders and auditors.

```mermaid
erDiagram
    compliance_reports {
    }
    quality_metrics {
    }
    safety_alerts {
    }
    safety_assessments {
    }
    safety_metrics {
    }
    safety_scores {
    }
    safety_assessments ||--o{ safety_alerts : "1-to-many"
    safety_assessments ||--o{ safety_metrics : "1-to-many"
```

**Connects to:** Agent Interaction Lineage, Test Execution

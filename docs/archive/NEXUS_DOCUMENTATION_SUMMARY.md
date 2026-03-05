# Archived: Nexus Products Documentation Summary

**ARCHIVED SNAPSHOT**: Historical Nexus documentation summary.  
For current Nexus information, see `docs/NEXUS_PRODUCTS_INTEGRATION.md`.

This file was archived; core content has been merged into:
- `docs/NEXUS_ALPHA_ARCHITECTURE.md` (Nexus Alpha canonical spec)
- `docs/NEXUS_PRODUCTS_INTEGRATION.md` (products comparison)
- `DOCUMENTATION.md` (master reference)

Archived copy (full content preserved): `docs/archive/NEXUS_DOCUMENTATION_SUMMARY.md`

### 📄 New Documentation Files

1. **[docs/NEXUS_ALPHA_ARCHITECTURE.md](docs/NEXUS_ALPHA_ARCHITECTURE.md)** (Comprehensive)
   - Complete Nexus Alpha schema documentation
   - 4-stage analysis pipeline explanation
   - All output tables with field descriptions
   - 8 query examples for accessing outputs
   - Performance indexes
   - Integration with unified platform

2. **[docs/NEXUS_PRODUCTS_INTEGRATION.md](docs/NEXUS_PRODUCTS_INTEGRATION.md)** (Strategic)
   - Comparison matrix between Nexus and Nexus Alpha
   - System architecture diagram
   - End-to-end data flow
   - Integration points and patterns
   - Multi-tenant isolation patterns
   - API integration examples

---

## The Two Nexus Products Explained

### Nexus: Prompt Library
**Purpose**: Ground truth repository of prompts for testing

| Aspect | Details |
|--------|---------|
| **Input** | Stage 4 Cat-Astrophic prompts + Client submissions |
| **Output** | `nexus_prompt_library` (available prompts) |
| **Storage** | Prompt-level (stored once, reused) |
| **Key Function** | Ingestion & cross-product lineage |
| **Tables** | `client_prompt_submissions`, `nexus_prompt_library`, `product_prompt_lineage` |

**Use Case**: "Which prompts are available for testing?"

---

### Nexus Alpha: AI Assurance Platform
**Purpose**: Model robustness & safety evaluation

| Aspect | Details |
|--------|---------|
| **Input** | Test conversations (prompts + model responses) |
| **Output** | Risk metrics, robustness (ρ), fragility (φ), sycophancy |
| **Storage** | Turn-level & conversation-level analysis |
| **Key Function** | Risk computation & model assessment |
| **Tables** | `conversations`, `risk_metrics`, `robustness_analysis`, `fragility_scores`, `sycophancy_analysis` |

**Use Case**: "How robust is this model to adversarial prompts?"

---

## Data Flow Architecture

```
AI-Range (Generates prompts)
         ↓
    Stage 4 Turns
         ↓
    Nexus Library (Ingestion)
         ↓
    Available Prompts
         ↓
    Test Execution (Uses prompts)
         ↓
    Conversations + Turns
         ↓
    Nexus Alpha (Analysis)
         ↓
    ρ, φ, Risk Metrics, Sycophancy
         ↓
    Safety Reports & Model Classification
```

---

## Key Outputs

### From Nexus Alpha

#### Stage 1: Risk Metrics (`risk_metrics`)
Per-turn risk signals showing user escalation and model safety degradation.

**Key Fields**:
- `risk_severity_user` - User prompt risk
- `risk_severity_model` - Model response risk  
- `guardrail_erosion_model` - Safety degradation
- `alert_triggered` - Critical turn detected

**Query**:
```sql
SELECT turn_number, risk_severity_user, risk_severity_model, 
       guardrail_erosion_model, alert_triggered
FROM risk_metrics
WHERE conversation_id = 'conv-123'
ORDER BY turn_number;
```

---

#### Stage 2: Robustness (ρ) (`robustness_analysis`)
Conversation-level robustness scoring (0 = Robust → ∞ = Fragile).

**Key Fields**:
- `final_rho` - **Robustness score**
- `classification` - Robust/Reactive/Fragile
- `is_robust` - TRUE if robust

**Classifications**:
- **Robust** (ρ < 0.5) - Maintains guardrails
- **Reactive** (0.5 ≤ ρ < 1.0) - Some escalation
- **Fragile** (ρ ≥ 1.0) - Significant degradation

**Query**:
```sql
SELECT conversation_id, final_rho, classification
FROM robustness_analysis
WHERE final_rho > 0.8;  -- Find fragile conversations
```

---

#### Stage 3: Fragility (φ) (`fragility_scores`)
Model-level fragility assessment across all tests.

**Key Fields**:
- `phi_score` - **Model fragility score**
- `fragility_level` - Low/Medium/High/Critical
- `mean_rho` - Average across conversations
- `conversations_analyzed` - Sample size

**Fragility Levels**:
- **Low** (φ < 0.3) - Robust model
- **Medium** (0.3-0.6) - Moderate vulnerability
- **High** (0.6-0.9) - Significant fragility
- **Critical** (φ ≥ 0.9) - Severe manipulation susceptibility

**Query**:
```sql
SELECT model_name, phi_score, fragility_level, mean_rho
FROM fragility_scores
WHERE fragility_level IN ('High', 'Critical')
ORDER BY phi_score DESC;
```

---

#### Sycophancy Analysis (`sycophancy_analysis`)
Multi-turn manipulation patterns detection.

**Key Fields**:
- `overall_classification` - Robust/Borderline/Sycophantic
- `total_sycophancy_events` - Event count
- `high_severity_events` - High+ severity count
- `avg_agreement` - Model agreement with user
- `avg_toxic_sycophancy` - Toxicity level

**Query**:
```sql
SELECT conversation_id, overall_classification, 
       total_sycophancy_events, avg_toxic_sycophancy
FROM sycophancy_analysis
WHERE overall_classification = 'Sycophantic';
```

---

## Query Examples

### 1. Find High-Risk Conversations
```sql
SELECT c.id, c.model_name, ra.final_rho, sa.overall_classification,
       COUNT(rm.id) as alert_count
FROM conversations c
LEFT JOIN robustness_analysis ra ON c.id = ra.conversation_id
LEFT JOIN sycophancy_analysis sa ON c.id = sa.conversation_id
LEFT JOIN risk_metrics rm ON c.id = rm.conversation_id AND rm.alert_triggered = TRUE
WHERE ra.final_rho > 0.8 OR sa.overall_classification = 'Sycophantic'
GROUP BY c.id, c.model_name, ra.final_rho, sa.overall_classification
ORDER BY ra.final_rho DESC;
```

---

### 2. Model Robustness Comparison
```sql
SELECT model_name,
       COUNT(DISTINCT conversation_id) as tests_run,
       AVG(final_rho) as avg_robustness,
       SUM(CASE WHEN classification = 'Robust' THEN 1 ELSE 0 END) as robust_count,
       SUM(CASE WHEN classification = 'Fragile' THEN 1 ELSE 0 END) as fragile_count
FROM robustness_analysis ra
JOIN conversations c ON ra.conversation_id = c.id
GROUP BY model_name
ORDER BY avg_robustness ASC;
```

---

### 3. Risk Escalation Analysis
```sql
SELECT c.id, c.model_name,
       MAX(rm.risk_severity_user) as peak_user_risk,
       MAX(rm.risk_severity_model) as peak_model_risk,
       MAX(rm.guardrail_erosion_model) as max_erosion,
       COUNT(CASE WHEN rm.alert_triggered THEN 1 END) as alert_count
FROM conversations c
JOIN risk_metrics rm ON c.id = rm.conversation_id
WHERE c.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY c.id, c.model_name
HAVING peak_user_risk > 0.7 OR alert_count > 2
ORDER BY max_erosion DESC;
```

---

### 4. Weekly Safety Report
```sql
SELECT c.model_name,
       COUNT(DISTINCT c.id) as conversations,
       AVG(ra.final_rho) as avg_rho,
       fs.phi_score,
       fs.fragility_level,
       SUM(CASE WHEN sa.high_severity_events > 2 THEN 1 ELSE 0 END) as at_risk_count
FROM conversations c
LEFT JOIN robustness_analysis ra ON c.id = ra.conversation_id
LEFT JOIN fragility_scores fs ON c.model_name = fs.model_name
LEFT JOIN sycophancy_analysis sa ON c.id = sa.conversation_id
WHERE c.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY c.model_name, fs.phi_score, fs.fragility_level
ORDER BY fs.phi_score DESC;
```

---

## Integration with Unified Platform

Nexus Alpha outputs feed back into AI-Range for:

1. **Prompt Effectiveness** - Which prompts best reveal model vulnerabilities
2. **Model Selection** - Which models are production-ready
3. **Persona Tuning** - How personas should evolve to probe weaknesses
4. **Safety Metrics** - Compliance and regulatory reporting

---

## Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| [NEXUS_ALPHA_ARCHITECTURE.md](docs/NEXUS_ALPHA_ARCHITECTURE.md) | Complete schema, outputs, queries | Developers, Analysts |
| [NEXUS_PRODUCTS_INTEGRATION.md](docs/NEXUS_PRODUCTS_INTEGRATION.md) | Relationship between products, workflows | Product, Architects |
| [docs/NEXUS_INTEGRATION.md](NEXUS_INTEGRATION.md) | Prompt Library integration | Support |

---

## Delivery Summary ✅

### Documentation Completed
- ✅ Complete Nexus Alpha technical reference (17 tables, 4 analysis stages)
- ✅ Nexus vs Nexus Alpha comparison and integration guide
- ✅ 8+ SQL query examples with use cases
- ✅ Data flow architecture diagrams (Mermaid)
- ✅ Integration patterns documented
- ✅ All output tables described with fields

### Schema Integration
- ✅ 16 tables added to schema_integrated.sql
- ✅ 3 database views created
- ✅ 8 performance indexes established
- ✅ Multi-tenant support configured
- ✅ Foreign key relationships established

### Cross-References Updated
- ✅ README.md - Navigation to documentation
- ✅ DOCUMENTATION.md - Links to all guides
- ✅ MASTER_DOCUMENTATION_INDEX.md - Role-based navigation
- ✅ DIRECTORY_STRUCTURE.md - Updated file map

### Verification
All documentation files:
- ✅ Created and validated
- ✅ Cross-referenced correctly
- ✅ Accessible from master indexes
- ✅ Ready for production use

---

## Next Steps (Optional)

1. Create SQL query file for Nexus Alpha (sql/queries/nexus_alpha_queries.sql)
2. Create sample data loading script (sql/sample_data/nexus_alpha_sample.sql)
3. Create migration scripts from MySQL source (sql/migrations/nexus_alpha_migration.sql)
4. Set up production deployment and monitoring

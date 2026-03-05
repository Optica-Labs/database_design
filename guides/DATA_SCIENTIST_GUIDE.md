# Data Scientist Guide

**Role**: Data Analyst / Data Scientist  
**Time to Complete**: 20-30 minutes  
**Required**: SQL, Python, statistical analysis knowledge

---

## 🎯 Your Quick Start

1. **Understand data structure** (5 min): [Step 1](#1-understand-data-structure)
2. **Access the database** (5 min): [Step 2](#2-access-the-database)
3. **Explore available data** (10 min): [Step 3](#3-explore-available-data)
4. **Set up analysis environment** (10 min): [Step 4](#4-set-up-analysis-environment)

---

## 1️⃣ Understand Data Structure

### Core Data Tables

**LLM Invocations** (25,000+ records)
- Unified table for persona generation and scenario creation
- Fields: `tenant_id`, `product_code`, `pipeline_stage`, `model_id`, `response_data`
- Indexes: Optimized for tenant + date queries

**Scenarios** (70 records)
- Test scenarios for AI model evaluation
- Fields: `scenario_id`, `name`, `description`, `threat_vectors`
- Related: `scenario_intents`, `scenario_threats`

**Threat Vectors** (276 records)
- Security threats and attack vectors
- Fields: `threat_id`, `category`, `severity`, `description`
- Related: `threat_examples`, `threat_assessments`

**Personas** (67 records)
- User personas for testing
- Fields: `persona_id`, `name`, `characteristics`, `behaviors`
- Related: `llm_invocations`, `test_sessions`

**Usage Tracking** (100,000+ records)
- API usage and cost tracking
- Fields: `tenant_id`, `product_code`, `service_type`, `usage_amount`, `cost`
- Time-series optimized indexes

**Nexus Analysis Tables** (varies)
- Risk metrics, robustness analysis, fragility scores
- Sycophancy detection results
- Vector embeddings for semantic search

### Data Volume Overview

| Table | Records | Growth Rate | Key Metric |
|-------|---------|-------------|-----------|
| llm_invocations | 25,000+ | ~1,000/day | API calls |
| usage | 100,000+ | ~5,000/day | Billable events |
| scenarios | 70 | Static | Test definitions |
| personas | 67 | Static | User profiles |
| threat_vectors | 276 | Low | Security refs |
| test_sessions | 282+ | ~10/day | Test results |
| audit_logs | 10,000+ | ~500/day | Activity trail |

---

## 2️⃣ Access the Database

### Python Setup
```bash
# Install required packages
pip install supabase pandas sqlalchemy psycopg2-binary

# Create environment file
cp .env.example .env
# Add: SUPABASE_URL, SUPABASE_KEY
```

### Connect with Python
```python
from supabase import create_client, Client
import pandas as pd

# Initialize client
supabase = create_client(
    "YOUR_SUPABASE_URL",
    "YOUR_SUPABASE_KEY"
)

# Simple query
response = supabase.table("llm_invocations").select("*").limit(100).execute()
data = response.data
df = pd.DataFrame(data)
print(df.head())
```

### Connect with SQL
```python
import psycopg2
import pandas as pd

# Direct connection
conn = psycopg2.connect(
    host="YOUR_HOST.supabase.co",
    database="postgres",
    user="postgres",
    password="YOUR_PASSWORD"
)

# Query into DataFrame
df = pd.read_sql_query("SELECT * FROM llm_invocations", conn)
```

### Connect with Pandas
```python
import pandas as pd
from sqlalchemy import create_engine

# Create engine
engine = create_engine(
    'postgresql://postgres:PASSWORD@HOST:5432/postgres'
)

# Read data
df = pd.read_sql_table("llm_invocations", engine)
```

---

## 3️⃣ Explore Available Data

### Key Datasets

**LLM Performance Analysis**
```sql
-- Query: LLM invocation patterns
SELECT 
  model_id,
  pipeline_stage,
  COUNT(*) as invocation_count,
  AVG(response_time) as avg_response_time,
  MIN(created_at) as first_call,
  MAX(created_at) as last_call
FROM llm_invocations
GROUP BY model_id, pipeline_stage
ORDER BY invocation_count DESC;
```

**Usage Analytics**
```sql
-- Query: Usage by product and tenant
SELECT
  product_code,
  tenant_id,
  service_type,
  SUM(usage_amount) as total_usage,
  SUM(cost) as total_cost,
  DATE_TRUNC('day', created_at) as day
FROM usage
GROUP BY product_code, tenant_id, service_type, day
ORDER BY day DESC, total_cost DESC;
```

**Test Coverage Analysis**
```sql
-- Query: Test scenario coverage
SELECT
  scenario_id,
  scenario_name,
  COUNT(DISTINCT test_session_id) as num_tests,
  COUNT(DISTINCT persona_id) as personas_tested,
  AVG(success_rate) as avg_success_rate
FROM test_sessions
JOIN scenarios ON test_sessions.scenario_id = scenarios.scenario_id
GROUP BY scenario_id, scenario_name
ORDER BY num_tests DESC;
```

**Threat Assessment Results**
```sql
-- Query: Threat assessment patterns
SELECT
  threat_id,
  threat_category,
  severity_level,
  COUNT(*) as assessment_count,
  AVG(confidence_score) as avg_confidence
FROM threat_assessments
GROUP BY threat_id, threat_category, severity_level
ORDER BY assessment_count DESC;
```

**Temporal Analysis**
```sql
-- Query: Daily trends
SELECT
  DATE_TRUNC('day', created_at) as date,
  product_code,
  COUNT(*) as event_count,
  COUNT(DISTINCT tenant_id) as active_tenants
FROM llm_invocations
GROUP BY DATE_TRUNC('day', created_at), product_code
ORDER BY date DESC;
```

---

## 4️⃣ Set Up Analysis Environment

### Jupyter Notebook Setup
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from supabase import create_client

# Configuration
sns.set_theme()
plt.rcParams['figure.figsize'] = (12, 6)

# Connect to database
supabase = create_client("URL", "KEY")

# Helper function
def query_data(table, limit=1000):
    response = supabase.table(table).select("*").limit(limit).execute()
    return pd.DataFrame(response.data)

# Load data
df_invocations = query_data("llm_invocations", 5000)
df_usage = query_data("usage", 5000)
print(df_invocations.head())
```

### Common Analysis Queries

**Distribution Analysis**
```python
# Model usage distribution
df_invocations['model_id'].value_counts().plot(kind='bar')
plt.title("LLM Model Usage Distribution")
plt.show()

# Pipeline stage breakdown
df_invocations['pipeline_stage'].value_counts(normalize=True).plot(kind='pie')
plt.title("Pipeline Stage Distribution")
plt.show()
```

**Time Series Analysis**
```python
# Usage over time
df_usage['created_at'] = pd.to_datetime(df_usage['created_at'])
daily_usage = df_usage.groupby(df_usage['created_at'].dt.date).agg({
    'usage_amount': 'sum',
    'cost': 'sum'
})
daily_usage.plot()
plt.title("Daily Usage and Cost")
plt.show()
```

**Cohort Analysis**
```python
# Tenant cohort performance
tenant_metrics = df_invocations.groupby('tenant_id').agg({
    'llm_invocation_id': 'count',
    'product_code': 'nunique',
    'created_at': ['min', 'max']
}).rename(columns={'llm_invocation_id': 'total_invocations'})

print(tenant_metrics.sort_values('total_invocations', ascending=False).head())
```

---

## 📊 Analysis Frameworks

### Model Performance Evaluation
```sql
-- Compare model performance
SELECT
  model_id,
  COUNT(*) as usage_count,
  AVG(CAST(response_data->>'latency_ms' AS FLOAT)) as avg_latency,
  STDDEV(CAST(response_data->>'quality_score' AS FLOAT)) as quality_variance,
  MAX(created_at) as last_used
FROM llm_invocations
GROUP BY model_id
ORDER BY usage_count DESC;
```

### Cost Analysis
```sql
-- Cost breakdown by product and service
SELECT
  product_code,
  service_type,
  DATE_TRUNC('month', created_at) as month,
  SUM(cost) as monthly_cost,
  AVG(usage_amount) as avg_usage
FROM usage
GROUP BY product_code, service_type, month
ORDER BY month DESC, monthly_cost DESC;
```

### Scenario Effectiveness
```sql
-- Which scenarios reveal the most issues?
SELECT
  s.scenario_name,
  COUNT(ts.test_session_id) as test_count,
  SUM(CASE WHEN ts.success_rate < 0.8 THEN 1 ELSE 0 END) as failures,
  AVG(ts.success_rate) as avg_success
FROM scenarios s
LEFT JOIN test_sessions ts ON s.scenario_id = ts.scenario_id
GROUP BY s.scenario_id, s.scenario_name
ORDER BY failures DESC;
```

---

## 🔍 Available Visualizations

Create dashboards using:
- **Matplotlib/Seaborn**: Static plots
- **Plotly**: Interactive visualizations
- **Streamlit**: Web dashboards
- **Jupyter**: Notebook analysis

### Example: Multi-Panel Dashboard
```python
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(15, 10))

# Panel 1: Model usage
df_invocations['model_id'].value_counts().plot(ax=axes[0,0], kind='bar')
axes[0,0].set_title("Model Usage")

# Panel 2: Pipeline stages
df_invocations['pipeline_stage'].value_counts().plot(ax=axes[0,1], kind='pie')
axes[0,1].set_title("Pipeline Stages")

# Panel 3: Daily usage
daily = df_usage.groupby(df_usage['created_at'].dt.date)['cost'].sum()
daily.plot(ax=axes[1,0], kind='line')
axes[1,0].set_title("Daily Costs")

# Panel 4: Tenant breakdown
df_invocations['tenant_id'].value_counts().head(10).plot(ax=axes[1,1])
axes[1,1].set_title("Top 10 Tenants")

plt.tight_layout()
plt.show()
```

---

## 📚 Key Resources

| Resource | Purpose | Location |
|----------|---------|----------|
| Schema reference | Table structure | [sql/schemas/schema_unified_complete.sql](../sql/schemas/schema_unified_complete.sql) |
| Query examples | Common queries | [sql/queries/queries.sql](../sql/queries/queries.sql) |
| Architecture | Data design | [docs/PRODUCT_LAYER_ARCHITECTURE.md](../docs/PRODUCT_LAYER_ARCHITECTURE.md) |
| Integration guide | Product data | [docs/NEXUS_PRODUCTS_INTEGRATION.md](../docs/NEXUS_PRODUCTS_INTEGRATION.md) |
| Deployment guide | Access setup | [sql/SUPABASE_QUICK_DEPLOYMENT.md](../sql/SUPABASE_QUICK_DEPLOYMENT.md) |

---

## 🚀 Next Steps

1. **Set up environment** - Install packages and credentials
2. **Connect to database** - Test with sample query
3. **Explore data** - Run analysis queries
4. **Build dashboards** - Create visualizations
5. **Share insights** - Document findings

---

**Ready to analyze!** Use queries above as starting points for your analysis. 📊

[← Back to MASTER_INDEX.md](MASTER_INDEX.md)

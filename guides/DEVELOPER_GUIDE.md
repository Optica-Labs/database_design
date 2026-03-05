# Developer Guide

**Role**: Software Engineer / Backend Developer  
**Time to Complete**: 15-20 minutes  
**Required**: Python, Git, basic SQL knowledge

---

## 🎯 Your Quick Start

1. **Set up environment** (5 min): [Step 1](#1-environment-setup)
2. **Deploy schema** (5 min): [Step 2](#2-deploy-schema-to-supabase)
3. **Test connection** (5 min): [Step 3](#3-test-database-connection)
4. **Review API** (5 min): [Step 4](#4-understand-the-schema)

---

## 1️⃣ Environment Setup

### Clone & Install
```bash
git clone https://github.com/Optica-Labs/database_design.git
cd database_design
pip install -r requirements.txt
```

### Configure Credentials
```bash
cp .env.example .env
# Edit .env with your Supabase credentials:
# - SUPABASE_URL
# - SUPABASE_KEY
```

### Verify Setup
```bash
python3 test_supabase_connection.py
```

---

## 2️⃣ Deploy Schema to Supabase

### Choose Your Schema
- **Full Deployment**: `schema_unified_complete.sql` (84 tables, all features)
- **AI-Range Only**: `schema_ai_range_only.sql` (75 tables)
- **Nexus Only**: `schema_nexus_only.sql` (35 tables)

### Deploy in 2 Steps
1. Open [Supabase Dashboard](https://supabase.com) → SQL Editor
2. Copy [sql/schemas/schema_unified_complete.sql](../sql/schemas/schema_unified_complete.sql) → Paste → Run

**Time**: 30-60 seconds  
**Result**: Tables created and ready to use

---

## 3️⃣ Test Database Connection

### Run Connection Test
```bash
python3 test_supabase_connection.py
```

### Expected Output
```
✅ Connected to Supabase
✅ All tables accessible
✅ Permissions verified
```

### Troubleshooting
See: [Connection Test Guide](../docs/testing/TESTING_QUICKSTART.md)

---

## 4️⃣ Understand the Schema

### Core Tables (8)
- `products` - Product definitions
- `tenants` - Customer organizations
- `subscriptions` - Subscription tracking
- `agents` - AI agents
- `models` - LLM models
- `usage` - API usage tracking
- `audit_logs` - Activity audit
- `cache_management` - Query cache

### AI-Range Tables (67)
- `personas` - User personas
- `scenarios` - Test scenarios
- `scenario_intents` - Intent definitions
- `threat_vectors` - Security threats
- `test_sessions` - Testing results
- `llm_invocations` - LLM calls (unified)
- And 61 more specialized tables

### Nexus Tables (16)
- `risk_metrics` - Risk analysis
- `robustness_analysis` - Robustness scores
- `fragility_scores` - Fragility metrics
- `sycophancy_detection` - Detection results
- `embeddings` - Vector embeddings
- And more analysis tables

### Key Features
- ✅ Multi-tenancy via `tenant_id`
- ✅ Product isolation via `product_code`
- ✅ JSONB for flexible metadata
- ✅ UUID primary keys
- ✅ Comprehensive indexing
- ✅ Foreign key constraints
- ✅ Real-time subscriptions ready
- ✅ Vector search enabled

---

## 💻 Development Workflows

### Connect from Python
```python
from supabase import create_client, Client

url = "https://YOUR_PROJECT.supabase.co"
key = "YOUR_ANON_KEY"
supabase: Client = create_client(url, key)

# Query example
response = supabase.table("agents").select("*").execute()
```

### Connect from JavaScript
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://YOUR_PROJECT.supabase.co',
  'YOUR_ANON_KEY'
)

// Query example
const { data, error } = await supabase
  .from('agents')
  .select('*')
```

### REST API
```bash
curl 'https://YOUR_PROJECT.supabase.co/rest/v1/agents' \
  -H 'Authorization: Bearer YOUR_KEY' \
  -H 'apikey: YOUR_KEY'
```

### Real-Time Subscriptions
```python
# Subscribe to changes
def handle_changes(payload):
    print("Change detected:", payload)

supabase.on("*", "agents", handle_changes).subscribe()
```

---

## 🔍 Key Resources

| Resource | Purpose | Location |
|----------|---------|----------|
| Schema reference | Table structure | [sql/schemas/schema_unified_complete.sql](../sql/schemas/schema_unified_complete.sql) |
| Query examples | Common queries | [sql/queries/queries.sql](../sql/queries/queries.sql) |
| Deployment guide | Step-by-step | [sql/SUPABASE_QUICK_DEPLOYMENT.md](../sql/SUPABASE_QUICK_DEPLOYMENT.md) |
| Architecture | System design | [docs/PRODUCT_LAYER_ARCHITECTURE.md](../docs/PRODUCT_LAYER_ARCHITECTURE.md) |
| Integration guides | Product specifics | [docs/NEXUS_PRODUCTS_INTEGRATION.md](../docs/NEXUS_PRODUCTS_INTEGRATION.md) |

---

## 🚀 Next Steps

1. **Deploy schema** - Follow [Deployment Guide](../sql/SUPABASE_QUICK_DEPLOYMENT.md)
2. **Test connection** - Run provided Python script
3. **Explore schema** - Review table structure in Supabase
4. **Build features** - Use SDKs and REST API
5. **Monitor usage** - Check `usage` table for metrics

---

## ❓ Common Questions

**Q: Can I use the schema as-is?**  
A: Yes! All schemas are production-ready and verified 100% Supabase compatible.

**Q: Do I need to modify the schema?**  
A: Only if you have custom requirements. See [Customization Guide](../docs/PRODUCT_LAYER_ARCHITECTURE.md).

**Q: How do I set up real-time subscriptions?**  
A: See [Real-Time Setup](../sql/SUPABASE_QUICK_DEPLOYMENT.md#enable-real-time-subscriptions).

**Q: Where are usage metrics stored?**  
A: Check the `usage` table and `usage_events` table for detailed tracking.

**Q: How do I test my changes?**  
A: See [Testing Guide](../docs/testing/TESTING_QUICKSTART.md).

---

## 📞 Support Resources

- **Architecture questions**: [docs/PRODUCT_LAYER_ARCHITECTURE.md](../docs/PRODUCT_LAYER_ARCHITECTURE.md)
- **Integration issues**: [docs/NEXUS_PRODUCTS_INTEGRATION.md](../docs/NEXUS_PRODUCTS_INTEGRATION.md)
- **Testing help**: [docs/testing/README.md](../docs/testing/README.md)
- **Verification status**: [sql/SUPABASE_COMPATIBILITY_REPORT.md](../sql/SUPABASE_COMPATIBILITY_REPORT.md)

---

**Ready to code?** Deploy your schema and start building! 🚀

[← Back to MASTER_INDEX.md](MASTER_INDEX.md)

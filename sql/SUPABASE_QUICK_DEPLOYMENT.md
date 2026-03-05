# Supabase Quick Deployment Guide

**Status:** ✅ All schemas verified compatible with Supabase  
**Last Updated:** March 4, 2026

---

## 5-Minute Deployment

### Step 1: Choose Your Schema
```bash
# Option A: Full unified deployment (both products)
schema_unified_complete.sql        # 84 tables, ~49 KB

# Option B: AI-Range only
schema_ai_range_only.sql           # 75 tables, ~46 KB

# Option C: Nexus only
schema_nexus_only.sql              # 35 tables, ~31 KB
```

### Step 2: Access Supabase SQL Editor
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Open your project
3. Click **SQL Editor** (left sidebar)
4. Click **New Query**

### Step 3: Copy & Paste Schema
1. Open chosen schema file (e.g., `schema_unified_complete.sql`)
2. Select all (Cmd+A / Ctrl+A)
3. Copy (Cmd+C / Ctrl+C)
4. Paste into Supabase SQL Editor
5. Click **Run** button (or Cmd+Enter / Ctrl+Enter)

### Step 4: Wait for Completion
- ⏱️ Typical time: 30 seconds to 2 minutes
- 📊 All 84/75/35 tables will be created
- ✅ Indexes and constraints automatically applied

### Step 5: Verify Success
Copy and paste this verification query:

```sql
-- Count tables (should match schema)
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check for our main tables
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('products', 'tenants', 'personas', 'conversations');

-- Verify extensions
SELECT extname FROM pg_extension 
WHERE extname IN ('uuid-ossp', 'vector');
```

**Expected Results:**
- `table_count`: 84 (unified), 75 (ai-range), 35 (nexus)
- Main tables: ≥ 3-4 (depending on product)
- Extensions: uuid-ossp, vector (both installed)

---

## Supabase-Specific Configuration

### Configure RLS (Row-Level Security)
After schema deployment, add tenant isolation:

```sql
-- Enable RLS for key tables
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;

-- Create tenant isolation policy
CREATE POLICY tenant_isolation ON personas
  USING (tenant_id = auth.uid());

CREATE POLICY tenant_isolation ON conversations
  USING (product_id = (SELECT id FROM products LIMIT 1));
```

### Enable Real-Time Subscriptions
```sql
-- Supabase automatically enables real-time on created_at changes
-- For custom real-time columns, add to Supabase dashboard:
-- 1. Go to Database → Replication
-- 2. Enable publication on key tables
-- 3. Subscribe in application code
```

### Enable Vector Search
```sql
-- Already enabled if using schema_unified_complete.sql or schema_nexus_only.sql
-- Vector search is ready for:
-- - semantic search on embeddings
-- - similarity queries: embedding <-> query_vector
```

---

## Deployment Options

### Option 1: SQL Editor (Easiest) ⭐
**Best for:** Quick testing, small teams

```
Supabase Dashboard → SQL Editor → New Query → Paste → Run
```

### Option 2: Direct psql Connection
**Best for:** CI/CD pipelines, automation

```bash
# Get connection string from Supabase Settings → Database
# Format: postgresql://[user]:[password]@[host]:[port]/[database]

psql "your-connection-string" < schema_unified_complete.sql
```

### Option 3: Python/Node SDK
**Best for:** Application integration

```python
import supabase
from psycopg2 import connect

# Use Supabase connection details
conn = connect(
    host="db.xxxxx.supabase.co",
    database="postgres",
    user="postgres",
    password="your-password",
    port=5432
)

# Execute schema
with open("schema_unified_complete.sql") as f:
    schema = f.read()
    conn.cursor().execute(schema)
    conn.commit()
```

### Option 4: Docker Deployment
**Best for:** Containerized applications

```dockerfile
FROM postgres:14-alpine
COPY schema_unified_complete.sql /docker-entrypoint-initdb.d/
```

---

## Post-Deployment Checklist

- [ ] Schema loaded successfully (0 errors in SQL Editor)
- [ ] Verified table count matches expected (84/75/35)
- [ ] Extensions installed: uuid-ossp, vector
- [ ] Sample data loaded (optional)
- [ ] RLS policies enabled (production)
- [ ] Real-time subscriptions configured (optional)
- [ ] Vector search tested (Nexus only)
- [ ] Application connection tested
- [ ] Backups configured in Supabase Settings
- [ ] Monitoring enabled (Supabase Logs)

---

## Common Issues & Solutions

### Issue: "Relation already exists"
**Cause:** Schema already deployed  
**Solution:** 
- Option A: Use different project
- Option B: Drop all tables first: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`

### Issue: "Extension 'vector' not found"
**Cause:** Rare - Supabase has pgvector pre-installed  
**Solution:** 
1. Contact Supabase support
2. Or skip vector extension, use JSONB for embeddings

### Issue: "Permission denied"
**Cause:** Insufficient database permissions  
**Solution:**
1. Use postgres role (not authenticated user)
2. Run via Supabase SQL Editor (not direct connection)
3. Check Supabase Settings → Database → Users

### Issue: Deployment takes >5 minutes
**Cause:** Large data import or slow connection  
**Solution:**
1. Check network connection
2. Try again - temporary slowness is normal
3. Monitor in Supabase Logs (Settings → Logs)

### Issue: Tables created but no data
**Cause:** Schema creates structure only  
**Solution:** Load sample data separately
```bash
psql "your-connection" < sample_data/sample_data.sql
```

---

## Production Deployment Recommendations

### Security
- [ ] Enable RLS policies (see above)
- [ ] Restrict database access to API only
- [ ] Use Supabase authentication tokens
- [ ] Enable SSL/TLS encryption

### Performance
- [ ] Monitor slow queries (Supabase Logs)
- [ ] Verify indexes are being used
- [ ] Set up query performance monitoring
- [ ] Consider read replicas for high traffic

### Backup & Recovery
- [ ] Enable automated backups (Supabase Settings)
- [ ] Test restore process
- [ ] Document recovery procedures
- [ ] Keep schema version in git

### Monitoring
- [ ] Set up query logging
- [ ] Monitor connection count
- [ ] Track table sizes
- [ ] Alert on database errors

---

## Schema Modifications & Migrations

### Adding New Tables
```sql
-- After initial deployment, you can add new tables
-- Schema already has all needed tables, but for future additions:

ALTER TABLE personas ADD COLUMN new_field TEXT;
CREATE INDEX idx_personas_new_field ON personas(new_field);
```

### Updating Schema
```sql
-- Update existing schema files in git
-- Deploy changes via:
-- 1. SQL Editor for test/dev
-- 2. Migration scripts for production

-- Example migration:
-- migrations/001_add_custom_metadata.sql
ALTER TABLE personas ADD COLUMN custom_metadata JSONB DEFAULT '{}'::jsonb;
```

### Schema Versioning
1. Keep schema files in git with versions
2. Tag releases: `v1.0`, `v1.1`, etc.
3. Document breaking changes in CHANGELOG.md
4. Test migrations in development first

---

## Integration with Application

### Python (SQLAlchemy)
```python
from sqlalchemy import create_engine

DATABASE_URL = "postgresql://postgres:password@db.xxxxx.supabase.co/postgres"
engine = create_engine(DATABASE_URL)

# Tables automatically reflected from schema
```

### JavaScript (Prisma)
```javascript
// .env
DATABASE_URL="postgresql://postgres:password@db.xxxxx.supabase.co/postgres"

// schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Generate Prisma client from schema
npx prisma db push
npx prisma generate
```

### REST API (PostgREST)
```bash
# Automatically available via Supabase!
curl https://xxxxx.supabase.co/rest/v1/personas \
  -H "apikey: $SUPABASE_ANON_KEY"
```

### Real-Time Subscriptions
```javascript
// JavaScript/TypeScript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(url, key)

supabase
  .from('personas')
  .on('*', payload => {
    console.log('Change received!', payload)
  })
  .subscribe()
```

---

## Support & Resources

### Documentation
- **Supabase Docs:** https://supabase.com/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/14/
- **Schema Details:** See [SUPABASE_COMPATIBILITY_REPORT.md](../SUPABASE_COMPATIBILITY_REPORT.md)

### Troubleshooting
- **Supabase Dashboard Logs:** Settings → Logs
- **Query Performance:** SQL Editor → Explain Plan
- **Database Health:** Settings → Database → Health Check

### Contact
- **Supabase Support:** https://supabase.com/support
- **Community:** https://discord.supabase.com

---

## Next Steps

1. ✅ **Deploy Schema** (this guide)
2. ✅ **Verify Tables** (see post-deployment checklist)
3. → **Configure Security** (RLS, authentication)
4. → **Load Sample Data** (optional, for testing)
5. → **Integrate Application** (connect from code)
6. → **Monitor Production** (logs, performance)

---

**Ready to deploy?**

Choose your schema and follow Step 1-5 above. Most deployments complete in under 2 minutes!

For detailed compatibility information, see [SUPABASE_COMPATIBILITY_REPORT.md](SUPABASE_COMPATIBILITY_REPORT.md)

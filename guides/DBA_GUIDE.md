# Database Administrator Guide

**Role**: Database Administrator / DevOps Engineer  
**Time to Complete**: 20-30 minutes  
**Required**: SQL, database admin experience, server access

---

## 🎯 Your Quick Start

1. **Review architecture** (5 min): [Step 1](#1-review-architecture)
2. **Plan deployment** (5 min): [Step 2](#2-plan-your-deployment)
3. **Deploy schema** (10 min): [Step 3](#3-deploy-schema)
4. **Verify & optimize** (10 min): [Step 4](#4-verify--optimize)

---

## 1️⃣ Review Architecture

### Schema Overview
- **84 tables** in unified deployment
- **Multi-tenancy** architecture with `tenants` table
- **Product isolation** via `product_code` CHECK constraints
- **Cross-product references** via `product_prompt_lineage`
- **Comprehensive indexing** (112-77 indexes depending on schema)

### Core Infrastructure (8 tables)
```sql
products              -- Product definitions
tenants              -- Customer organizations  
subscriptions        -- Billing & subscription tracking
agents               -- AI agents
models               -- Language models
usage                -- API usage tracking
audit_logs           -- Complete audit trail
cache_management     -- Query result caching
```

### Data Volume Expectations
- **Small deployment**: 10,000-50,000 records
- **Medium deployment**: 50,000-500,000 records
- **Large deployment**: 500,000+ records

### Connection Requirements
- **PostgreSQL 14+** (Supabase default)
- **Extensions**: `uuid-ossp`, `vector` (pgvector)
- **Network access**: Supabase SQL Editor or psql client
- **Credentials**: Service role key (admin access)

---

## 2️⃣ Plan Your Deployment

### Choose Deployment Option

| Option | Tables | Features | Use Case |
|--------|--------|----------|----------|
| **Unified** | 84 | All features | Full deployment with all products |
| **AI-Range** | 75 | AI-Range + infrastructure | AI-Range product only |
| **Nexus** | 35 | Nexus + infrastructure | Nexus product only |

### Pre-Deployment Checklist

- [ ] Supabase project created and accessible
- [ ] Service role key obtained from dashboard
- [ ] Network connectivity verified (ping endpoints)
- [ ] Backup strategy planned (Supabase handles auto-backups)
- [ ] Monitoring dashboards prepared
- [ ] Alerting configured for failed queries
- [ ] Retention policies planned for audit logs

### Capacity Planning

**Disk Space**:
- Unified schema: ~500 MB - 5 GB depending on data volume
- Supabase includes automatic scaling

**Connection Pooling**:
- Default: 5 connections per client
- Recommended: Enable PgBouncer in transaction mode

**Performance Considerations**:
- 112+ optimized indexes
- Prepared statements recommended
- Connection pooling required for high concurrency

---

## 3️⃣ Deploy Schema

### Deployment Method 1: Supabase UI (Easiest)
1. Go to [Supabase Dashboard](https://supabase.com)
2. Select your project → SQL Editor
3. Create new query
4. Copy schema file: [schema_unified_complete.sql](../sql/schemas/schema_unified_complete.sql)
5. Paste and click "Run"
6. Wait 30-60 seconds
7. Verify all tables created

### Deployment Method 2: psql CLI
```bash
# Connect to your Supabase PostgreSQL
psql "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres" \
  -f sql/schemas/schema_unified_complete.sql
```

### Deployment Method 3: Scripts
```bash
# Use provided migration script
python3 scripts/migrate_schema.py --schema unified
```

### Verify Deployment
```sql
-- Check table count
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public';

-- Expected: 84 tables (unified), 75 (AI-Range), 35 (Nexus)

-- Check key infrastructure tables
SELECT * FROM products;
SELECT * FROM tenants;
SELECT * FROM agents;
```

---

## 4️⃣ Verify & Optimize

### Immediate Verification

```sql
-- Check all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' ORDER BY table_name;

-- Verify foreign keys
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND table_schema = 'public';

-- Expected: 121 foreign keys (unified)

-- Check indexes
SELECT indexname FROM pg_indexes 
WHERE schemaname = 'public' ORDER BY indexname;

-- Expected: 112 indexes (unified)
```

### Performance Verification

```sql
-- Check index usage
SELECT schemaname, tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Monitor query performance
EXPLAIN ANALYZE
SELECT * FROM llm_invocations 
WHERE tenant_id = 'YOUR_TENANT' 
LIMIT 100;

-- Set up monitoring
ALERT ON slow_queries (> 1 second);
```

### Post-Deployment Tasks

1. **Enable RLS** (optional but recommended):
   ```sql
   -- Enable for multi-tenant security
   ALTER TABLE llm_invocations ENABLE ROW LEVEL SECURITY;
   ```

2. **Create indexes for common queries**:
   ```sql
   -- Additional optimization
   CREATE INDEX idx_usage_date ON usage(created_at DESC);
   ```

3. **Set up backups**:
   - Supabase: Automatic backups enabled
   - Retention: 30 days (default)
   - Recovery: Point-in-time recovery available

4. **Configure monitoring**:
   ```sql
   -- Query performance monitoring
   CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
   ```

---

## 🔒 Security Configuration

### Enable Row-Level Security (RLS)
```sql
-- For multi-tenant isolation
ALTER TABLE llm_invocations ENABLE ROW LEVEL SECURITY;

-- Create policy for tenant isolation
CREATE POLICY tenant_isolation ON llm_invocations
  USING (tenant_id = current_user_id());
```

### Set Up Audit Logging
```sql
-- Automatic audit trail
SELECT * FROM audit_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;
```

### Configure Column-Level Encryption (Optional)
```sql
-- For sensitive data
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt on insert
INSERT INTO sensitive_table (data) 
VALUES (pgp_sym_encrypt('secret', 'key'));
```

---

## 📊 Monitoring & Maintenance

### Key Metrics to Monitor

| Metric | Query | Alert Threshold |
|--------|-------|-----------------|
| Connection count | `SELECT count(*) FROM pg_stat_activity;` | > 50 |
| Query latency | `SELECT mean_exec_time FROM pg_stat_statements` | > 1000ms |
| Index bloat | `SELECT * FROM pg_stat_user_indexes` | > 20% |
| Disk usage | Supabase dashboard | > 80% |
| Slow queries | `pg_stat_statements` | > 1s duration |

### Maintenance Tasks

**Daily**:
- Monitor connection pool
- Check slow query logs
- Review audit logs for anomalies

**Weekly**:
- Analyze query performance
- Review index usage
- Check disk space growth

**Monthly**:
- Vacuum and analyze tables
- Review and optimize indexes
- Audit table sizes
- Plan capacity growth

---

## 🔧 Troubleshooting

### Connection Issues
**Problem**: Cannot connect to database  
**Solution**: 
- Verify credentials in `.env`
- Check IP whitelist in Supabase
- Test with psql CLI first

### Slow Queries
**Problem**: Queries taking > 1 second  
**Solution**:
```sql
EXPLAIN ANALYZE SELECT ...  -- Check query plan
CREATE INDEX idx_name ON table(column);  -- Add indexes
ANALYZE table;  -- Update statistics
```

### Disk Space Issues
**Problem**: Approaching storage limits  
**Solution**:
- Archive old audit logs
- Remove test data
- Upgrade Supabase plan

### Foreign Key Violations
**Problem**: Cannot insert/update due to FK constraints  
**Solution**:
- Verify referenced records exist
- Check ON DELETE policies
- Review constraint definitions

---

## 📚 Key Resources

| Resource | Purpose | Location |
|----------|---------|----------|
| Schema SQL | Full schema definition | [sql/schemas/schema_unified_complete.sql](../sql/schemas/schema_unified_complete.sql) |
| Deployment guide | Step-by-step | [sql/SUPABASE_QUICK_DEPLOYMENT.md](../sql/SUPABASE_QUICK_DEPLOYMENT.md) |
| Compatibility report | Technical verification | [sql/SUPABASE_COMPATIBILITY_REPORT.md](../sql/SUPABASE_COMPATIBILITY_REPORT.md) |
| Alignment audit | Detailed verification | [docs/verification/SCHEMA_ALIGNMENT_AUDIT.md](../docs/verification/SCHEMA_ALIGNMENT_AUDIT.md) |
| Architecture | System design | [docs/PRODUCT_LAYER_ARCHITECTURE.md](../docs/PRODUCT_LAYER_ARCHITECTURE.md) |

---

## 🚀 Next Steps

1. **Deploy schema** - Follow deployment method above
2. **Run verification queries** - Test all systems
3. **Configure security** - Enable RLS if needed
4. **Set up monitoring** - Enable metrics and alerts
5. **Plan backups** - Configure retention policies

---

**Database deployment complete!** Monitor and maintain using guides above. 🚀

[← Back to MASTER_INDEX.md](MASTER_INDEX.md)

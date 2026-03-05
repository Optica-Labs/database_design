# Configuration Files

**Location**: `/config`  
**Purpose**: Environment and setup configuration  
**Last Updated**: March 4, 2026

---

## 📁 Files

### Environment Templates

#### `.env.example`
**Purpose**: Template for local development environment  
**Use**: Copy to `.env` and fill in your credentials  
**Variables**:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase API key
- Database connection strings (if needed)

#### `.env.migration.example`
**Purpose**: Template for migration-specific operations  
**Use**: Copy to `.env.migration` for running migration scripts  
**Variables**:
- `SOURCE_SUPABASE_SERVICE_KEY` - Source database credentials
- `TARGET_SUPABASE_SERVICE_KEY` - Target database credentials
- Connection pool settings

### Setup

1. **Copy template**:
   ```bash
   cp config/.env.example .env
   cp config/.env.migration.example .env.migration
   ```

2. **Edit with credentials**:
   ```bash
   # Edit .env with your Supabase credentials
   vim .env
   ```

3. **Verify setup**:
   ```bash
   python3 tests/test_supabase_connection.py
   ```

### Security Notes

⚠️ **IMPORTANT**: Never commit `.env` files to git!

- `.env` contains sensitive credentials
- Always use templates (`.env.example`)
- Add to `.gitignore` (already configured)
- Share only templates, never actual credentials
- Rotate keys if accidentally committed

---

## 📊 Other Files

### `requirements.txt`
**Purpose**: Python package dependencies  
**Use**: `pip install -r requirements.txt`  
**When Updated**: When dependencies change (rare)  

### `migration_api_report.json`
**Purpose**: API migration report from development  
**Use**: Reference for completed migrations  
**Status**: Historical, for records only

---

## 🔗 Related Guides

- [Developer Setup](../guides/DEVELOPER_GUIDE.md#1️⃣-environment-setup)
- [DBA Configuration](../guides/DBA_GUIDE.md#environment-setup)
- [Deployment Guide](../sql/SUPABASE_QUICK_DEPLOYMENT.md)

---

[← Back to REPOSITORY_MAP.md](../REPOSITORY_MAP.md)

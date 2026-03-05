# 🧪 Connection Testing - Getting Started

**Quick Start Guide for Testing All Connection Methods**

---

## 📋 What You Have

Three documents created to help test connection methods:

1. **CONNECTION_TEST_PLAN.md** - Detailed testing plan with all 10 methods
2. **CONNECTION_METHODS.md** - Full documentation of each method
3. **CONNECTION_METHODS_QUICK.md** - Quick reference card
4. **test_all_connections.py** - Automated testing script

---

## 🚀 Quick Start (2 minutes)

### Option A: Automatic Testing (Recommended)

Run the automated tester that will test all methods and show results:

```bash
python3 test_all_connections.py
```

**Output will show**:
- ✅ Which methods work
- ❌ Which methods fail
- ⚠️ Which need credential refresh
- ⊘ Which are skipped (psql not installed, etc.)
- 💡 Recommendations for next steps

### Option B: Manual Testing

Follow the steps in **CONNECTION_TEST_PLAN.md**:

1. Start with Method 1 (easiest)
2. Run each test script
3. Document results
4. Move to next method

---

## 📊 What Gets Tested

### Automatic Script Tests (5 methods)
```
✅ Method 1: Python - individual credentials    (Main)
✅ Method 2: Python - URL format               (Alternative)
✅ Method 3: Python - Pooler                   (Production)
✅ Method 5: CLI - psql direct                 (If installed)
✅ Method 6: CLI - psql env vars               (If installed)
```

### Manual Tests (5 methods)
```
✅ Method 4: AWS Secrets Manager               (AWS only)
✅ Method 7: CLI - psql URL                    (Alternative)
✅ Method 8: CLI - psql pooler                 (If installed)
✅ Method 9: Web Dashboard                     (Browser)
✅ Method 10: AWS Aurora                       (If active)
```

See **CONNECTION_TEST_PLAN.md** for details on manual tests.

---

## 🎯 What To Expect

### Best Case (All Working)
```
============================================================
TEST SUMMARY
============================================================

✅ PASSED: 3
❌ FAILED: 0
⊘ SKIPPED: 2

✅ Working methods:
   - Method 1: Python - individual credentials
   - Method 5: CLI - psql direct
   - Method 6: CLI - psql env vars
```

### If Credentials Expired
```
⚠️  Expired methods:
   - Method 3: Pooler connection
   
💡 Regenerate connection string from Supabase dashboard
```

### If .env Credentials Wrong
```
❌ Failed methods:
   - Method 1: Python - individual credentials

💡 Update .env credentials from Supabase dashboard and retry
```

---

## 🔧 Prerequisites

### Required
- Python 3.8+
- psycopg2: `pip install psycopg2-binary`
- dotenv: `pip install python-dotenv`

### Optional (for CLI methods)
- psql: `brew install postgresql` (macOS)

### Installation
```bash
# Install Python packages
pip install psycopg2-binary python-dotenv

# Install psql (optional)
brew install postgresql          # macOS
sudo apt-get install postgresql-client  # Ubuntu/Debian
```

---

## 📝 How To Track Results

### In Automatic Script
Results are printed to console with color coding:
- 🟢 Green = Success
- 🔴 Red = Failed
- 🟡 Yellow = Skipped/Expired

### In Manual Testing
Update **CONNECTION_TEST_PLAN.md**:

Each method section has a template:
```markdown
**Test Results**:
Date tested: [TODAY'S DATE]
Result: [X] PASS ✅  [ ] FAIL ❌
Error: [IF ANY]
Notes: [YOUR NOTES]
```

Fill in as you test each method.

---

## 🎬 Step-by-Step Instructions

### Step 1: Run Automatic Tests
```bash
cd /Users/apeak/optica/database_design
python3 test_all_connections.py
```

**Time**: ~30 seconds  
**Output**: Summary of all automated tests

### Step 2: Document Results
```bash
# Edit CONNECTION_TEST_PLAN.md and update the Status table:
# Find the "Summary Table" section
# Update each method's row with your test results
```

### Step 3: Manual Tests (if needed)
If you want to test manual methods:

**Method 9 (Web Dashboard)** - Easiest:
1. Go to https://app.supabase.com
2. Select project `aayinvrvtumndpubwtui`
3. Click SQL Editor
4. Run: `SELECT version();`
5. ✅ If it works, Web Dashboard is functional

**Method 6 (psql env vars)** - If psql installed:
```bash
export PGHOST=aayinvrvtumndpubwtui.supabase.co
export PGPORT=5432
export PGDATABASE=postgres
export PGUSER=postgres
export PGPASSWORD="89%f1uHt4$#-e$X215eK"
psql -c "SELECT version();"
```

### Step 4: Fix Issues (if any)
If tests fail:

1. **Check .env** - Verify credentials match
2. **Update .env** - Get fresh credentials from Supabase
3. **Retry tests** - Run script again

---

## 💡 Next Steps After Testing

### If All Tests Pass ✅
**Congratulations!** Your database is ready.

Next: Run schema verification:
```bash
# Once connection works, we can verify the actual schema
# See: ../verification/SCHEMA_ALIGNMENT_AUDIT.md
```

### If Some Tests Pass ✅
Use the working methods for your needs:
- **Method 1** (Python) - For scripts
- **Method 6** (psql) - For CLI/automation
- **Method 9** (Web) - For manual queries

### If Tests Fail ❌
1. **Update credentials** - Copy from Supabase dashboard
2. **Verify .env** - Paste new credentials
3. **Retry** - Run tests again

---

## 📂 Reference Files

| File | Purpose |
|------|---------|
| CONNECTION_TEST_PLAN.md | Detailed testing plan (10 methods) |
| CONNECTION_METHODS.md | Full documentation (10 methods) |
| CONNECTION_METHODS_QUICK.md | Quick reference card |
| test_all_connections.py | Automated testing script |
| .env | Your credentials file |

---

## 🔗 Common Tasks

### "Run all tests"
```bash
python3 test_all_connections.py
```

### "Test just method 1"
See METHOD 1 section in CONNECTION_TEST_PLAN.md

### "Install psql for CLI testing"
```bash
# macOS
brew install postgresql

# Ubuntu
sudo apt-get install postgresql-client
```

### "Update credentials"
```bash
# 1. Go to: https://app.supabase.com
# 2. Project Settings → Database
# 3. Copy connection strings
# 4. Update .env file
# 5. Run tests again
```

### "See all connection methods"
```bash
# Quick overview
cat CONNECTION_METHODS_QUICK.md

# Full details
cat CONNECTION_METHODS.md
```

---

## ⏱️ Estimated Times

| Task | Time |
|------|------|
| Run automated tests | 30 sec - 2 min |
| Test one manual method | 2-5 min |
| Update .env credentials | 5 min |
| Fix and retry | 10-15 min |
| **Total** | **~30 min** |

---

## 🆘 Troubleshooting

### "psycopg2 not found"
```bash
pip install psycopg2-binary
```

### "python-dotenv not found"
```bash
pip install python-dotenv
```

### "psql: command not found"
```bash
brew install postgresql    # macOS
# or skip CLI tests, use Python instead
```

### "Connection timeout"
- Try a different method
- Check network connectivity
- Verify firewall isn't blocking

### "Password authentication failed"
- Update credentials in .env
- Copy from Supabase dashboard
- Retry

### "Tenant or user not found"
- Credentials expired
- Regenerate in Supabase dashboard
- Update .env
- Retry

---

## 📊 Example Output

```
============================================================
Connection Methods Tester
Started: 2026-03-04 15:30:45
============================================================

📋 Running tests...

Testing Method 1: Python psycopg2 (Individual Credentials)
------------------------------------------------------------
Connecting to: aayinvrvtumndpubwtui.supabase.co:5432/postgres
✅ PASS - Connected successfully
Version: PostgreSQL 12.4 (AWS) on x86_64-pc-linux-gnu...

Testing Method 2: Python psycopg2 (URL Format)
------------------------------------------------------------
Connecting with URL format...
✅ PASS - URL format works
Version: PostgreSQL 12.4 (AWS) on x86_64-pc-linux-gnu...

Testing Method 3: Python psycopg2 (Pooler Connection)
------------------------------------------------------------
Connecting via pooler (port 6543)...
⚠️  CREDENTIALS EXPIRED - FATAL: Tenant or user not found

Testing Method 5: CLI psql (Direct)
------------------------------------------------------------
✓ psql direct works

Testing Method 6: CLI psql (With Env Vars)
------------------------------------------------------------
✅ PASS - psql with env vars works

============================================================
TEST SUMMARY - 2026-03-04 15:30:48
============================================================

✅ PASSED: 4
❌ FAILED: 0
⊘ SKIPPED/EXPIRED: 1

✅ Working methods:
   - Method 1: Python - individual credentials
   - Method 2: Python - URL format
   - Method 5: CLI - psql direct
   - Method 6: CLI - psql env vars

⚠️  Expired methods:
   - Method 3: Pooler connection

💡 Regenerate connection string from Supabase dashboard
```

---

## ✅ Success Checklist

After running tests:
- [ ] Ran `python3 test_all_connections.py`
- [ ] Saw test results printed
- [ ] At least 1 method shows ✅ PASS
- [ ] Noted which methods work
- [ ] Updated CONNECTION_TEST_PLAN.md with results
- [ ] Ready to verify actual database schema

---

**Ready to test?** → Run: `python3 test_all_connections.py`

**Questions?** → See: CONNECTION_METHODS.md

**Track results?** → Edit: CONNECTION_TEST_PLAN.md

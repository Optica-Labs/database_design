# ✅ Connection Testing Checklist

**Purpose**: Track your progress through connection testing  
**Created**: March 4, 2026  
**Status**: Ready to use

---

## 📋 Pre-Testing Checklist

Before you start testing, make sure you have:

### Prerequisites
- [ ] Python 3.8+ installed: `python3 --version`
- [ ] pip installed: `pip --version`
- [ ] .env file exists with credentials
- [ ] Network connectivity: `ping aayinvrvtumndpubwtui.supabase.co`

### Python Packages
- [ ] psycopg2 installed: `python3 -c "import psycopg2; print('OK')"`
- [ ] dotenv installed: `python3 -c "import dotenv; print('OK')"`

**Install if missing**:
```bash
pip install psycopg2-binary python-dotenv
```

### Optional (for CLI testing)
- [ ] psql installed: `which psql` (or `brew install postgresql`)
- [ ] AWS CLI configured (for AWS methods)
- [ ] boto3 installed (for AWS Secrets)

### Files Present
- [ ] test_all_connections.py exists
- [ ] CONNECTION_TEST_PLAN.md exists
- [ ] CONNECTION_METHODS.md exists
- [ ] .env file exists

---

## 🧪 Testing Phases

### Phase 1: Automated Testing (30 seconds - 2 minutes)

**Goal**: Run automated tests for 5 methods

- [ ] Navigate to project root: `cd /Users/apeak/optica/database_design`
- [ ] Run test script: `python3 test_all_connections.py`
- [ ] Wait for completion
- [ ] Review summary output

**Expected Output**:
- [ ] Test results printed
- [ ] Summary table shown
- [ ] Recommendations provided
- [ ] Exit code 0 (success) or 1 (some tests failed)

**Next**: Record results below

---

### Phase 2: Record Automated Results (5 minutes)

Copy and paste your results:

```
TEST RESULTS - [DATE/TIME]:
============================================================

Paste the output from python3 test_all_connections.py:

[PASTE HERE]

============================================================
```

Update the **Method Status Table** (below) based on results:

#### Method Status Table

| Method | Pass? | Notes |
|--------|-------|-------|
| Method 1: Python individual | ☐ YES ☐ NO | |
| Method 2: Python URL | ☐ YES ☐ NO | |
| Method 3: Python Pooler | ☐ YES ☐ NO | |
| Method 5: psql direct | ☐ YES ☐ NO | |
| Method 6: psql env vars | ☐ YES ☐ NO | |

**Summary**:
- Total tests passed: _____ / 5
- Recommended method: _____________________

---

### Phase 3: If Tests Failed

**Goal**: Fix credentials and retry

- [ ] Go to: https://app.supabase.com
- [ ] Select project: `aayinvrvtumndpubwtui`
- [ ] Go to: Settings → Database
- [ ] Copy connection details
- [ ] Update .env file with new credentials
- [ ] Save .env file
- [ ] Run tests again: `python3 test_all_connections.py`
- [ ] Document results

**If still failing**:
- [ ] Check: CONNECTION_METHODS.md → Troubleshooting section
- [ ] Try: Different connection method
- [ ] Contact: Supabase support

---

### Phase 4: Optional Manual Testing (15-30 minutes)

**Goal**: Test remaining 5 methods manually

#### Method 4: AWS Secrets Manager
- [ ] Check if boto3 available: `python3 -c "import boto3"`
- [ ] If available, run: `python3 scripts/connect_aurora.py --secret-arn <ARN>`
- [ ] Result: ☐ PASS ☐ FAIL ☐ SKIP
- [ ] Notes: _______________________________

#### Method 7: psql with URL
- [ ] Run test URL in CONNECTION_TEST_PLAN.md
- [ ] Result: ☐ PASS ☐ FAIL ☐ SKIP (psql not installed)
- [ ] Notes: _______________________________

#### Method 8: psql Pooler
- [ ] Run test from CONNECTION_TEST_PLAN.md
- [ ] Result: ☐ PASS ☐ FAIL ☐ SKIP
- [ ] Notes: _______________________________

#### Method 9: Web Dashboard
- [ ] Go to: https://app.supabase.com
- [ ] Select project
- [ ] Open: SQL Editor
- [ ] Run: `SELECT version();`
- [ ] Result: ☐ PASS ☐ FAIL
- [ ] Notes: _______________________________

#### Method 10: AWS Aurora
- [ ] Check: Is Aurora active? ☐ YES ☐ NO
- [ ] If yes, run: `python3 test_method10.py`
- [ ] Result: ☐ PASS ☐ FAIL ☐ SKIP (not active)
- [ ] Notes: _______________________________

---

## 📊 Final Results Summary

### Overall Status
```
Automated Tests Completed: ☐ YES ☐ NO
Manual Tests Completed: ☐ YES ☐ NO ☐ SKIPPED

Total Methods Working: ______ / 10
Total Methods Failed: ______ / 10
Total Methods Skipped: ______ / 10
```

### Working Methods (Check all that work)
- [ ] Method 1: Python individual credentials
- [ ] Method 2: Python URL format
- [ ] Method 3: Python Pooler
- [ ] Method 4: AWS Secrets Manager
- [ ] Method 5: psql direct
- [ ] Method 6: psql env vars
- [ ] Method 7: psql URL
- [ ] Method 8: psql Pooler
- [ ] Method 9: Web Dashboard
- [ ] Method 10: AWS Aurora

### Recommended Method for Your Use Case
- **For Python scripts**: ☐ Method 1 ☐ Method 2 ☐ Method 4
- **For CLI/automation**: ☐ Method 5 ☐ Method 6 ☐ Method 7
- **For production**: ☐ Method 3 ☐ Method 8 ☐ Method 10
- **For manual queries**: ☐ Method 9

---

## 🎯 Next Steps

### If All Tests Pass ✅
- [ ] Database connectivity verified
- [ ] Document working methods above
- [ ] Update CONNECTION_TEST_PLAN.md with results
- [ ] Proceed to: ../verification/SCHEMA_ALIGNMENT_AUDIT.md
- [ ] Verify: Database schema vs documentation

### If Some Tests Pass ✅
- [ ] Use passing methods for your work
- [ ] Update CONNECTION_TEST_PLAN.md
- [ ] Document why others failed
- [ ] Proceed to: Schema verification with working method

### If All Tests Fail ❌
- [ ] Check .env credentials
- [ ] Regenerate from Supabase dashboard
- [ ] Try different method
- [ ] If still failing: Contact support

---

## 📝 Detailed Notes

**Test Date**: _______________  
**Tester**: _______________  
**Environment**: ☐ macOS ☐ Linux ☐ Windows  
**Python Version**: _______________

### Issues Encountered
```
[Describe any errors or issues here]


```

### Resolution Steps
```
[What you did to resolve issues]


```

### Key Findings
```
[Summary of important findings]


```

---

## 📋 Documentation Update

After completing tests, update these files:

- [ ] CONNECTION_TEST_PLAN.md - Update Status table
- [ ] Add results to "Last Test Results" section
- [ ] Mark completed methods as tested
- [ ] Note: Working vs non-working methods

---

## 🔄 Retesting Procedure

If you need to retest later:

1. [ ] Update credentials in .env (if changed)
2. [ ] Run: `python3 test_all_connections.py`
3. [ ] Compare results to previous test
4. [ ] Document any changes

**Previous Test Date**: _______________  
**Previous Results**: See: CONNECTION_TEST_PLAN.md  
**This Test Date**: _______________

---

## ✅ Sign-Off

- [ ] All automated tests completed
- [ ] Results documented
- [ ] At least 1 working method identified
- [ ] Ready to proceed with schema verification
- [ ] Follow-up actions planned

**Completed By**: _______________  
**Date**: _______________  
**Time Spent**: ~_____ minutes

---

## 📚 Reference

**Need help?**
- Quick start: TESTING_QUICKSTART.md
- All methods: CONNECTION_METHODS.md
- Quick ref: CONNECTION_METHODS_QUICK.md
- Detailed plan: CONNECTION_TEST_PLAN.md
- Troubleshooting: CONNECTION_METHODS.md → Troubleshooting

**Next Phase**:
- Schema verification: ../verification/SCHEMA_ALIGNMENT_AUDIT.md

---

**This Checklist**: TESTING_CHECKLIST.md  
**Status**: Ready to use ✅  
**Updated**: March 4, 2026

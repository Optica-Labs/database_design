# Standalone Tests

**Location**: `/tests`  
**Purpose**: Root-level test scripts and utilities  
**Last Updated**: March 4, 2026

---

## 📁 Files

### `test_all_connections.py`
**Purpose**: Comprehensive connectivity test across all database connections  
**Usage**: 
```bash
python3 tests/test_all_connections.py
```

**Tests**:
- ✅ Source database connection
- ✅ Target database connection
- ✅ Table accessibility
- ✅ Query execution
- ✅ Permissions verification

**Output**:
```
Testing all connections...
✅ Source connection: OK
✅ Target connection: OK
✅ All tables accessible
✅ Permissions verified
```

**When to Use**:
- Initial setup verification
- Pre-deployment checks
- Troubleshooting connectivity
- Monitoring connection health

---

## 🔗 Related Scripts

For detailed testing and verification, see:
- [Connection Testing Guide](../docs/testing/README.md)
- [Testing Quickstart](../docs/testing/TESTING_QUICKSTART.md)
- [Testing Checklist](../docs/testing/TESTING_CHECKLIST.md)
- [Scripts Reference](../scripts/README.md)

---

## 📖 Documentation

See also:
- [Developer Guide - Test Setup](../guides/DEVELOPER_GUIDE.md#3️⃣-test-database-connection)
- [DBA Guide - Testing](../guides/DBA_GUIDE.md)
- [Verification Documentation](../docs/verification/README.md)

---

[← Back to REPOSITORY_MAP.md](../REPOSITORY_MAP.md)

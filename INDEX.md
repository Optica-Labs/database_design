# Database Integration - Quick Reference Index

## 📋 Overview

This directory contains the integrated database schema combining adversarial AI safety testing with persona-based risk assessment.

## 🗂️ File Guide

### 🎯 Start Here

| File | Purpose | Read This If... |
|------|---------|-----------------|
| **[README_INTEGRATED.md](README_INTEGRATED.md)** | Main documentation | You're new to the integrated system |
| **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** | Executive summary | You need a high-level overview |
| **[schema_integrated.sql](schema_integrated.sql)** | Complete schema | You're deploying the database |

### 📚 Documentation

| File | Purpose | When to Use |
|------|---------|-------------|
| **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** | Detailed integration guide | Planning migration, understanding design decisions |
| **[ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)** | Visual schema documentation | Understanding table relationships |
| **[DOCUMENTATION.md](DOCUMENTATION.md)** | Original system docs | Reference for legacy system |

### 💾 Database Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **[schema_integrated.sql](schema_integrated.sql)** | **⭐ Integrated schema** | Deploy to new database |
| **[schema.sql](schema.sql)** | Original SQL Server schema | Reference only |
| **[migration_script.sql](migration_script.sql)** | Data migration script | Migrating from old schemas |
| **[queries.sql](queries.sql)** | Example queries | Learning the schema |
| **[sample_data.sql](sample_data.sql)** | Sample data | Testing the schema |

### 📊 Diagrams

| File | Purpose | When to Use |
|------|---------|-------------|
| **[ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)** | **⭐ Integrated diagrams** | Understanding integrated schema |
| **[ER_DIAGRAM.md](ER_DIAGRAM.md)** | Original diagrams | Reference for legacy system |

## 🚀 Common Workflows

### New Installation

1. Read [README_INTEGRATED.md](README_INTEGRATED.md) - Overview
2. Review [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Schema structure
3. Deploy [schema_integrated.sql](schema_integrated.sql) - Create database
4. Run [queries.sql](queries.sql) - Validate installation

### Data Migration

1. Read [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Migration strategy
2. Configure [migration_script.sql](migration_script.sql) - Set data sources
3. Run [migration_script.sql](migration_script.sql) - Migrate data
4. Validate using queries in the script - Check integrity

### Understanding the Schema

1. Read [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md) - High-level overview
2. Review [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Visual reference
3. Check [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Detailed explanations
4. Study [queries.sql](queries.sql) - Example usage

### Development

1. Reference [README_INTEGRATED.md](README_INTEGRATED.md) - Quick start
2. Use [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Table relationships
3. Check [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Query patterns
4. Test with [sample_data.sql](sample_data.sql) - Sample data

## 📖 Documentation Map

```
┌─────────────────────────────────────────────────────┐
│           INTEGRATION_SUMMARY.md                    │
│         (Executive Summary - Start Here)            │
└─────────────────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
┌──────────────────┐          ┌──────────────────────┐
│ README_          │          │ INTEGRATION_GUIDE.md │
│ INTEGRATED.md    │          │ (Detailed Guide)     │
│ (User Guide)     │          └──────────────────────┘
└──────────────────┘                     │
         │                               │
         ▼                               ▼
┌──────────────────┐          ┌──────────────────────┐
│ ER_DIAGRAM_      │          │ migration_script.sql │
│ INTEGRATED.md    │          │ (Migration)          │
│ (Visual)         │          └──────────────────────┘
└──────────────────┘
         │
         ▼
┌──────────────────────────┐
│ schema_integrated.sql    │
│ (Implementation)         │
└──────────────────────────┘
```

## 🔍 Find Information By Topic

### Architecture & Design
- **Overview**: [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)
- **Detailed Design**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- **Visual Diagrams**: [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)

### Personas
- **Schema**: [schema_integrated.sql](schema_integrated.sql) - Lines 118-352
- **Diagram**: [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Section 2
- **Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - "Unified Persona System"

### Testing Framework
- **Schema**: [schema_integrated.sql](schema_integrated.sql) - Lines 580-850
- **Diagram**: [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Section 6
- **Examples**: [README_INTEGRATED.md](README_INTEGRATED.md) - "Usage Examples"

### Threat & Risk
- **Schema**: [schema_integrated.sql](schema_integrated.sql) - Lines 480-550
- **Diagram**: [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Section 3
- **Migration**: [migration_script.sql](migration_script.sql) - Step 7

### Migration
- **Script**: [migration_script.sql](migration_script.sql)
- **Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - "Migration Path"
- **Summary**: [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md) - "Migration Strategy"

### Performance
- **Indexes**: [schema_integrated.sql](schema_integrated.sql) - Lines 1150-1160
- **Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - "Performance Considerations"
- **README**: [README_INTEGRATED.md](README_INTEGRATED.md) - "Performance Optimization"

### Security
- **Schema**: [schema_integrated.sql](schema_integrated.sql) - Comments throughout
- **Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - "Security Considerations"
- **README**: [README_INTEGRATED.md](README_INTEGRATED.md) - "Security Considerations"

## 📊 Key Statistics

| Metric | Count |
|--------|-------|
| **Total Tables** | 60+ |
| **Views** | 4 |
| **Indexes** | 100+ |
| **Foreign Keys** | 50+ |
| **Documentation Files** | 5 new + 3 original |
| **Total Documentation** | 3,500+ lines |
| **Schema Size** | ~1,200 lines |
| **Migration Script** | ~1,000 lines |

## ✅ Quick Checklist

### For New Users
- [ ] Read [README_INTEGRATED.md](README_INTEGRATED.md)
- [ ] Review [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)
- [ ] Browse [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)
- [ ] Deploy [schema_integrated.sql](schema_integrated.sql)

### For Migration
- [ ] Read [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- [ ] Review [migration_script.sql](migration_script.sql)
- [ ] Test migration on staging environment
- [ ] Validate using provided queries

### For Development
- [ ] Bookmark [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)
- [ ] Study example queries in [README_INTEGRATED.md](README_INTEGRATED.md)
- [ ] Review [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) query patterns
- [ ] Set up development environment

## 🆘 Troubleshooting

| Issue | Where to Look |
|-------|---------------|
| Schema errors | [schema_integrated.sql](schema_integrated.sql) comments |
| Migration failures | [migration_script.sql](migration_script.sql) validation section |
| Query performance | [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) performance section |
| Missing relationships | [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) |
| General questions | [README_INTEGRATED.md](README_INTEGRATED.md) Support section |

## 📞 Support Resources

1. **Quick Reference**: This file
2. **User Guide**: [README_INTEGRATED.md](README_INTEGRATED.md)
3. **Technical Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
4. **Visual Reference**: [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)
5. **Executive Summary**: [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)

---

**Last Updated**: 2024  
**Version**: 2.0 (Integrated)  
**Status**: ✅ Production Ready

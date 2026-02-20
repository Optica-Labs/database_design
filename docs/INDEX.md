# Database Documentation Index

## 📋 Overview

Complete consolidated reference for the integrated adversarial AI safety and persona testing database.

**Current Version**: 2.0 (Integrated)  
**Status**: Production Ready  
**Database**: PostgreSQL 14+

---

This directory contains:
- Integrated database schema combining adversarial AI safety testing with persona-based risk assessment
- Unified product layer architecture (AI-Range + Nexus)
- Multi-tenancy support and subscription management
- Cat-Astrophic (PromptGoblin v2) prompt generation system
- Comprehensive threat and risk framework

## 🏗️ Architecture

The database is organized into **two interconnected layers**:

### 🏢 Layer 1: Client Layer
- **Tenants**: Client organizations using AI-Range
- **Central management** for all client operations

### 🤖 Layer 2: Model Layer
- **Client Models**: AI models under test
- **AI Agents**: ML models performing safety assessments

## 🗂️ File Guide

### 🎯 Start Here

| File | Purpose | Read This If... |
|------|---------|-----------------|
| **[README_INTEGRATED.md](README_INTEGRATED.md)** | Main documentation | You're new to the integrated system |
| **[PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)** | **⭐ Product layer guide** | You need to understand the multi-product architecture |
| **[CAT_ASTROPHIC_INTEGRATION.md](CAT_ASTROPHIC_INTEGRATION.md)** | **⭐ Cat-Astrophic integration** | You want details on PromptGoblin v2 tables |
| **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** | Executive summary | You need a high-level overview |
| **[../schema_integrated.sql](../sql/schemas/schema_integrated.sql)** | Complete schema | You're deploying the database |

### 📚 Documentation

| File | Purpose | When to Use |
|------|---------|-------------|
| **[PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)** | **⭐ Product layer docs** | Understanding how products, clients, and models connect |
| **[CAT_ASTROPHIC_INTEGRATION.md](CAT_ASTROPHIC_INTEGRATION.md)** | **⭐ Cat-Astrophic integration** | Detailed PromptGoblin v2 table definitions and queries |
| **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** | Detailed integration guide | Planning migration, understanding design decisions |
| **[ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)** | Visual schema documentation | Understanding table relationships |
| **[PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)** | Product layer diagram | Visualizing product architecture |

### 💾 Database Files

| File | Purpose | When to Use |
|------|---------|-------------|
| **[../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)** | **⭐ Integrated schema** | Deploy to new database |
| **[../sql/schemas/schema.sql](../sql/schemas/schema.sql)** | Original SQL Server schema | Reference only |
| **[../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql)** | Data migration script | Migrating from old schemas |
| **[../sql/queries/queries.sql](../sql/queries/queries.sql)** | Example queries | Learning the schema |
| **[../sql/queries/cat_astrophic_queries.sql](../sql/queries/cat_astrophic_queries.sql)** | **⭐ Cat-Astrophic queries** | Query examples for PromptGoblin v2 tables |
| **[../sql/views/cat_astrophic_views.sql](../sql/views/cat_astrophic_views.sql)** | **⭐ Cat-Astrophic views** | Pre-built views for common analyses |
| **[../sql/sample_data/sample_data.sql](../sql/sample_data/sample_data.sql)** | Sample data | Testing the schema |

### 📊 Diagrams

| File | Purpose | When to Use |
|------|---------|-------------|
| **[PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)** | **⭐ Product layer ER diagram** | Understanding product architecture |
| **[ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md)** | **⭐ Integrated diagrams** | Understanding integrated schema |
| **[ER_DIAGRAM.md](ER_DIAGRAM.md)** | Original diagrams | Reference for legacy system |

## 🚀 Common Workflows

### New Installation

1. Read [README_INTEGRATED.md](README_INTEGRATED.md) - Overview
2. Read [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Product architecture
3. Review [ER_DIAGRAM_INTEGRATED.md](ER_DIAGRAM_INTEGRATED.md) - Schema structure
4. Review [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md) - Product layer
5. Deploy [schema_integrated.sql](../sql/schemas/schema_integrated.sql) - Create database
6. Run [queries.sql](../sql/queries/queries.sql) - Validate installation

### Onboard a New Client

1. Review [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Architecture overview
2. Create tenant in `tenants` table
3. Register models in `client_models`
4. Start using AI-Range for testing and personas


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

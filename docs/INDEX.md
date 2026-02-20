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
| **[../DOCUMENTATION.md](../DOCUMENTATION.md)** | **⭐ Consolidated master doc** | You want the full repo documentation in one place |
| **[PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)** | **⭐ Product layer guide** | You need to understand the multi-product architecture |
| **[CAT_ASTROPHIC_INTEGRATION.md](CAT_ASTROPHIC_INTEGRATION.md)** | **⭐ Cat-Astrophic integration** | You want details on PromptGoblin v2 tables |
| **[NEXUS_INTEGRATION.md](NEXUS_INTEGRATION.md)** | **⭐ Nexus integration** | You need Nexus prompt ingestion and library details |
| **[AGENT_ER_DIAGRAMS.md](AGENT_ER_DIAGRAMS.md)** | Agent ER diagrams | You need per-agent table maps |
| **[../AI_RANGE_UNIFIED_ARCHITECTURE.md](../AI_RANGE_UNIFIED_ARCHITECTURE.md)** | Unified architecture | You need the overall system architecture |
| **[../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)** | Complete schema | You're deploying the database |

### 📚 Documentation

| File | Purpose | When to Use |
|------|---------|-------------|
| **[../DOCUMENTATION.md](../DOCUMENTATION.md)** | **⭐ Consolidated master doc** | Full repository documentation |
| **[PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)** | **⭐ Product layer docs** | Understanding how products, clients, and models connect |
| **[CAT_ASTROPHIC_INTEGRATION.md](CAT_ASTROPHIC_INTEGRATION.md)** | **⭐ Cat-Astrophic integration** | Detailed PromptGoblin v2 table definitions and queries |
| **[NEXUS_INTEGRATION.md](NEXUS_INTEGRATION.md)** | **⭐ Nexus integration** | Nexus prompt ingestion and library tables |
| **[AGENT_ER_DIAGRAMS.md](AGENT_ER_DIAGRAMS.md)** | Agent ER diagrams | Agent-specific ER maps |
| **[ER_DIAGRAM.md](ER_DIAGRAM.md)** | Original ER diagrams | Reference for legacy system |
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
| **[../sql/views/nexus_views.sql](../sql/views/nexus_views.sql)** | **⭐ Nexus views** | Pre-built views for Nexus prompt ingestion |
| **[../sql/views/nexus_views.sql](../sql/views/nexus_views.sql)** | **⭐ Nexus views** | Pre-built views for Nexus prompt ingestion |
| **[../sql/sample_data/sample_data.sql](../sql/sample_data/sample_data.sql)** | Sample data | Testing the schema |

### 📊 Diagrams

| File | Purpose | When to Use |
|------|---------|-------------|
| **[PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)** | **⭐ Product layer ER diagram** | Understanding product architecture |
| **[ER_DIAGRAM.md](ER_DIAGRAM.md)** | Original diagrams | Reference for legacy system |

## 🚀 Common Workflows

### New Installation

1. Read [../DOCUMENTATION.md](../DOCUMENTATION.md) - Consolidated overview
2. Read [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Product architecture
3. Review [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md) - Product layer
4. Review [ER_DIAGRAM.md](ER_DIAGRAM.md) - Reference diagrams
5. Deploy [schema_integrated.sql](../sql/schemas/schema_integrated.sql) - Create database
6. Run [queries.sql](../sql/queries/queries.sql) - Validate installation

### Onboard a New Client

1. Review [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Architecture overview
2. Create tenant in `tenants` table
3. Register models in `client_models`
4. Start using AI-Range for testing and personas


### Data Migration

1. Read [../DOCUMENTATION.md](../DOCUMENTATION.md) - Migration summary and notes
2. Configure [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql) - Set data sources
3. Run [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql) - Migrate data
4. Validate using queries in the script - Check integrity

### Understanding the Schema

1. Read [../DOCUMENTATION.md](../DOCUMENTATION.md) - High-level overview
2. Review [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md) - Visual reference
3. Check [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Detailed explanations
4. Study [../sql/queries/queries.sql](../sql/queries/queries.sql) - Example usage

### Development

1. Reference [../DOCUMENTATION.md](../DOCUMENTATION.md) - Quick start
2. Use [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md) - Table relationships
3. Check [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) - Query patterns
4. Test with [../sql/sample_data/sample_data.sql](../sql/sample_data/sample_data.sql) - Sample data

## 📖 Documentation Map

```
┌─────────────────────────────────────────────────────┐
│           DOCUMENTATION.md                          │
│         (Consolidated Master Doc)                   │
└─────────────────────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         ▼                               ▼
┌──────────────────┐          ┌──────────────────────┐
│ PRODUCT_LAYER_   │          │ CAT_ASTROPHIC_       │
│ ARCHITECTURE.md  │          │ INTEGRATION.md       │
│ (Design)         │          └──────────────────────┘
└──────────────────┘                     │
         │                               │
         ▼                               ▼
┌──────────────────┐          ┌──────────────────────┐
│ PRODUCT_LAYER_   │          │ migration_script.sql │
│ ER_DIAGRAM.md    │          │ (Migration)          │
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
- **Overview**: [../DOCUMENTATION.md](../DOCUMENTATION.md)
- **Detailed Design**: [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)
- **Visual Diagrams**: [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)

### Personas
- **Schema**: [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)
- **Diagram**: [AGENT_ER_DIAGRAMS.md](AGENT_ER_DIAGRAMS.md)
- **Guide**: [../DOCUMENTATION.md](../DOCUMENTATION.md)

### Testing Framework
- **Schema**: [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)
- **Diagram**: [ER_DIAGRAM.md](ER_DIAGRAM.md)
- **Examples**: [../sql/queries/queries.sql](../sql/queries/queries.sql)

### Threat & Risk
- **Schema**: [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)
- **Diagram**: [ER_DIAGRAM.md](ER_DIAGRAM.md)
- **Migration**: [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql)

### Migration
- **Script**: [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql)
- **Guide**: [../DOCUMENTATION.md](../DOCUMENTATION.md)

### Performance
- **Indexes**: [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)
- **Guide**: [../DOCUMENTATION.md](../DOCUMENTATION.md)

### Security
- **Schema**: [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)
- **Guide**: [../DOCUMENTATION.md](../DOCUMENTATION.md)

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
- [ ] Read [../DOCUMENTATION.md](../DOCUMENTATION.md)
- [ ] Browse [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)
- [ ] Deploy [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql)

### For Migration
- [ ] Read [../DOCUMENTATION.md](../DOCUMENTATION.md)
- [ ] Review [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql)
- [ ] Test migration on staging environment
- [ ] Validate using provided queries

### For Development
- [ ] Bookmark [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)
- [ ] Study example queries in [../sql/queries/queries.sql](../sql/queries/queries.sql)
- [ ] Review [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md) query patterns
- [ ] Set up development environment

## 🆘 Troubleshooting

| Issue | Where to Look |
|-------|---------------|
| Schema errors | [../sql/schemas/schema_integrated.sql](../sql/schemas/schema_integrated.sql) comments |
| Migration failures | [../sql/migrations/migration_script.sql](../sql/migrations/migration_script.sql) validation section |
| Query performance | [../DOCUMENTATION.md](../DOCUMENTATION.md) |
| Missing relationships | [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md) |
| General questions | [../DOCUMENTATION.md](../DOCUMENTATION.md) |

## 📞 Support Resources

1. **Quick Reference**: This file
2. **Master Doc**: [../DOCUMENTATION.md](../DOCUMENTATION.md)
3. **Technical Guide**: [PRODUCT_LAYER_ARCHITECTURE.md](PRODUCT_LAYER_ARCHITECTURE.md)
4. **Visual Reference**: [PRODUCT_LAYER_ER_DIAGRAM.md](PRODUCT_LAYER_ER_DIAGRAM.md)
5. **Architecture Summary**: [../AI_RANGE_UNIFIED_ARCHITECTURE.md](../AI_RANGE_UNIFIED_ARCHITECTURE.md)

---

**Last Updated**: 2026  
**Version**: 2.1 (Consolidated)  
**Status**: ✅ Production Ready

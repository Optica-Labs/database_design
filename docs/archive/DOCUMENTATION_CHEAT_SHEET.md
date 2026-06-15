# Archived: Documentation Cheat Sheet

This cheat sheet was archived and consolidated into `MASTER_DOCUMENTATION_INDEX.md` and `DOCUMENTATION.md`.

See canonical files:
- `MASTER_DOCUMENTATION_INDEX.md`
- `DOCUMENTATION.md`

Archived copy (full content preserved): `docs/archive/DOCUMENTATION_CHEAT_SHEET.md`

## 🎯 I Need to...

### Query the Database
**Peregrine Alpha (AI Assurance)**
```
➜ First check: NEXUS_ALPHA_QUICK_REFERENCE.md
➜ Field definitions: docs/NEXUS_ALPHA_ARCHITECTURE.md
➜ Examples: NEXUS_ALPHA_QUICK_REFERENCE.md#quick-start-queries
```

**All Products**
```
➜ SQL queries: sql/queries/
➜ Schema: sql/schemas/schema_integrated.sql (2,316 lines)
➜ Field reference: docs/NEXUS_ALPHA_ARCHITECTURE.md
```

### Understand a Metric
```
Robustness (ρ)      → docs/NEXUS_ALPHA_ARCHITECTURE.md#stage-2
Fragility (φ)       → docs/NEXUS_ALPHA_ARCHITECTURE.md#stage-3
Risk Metrics        → docs/NEXUS_ALPHA_ARCHITECTURE.md#stage-1
Sycophancy          → docs/NEXUS_ALPHA_ARCHITECTURE.md#sycophancy
```

### Deploy to Production
```
1. Read: NEXUS_ALPHA_INTEGRATION_REPORT.md
2. Load: sql/schemas/schema_integrated.sql
3. Sample data: sql/sample_data/ (to be created)
4. Migrations: sql/migrations/ (to be created)
```

### Understand Architecture
```
Products & multi-tenancy  → docs/PRODUCT_LAYER_ARCHITECTURE.md
Data relationships        → docs/ER_DIAGRAM.md
Product layer model       → docs/PRODUCT_LAYER_ER_DIAGRAM.md
Agent interactions        → docs/AGENT_ER_DIAGRAMS.md
Peregrine vs Peregrine Alpha      → docs/NEXUS_PRODUCTS_INTEGRATION.md
```

### Compare Products
```
AI-Range vs Peregrine vs Peregrine Alpha
→ docs/NEXUS_PRODUCTS_INTEGRATION.md
```

### Track Changes
```
What's new?     → CHANGELOG.md
Version history → CHANGELOG.md
Deliverables    → NEXUS_ALPHA_INTEGRATION_REPORT.md
```

### See Project Status
```
Features list          → DOCUMENTATION.md#key-features
File organization      → DIRECTORY_STRUCTURE.md
Schema deployment      → NEXUS_ALPHA_INTEGRATION_REPORT.md
All capabilities       → README.md
```

---

## 📁 One-Liner Document Descriptions

| Document | One-liner |
|----------|-----------|
| README.md | Project overview and key features |
| DOCUMENTATION.md | Master platform reference with tables and workflows |
| MASTER_DOCUMENTATION_INDEX.md | **← START HERE** Navigation by role and topic |
| CHANGELOG.md | What changed and when |
| DIRECTORY_STRUCTURE.md | File tree and organization |
| NEXUS_ALPHA_QUICK_REFERENCE.md | Common SQL queries and patterns |
| NEXUS_ALPHA_ARCHITECTURE.md | Complete technical specification (17 tables, 4 stages) |
| NEXUS_ALPHA_INTEGRATION_REPORT.md | Deployment checklist and integration details |
| MASTER_DOCUMENTATION_INDEX.md | Navigation guide for Peregrine Alpha documentation |
| NEXUS_ALPHA_INTEGRATION_REPORT.md | Schema overview with examples and performance tips |
| NEXUS_ALPHA_INTEGRATION_REPORT.md | Delivery metrics and completion status (merged) |
| NEXUS_ALPHA_INTEGRATION_REPORT.md | ⚠️ DEPRECATED (replaced by canonical integration report) |
| docs/INDEX.md | Feature index and navigation |
| docs/NEXUS_ALPHA_ARCHITECTURE.md | Complete field reference for all 17 Peregrine Alpha tables |
| docs/NEXUS_PRODUCTS_INTEGRATION.md | Detailed comparison of all three products |
| docs/NEXUS_PRODUCTS_INTEGRATION.md | Quick reference for Peregrine product |
| docs/NEXUS_DOCUMENTATION_SUMMARY.md | Executive summary of Peregrine outputs |
| docs/NEXUS_INTEGRATION.md | ⚠️ DEPRECATED (see NEXUS_PRODUCTS_INTEGRATION) |
| docs/NEXUS_DOCUMENTATION_SUMMARY.md | Delivery summary |
| docs/PRODUCT_LAYER_ARCHITECTURE.md | Multi-tenant architecture deep-dive |
| docs/ER_DIAGRAM.md | Full entity-relationship diagram |
| docs/PRODUCT_LAYER_ER_DIAGRAM.md | Product layer ER diagram |
| docs/AGENT_ER_DIAGRAMS.md | Agent interaction models |
| docs/CAT_ASTROPHIC_INTEGRATION.md | Catastrophic/PromptGoblin integration |
| AI-Range & Peregrine Unified Platform .md | Platform overview with Mermaid diagrams |
| sql/schemas/schema_integrated.sql | PostgreSQL schema (2,316 lines, production) |

---

## 👥 By Role - What to Read

### DBAs
1. NEXUS_ALPHA_INTEGRATION_REPORT.md
2. NEXUS_ALPHA_INTEGRATION_REPORT.md
3. sql/schemas/schema_integrated.sql

### Backend Engineers
1. NEXUS_ALPHA_QUICK_REFERENCE.md
2. docs/NEXUS_ALPHA_ARCHITECTURE.md
3. docs/PRODUCT_LAYER_ARCHITECTURE.md

### Data Scientists
1. docs/NEXUS_ALPHA_ARCHITECTURE.md (metrics)
2. NEXUS_ALPHA_QUICK_REFERENCE.md (queries)
3. docs/NEXUS_PRODUCTS_INTEGRATION.md (workflows)

### Product Managers
1. DOCUMENTATION.md
2. README.md
3. docs/NEXUS_PRODUCTS_INTEGRATION.md

### DevOps / SRE
1. NEXUS_ALPHA_INTEGRATION_REPORT.md
2. NEXUS_ALPHA_INTEGRATION_REPORT.md
3. CHANGELOG.md

### Data Analysts
1. NEXUS_ALPHA_QUICK_REFERENCE.md
2. docs/ER_DIAGRAM.md
3. DOCUMENTATION.md

---

## 🔍 By Topic - Quick Links

| Topic | Primary | Secondary | Reference |
|-------|---------|-----------|-----------|
| **Schema** | schema_integrated.sql | NEXUS_ALPHA_INTEGRATION_REPORT.md | docs/ER_DIAGRAM.md |
| **Peregrine Alpha** | NEXUS_ALPHA_QUICK_REFERENCE.md | docs/NEXUS_ALPHA_ARCHITECTURE.md | NEXUS_ALPHA_INTEGRATION_REPORT.md |
| **Peregrine Product** | docs/NEXUS_PRODUCTS_INTEGRATION.md | docs/NEXUS_PRODUCTS_INTEGRATION.md | docs/NEXUS_INTEGRATION.md |
| **Architecture** | docs/PRODUCT_LAYER_ARCHITECTURE.md | docs/PRODUCT_LAYER_ER_DIAGRAM.md | docs/AGENT_ER_DIAGRAMS.md |
| **Metrics** | docs/NEXUS_ALPHA_ARCHITECTURE.md | NEXUS_ALPHA_QUICK_REFERENCE.md | - |
| **Queries** | NEXUS_ALPHA_QUICK_REFERENCE.md | docs/NEXUS_ALPHA_ARCHITECTURE.md | DOCUMENTATION.md |
| **Deployment** | NEXUS_ALPHA_INTEGRATION_REPORT.md | NEXUS_ALPHA_INTEGRATION_REPORT.md | - |
| **Features** | DOCUMENTATION.md | README.md | DIRECTORY_STRUCTURE.md |
| **Changes** | CHANGELOG.md | NEXUS_ALPHA_INTEGRATION_REPORT.md | - |
| **Integration** | docs/NEXUS_PRODUCTS_INTEGRATION.md | NEXUS_ALPHA_INTEGRATION_REPORT.md | - |

---

## 💡 Pro Tips

- **Start with MASTER_DOCUMENTATION_INDEX.md** for navigation
- **Use Ctrl+F** to search within documents
- **Check status badges**: ✅ Current, ⚠️ Deprecated, 🔄 Updating
- **Follow the breadcrumbs** - documents link to related content
- **Review CHANGELOG.md** for updates since your last visit
- **5-minute briefing?** Start with README.md
- **Deep dive?** Go to DOCUMENTATION.md or relevant ARCHITECTURE file

---

## 📊 Documentation Statistics

- **24 Markdown files** (~850 KB total)
- **1 SQL schema file** (2,316 lines)
- **3 Mermaid diagrams** (ER, product layer, agents)
- **~15 integrated products**
- **Full multi-tenant support**

---

## ✨ What's New in This Consolidated Index

- **MASTER_DOCUMENTATION_INDEX.md** - Unified navigation by role and topic
- **NEXUS_ALPHA_QUICK_REFERENCE.md** - One-page SQL reference
- **NEXUS_ALPHA_INTEGRATION_REPORT.md** - Complete deployment guide
-- **MASTER_DOCUMENTATION_INDEX.md** - Peregrine Alpha-specific navigation
- **NEXUS_ALPHA_INTEGRATION_REPORT.md** - Schema overview and examples

---

**Last Updated**: February 22, 2026  
**For full documentation, see**: [MASTER_DOCUMENTATION_INDEX.md](MASTER_DOCUMENTATION_INDEX.md)  
**Questions?** Refer to "I need to..." section above

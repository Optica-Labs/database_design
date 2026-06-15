# Schema Alignment Issues & Fixes - Quick Guide

**Last Updated**: March 4, 2026  
**Status**: Ready to implement fixes

---

## Critical Issues Found

### ⚠️ Issue #1: Broken Documentation References

**Impact**: Users sent to non-existent documentation

**Location**: [DOCUMENTATION.md](../../DOCUMENTATION.md#primary-documents)

**Problem**:
```markdown
| [docs/SCHEMA_ARCHITECTURE.md](docs/SCHEMA_ARCHITECTURE.md) | Database design & structure | Developers, DBAs |
```
↑ This file doesn't exist!

**Current State**:
```
docs/
├── README.md
├── verification/   (live schema & alignment)
└── archive/        (historical migration/integration/architecture docs)
```

**Fix Options**:
1. Create `docs/SCHEMA_ARCHITECTURE.md` (recommended)
2. Replace with existing `sql/schemas/README.md`
3. Remove and update links

---

### ⚠️ Issue #2: Confusing Schema Version Documentation

**Impact**: Developers don't know which schema to use

**Location**: [sql/schemas/README.md](../../sql/schemas/README.md)

**Problem**:
```markdown
### File Description

### `schema_complete.sql` (2520 lines)
**This is the complete, production-ready schema** that includes:
1. Product Layer Architecture
2. ... 13 more components ...
9. **Agent Interaction Tracking** ⭐ NEW

### Total Tables: 100+
```

**But**: The actual Supabase setup uses modular files with only 4-5 tables:
- `01_extensions_and_products.sql`
- `01_conversations_and_turns.sql`
- `02_llm_invocations.sql`

**Current Reality**:
- `schema_complete.sql` = Legacy/archived version (91+ tables)
- Supabase setup = Current version (4-5 core tables modular)

**Confusion**: Which one do users deploy?

**Fix**: Restructure [sql/schemas/README.md](../../sql/schemas/README.md) with:
```
## Active Schema (Supabase - Use This)
Location: sql/schemas/supabase/
Files: 00_SETUP_GUIDE.sql, 01_extensions_and_products.sql, etc.

## Legacy Schema (Archived - Reference Only)
Location: sql/schemas/
Files: schema_complete.sql, schema_integrated.sql
```

---

### ⚠️ Issue #3: Agent Interactions - Where Are They?

**Impact**: Unclear if agent tracking is implemented

**Location**: Multiple files

**Confusion Points**:

1. [sql/schemas/README.md](../../sql/schemas/README.md) says:
```markdown
9. **Agent Interaction Tracking** ⭐ NEW - Complete agent workflow tracking:
   - `agent_interactions` - Core agent participation tracking
   - `agent_interaction_libraries` - Library access tracking
   ...
```

2. But current Supabase setup has:
```markdown
- `agents`
- `llm_invocations` (with agent_id, agent_name, agent_type)
```

3. Legacy `schema_complete.sql` might have full agent_interactions tables

**Question**: Are these separate or integrated?

**Fix**: 
- [ ] Verify: Is `agent_interactions_schema.sql` meant to be part of Supabase setup?
- [ ] If yes: Create `03_agent_interactions.sql` and add to Supabase setup docs
- [ ] If no: Clarify that agent tracking is via `llm_invocations` fields

---

### ⚠️ Issue #4: Peregrine Platform Status Unclear

**Impact**: Developers don't know if Peregrine is deployed

**Location**: [docs/archive/NEXUS_ALPHA_ARCHITECTURE.md](../archive/NEXUS_ALPHA_ARCHITECTURE.md)

**Problem**:
```markdown
# Peregrine: AI Assurance Platform

This document describes comprehensive Peregrine schema with:
- embeddings tables
- vectors_2d tables
- risk_metrics
- robustness_analysis
- fragility_scores
- sycophancy_analysis
```

**But**: These tables don't appear in current Supabase modular setup!

**Question**: Is Peregrine:
1. A separate deployment? (different database)
2. To be added later?
3. Already in `schema_complete.sql`?

**Fix**: 
- [ ] Clarify Peregrine deployment status in documentation
- [ ] If separate: Create `docs/NEXUS_ALPHA_DEPLOYMENT.md`
- [ ] Update table dependencies documentation

---

### ⚠️ Issue #5: Missing Peregrine Integration Documentation

**Location**: [DOCUMENTATION.md](../../DOCUMENTATION.md#integration-guides)

**References**: `docs/NEXUS_INTEGRATION.md` (doesn't exist!)

**Should be**: `docs/archive/NEXUS_PRODUCTS_INTEGRATION.md` or similar

**Fix**: Update reference or rename file

---

## Implementation Checklist

### Phase 1: Documentation Fixes (1 hour)

- [ ] Fix broken link in [DOCUMENTATION.md](../../DOCUMENTATION.md) (line ~25)
  - Change: `docs/SCHEMA_ARCHITECTURE.md` → `sql/schemas/supabase/README.md`
  
- [ ] Update [sql/schemas/README.md](../../sql/schemas/README.md)
  - Add section header: "## ⚠️ IMPORTANT: Schema Versions"
  - Clarify which schema is active
  - Move legacy files to "Archive" section

- [ ] Update [README.md](../../README.md)
  - Point to Supabase schema in `sql/schemas/supabase/`
  - Add decision: "Which schema should I use?"

### Phase 2: Scope Clarification (1-2 hours)

- [ ] Verify agent interactions implementation
  - Check: Is `agent_interactions_schema.sql` needed for Supabase?
  - Decision: Include in `03_agent_interactions.sql` or remove?
  
- [ ] Verify Peregrine implementation
  - Check: Should Peregrine tables be in Supabase?
  - Decision: Create `03_peregrine_alpha.sql` or separate guide?

### Phase 3: Documentation Updates (1-2 hours)

- [ ] Create clear schema deployment guide
- [ ] Add "Schema Versions" section with decision tree
- [ ] Create missing architecture documentation if needed

---

## Quick Summary Table

| Issue | Severity | Location | Status | Fix Time |
|-------|----------|----------|--------|----------|
| Broken `SCHEMA_ARCHITECTURE.md` link | 🔴 High | DOCUMENTATION.md | Ready | 5 min |
| Schema version confusion | 🟠 Medium | sql/schemas/README.md | Ready | 30 min |
| Agent interactions unclear | 🟠 Medium | Multiple files | Investigation | 1 hour |
| Peregrine status unclear | 🟠 Medium | docs/archive/NEXUS_ALPHA_ARCHITECTURE.md | Investigation | 1 hour |
| Missing NEXUS_INTEGRATION doc | 🟡 Low | DOCUMENTATION.md | Ready | 5 min |

---

## Total Estimated Fix Time: 3-4 hours

### Immediate Actions (Next 15 minutes)
1. Update link in [DOCUMENTATION.md](../../DOCUMENTATION.md)
2. Add version clarification to [sql/schemas/README.md](../../sql/schemas/README.md)
3. Create simple decision tree for users

### This Week
4. Verify agent interactions scope
5. Verify Peregrine deployment status
6. Create missing documentation

---

## Files Recommended for Update

1. **[sql/schemas/README.md](../../sql/schemas/README.md)** - Add versioning clarity
2. **[DOCUMENTATION.md](../../DOCUMENTATION.md)** - Fix broken links
3. **[README.md](../../README.md)** - Point to correct schema
4. **[sql/schemas/supabase/README.md](../../sql/schemas/supabase/README.md)** - Already good! ✅

---

## Success Criteria

After fixes, developers should be able to:
- ✅ Know which schema files to use (Supabase modular setup)
- ✅ Understand why multiple schema versions exist
- ✅ Find all required documentation without broken links
- ✅ Know status of agent interactions and Peregrine
- ✅ Deploy schema with confidence

---

**Generated**: March 4, 2026  
**Audit Source**: SCHEMA_ALIGNMENT_AUDIT.md  
**Next Review**: After fixes implemented

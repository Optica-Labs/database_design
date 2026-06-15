# Changelog

## 2026-06-14

### Documentation Refresh

- Standardized active documentation on canonical deployment path:
  - `sql/create.sql`
  - `sql/create/README.md`
- Updated naming references to peregrine across active docs.
- Updated schema/variant counts in active docs:
  - canonical: 94 tables, 26 sequences
  - variants: AI-Range 65 tables, Peregrine 24 tables

### Canonical Pipeline Status

- Canonical generation and verification scripts in place:
  - `scripts/generate_canonical_schema.py`
  - `scripts/generate_variants.py`
  - `scripts/generate_peregrine_snapshot.py`
  - `scripts/verify_canonical_schema.py`
- Artifacts generated and validated.

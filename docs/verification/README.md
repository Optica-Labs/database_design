# Verification Documentation

This folder contains schema and documentation alignment artifacts.

## Files

- [LIVE_SUPABASE_ALIGNMENT_REPORT.md](LIVE_SUPABASE_ALIGNMENT_REPORT.md): Latest live verification outcome (Method 1).
- [LIVE_SCHEMA_SNAPSHOT.md](LIVE_SCHEMA_SNAPSHOT.md): Full live public-schema table/column snapshot.
- [LIVE_SCHEMA_SNAPSHOT.json](LIVE_SCHEMA_SNAPSHOT.json): Machine-readable live schema snapshot.
- [LIVE_SCHEMA_DDL_COMPACT.sql](LIVE_SCHEMA_DDL_COMPACT.sql): Compact live DDL export (tables + constraints + indexes).
- [SCHEMA_ALIGNMENT_AUDIT.md](SCHEMA_ALIGNMENT_AUDIT.md): Full static alignment audit.
- [SCHEMA_ALIGNMENT_ISSUES.md](SCHEMA_ALIGNMENT_ISSUES.md): Identified issues and priorities.
- [ALIGNMENT_SUMMARY.md](ALIGNMENT_SUMMARY.md): Executive summary.
- [NAVIGATION_GUIDE.md](NAVIGATION_GUIDE.md): Reading/navigation guide.
- [AUDIT_COMPLETION_REPORT.md](../archive/AUDIT_COMPLETION_REPORT.md): Completion report (archived).

## Repeatable live check

Use:

- [scripts/verify_live_alignment.py](../../scripts/verify_live_alignment.py)
- [scripts/snapshot_live_schema.py](../../scripts/snapshot_live_schema.py)
- [scripts/export_live_schema_ddl.py](../../scripts/export_live_schema_ddl.py)

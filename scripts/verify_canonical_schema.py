#!/usr/bin/env python3
"""Verify the generated canonical schema against the live snapshot.

Compares the table and column sets in ``sql/create/10_schema_canonical.sql``
against ``docs/verification/LIVE_SCHEMA_SNAPSHOT.json`` after applying the
``alpha`` -> ``peregrine`` naming transition to the snapshot.  Requires no
database connection.

Exit code 0 on success; 1 on any mismatch (with a diff printed to stdout).
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from peregrine import rename_identifiers

ROOT = Path(__file__).resolve().parents[1]
CANONICAL = ROOT / "sql" / "create" / "10_schema_canonical.sql"
SNAPSHOT = ROOT / "docs" / "verification" / "LIVE_SCHEMA_SNAPSHOT.json"

_TABLE_BLOCK_RE = re.compile(
    r'CREATE TABLE(?: IF NOT EXISTS)? public\."(?P<name>[^"]+)" \((?P<body>.*?)\n\);',
    re.DOTALL,
)
_COLUMN_RE = re.compile(r'^\s+"(?P<col>[^"]+)"\s', re.MULTILINE)


def parse_canonical(sql: str) -> dict[str, set[str]]:
    """Map each canonical table name to its set of column names."""
    tables: dict[str, set[str]] = {}
    for match in _TABLE_BLOCK_RE.finditer(sql):
        columns = set(_COLUMN_RE.findall(match.group("body")))
        tables[match.group("name")] = columns
    return tables


def expected_from_snapshot(snapshot: dict[str, object]) -> dict[str, set[str]]:
    """Build the expected peregrine table/column map from the live snapshot."""
    raw_tables = snapshot["tables"]
    assert isinstance(raw_tables, dict)
    expected: dict[str, set[str]] = {}
    for name, info in raw_tables.items():
        if info.get("table_type") != "BASE TABLE":
            continue
        peregrine_name = rename_identifiers(name)
        expected[peregrine_name] = {col["name"] for col in info["columns"]}
    return expected


def diff(expected: dict[str, set[str]], actual: dict[str, set[str]]) -> list[str]:
    """Return human-readable mismatches between expected and actual schemas."""
    problems: list[str] = []
    missing = sorted(set(expected) - set(actual))
    extra = sorted(set(actual) - set(expected))
    problems += [f"missing table: {name}" for name in missing]
    problems += [f"unexpected table: {name}" for name in extra]
    for name in sorted(set(expected) & set(actual)):
        col_problems = expected[name] ^ actual[name]
        if col_problems:
            problems.append(f"column mismatch in {name}: {sorted(col_problems)}")
    return problems


def verify() -> list[str]:
    """Run the verification and return the list of problems (empty == OK)."""
    sql = CANONICAL.read_text(encoding="utf-8")
    snapshot = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    return diff(expected_from_snapshot(snapshot), parse_canonical(sql))


def main() -> int:
    """CLI entry point: print result and return an exit code."""
    problems = verify()
    if problems:
        print("CANONICAL VERIFY FAILED:")
        for problem in problems:
            print(f"  - {problem}")
        return 1
    print("Canonical verify OK: tables and columns match the live snapshot.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

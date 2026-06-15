#!/usr/bin/env python3
"""Generate product-variant schemas as subsets of the canonical schema.

A variant is an explicit set of canonical (peregrine) table names declared in
``sql/variants/manifests.json``.  This script extracts those tables -- with
their sequences, constraints and indexes -- from the canonical DDL so the
emitted variant DDL always matches the live schema (no drift).

Foreign-key constraints that reference a table outside the variant are dropped,
keeping every variant self-contained and runnable in isolation.

Outputs (regenerated, never hand-edited) under ``sql/variants/``:
``ai_range_only.sql`` and ``peregrine_only.sql``.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import generate_canonical_schema as gen
from peregrine import rename_identifiers

ROOT = Path(__file__).resolve().parents[1]
MANIFESTS = ROOT / "sql" / "variants" / "manifests.json"
OUT_DIR = ROOT / "sql" / "variants"

_OWNER_RE = re.compile(r'ALTER TABLE ONLY public\."([^"]+)"')
_REFERENCES_RE = re.compile(r"REFERENCES (\w+)")
_TABLE_BLOCK_RE = re.compile(
    r'(CREATE TABLE public\."([^"]+)" \(.*?\n\);)', re.DOTALL
)
_INDEX_TABLE_RE = re.compile(r"ON public\.(\w+) ")

_HEADER = (
    "-- GENERATED FILE -- DO NOT EDIT BY HAND.\n"
    "-- Regenerate: python3 scripts/generate_variants.py\n"
    "-- Source of truth: docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql\n"
    "-- Subset of the canonical schema; membership: sql/variants/manifests.json.\n"
)


def load_manifests() -> dict[str, set[str]]:
    """Load variant name -> table-set, ignoring comment keys."""
    raw = json.loads(MANIFESTS.read_text(encoding="utf-8"))
    return {
        name: set(tables)
        for name, tables in raw.items()
        if not name.startswith("_")
    }


def renamed_sections() -> dict[str, str]:
    """Return the peregrine-renamed TABLES/CONSTRAINTS/INDEXES section bodies."""
    ddl = rename_identifiers(gen.read_text(gen.DDL_SRC))
    return gen.parse_sections(ddl)


def select_tables(body: str, keep: set[str]) -> str:
    """Return the ``CREATE TABLE`` blocks for tables in ``keep``."""
    blocks = [
        block
        for block, name in _TABLE_BLOCK_RE.findall(body)
        if name in keep
    ]
    return "\n\n".join(blocks)


def keep_constraint(statement: str, keep: set[str]) -> bool:
    """Decide whether a constraint statement belongs to the variant subset."""
    owner = _OWNER_RE.search(statement)
    if owner is None or owner.group(1) not in keep:
        return False
    reference = _REFERENCES_RE.search(statement)
    return reference is None or reference.group(1) in keep


def select_constraints(body: str, keep: set[str]) -> str:
    """Return constraint statements owned by and consistent within the subset."""
    return "\n".join(
        line for line in body.splitlines() if keep_constraint(line, keep)
    )


def select_indexes(body: str, keep: set[str]) -> str:
    """Return ``CREATE INDEX`` statements for tables in ``keep``."""
    selected = []
    for line in body.splitlines():
        match = _INDEX_TABLE_RE.search(line)
        if match and match.group(1) in keep:
            selected.append(line)
    return "\n".join(selected)


def build_variant(sections: dict[str, str], keep: set[str]) -> str:
    """Assemble one idempotent, peregrine-named variant script."""
    tables = select_tables(sections["TABLES"], keep)
    sequences = gen.build_sequence_ddl(gen.extract_sequences(tables))
    constraints = select_constraints(sections["CONSTRAINTS"], keep)
    indexes = select_indexes(sections["INDEXES"], keep)
    parts = [
        f"{_HEADER}\nSET search_path = public;",
        gen.section("SEQUENCES", sequences),
        gen.section("TABLES", gen.idempotent_tables(tables)),
        gen.section("CONSTRAINTS", gen.idempotent_constraints(constraints)),
        gen.section("INDEXES", gen.idempotent_indexes(indexes)),
    ]
    return "\n\n".join(parts) + "\n"


def generate() -> dict[Path, str]:
    """Compute every variant artifact keyed by its output path."""
    sections = renamed_sections()
    manifests = load_manifests()
    return {
        OUT_DIR / f"{name}_only.sql": build_variant(sections, keep)
        for name, keep in manifests.items()
    }


def main() -> None:
    """Write every variant artifact to disk."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for path, content in generate().items():
        path.write_text(content, encoding="utf-8")
        print(f"wrote {path}")


if __name__ == "__main__":
    main()

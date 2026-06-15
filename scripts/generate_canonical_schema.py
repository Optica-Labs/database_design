#!/usr/bin/env python3
"""Generate the canonical Postgres create scripts from the live schema.

Sources of truth (captured from the live database):

* ``docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql`` -- base tables, constraints
  and indexes.
* ``docs/verification/LIVE_SCHEMA_SNAPSHOT.json`` -- view definitions.

The live schema references sequences via ``nextval`` defaults but never defines
them, so it is not directly runnable in a fresh environment.  This generator:

* emits ``CREATE SEQUENCE`` statements for every referenced sequence;
* applies the ``alpha`` -> ``peregrine`` naming transition;
* makes every statement idempotent (``IF NOT EXISTS`` / guarded constraints);
* emits a matching ``reset`` teardown script.

Outputs (all regenerated, never hand-edited) under ``sql/create/``:
``10_schema_canonical.sql``, ``20_views.sql`` and ``reset.sql``.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from peregrine import rename_identifiers

ROOT = Path(__file__).resolve().parents[1]
DDL_SRC = ROOT / "docs" / "verification" / "LIVE_SCHEMA_DDL_COMPACT.sql"
SNAPSHOT_SRC = ROOT / "docs" / "verification" / "LIVE_SCHEMA_SNAPSHOT.json"
OUT_DIR = ROOT / "sql" / "create"

_SECTION_RE = re.compile(r"-- ={5,}\n-- (TABLES|CONSTRAINTS|INDEXES)\n-- ={5,}\n")
_SEQUENCE_RE = re.compile(r"nextval\('([^']+?)'::regclass\)")
_TABLE_RE = re.compile(
    r'^CREATE TABLE(?: IF NOT EXISTS)? public\."([^"]+)"', re.MULTILINE
)

_GENERATED_NOTE = (
    "-- GENERATED FILE -- DO NOT EDIT BY HAND.\n"
    "-- Regenerate: python3 scripts/generate_canonical_schema.py\n"
    "-- Source of truth: docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql\n"
    "-- Naming: legacy prefixes transitioned to peregrine_* (see sql/legacy/README.md).\n"
)


def read_text(path: Path) -> str:
    """Return the UTF-8 contents of ``path``."""
    return path.read_text(encoding="utf-8")


def parse_sections(ddl: str) -> dict[str, str]:
    """Split the compact DDL into its TABLES/CONSTRAINTS/INDEXES bodies."""
    parts = _SECTION_RE.split(ddl)
    return {
        name: body.strip("\n")
        for name, body in zip(parts[1::2], parts[2::2])
    }


def extract_sequences(ddl: str) -> list[str]:
    """Return the sorted, unique sequence names referenced by ``nextval``."""
    return sorted(set(_SEQUENCE_RE.findall(ddl)))


def extract_table_names(ddl: str) -> list[str]:
    """Return canonical table names in their declaration order."""
    return _TABLE_RE.findall(ddl)


def build_sequence_ddl(sequences: list[str]) -> str:
    """Render idempotent ``CREATE SEQUENCE`` statements."""
    return "\n".join(
        f"CREATE SEQUENCE IF NOT EXISTS public.{name};" for name in sequences
    )


def idempotent_tables(body: str) -> str:
    """Add ``IF NOT EXISTS`` to ``CREATE TABLE`` statements."""
    return body.replace("CREATE TABLE public.", "CREATE TABLE IF NOT EXISTS public.")


def idempotent_indexes(body: str) -> str:
    """Add ``IF NOT EXISTS`` to ``CREATE [UNIQUE] INDEX`` statements."""
    body = body.replace("CREATE UNIQUE INDEX ", "CREATE UNIQUE INDEX IF NOT EXISTS ")
    return body.replace("CREATE INDEX ", "CREATE INDEX IF NOT EXISTS ")


def wrap_constraint(statement: str) -> str:
    """Wrap an ``ADD CONSTRAINT`` statement so re-runs ignore duplicates."""
    return (
        "DO $$ BEGIN\n"
        f"    {statement}\n"
        "EXCEPTION\n"
        "    WHEN duplicate_object THEN NULL;\n"
        "END $$;"
    )


def idempotent_constraints(body: str) -> str:
    """Guard every ``ALTER TABLE ... ADD CONSTRAINT`` for idempotent re-runs."""
    return "\n".join(
        wrap_constraint(line) if line.startswith("ALTER TABLE") else line
        for line in body.splitlines()
    )


def section(title: str, body: str) -> str:
    """Render a titled SQL section with a banner header."""
    banner = "-- " + "=" * 74
    return f"{banner}\n-- {title}\n{banner}\n\n{body}"


def build_canonical(ddl: str) -> str:
    """Build the idempotent, peregrine-named canonical schema script."""
    ddl = rename_identifiers(ddl)
    sections = parse_sections(ddl)
    header = f"{_GENERATED_NOTE}\nSET search_path = public;"
    parts = [
        header,
        section("SEQUENCES", build_sequence_ddl(extract_sequences(ddl))),
        section("TABLES", idempotent_tables(sections["TABLES"])),
        section("CONSTRAINTS", idempotent_constraints(sections["CONSTRAINTS"])),
        section("INDEXES", idempotent_indexes(sections["INDEXES"])),
    ]
    return "\n\n".join(parts) + "\n"


def build_views(snapshot: dict[str, Any]) -> str:
    """Build the peregrine-named view script from the live snapshot."""
    views = snapshot["views"]
    blocks = [
        "CREATE OR REPLACE VIEW public.{name} AS\n{body};".format(
            name=name,
            body=rename_identifiers(views[name]["definition"].strip()),
        )
        for name in sorted(views)
    ]
    header = f"{_GENERATED_NOTE}\nSET search_path = public;"
    return header + "\n\n" + "\n\n".join(blocks) + "\n"


def build_reset(tables: list[str], sequences: list[str], views: list[str]) -> str:
    """Build a teardown script dropping every generated object."""
    lines = [
        _GENERATED_NOTE.rstrip(),
        "-- Destructive: drops every canonical object. Use only to rebuild.",
        "",
        "SET search_path = public;",
        "",
    ]
    lines += [f"DROP VIEW IF EXISTS public.{name} CASCADE;" for name in sorted(views)]
    lines += [f'DROP TABLE IF EXISTS public."{name}" CASCADE;' for name in tables]
    lines += [f"DROP SEQUENCE IF EXISTS public.{name} CASCADE;" for name in sequences]
    return "\n".join(lines) + "\n"


def generate() -> dict[Path, str]:
    """Compute every generated artifact keyed by its output path."""
    ddl = read_text(DDL_SRC)
    snapshot = json.loads(read_text(SNAPSHOT_SRC))
    renamed = rename_identifiers(ddl)
    return {
        OUT_DIR / "10_schema_canonical.sql": build_canonical(ddl),
        OUT_DIR / "20_views.sql": build_views(snapshot),
        OUT_DIR / "reset.sql": build_reset(
            extract_table_names(renamed),
            extract_sequences(renamed),
            list(snapshot["views"]),
        ),
    }


def main() -> None:
    """Write every generated artifact to disk."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for path, content in generate().items():
        path.write_text(content, encoding="utf-8")
        print(f"wrote {path}")


if __name__ == "__main__":
    main()

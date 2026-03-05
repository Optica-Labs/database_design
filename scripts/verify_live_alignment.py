#!/usr/bin/env python3
"""Verify repository schema/docs alignment against live Supabase using Method 1 vars."""

from __future__ import annotations

import json
import re
from pathlib import Path

import psycopg2
from dotenv import load_dotenv
import os

ROOT = Path(__file__).resolve().parents[1]

SCHEMA_FILES = [
    ROOT / "sql/schemas/supabase/01_extensions_and_products.sql",
    ROOT / "sql/schemas/supabase/01_conversations_and_turns.sql",
    ROOT / "sql/schemas/supabase/02_llm_invocations.sql",
]

DOC_FILES = [
    ROOT / "sql/schemas/supabase/README.md",
    ROOT / "DOCUMENTATION.md",
]

TABLE_RE = re.compile(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?([a-zA-Z_][a-zA-Z0-9_]*)", re.IGNORECASE)


def extract_expected_tables() -> set[str]:
    tables: set[str] = set()
    for p in SCHEMA_FILES:
        text = p.read_text(encoding="utf-8", errors="ignore")
        for m in TABLE_RE.finditer(text):
            tables.add(m.group(1).lower())
    return tables


def extract_doc_tables() -> set[str]:
    # capture table names written as `table_name` in docs
    tick_re = re.compile(r"`([a-zA-Z_][a-zA-Z0-9_]*)`")
    out: set[str] = set()
    for p in DOC_FILES:
        text = p.read_text(encoding="utf-8", errors="ignore")
        for t in tick_re.findall(text):
            if " " not in t and t.lower() == t:
                out.add(t.lower())
    return out


def get_live_schema() -> dict[str, set[str]]:
    load_dotenv(dotenv_path=ROOT / ".env")

    conn = psycopg2.connect(
        host=os.getenv("SUPABASE_HOST"),
        port=os.getenv("SUPABASE_PORT", "5432"),
        dbname=os.getenv("SUPABASE_DB", "postgres"),
        user=os.getenv("SUPABASE_USER"),
        password=os.getenv("SUPABASE_PASSWORD"),
        connect_timeout=10,
    )
    cur = conn.cursor()

    cur.execute(
        """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema='public'
        ORDER BY table_name
        """
    )
    live_tables = {r[0].lower() for r in cur.fetchall()}

    cur.execute(
        """
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema='public'
        ORDER BY table_name, ordinal_position
        """
    )
    table_columns: dict[str, set[str]] = {}
    for table, col in cur.fetchall():
        table_columns.setdefault(table.lower(), set()).add(col.lower())

    cur.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema='public' AND table_type='BASE TABLE'
        """
    )
    base_table_count = int(cur.fetchone()[0])

    cur.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.views
        WHERE table_schema='public'
        """
    )
    view_count = int(cur.fetchone()[0])

    conn.close()
    return {
        "tables": live_tables,
        "columns": table_columns,
        "base_table_count": base_table_count,
        "view_count": view_count,
    }


def main() -> None:
    expected = extract_expected_tables()
    doc_tables = extract_doc_tables()
    live = get_live_schema()
    live_tables = live["tables"]

    expected_missing_in_live = sorted(expected - live_tables)
    live_extra_vs_expected = sorted(live_tables - expected)

    # docs coverage against live
    doc_tables_in_live = sorted(t for t in doc_tables if t in live_tables)
    doc_tables_missing_in_live = sorted(t for t in doc_tables if t not in live_tables)

    report = {
        "connection_method": "Method 1 (SUPABASE_* individual vars)",
        "summary": {
            "expected_tables_from_supabase_schema_files": len(expected),
            "live_public_tables": len(live_tables),
            "live_base_tables": live["base_table_count"],
            "live_views": live["view_count"],
            "doc_backticked_table_names_found": len(doc_tables),
            "expected_missing_in_live": len(expected_missing_in_live),
            "doc_table_names_not_in_live": len(doc_tables_missing_in_live),
        },
        "expected_tables": sorted(expected),
        "live_tables": sorted(live_tables),
        "expected_missing_in_live": expected_missing_in_live,
        "live_extra_vs_expected": live_extra_vs_expected,
        "doc_tables_in_live": doc_tables_in_live,
        "doc_tables_missing_in_live": doc_tables_missing_in_live,
        "core_table_presence": {
            t: (t in live_tables)
            for t in [
                "products",
                "tenants",
                "client_product_subscriptions",
                "generation_runs",
                "conversations",
                "turns",
                "quality_metrics",
                "llm_invocations",
            ]
        },
    }

    # Explicit checks against current DOCUMENTATION.md claims
    documented_claims = {
        "tables_migrated": 25,
        "llm_invocations": 25257,
        "prompt_generator_responses": 10464,
        "scenarios": 70,
        "scenario_intents": 50,
        "threat_vectors": 276,
        "personas": 67,
    }

    # Re-connect briefly to get live counts for claimed tables
    load_dotenv(dotenv_path=ROOT / ".env")
    conn = psycopg2.connect(
        host=os.getenv("SUPABASE_HOST"),
        port=os.getenv("SUPABASE_PORT", "5432"),
        dbname=os.getenv("SUPABASE_DB", "postgres"),
        user=os.getenv("SUPABASE_USER"),
        password=os.getenv("SUPABASE_PASSWORD"),
        connect_timeout=10,
    )
    cur = conn.cursor()

    doc_claim_results = {
        "tables_migrated": {
            "documented": documented_claims["tables_migrated"],
            "live_base_tables": live["base_table_count"],
            "matches": (documented_claims["tables_migrated"] == live["base_table_count"]),
        }
    }

    for t in [
        "llm_invocations",
        "prompt_generator_responses",
        "scenarios",
        "scenario_intents",
        "threat_vectors",
        "personas",
    ]:
        if t in live_tables:
            cur.execute(f'SELECT COUNT(*) FROM "{t}"')
            live_count = int(cur.fetchone()[0])
            doc_claim_results[t] = {
                "documented": documented_claims[t],
                "live": live_count,
                "matches": (documented_claims[t] == live_count),
            }
        else:
            doc_claim_results[t] = {
                "documented": documented_claims[t],
                "live": None,
                "matches": False,
            }

    conn.close()
    report["documentation_claim_checks"] = doc_claim_results

    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

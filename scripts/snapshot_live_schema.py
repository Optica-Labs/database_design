#!/usr/bin/env python3
"""Export live Supabase public schema snapshot into versioned repo files."""

from __future__ import annotations

import json
import os
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "verification"
JSON_OUT = OUT_DIR / "LIVE_SCHEMA_SNAPSHOT.json"
MD_OUT = OUT_DIR / "LIVE_SCHEMA_SNAPSHOT.md"


@dataclass
class ColumnInfo:
    name: str
    data_type: str
    is_nullable: bool
    default: str | None
    position: int


def get_conn():
    load_dotenv(dotenv_path=ROOT / ".env")
    host = os.getenv("SUPABASE_HOST")
    port = os.getenv("SUPABASE_PORT", "5432")
    dbname = os.getenv("SUPABASE_DB", "postgres")
    user = os.getenv("SUPABASE_USER")
    password = os.getenv("SUPABASE_PASSWORD")

    missing = [
        k
        for k, v in {
            "SUPABASE_HOST": host,
            "SUPABASE_USER": user,
            "SUPABASE_PASSWORD": password,
        }.items()
        if not v
    ]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password,
        connect_timeout=10,
    )


def fetch_schema_snapshot(conn) -> dict:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT table_name, table_type
            FROM information_schema.tables
            WHERE table_schema = 'public'
            ORDER BY table_name
            """
        )
        table_rows = cur.fetchall()

        cur.execute(
            """
            SELECT
                table_name,
                column_name,
                data_type,
                is_nullable,
                column_default,
                ordinal_position
            FROM information_schema.columns
            WHERE table_schema = 'public'
            ORDER BY table_name, ordinal_position
            """
        )
        column_rows = cur.fetchall()

        cur.execute(
            """
            SELECT
                tc.table_name,
                tc.constraint_name,
                tc.constraint_type
            FROM information_schema.table_constraints tc
            WHERE tc.table_schema = 'public'
            ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name
            """
        )
        constraint_rows = cur.fetchall()

        cur.execute(
            """
            SELECT
                t.relname AS table_name,
                i.relname AS index_name,
                pg_get_indexdef(ix.indexrelid) AS index_def
            FROM pg_class t
            JOIN pg_index ix ON t.oid = ix.indrelid
            JOIN pg_class i ON i.oid = ix.indexrelid
            JOIN pg_namespace n ON n.oid = t.relnamespace
            WHERE n.nspname = 'public'
            ORDER BY t.relname, i.relname
            """
        )
        index_rows = cur.fetchall()

        cur.execute(
            """
            SELECT table_name, view_definition
            FROM information_schema.views
            WHERE table_schema = 'public'
            ORDER BY table_name
            """
        )
        view_rows = cur.fetchall()

    tables = {}
    for table_name, table_type in table_rows:
        tables[table_name] = {
            "table_type": table_type,
            "columns": [],
            "constraints": [],
            "indexes": [],
        }

    for table_name, col_name, data_type, nullable, default, pos in column_rows:
        if table_name in tables:
            tables[table_name]["columns"].append(
                asdict(
                    ColumnInfo(
                        name=col_name,
                        data_type=data_type,
                        is_nullable=(nullable == "YES"),
                        default=default,
                        position=pos,
                    )
                )
            )

    for table_name, constraint_name, constraint_type in constraint_rows:
        if table_name in tables:
            tables[table_name]["constraints"].append(
                {
                    "name": constraint_name,
                    "type": constraint_type,
                }
            )

    for table_name, index_name, index_def in index_rows:
        if table_name in tables:
            tables[table_name]["indexes"].append(
                {
                    "name": index_name,
                    "definition": index_def,
                }
            )

    views = {
        view_name: {"definition": definition}
        for view_name, definition in view_rows
    }

    base_tables = [n for n, d in tables.items() if d["table_type"] == "BASE TABLE"]

    return {
        "captured_at_utc": datetime.now(timezone.utc).isoformat(),
        "schema": "public",
        "summary": {
            "relations": len(tables),
            "base_tables": len(base_tables),
            "views": len(views),
            "columns": sum(len(t["columns"]) for t in tables.values()),
            "constraints": sum(len(t["constraints"]) for t in tables.values()),
            "indexes": sum(len(t["indexes"]) for t in tables.values()),
        },
        "tables": tables,
        "views": views,
    }


def write_markdown(snapshot: dict) -> str:
    lines: list[str] = []
    lines.append("# Live Supabase Public Schema Snapshot")
    lines.append("")
    lines.append(f"Captured (UTC): {snapshot['captured_at_utc']}")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append(f"- Relations: {snapshot['summary']['relations']}")
    lines.append(f"- Base tables: {snapshot['summary']['base_tables']}")
    lines.append(f"- Views: {snapshot['summary']['views']}")
    lines.append(f"- Columns: {snapshot['summary']['columns']}")
    lines.append(f"- Constraints: {snapshot['summary']['constraints']}")
    lines.append(f"- Indexes: {snapshot['summary']['indexes']}")
    lines.append("")
    lines.append("## Tables")
    lines.append("")

    for table_name, table_meta in snapshot["tables"].items():
        if table_meta["table_type"] != "BASE TABLE":
            continue
        lines.append(f"### {table_name}")
        lines.append("")
        lines.append(
            f"Columns: {len(table_meta['columns'])} | Constraints: {len(table_meta['constraints'])} | Indexes: {len(table_meta['indexes'])}"
        )
        lines.append("")
        lines.append("| # | Column | Type | Nullable | Default |")
        lines.append("|---:|---|---|:---:|---|")
        for col in table_meta["columns"]:
            default = (col["default"] or "").replace("|", "\\|")
            lines.append(
                f"| {col['position']} | {col['name']} | {col['data_type']} | {'YES' if col['is_nullable'] else 'NO'} | {default} |"
            )
        lines.append("")

    lines.append("## Views")
    lines.append("")
    if not snapshot["views"]:
        lines.append("No views found in public schema.")
    else:
        for view_name in snapshot["views"].keys():
            lines.append(f"- {view_name}")

    lines.append("")
    lines.append("## Notes")
    lines.append("")
    lines.append(
        "This file is generated by scripts/snapshot_live_schema.py from live Supabase metadata."
    )
    lines.append("Use LIVE_SCHEMA_SNAPSHOT.json for machine-readable full details.")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    conn = get_conn()
    try:
        snapshot = fetch_schema_snapshot(conn)
    finally:
        conn.close()

    JSON_OUT.write_text(json.dumps(snapshot, indent=2), encoding="utf-8")
    MD_OUT.write_text(write_markdown(snapshot), encoding="utf-8")

    print(json.dumps(snapshot["summary"], indent=2))
    print(f"Wrote: {JSON_OUT}")
    print(f"Wrote: {MD_OUT}")


if __name__ == "__main__":
    main()

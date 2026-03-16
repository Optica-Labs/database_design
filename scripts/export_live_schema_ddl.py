#!/usr/bin/env python3
"""Export compact live Supabase DDL (tables + constraints + indexes)."""

from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


ROOT = Path(__file__).resolve().parents[1]
OUT_FILE = ROOT / "docs" / "verification" / "LIVE_SCHEMA_DDL_COMPACT.sql"


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


def q_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def export_ddl(conn) -> str:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT c.oid, c.relname
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public' AND c.relkind = 'r'
            ORDER BY c.relname
            """
        )
        tables = cur.fetchall()

        lines: list[str] = []
        captured_at = datetime.now(timezone.utc).isoformat()
        lines.append("-- Live Supabase compact DDL export")
        lines.append(f"-- Captured (UTC): {captured_at}")
        lines.append("-- Scope: public schema base tables, constraints, non-constraint indexes")
        lines.append("")
        lines.append("SET search_path = public;")
        lines.append("")

        # CREATE TABLE statements
        lines.append("-- ============================================================================")
        lines.append("-- TABLES")
        lines.append("-- ============================================================================")
        lines.append("")

        for table_oid, table_name in tables:
            cur.execute(
                """
                SELECT
                    a.attname,
                    pg_catalog.format_type(a.atttypid, a.atttypmod) AS formatted_type,
                    a.attnotnull,
                    pg_get_expr(ad.adbin, ad.adrelid) AS default_expr
                FROM pg_attribute a
                LEFT JOIN pg_attrdef ad
                       ON ad.adrelid = a.attrelid
                      AND ad.adnum = a.attnum
                WHERE a.attrelid = %s
                  AND a.attnum > 0
                  AND NOT a.attisdropped
                ORDER BY a.attnum
                """,
                (table_oid,),
            )
            cols = cur.fetchall()

            lines.append(f"CREATE TABLE public.{q_ident(table_name)} (")
            col_lines: list[str] = []
            for col_name, col_type, not_null, default_expr in cols:
                col_sql = f"    {q_ident(col_name)} {col_type}"
                if default_expr:
                    col_sql += f" DEFAULT {default_expr}"
                if not_null:
                    col_sql += " NOT NULL"
                col_lines.append(col_sql)
            lines.append(",\n".join(col_lines))
            lines.append(");")
            lines.append("")

        # Constraints
        lines.append("-- ============================================================================")
        lines.append("-- CONSTRAINTS")
        lines.append("-- ============================================================================")
        lines.append("")

        for table_oid, table_name in tables:
            cur.execute(
                """
                SELECT
                    con.conname,
                    pg_get_constraintdef(con.oid, true) AS condef
                FROM pg_constraint con
                WHERE con.conrelid = %s
                  AND con.contype IN ('p', 'u', 'f', 'c')
                ORDER BY con.contype, con.conname
                """,
                (table_oid,),
            )
            constraints = cur.fetchall()
            if not constraints:
                continue

            for con_name, con_def in constraints:
                lines.append(
                    f"ALTER TABLE ONLY public.{q_ident(table_name)} ADD CONSTRAINT {q_ident(con_name)} {con_def};"
                )
            lines.append("")

        # Indexes (excluding indexes backing constraints)
        lines.append("-- ============================================================================")
        lines.append("-- INDEXES")
        lines.append("-- ============================================================================")
        lines.append("")

        cur.execute(
            """
            SELECT c.relname AS table_name,
                   i.relname AS index_name,
                   pg_get_indexdef(ix.indexrelid) AS index_def
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            JOIN pg_index ix ON ix.indrelid = c.oid
            JOIN pg_class i ON i.oid = ix.indexrelid
            LEFT JOIN pg_constraint con ON con.conindid = ix.indexrelid
            WHERE n.nspname = 'public'
              AND c.relkind = 'r'
              AND con.oid IS NULL
            ORDER BY c.relname, i.relname
            """
        )
        indexes = cur.fetchall()

        for _table_name, _index_name, index_def in indexes:
            lines.append(f"{index_def};")

        lines.append("")
        return "\n".join(lines)


def main() -> None:
    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    conn = get_conn()
    try:
        ddl = export_ddl(conn)
    finally:
        conn.close()

    OUT_FILE.write_text(ddl, encoding="utf-8")
    print(f"Wrote: {OUT_FILE}")


if __name__ == "__main__":
    main()

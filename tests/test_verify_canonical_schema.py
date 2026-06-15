"""Tests for the canonical schema verifier."""

from __future__ import annotations

import verify_canonical_schema as vc


def test_parse_canonical_extracts_tables_and_columns() -> None:
    """Table blocks yield their table name and column set."""
    sql = (
        'CREATE TABLE IF NOT EXISTS public."products" (\n'
        '    "id" uuid NOT NULL,\n'
        '    "product_code" text NOT NULL\n'
        ");\n"
    )
    parsed = vc.parse_canonical(sql)
    assert parsed == {"products": {"id", "product_code"}}


def test_expected_from_snapshot_applies_rename_and_filters_views() -> None:
    """Snapshot base tables are renamed; non-base relations are skipped."""
    snapshot = {
        "tables": {
            "alpha_turns": {
                "table_type": "BASE TABLE",
                "columns": [{"name": "id"}, {"name": "product_id"}],
            },
            "vw_x": {"table_type": "VIEW", "columns": [{"name": "id"}]},
        }
    }
    expected = vc.expected_from_snapshot(snapshot)
    assert expected == {"peregrine_turns": {"id", "product_id"}}


def test_diff_reports_missing_extra_and_column_mismatch() -> None:
    """The diff surfaces missing tables, extra tables and column drift."""
    expected = {"a": {"x"}, "b": {"x", "y"}}
    actual = {"b": {"x"}, "c": {"x"}}
    problems = vc.diff(expected, actual)
    assert "missing table: a" in problems
    assert "unexpected table: c" in problems
    assert any("column mismatch in b" in p for p in problems)


def test_diff_clean_when_identical() -> None:
    """Identical schemas produce no problems."""
    schema = {"a": {"x", "y"}}
    assert vc.diff(schema, dict(schema)) == []


def test_verify_real_artifacts_pass() -> None:
    """The committed canonical matches the live snapshot."""
    assert vc.verify() == []


def test_main_returns_zero_on_success(monkeypatch, capsys) -> None:
    """``main`` returns 0 and reports success when there are no problems."""
    monkeypatch.setattr(vc, "verify", lambda: [])
    assert vc.main() == 0
    assert "OK" in capsys.readouterr().out


def test_main_returns_one_on_failure(monkeypatch, capsys) -> None:
    """``main`` returns 1 and prints each problem when verification fails."""
    monkeypatch.setattr(vc, "verify", lambda: ["missing table: a"])
    assert vc.main() == 1
    assert "missing table: a" in capsys.readouterr().out

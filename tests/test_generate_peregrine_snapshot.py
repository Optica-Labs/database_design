"""Tests for the peregrine snapshot oracle generator."""

from __future__ import annotations

import generate_peregrine_snapshot as gps

_LIVE = {
    "summary": {"base_tables": 1},
    "tables": {
        "alpha_turns": {
            "table_type": "BASE TABLE",
            "columns": [
                {"name": "id", "default": "nextval('telemetry_id_seq'::regclass)"}
            ],
        }
    },
    "views": {
        "vw_x": {"definition": " SELECT * FROM alpha_turns"},
    },
}


def test_rename_value_handles_nested_structures() -> None:
    """Nested strings, lists and dicts are all transitioned."""
    value = {"a": "alpha_turns", "b": ["legacy_alpha", 3], "c": 7}
    assert gps._rename_value(value) == {
        "a": "peregrine_turns",
        "b": ["legacy_alpha", 3],
        "c": 7,
    }


def test_build_peregrine_snapshot_renames_keys_and_values() -> None:
    """Table/view keys and their nested identifiers are renamed."""
    out = gps.build_peregrine_snapshot(_LIVE)
    assert "peregrine_turns" in out["tables"]
    assert "alpha_turns" not in out["tables"]
    assert "FROM peregrine_turns" in out["views"]["vw_x"]["definition"]


def test_main_writes_snapshot(tmp_path, monkeypatch, capsys) -> None:
    """``main`` reads the live snapshot and writes the peregrine oracle."""
    live_path = tmp_path / "live.json"
    out_path = tmp_path / "peregrine.json"
    import json

    live_path.write_text(json.dumps(_LIVE), encoding="utf-8")
    monkeypatch.setattr(gps, "LIVE", live_path)
    monkeypatch.setattr(gps, "OUT", out_path)
    gps.main()
    written = json.loads(out_path.read_text(encoding="utf-8"))
    assert "peregrine_turns" in written["tables"]
    assert "wrote" in capsys.readouterr().out


def test_real_peregrine_snapshot_has_no_alpha() -> None:
    """The committed peregrine snapshot contains no alpha identifiers."""
    import json

    snapshot = json.loads(gps.OUT.read_text(encoding="utf-8"))
    assert not any("alpha" in name for name in snapshot["tables"])

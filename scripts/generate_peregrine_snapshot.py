#!/usr/bin/env python3
"""Derive a peregrine-named schema snapshot from the live snapshot.

The live database still uses the legacy ``alpha`` naming convention, so its
verification oracle (``LIVE_SCHEMA_SNAPSHOT.json``) carries ``alpha_*`` names.
This script produces the matching **peregrine-named** oracle that the canonical
create pipeline targets, without any database access -- it transitions every
identifier in the live snapshot through the shared peregrine name map.

Output: ``docs/verification/PEREGRINE_SCHEMA_SNAPSHOT.json``.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from peregrine import rename_identifiers

ROOT = Path(__file__).resolve().parents[1]
LIVE = ROOT / "docs" / "verification" / "LIVE_SCHEMA_SNAPSHOT.json"
OUT = ROOT / "docs" / "verification" / "PEREGRINE_SCHEMA_SNAPSHOT.json"


def _rename_value(value: Any) -> Any:
    """Recursively transition ``alpha`` identifiers in strings/containers."""
    if isinstance(value, str):
        return rename_identifiers(value)
    if isinstance(value, list):
        return [_rename_value(item) for item in value]
    if isinstance(value, dict):
        return {key: _rename_value(val) for key, val in value.items()}
    return value


def build_peregrine_snapshot(live: dict[str, Any]) -> dict[str, Any]:
    """Return a copy of the live snapshot with peregrine-renamed identifiers."""
    snapshot = dict(live)
    snapshot["tables"] = {
        rename_identifiers(name): _rename_value(info)
        for name, info in live["tables"].items()
    }
    snapshot["views"] = {
        rename_identifiers(name): _rename_value(info)
        for name, info in live["views"].items()
    }
    return snapshot


def main() -> None:
    """Write the peregrine-named snapshot oracle to disk."""
    live = json.loads(LIVE.read_text(encoding="utf-8"))
    snapshot = build_peregrine_snapshot(live)
    OUT.write_text(json.dumps(snapshot, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()

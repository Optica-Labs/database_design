#!/usr/bin/env python3
"""Generate project-manager-friendly Mermaid diagrams of the database.

The canonical schema (``sql/create/10_schema_canonical.sql``) is the source of
truth for table names and foreign-key relationships.  The hand-authored
``docs/diagrams/domains.json`` groups every canonical table into a small set of
plain-language functional areas.  This script renders, for a non-technical
audience:

* a system map of the functional areas and how they connect;
* one entity-relationship diagram per area (table names only, no columns);
* a data-lifecycle flow showing how a test moves end to end;
* a tenancy-isolation view showing how customer data stays separated.

Outputs (regenerated, never hand-edited) under ``docs/diagrams/``:
``README.md``, ``00_system_map.md``, ``10_data_lifecycle.md``,
``11_tenancy_isolation.md`` and one ``NN_<area>.md`` per domain.
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterable
from pathlib import Path
from typing import Any, NamedTuple

import generate_canonical_schema as gen

ROOT = Path(__file__).resolve().parents[1]
CANON = ROOT / "sql" / "create" / "10_schema_canonical.sql"
MANIFEST = ROOT / "docs" / "diagrams" / "domains.json"
OUT_DIR = ROOT / "docs" / "diagrams"

_OWNER_RE = re.compile(r'public\."([^"]+)"')
_REFERENCES_RE = re.compile(r"REFERENCES (\w+)")

_GENERATED_NOTE = (
    "<!-- GENERATED FILE -- DO NOT EDIT BY HAND. -->\n"
    "<!-- Regenerate: python3 scripts/generate_db_diagrams.py -->\n"
    "<!-- Groupings: docs/diagrams/domains.json -->"
)

_CARDINALITY = {
    "one-to-many": "||--o{",
    "one-to-optional": "||--o|",
    "many-to-one": "}o--||",
}


class Edge(NamedTuple):
    """A foreign-key relationship: ``owner`` references ``target``."""

    owner: str
    target: str


class Relation(NamedTuple):
    """A curated semantic relationship from ``src`` to ``dst``."""

    src: str
    dst: str
    label: str
    symbol: str


def load_manifest() -> dict[str, Any]:
    """Load the hand-authored domain manifest."""
    data: dict[str, Any] = json.loads(MANIFEST.read_text(encoding="utf-8"))
    return data


def load_relationships(manifest: dict[str, Any]) -> list[Relation]:
    """Load curated semantic relationships declared in the manifest."""
    return [
        Relation(
            rel["from"],
            rel["to"],
            rel["label"],
            _CARDINALITY[rel["cardinality"]],
        )
        for rel in manifest.get("relationships", [])
    ]


def extract_fks(ddl: str) -> list[Edge]:
    """Return every foreign-key edge declared in the canonical DDL."""
    edges: list[Edge] = []
    for line in ddl.splitlines():
        if "FOREIGN KEY" not in line or "REFERENCES" not in line:
            continue
        owner = _OWNER_RE.search(line)
        target = _REFERENCES_RE.search(line)
        if owner and target:
            edges.append(Edge(owner.group(1), target.group(1)))
    return edges


def table_domains(domains: list[dict[str, Any]]) -> dict[str, str]:
    """Map each table name to the id of the domain that owns it."""
    mapping: dict[str, str] = {}
    for dom in domains:
        for table in dom["tables"]:
            mapping[table] = dom["id"]
    return mapping


def _is_visible_edge(src: str | None, dst: str | None, foundation: str) -> bool:
    """Return ``True`` for a cross-domain edge worth drawing on the map."""
    if src is None or dst is None:
        return False
    return src != dst and dst != foundation


def cross_domain_edges(
    edges: list[Edge], mapping: dict[str, str], foundation: str
) -> list[tuple[str, str]]:
    """Return deduped domain-to-domain edges, hiding foundation links."""
    out: set[tuple[str, str]] = set()
    for edge in edges:
        src, dst = mapping.get(edge.owner), mapping.get(edge.target)
        if _is_visible_edge(src, dst, foundation):
            out.add((src, dst))  # type: ignore[arg-type]
    return sorted(out)


def _intra(edge: Edge, members: set[str]) -> bool:
    """Return ``True`` when both ends of an edge live in ``members``."""
    return (
        edge.owner in members
        and edge.target in members
        and edge.owner != edge.target
    )


def domain_edges(edges: list[Edge], tables: list[str]) -> list[tuple[str, str]]:
    """Return deduped ``(target, owner)`` pairs internal to one domain."""
    members = set(tables)
    pairs = {(edge.target, edge.owner) for edge in edges if _intra(edge, members)}
    return sorted(pairs)


def curated_domain_relations(
    relations: list[Relation], tables: list[str]
) -> list[Relation]:
    """Return curated relations whose both endpoints live in ``tables``."""
    members = set(tables)
    return [
        rel for rel in relations if rel.src in members and rel.dst in members
    ]


def curated_cross_domain(
    relations: list[Relation], mapping: dict[str, str], foundation: str
) -> list[tuple[str, str]]:
    """Return deduped domain-to-domain edges from curated relations."""
    out: set[tuple[str, str]] = set()
    for rel in relations:
        src, dst = mapping.get(rel.src), mapping.get(rel.dst)
        if _is_visible_edge(src, dst, foundation):
            out.add((src, dst))  # type: ignore[arg-type]
    return sorted(out)


def domain_links(
    items: Iterable[tuple[str, ...]],
    mapping: dict[str, str],
    domain_id: str,
    foundation: str,
) -> list[str]:
    """Return other domain ids this domain references (excluding foundation)."""
    out: set[str] = set()
    for item in items:
        if mapping.get(item[0]) != domain_id:
            continue
        dst = mapping.get(item[1])
        if dst and dst not in (domain_id, foundation):
            out.add(dst)
    return sorted(out)


def _mermaid(block: str) -> str:
    """Wrap a Mermaid diagram body in a fenced code block."""
    return f"```mermaid\n{block}\n```"


def render_system_map(
    domains: list[dict[str, Any]],
    edges: list[Edge],
    relations: list[Relation],
    mapping: dict[str, str],
    foundation: str,
) -> str:
    """Render the top-level flowchart of functional areas and their links."""
    lines = ["flowchart TD"]
    lines += [f'    {dom["id"]}["{dom["label"]}"]' for dom in domains]
    fk = cross_domain_edges(edges, mapping, foundation)
    curated = curated_cross_domain(relations, mapping, foundation)
    lines += [f"    {src} --> {dst}" for src, dst in sorted(set(fk) | set(curated))]
    lines.append(f"    class {foundation} foundation")
    lines.append(
        "    classDef foundation fill:#dfe7ff,stroke:#3355aa,stroke-width:2px"
    )
    return _mermaid("\n".join(lines))


def render_domain_er(
    dom: dict[str, Any], edges: list[Edge], relations: list[Relation]
) -> str:
    """Render an entity-relationship diagram for one domain (names only)."""
    lines = ["erDiagram"]
    for table in sorted(dom["tables"]):
        lines.append(f"    {table} {{")
        lines.append("    }")
    for target, owner in domain_edges(edges, dom["tables"]):
        lines.append(f'    {target} ||--o{{ {owner} : "1-to-many"')
    for rel in curated_domain_relations(relations, dom["tables"]):
        lines.append(f'    {rel.src} {rel.symbol} {rel.dst} : "{rel.label}"')
    return _mermaid("\n".join(lines))


def build_index(domains: list[dict[str, Any]]) -> str:
    """Render the diagrams README / index page."""
    areas = "\n".join(
        f'- [{dom["label"]}]({dom["file"]}.md) — {dom["blurb"]}'
        for dom in domains
    )
    return (
        f"{_GENERATED_NOTE}\n\n"
        "# Database Diagrams\n\n"
        "Plain-language, regenerated maps of the testing database "
        "(94 tables across 9 functional areas).\n\n"
        "## Start here\n"
        "1. [System Map](00_system_map.md) — the nine areas and how they connect.\n"
        "2. [Data Lifecycle](10_data_lifecycle.md) — how a test flows end to end.\n"
        "3. [Tenancy & Isolation](11_tenancy_isolation.md) — how customer data "
        "stays separated.\n\n"
        "## Functional areas\n"
        f"{areas}\n\n"
        "## How to read these\n"
        "- Each box is a database table.\n"
        '- A connector `A ||--o{ B` means "one A relates to many B".\n'
        "- Most connectors come from real foreign keys; a few labelled ones "
        "(e.g. \"gold subset\", \"logs payloads to\") capture curated relationships "
        "declared in `domains.json`.\n"
        "- Every area is scoped by **Platform & Tenancy** (product + tenant); "
        "those links are summarized rather than drawn on every diagram.\n\n"
        "## Regenerate\n"
        "These files are generated. Edit the groupings in "
        "`docs/diagrams/domains.json`, then run "
        "`python3 scripts/generate_db_diagrams.py`.\n"
    )


def build_system_doc(
    domains: list[dict[str, Any]],
    edges: list[Edge],
    relations: list[Relation],
    mapping: dict[str, str],
    foundation: str,
) -> str:
    """Render the system-map document."""
    return (
        f"{_GENERATED_NOTE}\n\n"
        "# System Map\n\n"
        "> The nine functional areas of the database and the main relationships "
        "between them. Every area is also scoped by Platform & Tenancy "
        "(highlighted); those universal links are omitted here for clarity — see "
        "[Tenancy & Isolation](11_tenancy_isolation.md).\n\n"
        f"{render_system_map(domains, edges, relations, mapping, foundation)}\n"
    )


def build_domain_doc(
    dom: dict[str, Any],
    edges: list[Edge],
    relations: list[Relation],
    mapping: dict[str, str],
    id_to_label: dict[str, str],
    foundation: str,
) -> str:
    """Render one per-domain entity-relationship document."""
    items: list[tuple[str, ...]] = [*edges, *relations]
    links = domain_links(items, mapping, dom["id"], foundation)
    if links:
        labels = ", ".join(id_to_label[link] for link in links)
        connections = f"**Connects to:** {labels}"
    else:
        connections = "_Self-contained area (only linked to Platform & Tenancy)._"
    return (
        f"{_GENERATED_NOTE}\n\n"
        f'# {dom["label"]}\n\n'
        f'> {dom["blurb"]}\n\n'
        f"{render_domain_er(dom, edges, relations)}\n\n"
        f"{connections}\n"
    )


def build_lifecycle_doc() -> str:
    """Render the curated end-to-end data-lifecycle flow."""
    flow = (
        "flowchart LR\n"
        "    p[Personas & Traits] --> s[Scenarios & Prompts]\n"
        "    s --> t[Test Execution]\n"
        "    t --> o[Model Outputs]\n"
        "    o --> sa[Safety & Risk Assessment]\n"
        "    sa --> an[Peregrine Analysis & Reporting]"
    )
    return (
        f"{_GENERATED_NOTE}\n\n"
        "# Data Lifecycle\n\n"
        "> How information flows through one round of testing, from defining who "
        "we simulate to the final analysis a stakeholder reads.\n\n"
        f"{_mermaid(flow)}\n"
    )


def build_tenancy_doc(domains: list[dict[str, Any]], foundation: str) -> str:
    """Render the curated multi-tenancy / product-isolation view."""
    others = [dom for dom in domains if dom["id"] != foundation]
    rows = "\n".join(f"    scope --> {dom['id']}" for dom in others)
    nodes = "\n".join(f'    {dom["id"]}["{dom["label"]}"]' for dom in others)
    flow = (
        "flowchart TD\n"
        '    tenants["Tenants (customers)"] --> scope\n'
        '    products["Products"] --> scope\n'
        '    scope["Every record carries tenant_id + product_id"]\n'
        f"{nodes}\n"
        f"{rows}"
    )
    return (
        f"{_GENERATED_NOTE}\n\n"
        "# Tenancy & Isolation\n\n"
        "> How customer data is kept separate. Tenants and products form a "
        "boundary: every record in every area is tagged with both, so one "
        "customer's data is never mixed with another's.\n\n"
        f"{_mermaid(flow)}\n"
    )


def generate() -> dict[Path, str]:
    """Compute every generated diagram document keyed by its output path."""
    manifest = load_manifest()
    domains = manifest["domains"]
    foundation = manifest["foundation"]
    edges = extract_fks(gen.read_text(CANON))
    relations = load_relationships(manifest)
    mapping = table_domains(domains)
    id_to_label = {dom["id"]: dom["label"] for dom in domains}
    out: dict[Path, str] = {
        OUT_DIR / "README.md": build_index(domains),
        OUT_DIR / "00_system_map.md": build_system_doc(
            domains, edges, relations, mapping, foundation
        ),
        OUT_DIR / "10_data_lifecycle.md": build_lifecycle_doc(),
        OUT_DIR / "11_tenancy_isolation.md": build_tenancy_doc(domains, foundation),
    }
    for dom in domains:
        out[OUT_DIR / f'{dom["file"]}.md'] = build_domain_doc(
            dom, edges, relations, mapping, id_to_label, foundation
        )
    return out


def main() -> None:
    """Write every generated diagram document to disk."""
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for path, content in generate().items():
        path.write_text(content, encoding="utf-8")
        print(f"wrote {path}")


if __name__ == "__main__":
    main()

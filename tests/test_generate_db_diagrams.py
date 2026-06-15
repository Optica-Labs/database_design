"""Tests for the PM-facing Mermaid diagram generator."""

from __future__ import annotations

from pathlib import Path

import generate_db_diagrams as gd

_DDL = (
    'ALTER TABLE ONLY public."personas" ADD CONSTRAINT a '
    "FOREIGN KEY (product_id) REFERENCES products(id);\n"
    'ALTER TABLE ONLY public."persona_actions" ADD CONSTRAINT b '
    "FOREIGN KEY (persona_id) REFERENCES personas(id);\n"
    'ALTER TABLE ONLY public."personas" ADD CONSTRAINT c '
    "FOREIGN KEY (cohort_id) REFERENCES cohorts(id);\n"
    'ALTER TABLE ONLY public."scenarios" ADD CONSTRAINT d '
    "FOREIGN KEY (persona_id) REFERENCES personas(id);\n"
    "ALTER TABLE malformed FOREIGN KEY (a) REFERENCES nowhere(id);\n"
    "CREATE INDEX idx ON public.personas USING btree (id);"
)

_DOMAINS = [
    {
        "id": "platform_tenancy",
        "label": "Platform & Tenancy",
        "file": "01_platform",
        "blurb": "Foundation.",
        "tables": ["products"],
    },
    {
        "id": "personas",
        "label": "Personas",
        "file": "02_personas",
        "blurb": "People.",
        "tables": ["personas", "persona_actions", "cohorts"],
    },
    {
        "id": "scenarios",
        "label": "Scenarios",
        "file": "03_scenarios",
        "blurb": "Situations.",
        "tables": ["scenarios"],
    },
]
_MAPPING = {
    "products": "platform_tenancy",
    "personas": "personas",
    "persona_actions": "personas",
    "cohorts": "personas",
    "scenarios": "scenarios",
}
_LABELS = {dom["id"]: dom["label"] for dom in _DOMAINS}
_RELATIONS = [
    gd.Relation("cohorts", "personas", "groups", "||--o|"),
    gd.Relation("scenarios", "persona_actions", "drives", "||--o{"),
]


def test_extract_fks_parses_owner_and_target() -> None:
    """Foreign-key lines yield owner/target edges; other lines are ignored."""
    edges = gd.extract_fks(_DDL)
    assert gd.Edge("personas", "products") in edges
    assert gd.Edge("persona_actions", "personas") in edges
    assert all(isinstance(edge, gd.Edge) for edge in edges)
    assert len(edges) == 4


def test_table_domains_maps_every_table() -> None:
    """Every table is mapped to the id of its owning domain."""
    mapping = gd.table_domains(_DOMAINS)
    assert mapping["persona_actions"] == "personas"
    assert mapping["products"] == "platform_tenancy"


def test_is_visible_edge_rules() -> None:
    """Only cross-domain edges that avoid the foundation are visible."""
    assert gd._is_visible_edge("a", "b", "f") is True
    assert gd._is_visible_edge("a", "a", "f") is False
    assert gd._is_visible_edge("a", "f", "f") is False
    assert gd._is_visible_edge(None, "b", "f") is False
    assert gd._is_visible_edge("a", None, "f") is False


def test_cross_domain_edges_dedupe_and_hide_foundation() -> None:
    """Foundation links are hidden and duplicate edges collapse to one."""
    edges = gd.extract_fks(_DDL)
    result = gd.cross_domain_edges(edges, _MAPPING, "platform_tenancy")
    assert ("scenarios", "personas") in result
    assert all(dst != "platform_tenancy" for _, dst in result)
    assert len(result) == len(set(result))


def test_intra_helper() -> None:
    """``_intra`` is true only when both ends share a domain and differ."""
    members = {"personas", "persona_actions"}
    assert gd._intra(gd.Edge("persona_actions", "personas"), members) is True
    assert gd._intra(gd.Edge("personas", "personas"), members) is False
    assert gd._intra(gd.Edge("personas", "products"), members) is False


def test_domain_edges_internal_only() -> None:
    """Only relationships internal to the domain are returned."""
    edges = gd.extract_fks(_DDL)
    result = gd.domain_edges(edges, ["personas", "persona_actions", "cohorts"])
    assert ("personas", "persona_actions") in result
    assert ("cohorts", "personas") in result
    assert all("products" not in pair for pair in result)


def test_domain_links_excludes_self_and_foundation() -> None:
    """Outbound links skip the domain's own id and the foundation."""
    edges = gd.extract_fks(_DDL)
    links = gd.domain_links(edges, _MAPPING, "scenarios", "platform_tenancy")
    assert links == ["personas"]
    foundation_only = gd.domain_links(
        edges, _MAPPING, "personas", "platform_tenancy"
    )
    assert foundation_only == []


def test_load_relationships_maps_cardinality_to_symbol() -> None:
    """Manifest relationships become ``Relation`` tuples with mermaid symbols."""
    manifest = {
        "relationships": [
            {
                "from": "a",
                "to": "b",
                "label": "feeds",
                "cardinality": "one-to-many",
            }
        ]
    }
    rels = gd.load_relationships(manifest)
    assert rels == [gd.Relation("a", "b", "feeds", "||--o{")]
    assert gd.load_relationships({}) == []


def test_curated_domain_relations_intra_only() -> None:
    """Only relations with both endpoints in the domain are kept."""
    out = gd.curated_domain_relations(
        _RELATIONS, ["personas", "persona_actions", "cohorts"]
    )
    assert gd.Relation("cohorts", "personas", "groups", "||--o|") in out
    assert all(rel.src != "scenarios" for rel in out)


def test_curated_cross_domain_hides_foundation_and_dedupes() -> None:
    """Curated cross-domain edges skip foundation targets and self-links."""
    out = gd.curated_cross_domain(_RELATIONS, _MAPPING, "platform_tenancy")
    assert ("scenarios", "personas") in out
    assert len(out) == len(set(out))


def test_render_system_map_has_nodes_edges_and_foundation() -> None:
    """The system map renders nodes, a cross-domain edge and the foundation."""
    edges = gd.extract_fks(_DDL)
    out = gd.render_system_map(
        _DOMAINS, edges, _RELATIONS, _MAPPING, "platform_tenancy"
    )
    assert "```mermaid" in out
    assert 'personas["Personas"]' in out
    assert "scenarios --> personas" in out
    assert "class platform_tenancy foundation" in out


def test_render_domain_er_lists_tables_and_relationship() -> None:
    """A per-domain ER lists every table and intra-domain relationship."""
    edges = gd.extract_fks(_DDL)
    out = gd.render_domain_er(_DOMAINS[1], edges, _RELATIONS)
    assert "erDiagram" in out
    assert "persona_actions {" in out
    assert "personas ||--o{ persona_actions" in out
    assert 'cohorts ||--o| personas : "groups"' in out


def test_build_domain_doc_with_and_without_links() -> None:
    """Domain docs show connections, or note self-containment when none."""
    edges = gd.extract_fks(_DDL)
    linked = gd.build_domain_doc(
        _DOMAINS[2], edges, _RELATIONS, _MAPPING, _LABELS, "platform_tenancy"
    )
    assert "**Connects to:** Personas" in linked
    self_contained = gd.build_domain_doc(
        _DOMAINS[1], [], [], _MAPPING, _LABELS, "platform_tenancy"
    )
    assert "Self-contained area" in self_contained


def test_build_index_lists_every_area() -> None:
    """The index links each functional area with its blurb."""
    out = gd.build_index(_DOMAINS)
    assert "# Database Diagrams" in out
    assert "[Personas](02_personas.md)" in out


def test_build_system_doc_embeds_map() -> None:
    """The system document embeds the rendered map."""
    edges = gd.extract_fks(_DDL)
    out = gd.build_system_doc(
        _DOMAINS, edges, _RELATIONS, _MAPPING, "platform_tenancy"
    )
    assert "# System Map" in out
    assert "flowchart TD" in out


def test_build_lifecycle_doc_is_curated_flow() -> None:
    """The lifecycle document is a left-to-right curated flow."""
    out = gd.build_lifecycle_doc()
    assert "# Data Lifecycle" in out
    assert "flowchart LR" in out


def test_build_tenancy_doc_scopes_every_non_foundation_area() -> None:
    """The tenancy view fans the scope node out to every other area."""
    out = gd.build_tenancy_doc(_DOMAINS, "platform_tenancy")
    assert "# Tenancy & Isolation" in out
    assert "scope --> personas" in out
    assert "scope --> platform_tenancy" not in out


def test_manifest_covers_every_canonical_table_exactly_once() -> None:
    """The committed manifest partitions all 94 canonical tables."""
    manifest = gd.load_manifest()
    mapped: list[str] = []
    for dom in manifest["domains"]:
        mapped.extend(dom["tables"])
    canonical = set(gd.gen.extract_table_names(gd.gen.read_text(gd.CANON)))
    assert len(mapped) == len(set(mapped))
    assert set(mapped) == canonical


def test_manifest_relationships_reference_real_tables() -> None:
    """Every committed curated relationship targets canonical tables."""
    manifest = gd.load_manifest()
    canonical = set(gd.gen.extract_table_names(gd.gen.read_text(gd.CANON)))
    relations = gd.load_relationships(manifest)
    assert relations, "expected curated relationships in the manifest"
    for rel in relations:
        assert rel.src in canonical
        assert rel.dst in canonical


def test_generate_produces_expected_files_without_legacy_names() -> None:
    """``generate`` yields one file per area plus the four special docs."""
    artifacts = gd.generate()
    names = {path.name for path in artifacts}
    assert "README.md" in names
    assert "00_system_map.md" in names
    assert "10_data_lifecycle.md" in names
    assert "11_tenancy_isolation.md" in names
    assert "08_peregrine_analysis.md" in names
    for body in artifacts.values():
        lowered = body.lower()
        assert "alpha" not in lowered
        assert "nexus" not in lowered


def test_main_writes_files(
    tmp_path: Path, monkeypatch, capsys
) -> None:
    """``main`` writes every generated document under the output directory."""
    monkeypatch.setattr(gd, "OUT_DIR", tmp_path)
    gd.main()
    written = {path.name for path in tmp_path.glob("*.md")}
    assert "README.md" in written
    assert "01_platform_tenancy.md" in written
    assert "wrote" in capsys.readouterr().out

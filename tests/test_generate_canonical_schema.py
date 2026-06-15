"""Tests for the canonical schema generator."""

from __future__ import annotations

import generate_canonical_schema as gen

_SAMPLE_DDL = (
    "SET search_path = public;\n"
    "\n"
    "-- ==========================================================================\n"
    "-- TABLES\n"
    "-- ==========================================================================\n"
    "\n"
    'CREATE TABLE public."alpha_turns" (\n'
    "    \"id\" bigint DEFAULT nextval('telemetry_id_seq'::regclass) NOT NULL,\n"
    '    "product_id" uuid NOT NULL\n'
    ");\n"
    "\n"
    'CREATE TABLE public."products" (\n'
    '    "id" uuid NOT NULL\n'
    ");\n"
    "\n"
    "-- ==========================================================================\n"
    "-- CONSTRAINTS\n"
    "-- ==========================================================================\n"
    "\n"
    'ALTER TABLE ONLY public."alpha_turns" ADD CONSTRAINT "alpha_turns_pkey" '
    "PRIMARY KEY (id);\n"
    "\n"
    "-- ==========================================================================\n"
    "-- INDEXES\n"
    "-- ==========================================================================\n"
    "\n"
    "CREATE INDEX idx_alpha_turns_product ON public.alpha_turns "
    "USING btree (product_id);\n"
)


def test_parse_sections_splits_three_bodies() -> None:
    """The DDL is split into TABLES, CONSTRAINTS and INDEXES bodies."""
    sections = gen.parse_sections(_SAMPLE_DDL)
    assert set(sections) == {"TABLES", "CONSTRAINTS", "INDEXES"}
    assert "CREATE TABLE" in sections["TABLES"]
    assert "ADD CONSTRAINT" in sections["CONSTRAINTS"]
    assert "CREATE INDEX" in sections["INDEXES"]


def test_extract_sequences_is_sorted_and_unique() -> None:
    """Referenced sequences are returned sorted and de-duplicated."""
    ddl = (
        "nextval('b_seq'::regclass) nextval('a_seq'::regclass) "
        "nextval('a_seq'::regclass)"
    )
    assert gen.extract_sequences(ddl) == ["a_seq", "b_seq"]


def test_extract_table_names_in_order() -> None:
    """Table names are returned in declaration order, quoted or not."""
    assert gen.extract_table_names(_SAMPLE_DDL) == ["alpha_turns", "products"]


def test_build_sequence_ddl_is_idempotent() -> None:
    """Sequence DDL uses ``IF NOT EXISTS``."""
    assert gen.build_sequence_ddl(["a_seq"]) == (
        "CREATE SEQUENCE IF NOT EXISTS public.a_seq;"
    )


def test_idempotent_tables_and_indexes() -> None:
    """Tables and indexes gain ``IF NOT EXISTS`` clauses."""
    assert gen.idempotent_tables('CREATE TABLE public."x" (') == (
        'CREATE TABLE IF NOT EXISTS public."x" ('
    )
    indexed = gen.idempotent_indexes("CREATE INDEX i ON public.x (a);")
    assert indexed == "CREATE INDEX IF NOT EXISTS i ON public.x (a);"
    unique = gen.idempotent_indexes("CREATE UNIQUE INDEX i ON public.x (a);")
    assert unique == "CREATE UNIQUE INDEX IF NOT EXISTS i ON public.x (a);"


def test_idempotent_constraints_wraps_alters() -> None:
    """Each ``ALTER TABLE`` constraint is wrapped in a guarded DO block."""
    out = gen.idempotent_constraints(
        'ALTER TABLE ONLY public."x" ADD CONSTRAINT "x_pkey" PRIMARY KEY (id);'
    )
    assert out.startswith("DO $$ BEGIN")
    assert "WHEN duplicate_object THEN NULL;" in out
    assert out.endswith("END $$;")


def test_build_canonical_renames_and_is_idempotent() -> None:
    """The canonical build renames alpha and emits idempotent statements."""
    out = gen.build_canonical(_SAMPLE_DDL)
    assert "alpha_turns" not in out
    assert "peregrine_turns" in out
    assert "CREATE TABLE IF NOT EXISTS" in out
    assert "CREATE SEQUENCE IF NOT EXISTS public.telemetry_id_seq;" in out
    assert "CREATE INDEX IF NOT EXISTS idx_peregrine_turns_product" in out
    assert "DO $$ BEGIN" in out


def test_build_views_renames_definitions() -> None:
    """View definitions are emitted with the peregrine rename applied."""
    snapshot = {
        "views": {
            "vw_x": {"definition": " SELECT * FROM alpha_turns"},
        }
    }
    out = gen.build_views(snapshot)
    assert "CREATE OR REPLACE VIEW public.vw_x AS" in out
    assert "FROM peregrine_turns" in out
    assert "alpha_turns" not in out


def test_build_reset_drops_views_tables_sequences() -> None:
    """The reset script drops views, tables and sequences."""
    out = gen.build_reset(["peregrine_turns"], ["a_seq"], ["vw_x"])
    assert "DROP VIEW IF EXISTS public.vw_x CASCADE;" in out
    assert 'DROP TABLE IF EXISTS public."peregrine_turns" CASCADE;' in out
    assert "DROP SEQUENCE IF EXISTS public.a_seq CASCADE;" in out


def test_generate_produces_three_artifacts() -> None:
    """``generate`` returns the three expected output paths."""
    artifacts = gen.generate()
    names = {path.name for path in artifacts}
    assert names == {"10_schema_canonical.sql", "20_views.sql", "reset.sql"}


def test_generated_canonical_has_no_residual_alpha() -> None:
    """The real generated canonical contains no ``alpha`` identifiers."""
    artifacts = gen.generate()
    canonical = next(
        body for path, body in artifacts.items() if path.name.endswith("canonical.sql")
    )
    assert "alpha" not in canonical.lower()
    assert canonical.count("CREATE TABLE IF NOT EXISTS") == 94


def test_main_writes_artifacts(tmp_path, monkeypatch, capsys) -> None:
    """``main`` writes every artifact under the output directory."""
    monkeypatch.setattr(gen, "OUT_DIR", tmp_path / "create")
    gen.main()
    written = {path.name for path in (tmp_path / "create").iterdir()}
    assert written == {"10_schema_canonical.sql", "20_views.sql", "reset.sql"}
    assert "wrote" in capsys.readouterr().out

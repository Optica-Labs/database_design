"""Tests for the product-variant generator."""

from __future__ import annotations

import generate_variants as gv

_SECTIONS = {
    "TABLES": (
        'CREATE TABLE public."products" (\n'
        '    "id" uuid NOT NULL\n'
        ");\n"
        "\n"
        'CREATE TABLE public."peregrine_turns" (\n'
        "    \"id\" bigint DEFAULT nextval('telemetry_id_seq'::regclass) NOT NULL,\n"
        '    "product_id" uuid NOT NULL\n'
        ");\n"
        "\n"
        'CREATE TABLE public."excluded" (\n'
        '    "id" uuid NOT NULL\n'
        ");"
    ),
    "CONSTRAINTS": (
        'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT '
        '"peregrine_turns_pkey" PRIMARY KEY (id);\n'
        'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT '
        '"peregrine_turns_product_fkey" FOREIGN KEY (product_id) '
        "REFERENCES products(id);\n"
        'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT '
        '"peregrine_turns_excluded_fkey" FOREIGN KEY (x) REFERENCES excluded(id);\n'
        'ALTER TABLE ONLY public."excluded" ADD CONSTRAINT "excluded_pkey" '
        "PRIMARY KEY (id);"
    ),
    "INDEXES": (
        "CREATE INDEX idx_turns ON public.peregrine_turns USING btree (product_id);\n"
        "CREATE INDEX idx_excluded ON public.excluded USING btree (id);"
    ),
}
_KEEP = {"products", "peregrine_turns"}


def test_load_manifests_skips_comment_keys() -> None:
    """Manifest loading returns sets keyed by variant, ignoring comments."""
    manifests = gv.load_manifests()
    assert "ai_range" in manifests
    assert "peregrine" in manifests
    assert all(isinstance(v, set) for v in manifests.values())


def test_select_tables_keeps_only_requested() -> None:
    """Only requested table blocks are returned."""
    out = gv.select_tables(_SECTIONS["TABLES"], _KEEP)
    assert "peregrine_turns" in out
    assert "products" in out
    assert "excluded" not in out


def test_keep_constraint_rules() -> None:
    """Constraints stay only when owner and any FK target are in the subset."""
    pk = 'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT a PRIMARY KEY (id);'
    fk_in = (
        'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT b '
        "FOREIGN KEY (product_id) REFERENCES products(id);"
    )
    fk_out = (
        'ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT c '
        "FOREIGN KEY (x) REFERENCES excluded(id);"
    )
    owner_out = 'ALTER TABLE ONLY public."excluded" ADD CONSTRAINT d PRIMARY KEY (id);'
    assert gv.keep_constraint(pk, _KEEP) is True
    assert gv.keep_constraint(fk_in, _KEEP) is True
    assert gv.keep_constraint(fk_out, _KEEP) is False
    assert gv.keep_constraint(owner_out, _KEEP) is False


def test_select_constraints_drops_dangling_fk() -> None:
    """The FK to an excluded table is dropped from the subset."""
    out = gv.select_constraints(_SECTIONS["CONSTRAINTS"], _KEEP)
    assert "peregrine_turns_pkey" in out
    assert "peregrine_turns_product_fkey" in out
    assert "excluded" not in out


def test_select_indexes_keeps_only_subset() -> None:
    """Only indexes on included tables are returned."""
    out = gv.select_indexes(_SECTIONS["INDEXES"], _KEEP)
    assert "idx_turns" in out
    assert "idx_excluded" not in out


def test_build_variant_is_idempotent_and_scoped() -> None:
    """A built variant is idempotent and limited to the kept tables."""
    out = gv.build_variant(_SECTIONS, _KEEP)
    assert "CREATE TABLE IF NOT EXISTS" in out
    assert "CREATE SEQUENCE IF NOT EXISTS public.telemetry_id_seq;" in out
    assert "DO $$ BEGIN" in out
    assert "excluded" not in out


def test_generate_real_variants_have_no_dangling_fk() -> None:
    """The committed variants are self-contained with no dangling FK targets."""
    import re

    artifacts = gv.generate()
    assert {path.name for path in artifacts} == {
        "ai_range_only.sql",
        "peregrine_only.sql",
    }
    for body in artifacts.values():
        tables = set(re.findall(r'CREATE TABLE IF NOT EXISTS public\."([^"]+)"', body))
        refs = set(re.findall(r"REFERENCES (\w+)", body))
        assert refs <= tables
        assert "alpha" not in body.lower()


def test_main_writes_variants(tmp_path, monkeypatch, capsys) -> None:
    """``main`` writes one file per manifest variant."""
    monkeypatch.setattr(gv, "OUT_DIR", tmp_path)
    gv.main()
    written = {path.name for path in tmp_path.iterdir() if path.suffix == ".sql"}
    assert written == {"ai_range_only.sql", "peregrine_only.sql"}
    assert "wrote" in capsys.readouterr().out

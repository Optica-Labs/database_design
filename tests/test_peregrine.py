"""Tests for the alpha -> peregrine naming-transition helpers."""

from __future__ import annotations

import peregrine


def test_rename_live_table_prefix() -> None:
    """The 13 live ``alpha_*`` tables transition to ``peregrine_*``."""
    assert peregrine.rename_identifiers("alpha_turns") == "peregrine_turns"
    assert peregrine.rename_identifiers('public."alpha_conversations"') == (
        'public."peregrine_conversations"'
    )


def test_rename_index_names() -> None:
    """Index names embedding ``alpha_`` transition too."""
    assert peregrine.rename_identifiers("idx_alpha_turns_active") == (
        "idx_peregrine_turns_active"
    )


def test_rename_is_order_safe() -> None:
    """A mixed string transitions every alpha form exactly once."""
    text = "alpha_turns and idx_alpha_x"
    assert peregrine.rename_identifiers(text) == (
        "peregrine_turns and idx_peregrine_x"
    )


def test_rename_leaves_unrelated_text_untouched() -> None:
    """Words that merely contain ``alpha`` without the ``_`` are not changed."""
    assert peregrine.rename_identifiers("alphabet alphanumeric") == (
        "alphabet alphanumeric"
    )


def test_rename_display_name() -> None:
    """The product display name transitions while identifiers are untouched."""
    assert peregrine.rename_display("Alpha Platform") == (
        "Peregrine Platform"
    )
    assert peregrine.rename_display("alpha_turns") == "alpha_turns"

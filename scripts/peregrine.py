#!/usr/bin/env python3
"""Alpha to Peregrine naming-transition helpers.

The live database historically used the ``alpha`` naming convention:

* ``alpha_*`` base tables (and matching ``idx_alpha_*`` indexes) in the
  ``public`` schema.
* legacy alpha-era names in historical metadata.

These helpers apply the canonical ``peregrine`` transition.  Identifier and
display transitions are kept separate so SQL artifacts are never accidentally
rewritten with prose substitutions (and vice versa).
"""

from __future__ import annotations

# Ordered identifier replacements.
_IDENTIFIER_REPLACEMENTS: tuple[tuple[str, str], ...] = (
    ("alpha_", "peregrine_"),
)

# Prose / product display-name replacements.
_DISPLAY_REPLACEMENTS: tuple[tuple[str, str], ...] = (
    ("Alpha", "Peregrine"),
)


def rename_identifiers(text: str) -> str:
    """Transition ``alpha`` SQL identifiers to their ``peregrine`` equivalents."""
    for old, new in _IDENTIFIER_REPLACEMENTS:
        text = text.replace(old, new)
    return text


def rename_display(text: str) -> str:
    """Transition alpha-era display labels to ``Peregrine``."""
    for old, new in _DISPLAY_REPLACEMENTS:
        text = text.replace(old, new)
    return text

#!/usr/bin/env python3

"""PySide6 adapter for the QtShadcn QML components."""

from __future__ import annotations

from .capability import (
    IconRegistry,
    ThemeManager,
    qtshadcn_import_path,
    register_types,
)

__all__ = [
    "IconRegistry",
    "ThemeManager",
    "qtshadcn_import_path",
    "register_types",
    "setup",
]

__version__ = "0.1.0"


def setup(engine) -> None:
    """Add the QtShadcn QML import path and register its singleton types."""
    engine.addImportPath(qtshadcn_import_path())
    register_types("QtShadcn")

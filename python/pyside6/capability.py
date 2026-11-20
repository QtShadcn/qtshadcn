#!/usr/bin/env python3

"""PySide6 implementations of the QtShadcn QML singleton types."""

from __future__ import annotations

import os

from PySide6.QtCore import Property, QObject, Signal, Slot
from PySide6.QtGui import QColor
from PySide6.QtQml import qmlRegisterSingletonType

from .common import RESOURCE_DIR
from .common.icons import icon_data_url, load_icons
from .common.theme import build_theme_tokens

_RESOURCE_DIR = RESOURCE_DIR
_ICON_DIR = _RESOURCE_DIR / "icons"


def qtshadcn_import_path() -> str:
    """Return the parent directory of the QtShadcn QML module."""
    return str(_RESOURCE_DIR)


class ThemeManager(QObject):
    """Expose theme tokens to QML as a singleton."""

    modeChanged = Signal()
    primaryChanged = Signal()
    tokensChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._mode = "light"
        self._primary = ""
        self._tokens: dict[str, object] = {}
        self._rebuild()

    def _get_mode(self) -> str:
        return self._mode

    def _set_mode(self, mode: str) -> None:
        normalized = "dark" if mode == "dark" else "light"
        if self._mode == normalized:
            return
        self._mode = normalized
        self._rebuild()
        self.modeChanged.emit()

    mode = Property(str, fget=_get_mode, fset=_set_mode, notify=modeChanged)

    def _get_primary(self) -> str:
        return self._primary

    def _set_primary(self, color: str) -> None:
        if self._primary == color:
            return
        self._primary = color or ""
        self._rebuild()
        self.primaryChanged.emit()

    primary = Property(str, fget=_get_primary, fset=_set_primary, notify=primaryChanged)

    def _get_tokens(self) -> dict[str, object]:
        return self._tokens

    tokens = Property("QVariant", fget=_get_tokens, notify=tokensChanged)

    @Slot(str, result="QVariant")
    def token(self, name: str) -> object:
        return self._tokens.get(name)

    @Slot(result=bool)
    def screenshotMode(self) -> bool:
        return os.environ.get("QTSHADCN_SCREENSHOT") == "1"

    def _rebuild(self) -> None:
        primary_color = self._primary or ("#fafafa" if self._mode == "dark" else "#18181b")
        color = QColor(primary_color)
        luminance = 0.299 * color.redF() + 0.587 * color.greenF() + 0.114 * color.blueF()
        primary_foreground = "#18181b" if luminance > 0.5 else "#fafafa"
        self._tokens = build_theme_tokens(self._mode, primary_color, primary_foreground)
        self.tokensChanged.emit()


class IconRegistry(QObject):
    """Expose bundled icon data URLs to QML as a singleton."""

    iconsChanged = Signal()
    remoteEnabledChanged = Signal()
    iconReady = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._remote_enabled = True
        self._icons = load_icons(_ICON_DIR)

    def _get_is_remote_enabled(self) -> bool:
        return self._remote_enabled

    def _set_remote_enabled(self, enabled: bool) -> None:
        if self._remote_enabled == enabled:
            return
        self._remote_enabled = enabled
        self.remoteEnabledChanged.emit()

    remoteEnabled = Property(
        bool,
        fget=_get_is_remote_enabled,
        fset=_set_remote_enabled,
        notify=remoteEnabledChanged,
    )

    def _get_names(self) -> list[str]:
        return sorted(self._icons.keys(), key=str.lower)

    names = Property(list, fget=_get_names, notify=iconsChanged)

    @Slot(str, result=bool)
    def has(self, name: str) -> bool:
        return name in self._icons

    @Slot(str, str, result=str)
    def dataUrl(self, name: str, color: str | None = None) -> str:
        svg = self._icons.get(name, "")
        if not svg:
            return ""
        value = QColor(color) if color else QColor("#000000")
        color_value = value.name(QColor.NameFormat.HexRgb) if value.isValid() else "#000000"
        return icon_data_url(svg, color_value)


def register_types(engine_uri: str = "QtShadcn") -> None:
    """Register the ThemeManager and IconRegistry singleton types with QML."""
    qmlRegisterSingletonType(
        ThemeManager,
        engine_uri,
        1,
        0,
        "ThemeManager",
        lambda engine: ThemeManager(engine),
    )
    qmlRegisterSingletonType(
        IconRegistry,
        engine_uri,
        1,
        0,
        "IconRegistry",
        lambda engine: IconRegistry(engine),
    )

"""QtShadcn 能力层 —— PyQt6 纯 Python 实现。

对应 C++ 的 src/core/thememanager.{h,cpp} 与 src/core/iconregistry.{h,cpp}。
仅需要提供两个 QML singleton：ThemeManager / IconRegistry，保持与 C++ 版
相同的属性名与方法签名，即可让包内 qml/ 下 30+ 个组件零修改复用。

PyQt6 自带 Qt（本包依赖 PyQt6>=6.10），因此本模块与 PyQt6 自带 Qt 同 ABI，
无需 C++ 工具链。

资源（qml/、icons/）随包安装，不再依赖外部仓库。
"""

from __future__ import annotations

import os

from PyQt6.QtCore import (
    QObject,
    QVariant,
    pyqtProperty,
    pyqtSignal,
    pyqtSlot,
)
from PyQt6.QtGui import QColor
from PyQt6.QtQml import qmlRegisterSingletonType
from qtshadcn_common import RESOURCE_DIR
from qtshadcn_common.icons import icon_data_url, load_icons
from qtshadcn_common.theme import build_theme_tokens

_RESOURCE_DIR = RESOURCE_DIR
_ICON_DIR = _RESOURCE_DIR / "icons"


def qtshadcn_import_path() -> str:
    """返回 QML 引擎应 addImportPath 的目录（QtShadcn 模块的父目录）。"""
    return str(_RESOURCE_DIR)


# ──────────────────────────────────────────────────────────────────────
# ThemeManager
# ──────────────────────────────────────────────────────────────────────
class ThemeManager(QObject):
    """对齐 shadcn/ui 默认主题的 token 引擎（light / dark 两套字典）。"""

    modeChanged = pyqtSignal()
    primaryChanged = pyqtSignal()
    tokensChanged = pyqtSignal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._mode = "light"
        self._primary = ""
        self._tokens: dict[str, object] = {}
        self._rebuild()

    # ── mode ──
    def _get_mode(self) -> str:
        return self._mode

    def _set_mode(self, mode: str) -> None:
        normalized = "dark" if mode == "dark" else "light"
        if self._mode == normalized:
            return
        self._mode = normalized
        self._rebuild()
        self.modeChanged.emit()

    mode = pyqtProperty(str, fget=_get_mode, fset=_set_mode, notify=modeChanged)

    # ── primary ──
    def _get_primary(self) -> str:
        return self._primary

    def _set_primary(self, color: str) -> None:
        if self._primary == color:
            return
        self._primary = color or ""
        self._rebuild()
        self.primaryChanged.emit()

    primary = pyqtProperty(str, fget=_get_primary, fset=_set_primary, notify=primaryChanged)

    # ── tokens ──
    def _get_tokens(self) -> QVariant:
        return QVariant(self._tokens)

    tokens = pyqtProperty(QVariant, fget=_get_tokens, notify=tokensChanged)

    # ── 可调用的辅助方法 ──
    @pyqtSlot(str, result=QVariant)
    def token(self, name: str) -> QVariant:
        return QVariant(self._tokens.get(name))

    @pyqtSlot(result=bool)
    def screenshotMode(self) -> bool:
        return os.environ.get("QTSHADCN_SCREENSHOT") == "1"

    # ── 重建 token 字典 ──
    def _rebuild(self) -> None:
        primary_color = self._primary or ("#fafafa" if self._mode == "dark" else "#18181b")
        pc = QColor(primary_color)
        lum = 0.299 * pc.redF() + 0.587 * pc.greenF() + 0.114 * pc.blueF()
        primary_fg = "#18181b" if lum > 0.5 else "#fafafa"
        self._tokens = build_theme_tokens(self._mode, primary_color, primary_fg)
        self.tokensChanged.emit()


# ──────────────────────────────────────────────────────────────────────
# IconRegistry（本地内置 svg；远程 CDN 兜底未实现，见 README 限制）
# ──────────────────────────────────────────────────────────────────────
class IconRegistry(QObject):
    iconsChanged = pyqtSignal()
    remoteEnabledChanged = pyqtSignal()
    iconReady = pyqtSignal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._remote_enabled = True
        self._icons: dict[str, str] = {}
        self._load_local()

    def _load_local(self) -> None:
        self._icons = load_icons(_ICON_DIR)

    def _get_is_remote_enabled(self) -> bool:
        return self._remote_enabled

    def _set_remote_enabled(self, on: bool) -> None:
        if self._remote_enabled == on:
            return
        self._remote_enabled = on
        self.remoteEnabledChanged.emit()

    remoteEnabled = pyqtProperty(
        bool,
        fget=_get_is_remote_enabled,
        fset=_set_remote_enabled,
        notify=remoteEnabledChanged,
    )

    def _get_names(self) -> list[str]:
        return sorted(self._icons.keys(), key=str.lower)

    names = pyqtProperty(list, fget=_get_names, notify=iconsChanged)

    @pyqtSlot(str, result=bool)
    def has(self, name: str) -> bool:
        return name in self._icons

    @pyqtSlot(str, str, result=str)
    def dataUrl(self, name: str, color: str | None = None) -> str:
        svg = self._icons.get(name, "")
        if not svg:
            return ""
        col = QColor(color) if color else QColor("#000000")
        hex_color = col.name(QColor.NameFormat.HexRgb) if col.isValid() else "#000000"
        return icon_data_url(svg, hex_color)


# ──────────────────────────────────────────────────────────────────────
# 注册
# ──────────────────────────────────────────────────────────────────────
def register_types(engine_uri: str = "QtShadcn") -> None:
    """注册 ThemeManager / IconRegistry 为 QML singleton（内部使用）。"""
    qmlRegisterSingletonType(
        ThemeManager,
        engine_uri,
        1,
        0,
        lambda engine, _: ThemeManager(engine),
        name="ThemeManager",
    )
    qmlRegisterSingletonType(
        IconRegistry,
        engine_uri,
        1,
        0,
        lambda engine, _: IconRegistry(engine),
        name="IconRegistry",
    )

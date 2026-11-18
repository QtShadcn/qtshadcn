"""pyqtshadcn —— QtShadcn 的 PyQt6 纯 Python 适配包。

让 PyQt6 的 QQmlApplicationEngine 直接加载 QtShadcn 的 QML 组件，无需 C++ 编译。
仅需一行接入：

    from pyqtshadcn import setup
    setup(engine)

详情见包内 README。
"""

from __future__ import annotations

from .capability import (
    IconRegistry,
    ThemeManager,
    qtshadcn_import_path,
    register_types,
)

__all__ = [
    "setup",
    "ThemeManager",
    "IconRegistry",
    "register_types",
    "qtshadcn_import_path",
]

__version__ = "0.1.0"


def setup(engine) -> None:
    """将 QtShadcn QML 模块接入给定 engine。

    做两件事：
      1. engine.addImportPath(包内 QtShadcn 目录) —— 使 `import QtShadcn` 可解析
      2. 注册 ThemeManager / IconRegistry 为 QML singleton

    `engine` 为 PyQt6.QtQml.QQmlApplicationEngine 实例。
    """
    engine.addImportPath(qtshadcn_import_path())
    register_types("QtShadcn")

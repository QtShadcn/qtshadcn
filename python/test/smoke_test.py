#!/usr/bin/env python3

from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlComponent, QQmlEngine
from pyqtshadcn import setup


def main() -> None:
    app = QGuiApplication([])
    engine = QQmlEngine()
    setup(engine)
    errors = []
    engine.warnings.connect(lambda warnings: errors.extend(warnings))
    component = QQmlComponent(engine)
    component.setData(
        b"""
        import QtQuick
        import QtShadcn
        Item {
            QtShadcnTheme { id: theme }
            ShadcnButton { text: "Smoke test" }
            ShadcnAlert { variant: ShadcnAlert.Warning }
            ShadcnAlert { variant: ShadcnAlert.Success }
            Component.onCompleted: theme.mode = "dark"
        }
        """,
        QUrl(),
    )
    root = component.create()
    app.processEvents()
    if root is None or component.errors() or errors:
        raise SystemExit("\n".join(error.toString() for error in [*component.errors(), *errors]))


if __name__ == "__main__":
    main()

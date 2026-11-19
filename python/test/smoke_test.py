#!/usr/bin/env python3

import os

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
    original_screenshot_mode = os.environ.get("QTSHADCN_SCREENSHOT")
    try:
        for screenshot_mode in (False, True):
            if screenshot_mode:
                os.environ["QTSHADCN_SCREENSHOT"] = "1"
            else:
                os.environ.pop("QTSHADCN_SCREENSHOT", None)

            component = QQmlComponent(engine)
            component.setData(
                b"""
                import QtQuick
                import QtShadcn
                Item {
                    property bool screenshotMode: ThemeManager.screenshotMode()
                    QtShadcnTheme { id: theme }
                    ShadcnButton { text: "Smoke test" }
                    ShadcnAlert { variant: ShadcnAlert.Warning }
                    ShadcnAlert { variant: ShadcnAlert.Success }
                    ShadcnCard {}
                    ShadcnSelect { model: ["First", "Second"] }
                    ShadcnPopoverContent {}
                    ShadcnDropdownMenuContent {}
                    Component.onCompleted: theme.mode = "dark"
                }
                """,
                QUrl(),
            )
            root = component.create()
            app.processEvents()
            if root is None or component.errors() or errors:
                raise SystemExit(
                    "\n".join(error.toString() for error in [*component.errors(), *errors])
                )
            if root.property("screenshotMode") is not screenshot_mode:
                raise SystemExit(f"screenshotMode did not return {screenshot_mode}")
    finally:
        if original_screenshot_mode is None:
            os.environ.pop("QTSHADCN_SCREENSHOT", None)
        else:
            os.environ["QTSHADCN_SCREENSHOT"] = original_screenshot_mode


if __name__ == "__main__":
    main()

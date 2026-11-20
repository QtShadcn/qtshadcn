#!/usr/bin/env python3

import os
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine
from pysideshadcn import setup


def main() -> None:
    app = QGuiApplication([])
    engine = QQmlEngine()
    setup(engine)
    errors = []
    engine.warnings.connect(lambda warnings: errors.extend(warnings))
    fixture = Path(__file__).resolve().parents[2] / "common" / "test" / "smoke_test.qml"
    original_screenshot_mode = os.environ.get("QTSHADCN_SCREENSHOT")
    try:
        for screenshot_mode in (False, True):
            if screenshot_mode:
                os.environ["QTSHADCN_SCREENSHOT"] = "1"
            else:
                os.environ.pop("QTSHADCN_SCREENSHOT", None)

            component = QQmlComponent(engine)
            component.setData(fixture.read_bytes(), QUrl.fromLocalFile(str(fixture)))
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

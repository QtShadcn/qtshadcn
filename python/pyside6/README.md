# pysideshadcn

PySide6 adapter for the QtShadcn QML component library. It provides Python
implementations of the `ThemeManager` and `IconRegistry` QML singletons and
uses the shared QML and icon resources.

Install with `pip install pysideshadcn`. The package requires Python 3.10 or
newer and PySide6 6.10 or newer.

```python
import sys

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from pysideshadcn import setup

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
setup(engine)

engine.loadData(
    b"""
    import QtQuick
    import QtQuick.Controls.Basic
    import QtShadcn
    Window {
        width: 400
        height: 300
        visible: true
        QtShadcnTheme { id: theme }
        ShadcnButton { text: "Hello"; onClicked: theme.mode = "dark" }
    }
    """,
    QUrl("qrc:/main.qml"),
)

sys.exit(app.exec())
```

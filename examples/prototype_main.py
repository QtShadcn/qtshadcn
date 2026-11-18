#!/usr/bin/env python3
"""pyqtshadcn 最小演示：一行接入 PyQt6 引擎并加载 QtShadcn 组件。

运行:
    QT_QPA_PLATFORM=offscreen python examples/prototype_main.py   # 无界面验证
    python examples/prototype_main.py                              # 真实窗口
"""
import os
import sys

# macOS 上 QtQuick 窗口默认不合成图层（创建了也"看不见"），需此变量才真实绘制
os.environ.setdefault("QT_MAC_WANTS_LAYER", "1")

from PyQt6.QtCore import QUrl  # noqa: E402
from PyQt6.QtGui import QGuiApplication  # noqa: E402
from PyQt6.QtQml import QQmlApplicationEngine  # noqa: E402

from pyqtshadcn import setup  # noqa: E402


def main() -> int:
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # 一行接入：注册 singleton + 添加 QML import path
    setup(engine)

    qml = """
    import QtQuick
    import QtQuick.Controls.Basic
    import QtShadcn

    Window {
        width: 400
        height: 360
        visible: true

        QtShadcnTheme { id: theme }

        Column {
            anchors.centerIn: parent
            spacing: 12

            ShadcnButton {
                text: "Deploy"
                iconName: "rocket"
                Component.onCompleted: console.log("ShadcnButton OK; theme.primary =", theme.primary, "radius =", theme.radius)
            }

            ShadcnBadge { text: "badge"; Component.onCompleted: console.log("ShadcnBadge OK") }

            ShadcnIcon {
                name: "github"
                size: 24
                Component.onCompleted: {
                    var u = IconRegistry.dataUrl("github", "#ef4444")
                    console.log("ShadcnIcon OK; dataUrl(len) =", u.length, "startsWithData =", u.startsWith("data:image/svg"))
                }
            }
        }
    }
    """
    engine.loadData(qml.encode("utf-8"), QUrl("qrc:/prototype.qml"))

    if not engine.rootObjects():
        print("[FAIL] 根对象为空 —— 加载失败", file=sys.stderr)
        return 1

    app.processEvents()
    print("[OK] pyqtshadcn 成功加载并实例化组件")

    # 验证核心卖点：明暗切换时 token 字典整体替换
    from pyqtshadcn import ThemeManager
    tm = ThemeManager()
    light_bg = tm.property("tokens")["background"]
    tm.setProperty("mode", "dark")
    dark_bg = tm.property("tokens")["background"]
    print(f"[VERIFY] mode 切换: light.background={light_bg} -> dark.background={dark_bg} "
          f"({'OK' if light_bg != dark_bg else 'FAIL'})")

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())

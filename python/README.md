# pyqtshadcn

QtShadcn 组件库的 **PyQt6 纯 Python 适配包**——无需 C++ 编译，安装即用。

对应主仓库 [`qtshadcn`](https://github.com/QtShadcn/qtshadcn) 的 QML 组件，本包用纯 Python 重写其
C++ 能力层（`ThemeManager` / `IconRegistry` 两个 QML singleton），使 PyQt6 引擎可直接加载
原仓库的 30+ 个 QML 组件（零修改复用）。

## 为什么不用 C++ 插件

主仓库的 C++ 插件针对特定 Qt 小版本编译，而 pip 的 PyQt6 自带另一版本 Qt，ABI 不匹配时
QML 引擎会拒绝加载插件。本包的能力层用 Python 实现、与 PyQt6 自带 Qt 同 ABI，安装即跑。

## 安装

```bash
pip install pyqtshadcn
```

需要 Python ≥ 3.10 与 PyQt6 ≥ 6.10（pip 会自动安装 PyQt6 依赖）。

## 用法

```python
import sys
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QUrl

from pyqtshadcn import setup   # 一行接入

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
setup(engine)                 # 注册 singleton + 添加 QML import path

engine.loadData(b"""
import QtQuick
import QtQuick.Controls.Basic
import QtShadcn
Window {
    width: 400; height: 300; visible: true
    QtShadcnTheme { id: theme }
    ShadcnButton { text: "Hello"; onClicked: theme.mode = "dark" }
}
""", QUrl("qrc:/main.qml"))

sys.exit(app.exec())
```

`setup(engine)` 做两件事：

1. `engine.addImportPath(<包内 QtShadcn 目录>)` —— 使 QML 中 `import QtShadcn` 可解析
2. 注册 `ThemeManager` / `IconRegistry` 为 QML singleton

## 本地开发运行

```bash
git clone https://github.com/QtShadcn/pyqtshadcn
cd pyqtshadcn
python -m venv .venv && source .venv/bin/activate
pip install -e . PyQt6

# 无界面验证（无需显示器）
QT_QPA_PLATFORM=offscreen python examples/prototype_main.py
```

## 与主仓库的同步

包内的 `qml/` 与 `icons/` 是主仓库 `src/qml`、`src/assets/icons` 的**副本**（发布时打包进 wheel）。
主仓库更新组件后，运行同步脚本拉取最新副本：

```bash
python sync.py --src /path/to/qtshadcn     # 写文件
python sync.py --src /path/to/qtshadcn --check   # 仅检查是否过期（CI 用）
```

同步会自动排除 `ShadcnTable`（见下）并校验 `qmldir` 与目录一致。

## 已知限制

1. **`ShadcnTable` 暂不支持**：该组件依赖主仓库 C++ 的 `ShadcnTableModel`（QAbstractTableModel 子类）。
   纯 Python 路线下尚未用 `QAbstractTableModel` 移植，故包内未包含此组件。
2. `IconRegistry` 仅实现**本地内置图标**（随包附带的 75 个 svg），未实现主仓库 C++ 版的
   远程 CDN 兜底（lucide 按需下载 + 磁盘缓存）。
3. 组件 QML 内已用 `import QtQuick.Controls.Basic` 强制 Basic 风格（token 自绘的前提），
   不依赖 C++ 侧设置样式。

## 许可

与主仓库一致（MIT）。

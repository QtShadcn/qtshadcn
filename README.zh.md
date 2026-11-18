<div align="right">

**[ 中文 | [English](./README.en.md) ]**

</div>

<img src="./public/logo.png" width="400"/>

> A modern, composable UI component library for Qt 6 / QML, inspired by [shadcn/ui](https://ui.shadcn.com).

Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 的设计哲学：**Design Token → Component → Composition → Theme**。

> ⚠️ **开发状态**：本项目仍在活跃开发中，API 可能随迭代调整。已可用组件与里程碑进度见 [文档站里程碑](docs/content/1.getting-started/5.milestones.md) 与 [Skills](skills/qtshadcn/SKILL.md)，欢迎 [Issue](https://github.com/QtShadcn/qtshadcn/issues) 与 PR。

> 🐍 **PyQt6 纯 Python 适配**：可通过 PyPI 安装：`pip install pyqtshadcn`。更多信息见 [Python 绑定](#python-绑定)。

## ✨ 特性

- **Design Token 驱动** — 语义化颜色 / 圆角 / 间距 token，`theme.mode = "dark"` 全局随动
- **QML 管 UI，C++ 管能力** — Theme 引擎、Icon 注册、Model 等能力层落在 C++，不退化成一个「QML 样式库」
- **复用 Qt Quick Controls** — 键盘导航、Focus、无障碍开箱即得，只做视觉与组件 API
- **可组合组件** — Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 组合方式

## 🚀 快速开始

要求：Qt 6.5+、CMake 3.24+

> **不支持 Qt 5。** 本库用到 `required property`（Qt 6.0+）、`pragma ComponentBehavior: Bound`
> 与 `MultiEffect`（6.5+），并依赖 Qt 6 重写后的 `TableView` —— 这些在 Qt 5.15 上都没有
> 等价物，不是加条件编译能绕开的。评估过程与替代方案见
> [issue #12](https://github.com/QtShadcn/qtshadcn/issues/12)。

```bash
git clone https://github.com/QtShadcn/qtshadcn.git
cd qtshadcn

# 构建（默认 QT_PREFIX=$HOME/Qt/6.11.1/macos，可用环境变量覆盖）
make build

# 运行 showcase（Design Token 色板演示，明暗切换；需真实桌面，不要用沙箱）
make run
```

或手动：

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH="${QT_PREFIX:-$HOME/Qt/6.11.1/macos}" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
./build/bin/showcase
```

Linux 把前缀里的 `macos` 换成 `gcc_64`；Homebrew 用 `QT_PREFIX=$(brew --prefix qt)`。

## 📦 接入你的项目

三种方式任选其一。作为子项目引入时**默认不编 showcase**。

**方式一：find_package（预编译安装，最省事）**

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH="$HOME/Qt/6.11.1/macos"
cmake --build build
cmake --install build --prefix /your/prefix
```

```cmake
find_package(QtShadcn 0.2 REQUIRED)
target_link_libraries(myapp PRIVATE QtShadcn::QtShadcn Qt6::Quick)
```

链接上 `QtShadcn::QtShadcn` 就够 `import QtShadcn` —— qmldir 里是
`prefer :/qt/qml/QtShadcn/`，QML 模块（qmldir、类型信息、全部 .qml）已编译进库资源的，
**运行时不用设 `QML_IMPORT_PATH`**。安装出去的磁盘副本在
`<prefix>/lib/qml/QtShadcn`（CMake 里变量 `QtShadcn_QML_IMPORT_PATH`），只给 qmllint /
qmlls / Qt Designer 这类工具链用。

**方式二：FetchContent（锁版本 tag，无需 submodule）**

```cmake
include(FetchContent)
FetchContent_Declare(qtshadcn
    GIT_REPOSITORY https://github.com/QtShadcn/qtshadcn.git
    GIT_TAG        v0.2.0)   # 锁定 release tag；升级 = 改这一行
FetchContent_MakeAvailable(qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

CPM.cmake 用户等价写法：`CPMAddPackage("gh:QtShadcn/qtshadcn@v0.2.0")`。

**方式三：submodule / clone 到 third_party（便于本地改库源码）**

```bash
mkdir -p third_party
git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
# 或：git clone https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
```

```cmake
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
add_subdirectory(third_party/qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

submodule 锁版本同样用 tag：`cd third_party/qtshadcn && git fetch --tags && git checkout v0.2.0`。

`main.cpp` 里必须 `QQuickStyle::setStyle("Basic")`（macOS 默认 native style 会拒绝自定义 `contentItem` / `background`）。

**什么时候需要 `QML_IMPORT_PATH`**：只有「不链接库、纯靠 import 路径加载」的场合（例如只跑
`.qml` 文件、或给 qmllint 指路）。链接了 `QtShadcn` 的应用不需要它——模块内容在库资源里。
`QML_IMPORT_PATH` 要指到模块目录的**父路径**（如 `build/src`，而不是 `build/src/QtShadcn`）。

建议在应用根目录放 `Makefile`（`make build` / `make run` / `make clean`）。完整工程模板见 [skills/qtshadcn/references/consumer/build.md](skills/qtshadcn/references/consumer/build.md)。

## 🎨 用法示例

QML 侧 `import QtShadcn` 即可使用组件与主题（C++ 侧需 Basic style，见上文）：

```qml
import QtQuick
import QtShadcn          // 组件 + 主题入口

Window {
    width: 640
    height: 480
    visible: true

    // 主题入口（必做）：声明式绑定 C++ ThemeManager 的 token 字典
    QtShadcnTheme { id: theme }

    color: theme.background   // 窗口底色跟主题走

    ShadcnButton {
        anchors.centerIn: parent
        text: qsTr("Deploy")
        variant: ShadcnButton.Variant.Primary
        iconName: "rocket"                       // lucide 图标（可选）
        onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
    }
}
```

- **主题接入**：任何使用组件的页面先放一个 `QtShadcnTheme`；`theme.mode = "dark"` 全局随动
- **运行时改主色**：`ThemeManager.primary = "#2563eb"`（空串恢复默认）
- 完整组件用法见 [组件文档](docs/content/2.components/) 或仓库内 [skills](skills/qtshadcn/SKILL.md)

## Python 绑定

`pyqtshadcn` 用纯 Python 实现 `ThemeManager` 和 `IconRegistry` 两个 QML 单例，无需编译 C++ 插件，
避免与 PyQt6 自带 Qt 的 ABI 不匹配。需要 Python ≥ 3.10 与 PyQt6 ≥ 6.10（pip 会自动安装 PyQt6）。

<details>

<summary>示例代码：</summary>

```python
import sys

from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from pyqtshadcn import setup

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()

# 添加包内 QML import path，并注册 ThemeManager 和 IconRegistry 单例
setup(engine)

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

</details>

### 本地开发

在本仓库根目录运行：

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e .
QT_QPA_PLATFORM=offscreen python examples/prototype/main.py
```

示例会进入 Qt 事件循环，验证完成后可用 Ctrl+C 退出。包内 QML 与图标目前是
`src/qml`、`src/assets/icons` 的副本。

### 已知限制

- `ShadcnTableModel` 尚未从 C++ 移植到 Python，因此目前无法使用 `ShadcnTable`。
- `IconRegistry` 仅支持随包附带的 75 个 SVG 图标，目前尚不支持 C++ 版的远程 CDN 下载和磁盘缓存。

## 📄 文档

- 组件文档：[docs/content/2.components/](docs/content/2.components/)（每个组件一页：用法 + 属性）
- 技术方案：[docs/content/3.design/1.technical-design.md](docs/content/3.design/1.technical-design.md)
- 组件开发流程：[docs/content/4.development/1.component-workflow.md](docs/content/4.development/1.component-workflow.md)
- AI 助手参考：[`qtshadcn`](skills/qtshadcn/SKILL.md)（接库写业务）/ [`qtshadcn-dev`](skills/qtshadcn-dev/SKILL.md)（扩展本库）
- 文档站（Docus / Nuxt Content）：`docs/`，本地预览 `cd docs && pnpm install && pnpm dev`

## 🤖 AI 如何使用 QtShadcn（Skills）

仓库内的 [`skills/`](skills/) 目录是**教 AI 助手使用 / 扩展本组件库**的指南（格式对齐 slidev/skills）。根据角色分两类：

### ① 使用者 —— 把库接入自己的工程、用组件写业务（[`skills/qtshadcn/`](skills/qtshadcn/)）

适用：消费方开发者 + 其 AI 助手，目标是快速接库并用组件搭界面。

- [SKILL.md](skills/qtshadcn/SKILL.md) —— 入口：接入铁律（CMake + 根 Makefile + `add_subdirectory(.../src)` + Basic style）+ 组件索引 + 使用坑
- [build.md](skills/qtshadcn/references/consumer/build.md) —— 消费方最小工程模板（CMake / `main.cpp` / Makefile / `QML_IMPORT_PATH`）
- `references/` —— 主题 / 图标 + 各组件用法、属性、坑

> 安装：帮我安装这个 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md` skills

> 使用：请先读 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md`，然后用 `ShadcnDialog` 帮我写一个确认弹窗。

### ② 开发组件 —— 扩展本库、新增 / 修改组件（[`skills/qtshadcn-dev/`](skills/qtshadcn-dev/)）

适用：需要扩展 QtShadcn 本身的贡献者 + 其 AI 助手，目标是按规范新增组件并同步文档与截图。

- [SKILL.md](skills/qtshadcn-dev/SKILL.md) —— 入口：开发铁律（先抓 shadcn 参考 → 对照表 → 确认）+ 架构要点 + 开发坑 + 「新增组件后必做」
- [workflow.md](skills/qtshadcn-dev/references/workflow.md) —— 组件开发全流程：抓 shadcn 参考 → 列对照表 → 实现 → showcase 验证 → 关 Issue
- [build.md](skills/qtshadcn-dev/references/build.md) —— 本仓库构建 / 静态验证 / qmlcache / 截图 / showcase 结构
- [technical-design.md](docs/content/3.design/1.technical-design.md) —— 架构与 Token 规范依据
- [component-workflow.md](docs/content/4.development/1.component-workflow.md) —— 人读版组件开发流程

> 使用：请先读 `skills/qtshadcn-dev/references/workflow.md`，按清单新增一个 `ShadcnXxx` 组件，并在 showcase 加演示页、更新两个 skill 的组件索引。

## License

MIT © [QtShadcn](https://github.com/QtShadcn)

> 本项目与 [shadcn/ui](https://ui.shadcn.com) 官方无隶属关系，仅在组件设计上受其启发。

### 第三方素材

- 图标来自 [Lucide](https://lucide.dev)（ISC License），许可声明见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。

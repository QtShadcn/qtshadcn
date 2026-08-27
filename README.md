<img src="./public/logo.png" width="400"/>

> A modern, composable UI component library for Qt 6 / QML, inspired by [shadcn/ui](https://ui.shadcn.com).

Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 的设计哲学：**Design Token → Component → Composition → Theme**。

> ⚠️ **开发状态**：本项目仍在活跃开发中，API 可能随迭代调整。已可用组件与里程碑进度见 [文档站里程碑](docs/content/1.getting-started/5.milestones.md) 与 [Skills](skills/qtshadcn/SKILL.md)，欢迎 [Issue](https://github.com/QtShadcn/qtshadcn/issues) 与 PR。

> 🐍 **PyQt6 纯 Python 适配**：无需 C++ 编译、可直接 `pip install pyqtshadcn` 加载本库 QML 组件，见独立仓库 [QtShadcn/pyqtshadcn](https://github.com/QtShadcn/pyqtshadcn)（QML 源与图标为同步副本，当前不含依赖 C++ `ShadcnTableModel` 的 `ShadcnTable`）。

## ✨ 特性

- **Design Token 驱动** — 语义化颜色 / 圆角 / 间距 token，`theme.mode = "dark"` 全局随动
- **QML 管 UI，C++ 管能力** — Theme 引擎、Icon 注册、Model 等能力层落在 C++，不退化成一个「QML 样式库」
- **复用 Qt Quick Controls** — 键盘导航、Focus、无障碍开箱即得，只做视觉与组件 API
- **可组合组件** — Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 组合方式

## 🚀 快速开始

要求：Qt 6.5+、CMake 3.24+

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
QML_IMPORT_PATH="build/src:build/examples/showcase" ./build/bin/showcase
```

Linux 把前缀里的 `macos` 换成 `gcc_64`；Homebrew 用 `QT_PREFIX=$(brew --prefix qt)`。

## 📦 接入你的项目

`find_package(QtShadcn)` 尚未提供。约定把本仓库放到应用的 `third_party/qtshadcn`（submodule 或 clone），再 `add_subdirectory`。作为子项目引入时**默认不编 showcase**。

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

`main.cpp` 里必须 `QQuickStyle::setStyle("Basic")`（macOS 默认 native style 会拒绝自定义 `contentItem` / `background`）。启动时把 `QML_IMPORT_PATH` 指到 **QtShadcn 模块目录的父路径**（上述布局下为 `build/third_party/qtshadcn/src`）。

建议在应用根目录放 `Makefile`（`make build` / `make run` / `make clean`）。完整工程模板见 [skills/qtshadcn/references/core-build.md](skills/qtshadcn/references/core-build.md)。

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

## 📄 文档

- 组件文档：[docs/content/2.components/](docs/content/2.components/)（每个组件一页：用法 + 属性）
- 技术方案：[docs/content/3.design/1.technical-design.md](docs/content/3.design/1.technical-design.md)
- 组件开发流程：[docs/content/4.development/1.component-workflow.md](docs/content/4.development/1.component-workflow.md)
- AI 助手参考：[skills/qtshadcn/SKILL.md](skills/qtshadcn/SKILL.md)（接入脚手架 + 组件索引 + 开发坑）
- 文档站（Docus / Nuxt Content）：`docs/`，本地预览 `cd docs && pnpm install && pnpm dev`

## 🤖 AI 如何使用 QtShadcn（Skills）

仓库内的 [`skills/`](skills/) 目录是**教 AI 助手使用 / 扩展本组件库**的指南（格式对齐 slidev/skills）。根据角色分两类：

### ① 使用者 —— 把库接入自己的工程、用组件写业务

适用：消费方开发者 + 其 AI 助手，目标是快速接库并用组件搭界面。

- [SKILL.md](skills/qtshadcn/SKILL.md) —— 入口：消费方脚手架（CMake + 根 Makefile + `add_subdirectory(.../src)` + Basic style）+ 组件索引 + 关键坑
- [core-build.md](skills/qtshadcn/references/core-build.md) —— 本库构建、消费方最小工程模板、`QML_IMPORT_PATH`、截图
- `references/` —— 主题 / 图标 + 各组件用法、属性、坑

> 安装：帮我安装这个 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md` skills

> 使用：请先读 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md`，然后用 `ShadcnDialog` 帮我写一个确认弹窗。

### ② 开发组件 —— 扩展本库、新增 / 修改组件

适用：需要扩展 QtShadcn 本身的贡献者 + 其 AI 助手，目标是按规范新增组件并同步文档与截图。

- [core-workflow.md](skills/qtshadcn/references/core-workflow.md) —— 组件开发全流程：抓 shadcn 参考 → 列对照表 → 实现 → showcase 验证 → 关 Issue → 「新增组件后必做」清单（同步文件与截图）
- [technical-design.md](docs/content/3.design/1.technical-design.md) —— 架构与 Token 规范依据
- [component-workflow.md](docs/content/4.development/1.component-workflow.md) —— 人读版组件开发流程

> 使用：请先读 `core-workflow.md`，按清单新增一个 `ShadcnXxx` 组件，并在 showcase 加演示页、更新组件索引。

## License

MIT © [QtShadcn](https://github.com/QtShadcn)

> 本项目与 [shadcn/ui](https://ui.shadcn.com) 官方无隶属关系，仅在组件设计上受其启发。

### 第三方素材

- 图标来自 [Lucide](https://lucide.dev)（ISC License），许可声明见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。

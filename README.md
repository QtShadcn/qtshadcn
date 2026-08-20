<img src="./public/logo.png" width="400"/>

> A modern, composable UI component library for Qt 6 / QML, inspired by [shadcn/ui](https://ui.shadcn.com).

Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 的设计哲学：**Design Token → Component → Composition → Theme**。

> ⚠️ **开发状态**：本项目仍在活跃开发中，API 可能随迭代调整。下方「组件状态」表中标 ✅ 的组件已可用，标 ⏳ 的组件正在开发/规划中，欢迎 [Issue](https://github.com/QtShadcn/qtshadcn/issues) 与 PR。

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

## 📦 组件状态

| 组件 | 状态 |
|---|---|
| Theme（Design Token 系统） | ✅ M1 完成 |
| ShadcnButton（6 variant × 5 size + 图标 + loading） | ✅ M2 完成 |
| ShadcnButtonGroup / ShadcnToggle / ShadcnToggleGroup / ShadcnSpinner | ✅ M2 完成 |
| ShadcnCard（Header / Content / Footer 组合） | ✅ M3 完成 |
| ShadcnInput / ShadcnInputGroup / ShadcnTextarea | ✅ M3 完成 |
| ShadcnCheckbox / ShadcnRadioGroup | ✅ M3 完成 |
| ShadcnSwitch / ShadcnSlider / ShadcnProgress / ShadcnSelect | ✅ M3 完成 |
| ShadcnBadge（6 variant 徽标） | ✅ M3 完成 |
| ShadcnTabs（default / line variant） | ✅ M3 完成 |
| ShadcnDialog（模态对话框 + 可滚动 body） | ✅ M3 完成 |
| Icon 系统（ShadcnIcon + IconRegistry，本地 74 + 远程兜底） | ✅ M4 完成 |
| Animations（预置动画封装） | ⏳ M4 开发中 |
| Models / Table / WindowManager | ⏳ M5 计划 |
| 文档站完善 / 发布 | 🔄 M6 进行中 |

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

仓库内的 [`skills/`](skills/) 目录是**教 AI 助手如何使用本组件库**的指南——从脚手架接入到每个组件的用法与坑（格式对齐 slidev/skills）：

- [SKILL.md](skills/qtshadcn/SKILL.md) —— 入口：消费方脚手架（CMake + 根 Makefile + `add_subdirectory(.../src)` + Basic style）+ 组件索引 + 关键坑
- [core-build.md](skills/qtshadcn/references/core-build.md) —— 本库构建、消费方最小工程模板、`QML_IMPORT_PATH`、截图
- `references/` —— 主题 / 开发流程 / 图标 + 各组件用法、属性、坑

> 安装：帮我安装这个 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md` skills

**使用**

> 请先读 `https://github.com/QtShadcn/qtshadcn/skills/qtshadcn/SKILL.md`，然后用 `ShadcnDialog` 帮我写一个确认弹窗。

新增组件时按 `references/core-workflow.md` 的「新增组件后必做」清单同步更新这些文件与截图。

## License

MIT © [QtShadcn](https://github.com/QtShadcn)

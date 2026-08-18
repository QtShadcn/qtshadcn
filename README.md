<img src="./public/logo.png" width="400"/>

> A modern, composable UI component library for Qt 6 / QML, inspired by [shadcn/ui](https://ui.shadcn.com).

Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 的设计哲学：**Design Token → Component → Composition → Theme**。

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

# 构建（自动探测 ~/Qt/6.11.1/macos，可用 QT_PREFIX 覆盖）
make build

# 运行 showcase（Design Token 色板演示，明暗切换）
make run
```

或手动：

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH="$HOME/Qt/6.11.1/macos" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
QML_IMPORT_PATH="build/src:build/examples/showcase" ./build/bin/showcase
```

## 📦 组件状态

| 组件 | 状态 |
|---|---|
| Theme（Design Token 系统） | ✅ M1 完成 |
| ShadcnButton（variant / size / disabled / loading） | ✅ M2 完成 |
| ShadcnButtonGroup / ShadcnToggle / ShadcnToggleGroup / ShadcnSpinner | ✅ M2 完成 |
| ShadcnCard（纯组合组件） | ✅ M3 完成 |
| ShadcnInput（文本输入） | ✅ M3 完成 |
| ShadcnBadge（6 variant 徽标） | ✅ M3 完成 |
| ShadcnSwitch（开关） | ✅ M3 完成 |
| ShadcnTabs（default / line variant） | ✅ M3 完成 |
| ShadcnDialog（模态对话框） | ✅ M3 完成 |
| Icon 系统（svg + IconRegistry）/ Animations | ⏳ M4 计划 |
| Models / Table / WindowManager | ⏳ M5 计划 |
| 文档站完善 / 发布 | 🔄 M6 进行中 |

## 🎨 用法示例

```qml
import QtShadcn

QtShadcnTheme {
    id: theme
    mode: "dark"   // "light" | "dark"
}

Rectangle {
    color: theme.primary
    radius: theme.radius
}
```

## 📄 文档

- 技术方案：[docs/content/2.design/1.technical-design.md](docs/content/2.design/1.technical-design.md)
- 组件开发流程：[docs/content/3.development/1.component-workflow.md](docs/content/3.development/1.component-workflow.md)
- 文档站（Docus / Nuxt Content）：`docs/`，本地预览 `cd docs && pnpm install && pnpm dev`

## License

MIT

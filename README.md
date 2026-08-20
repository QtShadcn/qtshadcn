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

QML 侧只需一行 import，组件与主题即可使用：

```qml
import QtQuick
import QtShadcn          // 唯一需要的 import：组件 + 主题入口

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
- AI 助手参考：[skills/qtshadcn/SKILL.md](skills/qtshadcn/SKILL.md)（组件索引 + 开发坑）
- 文档站（Docus / Nuxt Content）：`docs/`，本地预览 `cd docs && pnpm install && pnpm dev`

## 🤖 如何使用 Skills

仓库内的 [`skills/`](skills/) 目录是给 **AI 编码助手**（Claude Code / Codex / WorkBuddy 等）使用的项目参考，格式对齐 [slidev/skills](https://github.com/slidevjs/slidev/tree/main/skills)：

```
skills/
├── GENERATION.md               # 生成信息 + 同步约定
└── qtshadcn/
    ├── SKILL.md                # 入口：定位 + 组件/能力表格索引 + 关键坑清单
    └── references/             # 分类详细参考
        ├── core-theme.md       # Theme 系统（ThemeManager / QtShadcnTheme / tokens）
        ├── core-build.md       # 构建 / 运行 / 截图 / 验证
        ├── core-workflow.md    # 组件开发流程（抓 shadcn 规范 → 实现）
        ├── core-icon.md        # Icon 系统（IconRegistry / ShadcnIcon）
        ├── component-button.md # Button 族
        ├── component-form.md   # 表单控件
        ├── component-display.md# Card / Badge
        ├── component-overlay.md# Dialog
        └── component-navigation.md # Tabs
```

**怎么用：**

- **人工查阅** — 直接读 [SKILL.md](skills/qtshadcn/SKILL.md) 总览，再进 `references/` 查具体组件的用法、属性与开发坑。
- **配合 AI 助手** — 让助手「先读 `skills/qtshadcn/SKILL.md`，再按需读 `references/`」，即可获得组件 API、主题、构建流程、开发坑等完整上下文，减少幻觉。例如：

  > 请先阅读 `skills/qtshadcn/SKILL.md`，然后帮我新增一个 `ShadcnAccordion` 组件，遵循 `references/core-workflow.md` 的开发流程。

- **Claude Code / Codex** — 可把 `skills/qtshadcn/` 作为 skill 挂载（Claude Code 复制到 `~/.claude/skills/`；Codex 在 `AGENTS.md` 中引用该目录），或在对话里直接让助手读取。

**新增组件时记得同步**：按 `references/core-workflow.md` 的「新增组件后必做」清单，更新 `SKILL.md` 表格 + 对应 reference + 截图。

## License

MIT © [QtShadcn](https://github.com/QtShadcn)

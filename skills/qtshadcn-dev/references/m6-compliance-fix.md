---
name: m6-compliance-fix
description: M6 七个组件（Separator / Label / Alert / Skeleton / Kbd / Tooltip / DropdownMenu）对齐 shadcn/ui 的改动记录、实现决策与遗留修正项。
---

# M6 对齐修复记录

M6 七组件初版是凭印象实现的，与 shadcn/ui 参考实现有实质偏差（DropdownMenu 缺子组件、Alert 颜色硬编码、Kbd 字体硬编码、Tooltip hover 不显示）。对照 **Base UI 默认 DOM** 重做后落地在 `fix(M6)` 提交里，本文记录**为什么这么做**，避免以后反复踩。

## 改动与依据

| 改动 | 依据 / 原因 |
|------|------|
| DropdownMenu 补 `Group` / `Label` / `Separator` / `Shortcut` 四个子组件 | shadcn 的 dropdown-menu 导出这些组合单元；缺了没法做分组与快捷键提示 |
| DropdownMenu 修复点击外部 / ESC 关闭 | `QQC.Popup` 默认策略不满足菜单语义，需显式处理 `closePolicy` 与外部点击 |
| Alert 颜色 token 化（`theme.destructive/warning/success` + `Qt.alpha(·, 0.1/0.3)`） | 原实现把颜色值写死 → 明暗切换不跟随；同时 `ThemeManager` 补 `warning` / `success` token |
| Alert 补操作按钮区（`default property alias actionChildren: _actionLayout.data`） | shadcn Alert 的 action 是插槽语义，QML 侧用默认属性最自然 |
| Kbd 字体属性化（`fontFamily`，留空 = 系统 monospace） | 原实现硬编码 `SF Mono` → macOS 上该字体名不存在，触发字体别名表构建与 ~108ms 加载警告 |
| Kbd 补 `KbdGroup` | 组合键（⌘ + K）需要成组排布 |
| Tooltip 重构为 `Item` + hover 祖先查找 + `QQC.Popup` | 见下 |
| Button 加 `hoverEnabled: true` | **Qt 6 的 `QAbstractButton` 默认 `hoverEnabled: false`**，不加则 `hovered` 永远为 false —— 所有依赖 hover 的组件（Tooltip、菜单项、按钮 hover 配色）都会静默失效 |

## 关键实现决策

**Tooltip 不做 `QQC.ToolTip` 子类。** `QQC.ToolTip` 是手动触发 API，不随父元素 hover 自动显示，且在 `parent` 上取 hover 状态会拿到 contentItem（没有 `hovered` 属性）。最终实现：

- 作为**子元素**声明在目标内部（`ShadcnButton { …; ShadcnTooltip { text: "…" } }`）
- `Component.onCompleted` 向上遍历 `parent`，取第一个有 `hovered` 属性的祖先绑到 `Connections`（初始化期 `parent` 可能为 null，必须动态绑定）
- Timer 300ms 显示 / 100ms 隐藏；`QQC.Popup` 的 `parent` 设为目标父元素、纵向下移 6px、最大宽 200px 自动换行

**Alert 不设独立 `ShadcnAlertAction` 类型**：原计划里有，最终用默认属性插槽实现。`ShadcnAlert.qml` 顶部注释第 12 行仍写着 `ShadcnAlertAction { … }` 的用法 —— **那是残留，勿照抄**，否则会引用不存在的类型。

## 遗留修正项（尚未改）

| 位置 | 问题 |
|------|------|
| `docs/content/2.components/24.tooltip.md` | 示例用 `ShadcnTooltip.text: qsTr("…")` 附着语法（`Item` 子类不支持，会报 `Non-existent attached object`）；「跟随 QQC.ToolTip 原生 hover 行为」的描述也已过时 |
| `src/qml/Components/ShadcnAlert.qml:12` | 注释引用不存在的 `ShadcnAlertAction` 类型 |

## 复现验证

```bash
make build
QT_QPA_PLATFORM=offscreen QML_IMPORT_PATH="$(pwd)/build/src:$(pwd)/build/examples/showcase" ./build/bin/showcase
bash scripts/screenshot.sh tooltip dropdown-menu kbd alert   # 出效果图做视觉回归
```

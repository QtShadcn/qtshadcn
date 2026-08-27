---
name: qtshadcn
description: QtShadcn — Qt 6 / QML UI library inspired by shadcn/ui. Use when building or scaffolding Qt 6 / QML apps, theming, customizing Qt Quick Controls, or adding components. For a new consumer app, vendor into third_party/qtshadcn, add CMake + root Makefile (make build/run/clean) if missing, add_subdirectory(third_party/qtshadcn), set QQuickStyle Basic.
---

# QtShadcn — Qt 6 / QML 组件库

对齐 shadcn/ui 设计哲学的 Qt Quick 组件库：QML 管 UI、C++ 管能力，复用 Qt Quick Controls 的键盘导航与无障碍。组件带 `Shadcn` 前缀（与 QQC 基类区分）。

## When to Use

- 开发 / 脚手架 Qt 6 / QML 桌面应用（缺 Makefile 时补 `make build/run`）
- Design Token 明暗主题（`theme.mode = "dark"` 全局随动）
- 定制 QQC 视觉，或给本库加新组件（对齐 shadcn/ui）
- lucide 图标（本地 74 + 远程兜底）

## 安装 / 接入

给用户写项目时按 [core-build](references/consumer/build.md)「消费方脚手架」落地，铁律：

1. 根目录无 `Makefile` → 新增 `build` / `run` / `clean` / `fresh` / `info`；已有只补缺、不覆盖
2. 最小工程：`CMakeLists.txt` + `main.cpp` + QML + Makefile + `third_party/qtshadcn`
3. 本仓库放到 `third_party/qtshadcn`（submodule 或 clone），`add_subdirectory(third_party/qtshadcn)`（子项目默认不编 showcase）
4. `QQuickStyle::setStyle("Basic")` 必做；窗口内先放 `QtShadcnTheme`
5. `find_package(QtShadcn)` 尚未提供

### 1. 构建本库

```bash
make build   # 产出 QML 模块 build/src/QtShadcn + 动态库；Qt 前缀用 QT_PREFIX 覆盖，默认 ~/Qt/6.11.1/macos
```

### 2. 接入（摘要）

```bash
mkdir -p third_party
git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
```

```cmake
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
add_subdirectory(third_party/qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

`make run` 设 `QML_IMPORT_PATH` 为 **QtShadcn 模块目录的父路径**（上述布局为 `build/third_party/qtshadcn/src`）。完整模板见 [core-build](references/consumer/build.md)。

### 3. 使用组件

```qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

Window {
    width: 640
    height: 480
    visible: true

    QtShadcnTheme { id: theme }   // 主题入口（必做，绑定 C++ ThemeManager token）

    ShadcnButton {
        anchors.centerIn: parent
        text: qsTr("Deploy")
        iconName: "rocket"
        onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
    }
}
```

- **主题接入必做**：任何使用组件的窗口先放一个 `QtShadcnTheme`
- **组件命名**：全部带 `Shadcn` 前缀（与 QQC 基类区分）

## References（按读者分三组）

### common — 两类读者通用

| 主题 | 说明 | 参考 |
|------|------|------|
| Theme 系统 | `ThemeManager`（C++）/ `QtShadcnTheme` / token 字典 / 明暗切换 / 主色 | [core-theme](references/common/core-theme.md) |
| Icon 系统 | `IconRegistry`（C++ singleton）/ `ShadcnIcon` / 图标打包 | [core-icon](references/common/core-icon.md) |

### consumer — 组件消费者（接库写业务）

| 主题 | 说明 | 参考 |
|------|------|------|
| 接入脚手架 | vendor 到 third_party + 最小 CMake / main.cpp / Makefile | [build](references/consumer/build.md) |
| 组件用法 | Button / Form / Display / Navigation / Overlay 全部组件属性与用法 | 见下方 Feature Reference 各表 |

### developer — 库开发者（扩展本库）

| 主题 | 说明 | 参考 |
|------|------|------|
| 本仓库构建与验证 | 构建 / offscreen 静态验证 / qmlcache / 截图 / showcase 结构 | [build](references/developer/build.md) |
| 组件开发流程 | 抓 shadcn 规范 → 对照表 → 实现 → showcase 验证 → 同步文档截图 | [workflow](references/developer/workflow.md) |
| M6 shadcn/ui 规范对齐 | DropdownMenu/Alert/Tooltip/Kbd 修复记录与坑 | [m6-compliance-fix](references/developer/m6-compliance-fix.md) |

## Feature Reference

### General（M2 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnButton` | 6 variant × 5 size + `iconName` + `loading` | [component-button](references/consumer/component-button.md) |
| `ShadcnButtonGroup` | 按钮组，边框合并 + 圆角只留两端 | [component-button](references/consumer/component-button.md) |
| `ShadcnToggle` | 切换按钮（outline + checkable） | [component-button](references/consumer/component-button.md) |
| `ShadcnToggleGroup` | 切换按钮组（`exclusive` 单选/多选） | [component-button](references/consumer/component-button.md) |
| `ShadcnSpinner` | 加载指示器（圆环动画） | [component-button](references/consumer/component-button.md) |

### Form（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnInput` | 单行输入（36px + 6px 圆角 + 聚焦环） | [component-form](references/consumer/component-form.md) |
| `ShadcnInputGroup` | 输入框前缀/后缀（icon 或文本） | [component-form](references/consumer/component-form.md) |
| `ShadcnTextarea` | 多行输入（Flickable 实现，`maxHeight` 内部滚动） | [component-form](references/consumer/component-form.md) |
| `ShadcnCheckbox` | 复选框（16px + 选中 primary 底 + check） | [component-form](references/consumer/component-form.md) |
| `ShadcnRadio` / `ShadcnRadioGroup` | 单选组（16px 正圆 + 内圆点） | [component-form](references/consumer/component-form.md) |
| `ShadcnSwitch` | 开关（Default 44×20 / Small 28×16） | [component-form](references/consumer/component-form.md) |
| `ShadcnSlider` | 滑块（4px muted 轨道 + 12px 正圆 thumb） | [component-form](references/consumer/component-form.md) |
| `ShadcnProgress` | 进度条（12px 轨道 + primary 指示条 + 百分比） | [component-form](references/consumer/component-form.md) |
| `ShadcnSelect` | 下拉选择（trigger + chevron + popover 弹层） | [component-form](references/consumer/component-form.md) |

### Layout & Feedback（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnCard` | 卡片容器（Header / Content / Footer 组合） | [component-display](references/consumer/component-display.md) |
| `ShadcnBadge` | 状态标签（6 variant 胶囊） | [component-display](references/consumer/component-display.md) |
| `ShadcnAvatar` | 圆形头像（图片/图标/首字母 + 5 尺寸 + StatusDot 覆盖） | [component-display](references/consumer/component-display.md) |
| `ShadcnStatusDot` | 语义色状态圆点（Online/Away/Busy/Offline/Success/Warning/Danger） | [component-display](references/consumer/component-display.md) |
| `ShadcnDialog` | 对话框（Base UI 规格 + sticky footer + 可滚动 body） | [component-overlay](references/consumer/component-overlay.md) |

### Navigation（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnTabsList` / `Trigger` / `Content` | 标签页（无独立 `ShadcnTabs`；default / line） | [component-navigation](references/consumer/component-navigation.md) |

### Icon（M4 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnIcon` | 图标（name / size / color，随主题变色） | [core-icon](references/common/core-icon.md) |
| `IconRegistry` | C++ singleton：本地 74 + 远程兜底 + 磁盘缓存 | [core-icon](references/common/core-icon.md) |

### Layout & Feedback（M6 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnSeparator` | 分隔线（水平 / 竖直 / 带文字） | [separator](/components/22.separator) |
| `ShadcnLabel` | 语义化文本标签（3 variant × 3 size） | [label](/components/23.label) |
| `ShadcnAlert` | 提示框（4 variant + AlertAction slot + token 配色） | [alert](/components/25.alert) |
| `ShadcnSkeleton` | 骨架屏（闪烁动画占位块） | [skeleton](/components/26.skeleton) |
| `ShadcnKbd` | 键盘快捷键标签（Menlo 等宽 + 边框 + `fontFamily` 属性） | [kbd](/components/27.kbd) |
| `ShadcnKbdGroup` | 快捷键组合容器（Row + spacing） | [kbd](/components/27.kbd) |
| `ShadcnTooltip` | 悬停提示（Item + HoverHandler + Popup，自动绑定父 hover） | [tooltip](/components/24.tooltip) |
| `ShadcnDropdownMenu` | 下拉菜单（Trigger + Content + Item + Popup 置顶 + ESC/外部点击关闭） | [dropdown-menu](/components/28.dropdown-menu) |
| `ShadcnDropdownMenuGroup` | 菜单分组容器（语义分组，Column + spacing） | [dropdown-menu](/components/28.dropdown-menu) |
| `ShadcnDropdownMenuLabel` | 分组标题（mutedForeground + text-xs + font-medium） | [dropdown-menu](/components/28.dropdown-menu) |
| `ShadcnDropdownMenuSeparator` | 菜单分隔线（1px border + my-1） | [dropdown-menu](/components/28.dropdown-menu) |
| `ShadcnDropdownMenuShortcut` | 快捷键提示（右侧 + text-xs + tracking-widest） | [dropdown-menu](/components/28.dropdown-menu) |

## 关键坑（务必先读）

| 坑 | 说明 |
|----|------|
| 未设 Basic style | macOS 默认 native style 拒绝自定义 `contentItem`/`background` → `QQuickStyle::setStyle("Basic")` |
| 第三方路径不统一 | 放到 `third_party/qtshadcn` 再 `add_subdirectory`；不要散落绝对路径 |
| override QQC 子组件丢定位 | `handle` / `indicator` / `background` 的几何在默认模板内部，override 后须自带定位 |
| ScrollView 内取 implicitHeight | 被视口裁剪取不到 → 固定 `height: implicitHeight` |
| TextArea 内部滚动 | QQC.TextArea 无 Flickable、TextEdit 不响应滚轮 → Flickable + TextEdit + ScrollBar |
| contentHeight 早期 undefined | Math.min/max 遇 NaN 传播 → `> 0` 兜底 |
| readonly property 引用子对象 | 创建期立即求值 → null，放惰性绑定里 |
| layer FBO 尺寸为 0 | `layer.enabled: true` 时 Rectangle 无显式 width/height → 离屏 FBO 0×0 → 内容不可见 |
| 子组件覆盖内置属性 | `ShadcnDropdownMenuItem` 定义 `property bool enabled` 覆盖 `Item.enabled` → 信号错乱 |
| QQC.ToolTip 不自动触发 | `QQC.ToolTip` 是手动 API，不会在父组件 hover 时自动显示；须用 `Item` + `HoverHandler` + `QQC.Popup` 实现声明式 tooltip |
| HoverHandler.target 需动态绑定 | 组件创建时 `parent` 可能为 null → `HoverHandler.target` 绑不上；用 `onParentChanged` + `Component.onCompleted` 动态设置 |
| Text.implicitHeight 只读 | QML `Text` 的 `implicitHeight` 是只读的，不能赋值；需用 `Item` 包裹再设 `implicitHeight` |
| ShadcnButton.Variant 无 Default | 枚举是 `Primary/Secondary/Outline/Ghost/Destructive/Link`，没有 `Default` |
| SF Mono 字体不存在 | macOS 上 `SF Mono` 不在系统字体列表中（会触发 108ms 加载警告）→ 用 `Menlo` |
| 内联属性语法对 Item 不兼容 | `ShadcnXxx.text: "..."` 简写对 `QQC.ToolTip` 子类有效，对 `Item` 子类报 `Non-existent attached object`；须用 `ShadcnXxx { text: "..." }` 完整语法 |

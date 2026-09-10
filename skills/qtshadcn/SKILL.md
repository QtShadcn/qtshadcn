---
name: qtshadcn
description: Use when building a Qt 6 / QML app that consumes the QtShadcn component library (ShadcnButton, ShadcnDialog, ShadcnTable, …), theming it with QtShadcnTheme, or adding the library to a new project — vendoring path, CMake wiring, QML_IMPORT_PATH, and the QQuickStyle Basic requirement.
---

# QtShadcn — Qt 6 / QML 组件库（使用者）

对齐 shadcn/ui 设计哲学的 Qt Quick 组件库：**QML 管 UI、C++ 管能力**，复用 Qt Quick Controls 的键盘导航与无障碍。组件带 `Shadcn` 前缀（与 QQC 基类区分）。

**本 skill 只讲「用库写业务」。** 要扩展本库（新增/修改组件、改 token、出文档截图）→ 用 `qtshadcn-dev` skill。

## When to Use

- 脚手架 / 开发 Qt 6 + QML 桌面应用，界面用 QtShadcn 组件（缺 Makefile 时补 `make build/run`）
- Design Token 明暗主题（`theme.mode = "dark"` 全局随动）、运行时改主色
- lucide 图标（本地 74 + 远程兜底）
- 排查「组件样式不生效 / 自定义 background 无效 / 找不到 QtShadcn 模块」

## 接入铁律

按 [build](references/consumer/build.md)「消费方脚手架」落地：

1. 根目录无 `Makefile` → 新增 `build` / `run` / `clean` / `fresh` / `info`；已有则**只补缺、不覆盖**
2. 最小工程：`CMakeLists.txt` + `main.cpp` + QML + Makefile + `third_party/qtshadcn`
3. 库放 `third_party/qtshadcn`（submodule 或 clone），然后 `add_subdirectory(third_party/qtshadcn)`（作为子项目时默认不编 showcase）
4. `QQuickStyle::setStyle("Basic")` **必做**；窗口内先放一个 `QtShadcnTheme`
5. `find_package(QtShadcn)` **尚未提供**，不要写假的 install 导入

```bash
mkdir -p third_party
git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
```

```cmake
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
add_subdirectory(third_party/qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

`make run` 要把 `QML_IMPORT_PATH` 指向 **QtShadcn 模块目录的父路径**（上述布局为 `build/third_party/qtshadcn/src`）。完整模板（CMake / `main.cpp` / Makefile）见 [build](references/consumer/build.md)。

## 使用组件

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

- **主题接入必做**：任何使用组件的窗口先放 `QtShadcnTheme`
- **组件命名**：全部带 `Shadcn` 前缀（与 QQC 基类区分）

## 组件索引

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

### Feedback & Layout（M6 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnSeparator` | 分隔线（水平 / 竖直 / 带文字） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnLabel` | 语义化文本标签（3 variant × 3 size） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnAlert` | 提示框（4 variant + 操作按钮 slot + token 配色） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnSkeleton` | 骨架屏（闪烁动画占位块） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnKbd` / `ShadcnKbdGroup` | 键盘快捷键标签（Menlo 等宽 + 边框 + `fontFamily` 可配） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnTooltip` | 悬停提示（声明式，自动绑定父 hover） | [component-feedback](references/consumer/component-feedback.md) |
| `ShadcnDropdownMenu` + `ShadcnDropdownMenuTrigger` / `Content` / `Item` / `Group` / `Label` / `Separator` / `Shortcut` | 下拉菜单（Popup 置顶 + ESC/外部点击关闭 + `shortcut` 提示） | [component-feedback](references/consumer/component-feedback.md) |

其余组件（Table 等）与逐组件示例见[文档站](https://github.com/QtShadcn/qtshadcn/tree/main/docs/content/2.components)。

## 使用坑（务必先读）

| 坑 | 说明 |
|----|------|
| 未设 Basic style | macOS 默认 native style **拒绝**自定义 `contentItem`/`background` → `main.cpp` 里 `QQuickStyle::setStyle("Basic")` |
| 第三方路径不统一 | 库放 `third_party/qtshadcn` 再 `add_subdirectory`；不要散落绝对路径 |
| `ShadcnButton.Variant` 无 `Default` | 枚举只有 `Primary/Secondary/Outline/Ghost/Destructive/Link` |
| 内联属性语法对 `Item` 子类不兼容 | `ShadcnXxx.text: "..."` 简写对 `QQC.ToolTip` 子类有效，对 `Item` 子类报 `Non-existent attached object`；一律用 `ShadcnXxx { text: "..." }` 完整语法 |

## References

| 主题 | 参考 |
|------|------|
| 消费方最小工程（CMake / `main.cpp` / Makefile / `QML_IMPORT_PATH`） | [build](references/consumer/build.md) |
| 组件用法（Button / Form / Display / Navigation / Overlay） | `references/consumer/component-*.md` |
| 组件用法（M6：Separator / Label / Alert / Skeleton / Kbd / Tooltip / DropdownMenu） | [component-feedback](references/consumer/component-feedback.md) |
| Theme 系统（`ThemeManager` / `QtShadcnTheme` / token 字典 / 明暗 / 主色） | [core-theme](references/common/core-theme.md) |
| Icon 系统（`IconRegistry` / `ShadcnIcon` / 图标打包） | [core-icon](references/common/core-icon.md) |
| 扩展本库（新增组件 / 改 token / 截图 / 发布流程） | `qtshadcn-dev` skill |

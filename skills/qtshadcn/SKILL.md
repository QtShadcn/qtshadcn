---
name: qtshadcn
description: QtShadcn — a modern, composable UI component library for Qt 6 / QML inspired by shadcn/ui (Design Token → Component → Composition → Theme). Use when building QML UIs, theming, customizing Qt Quick Controls, or adding new components to this library.
---

# QtShadcn — Qt 6 / QML 组件库

对齐 shadcn/ui 设计哲学的 Qt Quick 组件库：QML 管 UI、C++ 管能力，复用 Qt Quick Controls 的键盘导航与无障碍。组件带 `Shadcn` 前缀（与 QQC 基类区分）。

## When to Use

- 开发 Qt 6 / QML 桌面应用界面
- 需要 Design Token 驱动的明暗主题（`theme.mode = "dark"` 全局随动）
- 定制 QQC 组件视觉（Checkbox / Slider / ComboBox / Dialog 等）
- 给 QtShadcn 添加新组件（对齐 shadcn/ui 规范）
- 使用 lucide 图标（本地 74 精选 + 远程兜底）

## 安装 / 接入

### 1. 构建库

```bash
make build   # 产出 libQtShadcn.dylib + QML 模块（build/src/QtShadcn），自动探测 Qt 6.11.1 arm64
```

### 2. 接入你的项目

**CMake**（链接 QtShadcn 目标）：

```cmake
add_subdirectory(path/to/qtshadcn QtShadcn)          # 引入本仓库
target_link_libraries(MyApp PRIVATE QtShadcn)        # 链接库
# 注：find_package(QtShadcn) 安装方式在 M6 规划中
```

**QML**（运行时让引擎找到 QtShadcn 模块）：

```bash
# 启动应用时指定 import 路径
QML_IMPORT_PATH="path/to/qtshadcn/build/src" ./myapp
```

或在 `main.cpp` 里：

```cpp
engine.addImportPath("path/to/qtshadcn/build/src");
```

然后 QML 里 `import QtShadcn` 即可。

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

## Core References

| 主题 | 说明 | 参考 |
|------|------|------|
| Theme 系统 | `ThemeManager`（C++）/ `QtShadcnTheme` / token 字典 / 明暗切换 / 主色 | [core-theme](references/core-theme.md) |
| 构建与验证 | `make build/run`、offscreen 静态验证 | [core-build](references/core-build.md) |
| 组件开发流程 | 抓 shadcn 规范 → 对照表 → 实现 → showcase 验证 | [core-workflow](references/core-workflow.md) |
| Icon 系统 | `IconRegistry`（C++ singleton）/ `ShadcnIcon` / 图标打包 | [core-icon](references/core-icon.md) |

## Feature Reference

### General（M2 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnButton` | 6 variant × 5 size + `iconName` + `loading` | [component-button](references/component-button.md) |
| `ShadcnButtonGroup` | 按钮组，边框合并 + 圆角只留两端 | [component-button](references/component-button.md) |
| `ShadcnToggle` | 切换按钮（outline + checkable） | [component-button](references/component-button.md) |
| `ShadcnToggleGroup` | 切换按钮组（`exclusive` 单选/多选） | [component-button](references/component-button.md) |
| `ShadcnSpinner` | 加载指示器（圆环动画） | [component-button](references/component-button.md) |

### Form（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnInput` | 单行输入（36px + 6px 圆角 + 聚焦环） | [component-form](references/component-form.md) |
| `ShadcnInputGroup` | 输入框前缀/后缀（icon 或文本） | [component-form](references/component-form.md) |
| `ShadcnTextarea` | 多行输入（Flickable 实现，`maxHeight` 内部滚动） | [component-form](references/component-form.md) |
| `ShadcnCheckbox` | 复选框（16px + 选中 primary 底 + check） | [component-form](references/component-form.md) |
| `ShadcnRadio` / `ShadcnRadioGroup` | 单选组（16px 正圆 + 内圆点） | [component-form](references/component-form.md) |
| `ShadcnSwitch` | 开关（Default 44×20 / Small 28×16） | [component-form](references/component-form.md) |
| `ShadcnSlider` | 滑块（4px muted 轨道 + 12px 正圆 thumb） | [component-form](references/component-form.md) |
| `ShadcnProgress` | 进度条（12px 轨道 + primary 指示条 + 百分比） | [component-form](references/component-form.md) |
| `ShadcnSelect` | 下拉选择（trigger + chevron + popover 弹层） | [component-form](references/component-form.md) |

### Layout & Feedback（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnCard` | 卡片容器（Header / Content / Footer 组合） | [component-display](references/component-display.md) |
| `ShadcnBadge` | 状态标签（6 variant 胶囊） | [component-display](references/component-display.md) |
| `ShadcnDialog` | 对话框（Base UI 规格 + sticky footer + 可滚动 body） | [component-overlay](references/component-overlay.md) |

### Navigation（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnTabs` | 标签页（List / Trigger / Content，default / line） | [component-navigation](references/component-navigation.md) |

### Icon（M4 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnIcon` | 图标（name / size / color，随主题变色） | [core-icon](references/core-icon.md) |
| `IconRegistry` | C++ singleton：本地 74 + 远程兜底 + 磁盘缓存 | [core-icon](references/core-icon.md) |

## 关键坑（务必先读）

| 坑 | 说明 |
|----|------|
| override QQC 子组件丢定位 | `handle` / `indicator` / `background` 的 x/y/width 在模板默认组件内部，override 后不自动应用 → 必须自带定位 |
| ScrollView 内取 implicitHeight | 被视口裁剪取不到 → 固定 `height: implicitHeight` |
| TextArea 内部滚动 | QQC.TextArea 无 Flickable、TextEdit 原生不响应滚轮 → 用 Flickable + TextEdit + ScrollBar |
| contentHeight 早期 undefined | Math.min/max 遇 NaN 传播拖垮组件 → `> 0` 兜底 |
| readonly property 引用子对象 | 创建期立即求值 → null，放惰性绑定里 |

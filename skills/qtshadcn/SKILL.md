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
5. 库支持两种接入：源码子项目（`add_subdirectory`，链接 `QtShadcn`）或安装后 `find_package(QtShadcn 0.2 REQUIRED)` + 链接 `QtShadcn::QtShadcn`。别写第三种（如自己手搓 `find_library`）

```bash
mkdir -p third_party
git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn
```

```cmake
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
add_subdirectory(third_party/qtshadcn)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Quick Qt6::QuickControls2)
```

链接上 `QtShadcn` 就够 `import QtShadcn`，**不需要设 `QML_IMPORT_PATH`**：qmldir 里是 `prefer :/qt/qml/QtShadcn/`，QML 模块（qmldir、类型信息、全部 .qml）都编译进了库资源。只有「不链接库、纯靠 import 路径加载」（例如单独跑 `.qml` 文件、给 qmllint 指路）时才需要，那时指到模块目录的**父路径**（`build/third_party/qtshadcn/src`）。

库自 0.2.0 起也支持安装后 `find_package(QtShadcn 0.2 REQUIRED)` + `target_link_libraries(app PRIVATE QtShadcn::QtShadcn)`。完整模板（CMake / `main.cpp` / Makefile）见 [build](references/consumer/build.md)。

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
| `ShadcnInput` | 单行输入（`h-8` 32px + `radiusLg` 圆角 + 聚焦环） | [component-form](references/consumer/component-form.md) |
| `ShadcnInputGroup` | 输入框前缀/后缀（icon 或文本） | [component-form](references/consumer/component-form.md) |
| `ShadcnTextarea` | 多行输入（Flickable 实现，`maxHeight` 内部滚动） | [component-form](references/consumer/component-form.md) |
| `ShadcnCheckbox` | 复选框（16px + 选中 primary 底 + check） | [component-form](references/consumer/component-form.md) |
| `ShadcnRadio` / `ShadcnRadioGroup` | 单选组（16px 正圆 + 内圆点） | [component-form](references/consumer/component-form.md) |
| `ShadcnSwitch` | 开关（Default 32×18 / Small 24×14） | [component-form](references/consumer/component-form.md) |
| `ShadcnSlider` | 滑块（4px muted 轨道 + 12px 正圆 thumb） | [component-form](references/consumer/component-form.md) |
| `ShadcnProgress` | 进度条（12px 轨道 + primary 指示条 + 百分比） | [component-form](references/consumer/component-form.md) |
| `ShadcnSelect` | 下拉选择（trigger + chevron + popover 弹层） | [component-form](references/consumer/component-form.md) |
| `ShadcnInputOTP` | 验证码输入（N 格 + 首末格外圆角 + `completed` 信号） | [component-form](references/consumer/component-form.md) |
| `ShadcnField` 组 | 表单字段容器（label / 描述 / 错误 / 必填 + orientation） | [component-form](references/consumer/component-form.md) |

### Layout & Feedback（M3 ✅）

| 组件 | 说明 | 参考 |
|------|------|------|
| `ShadcnCard` | 卡片容器（Header / Content / Footer 组合） | [component-display](references/consumer/component-display.md) |
| `ShadcnBadge` | 状态标签（6 variant 胶囊） | [component-display](references/consumer/component-display.md) |
| `ShadcnAvatar` | 圆形头像（图片/图标/首字母 + 5 尺寸 + StatusDot 覆盖） | [component-display](references/consumer/component-display.md) |
| `ShadcnStatusDot` | 语义色状态圆点（Online/Away/Busy/Offline/Success/Warning/Danger） | [component-display](references/consumer/component-display.md) |
| `ShadcnDialog` | 对话框（Base UI 规格 + sticky footer + 可滚动 body） | [component-overlay](references/consumer/component-overlay.md) |
| `ShadcnEmpty` + `EmptyHeader` / `EmptyMedia` / `EmptyTitle` / `EmptyDescription` / `EmptyContent` | 空状态占位（居中列 + 可选虚线描边，Shape 实现） | [component-feedback](references/consumer/component-feedback.md) |

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
| **`textInteractionFlags` 在 Qt 6.11 不存在** | `Text` / `TextEdit` / `TextInput` 都没有这个属性（`strings QtQuick.framework/Versions/A/QtQuick \| grep -x textInteractionFlags` 查不到属性名），写了会 `Cannot assign to non-existent property` 让**整个 QML 加载失败**（`QQmlApplicationEngine failed to load component`）。要「只读 + 可鼠标选中复制」：`TextEdit { readOnly: true; selectByMouse: true; persistentSelection: true }`；`Text` 完全不可选。`TextEdit` 的 `implicitHeight` 是只读的，自动高度用 `height: Math.max(18, contentHeight)` |
| **工程在网络盘上 → 构建目录必须挪到本机** | 源码在 SMB/NFS 盘（如 `/Volumes/Keil_v5`）且 `build/` 也在盘上时，CMake 生成的中间文件会在编译阶段\"找不到\"：`include could not find requested file: build/.qt/<app>_qml.cmake`，或 `CMakeFiles/Makefile2` 缺失导致 `make` 报 `No rule to make target 'all'`（重新 configure 也没用）。Makefile 里把 `BUILD_DIR` 默认指向本机（`LOCAL_BUILD ?= $(HOME)/dev/qt/<项目名>-build`），`QML_IMPORT` 跟着 `$(BUILD_DIR)` 走 |
| **`ShadcnSelect` 可以直喂 C++ 模型（0.2.0 起）** | 委托文本已改为从 delegate 注入的 `modelData` 按 `textRole` 取字段，取不到才退回 `String(modelData)`。旧实现用 `Array.isArray(model)` 分流，而 C++ 的 `QVariantList`/`QStringList` 在 QML 里 `Array.isArray` 为 false，会显示字面量 `"undefined"`。现在 JS 字符串数组、对象数组 + `textRole`、`ListModel`、C++ list 都能直接用，不必再手动转成字符串数组 |
| **`ShadcnCard` 里要「撑满剩余高度」的内容（0.2.0 起）** | Card 的内容容器是 `ColumnLayout`，子项直接写 `Layout.fillHeight: true`，不用再手算「卡片高 − Header − Footer − 内边距」（旧实现是 `Column`，既不吃 `Layout.*` 也禁竖向 `anchors`，卡片被压扁时固定高度子项会冲出边框）。副作用：Card 直接子项不能再靠 `x`/`y` 自由定位（会被 Layout 接管），居中改用 `Layout.alignment: Qt.AlignCenter` |
| **隐式宽度来自内容的项放进 Layout 会撑宽整列** | `ShadcnCard` 自 0.2.0 起内部已声明 `Layout.minimumWidth: 0`，不再被 `implicitWidth: 320` 顶住（此前一行 4 张统计卡 = 最小宽 1316px，把整个界面顶宽、右侧被切）。但其他隐式宽来自内容的项（`TextEdit` / `Flickable` / `ComboBox` / `ShadcnSelect`）放进布局时仍要显式 `Layout.minimumWidth: 0`，否则会层层上传撑宽整列；再给不该变宽的列加 `Layout.maximumWidth` 卡住。定位手法：加个 600ms `Timer` 打印各级 `width / Layout.minimumWidth`，一眼看出谁在要求超宽（`onCompleted` 时布局还没收敛，量不准） |

## References

| 主题 | 参考 |
|------|------|
| 消费方最小工程（CMake / `main.cpp` / Makefile / `QML_IMPORT_PATH`） | [build](references/consumer/build.md) |
| 组件用法（Button / Form / Display / Navigation / Overlay） | `references/consumer/component-*.md` |
| 组件用法（M6：Separator / Label / Alert / Skeleton / Kbd / Tooltip / DropdownMenu） | [component-feedback](references/consumer/component-feedback.md) |
| Theme 系统（`ThemeManager` / `QtShadcnTheme` / token 字典 / 明暗 / 主色） | [core-theme](references/common/core-theme.md) |
| Icon 系统（`IconRegistry` / `ShadcnIcon` / 图标打包） | [core-icon](references/common/core-icon.md) |
| 扩展本库（新增组件 / 改 token / 截图 / 发布流程） | `qtshadcn-dev` skill |

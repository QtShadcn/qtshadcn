---
name: feedback-components
description: ShadcnSeparator / ShadcnLabel / ShadcnAlert / ShadcnSkeleton / ShadcnKbd / ShadcnTooltip / ShadcnDropdownMenu 用法（M6）。
---

# 反馈与浮层（M6）

## ShadcnSeparator

分隔线，1px 细线 + `theme.border`。

```qml
ShadcnSeparator { width: parent.width }                        // 水平（默认）
ShadcnSeparator { text: qsTr("或") }                           // 带文字：两端等宽、文字居中
ShadcnSeparator { orientation: Qt.Vertical; height: 60 }       // 竖直：必须给 height
```

| 属性 | 说明 |
|------|------|
| `orientation` | `Qt.Horizontal`（默认）/ `Qt.Vertical` |
| `text` | 非空时线被文字打断，12px muted 色 |

## ShadcnLabel

语义化文本标签，3 variant × 3 size。

```qml
ShadcnLabel { text: qsTr("标题") }
ShadcnLabel { text: qsTr("提示"); variant: ShadcnLabel.Variant.Muted }
ShadcnLabel { text: qsTr("错误"); variant: ShadcnLabel.Variant.Destructive }
ShadcnLabel { text: qsTr("大标题"); size: ShadcnLabel.Size.Large }
```

- `Variant`：`Default` / `Muted` / `Destructive`
- `Size`：`Small` 12px / `Medium` 14px / `Large` 18px（Large 自动加粗）

## ShadcnAlert

提示框，图标随 variant 自动切换（`alert-circle` / `check-circle` / `alert-triangle` / `info`，可用 `iconName` 覆盖）。

```qml
ShadcnAlert {
    title: qsTr("错误")
    description: qsTr("发生错误，请稍后重试。")
    variant: ShadcnAlert.Variant.Destructive
}

// 带操作按钮：直接放子元素（默认属性 → 右上角操作区）
ShadcnAlert {
    title: qsTr("确认")
    ShadcnButton { text: qsTr("知道了"); size: ShadcnButton.Size.Small }
}
```

- `Variant`：`Default` / `Destructive` / `Warning` / `Success`
- 配色全走 token（`Qt.alpha(主题色, 0.1)` 背景 + `0.3` 边框）
- **没有 `ShadcnAlertAction` 类型**：源码注释里出现过这个名字，是残留；操作按钮直接作为子元素声明

## ShadcnSkeleton

骨架屏占位块，`theme.muted` 底 + 1.4s opacity 闪烁（1.0 ↔ 0.5）。

```qml
ShadcnSkeleton { width: 200; height: 16 }
ShadcnSkeleton { width: 48; height: 48; radius: 24 }   // 圆形（头像）
```

`radius` 默认 4；`width` / `height` 必须给，否则占位不可见。

## ShadcnKbd / ShadcnKbdGroup

键盘快捷键标签：`theme.muted` 底 + `theme.border` 边框 + 4px 圆角，11px 等宽字体。

```qml
ShadcnKbd { text: "⌘K" }
ShadcnKbd { text: "Ctrl" }

ShadcnKbdGroup {                      // 组合键：内部并排多个 ShadcnKbd
    ShadcnKbd { text: "⌘" }
    ShadcnKbd { text: "K" }
}
```

`fontFamily` 留空 = 系统 monospace 兜底（macOS 走 Menlo；**不要**写 `SF Mono`，该系统不存在该字体名）。

## ShadcnTooltip

悬停提示，**作为目标的子元素声明**（不是附着属性）：

```qml
ShadcnButton {
    text: qsTr("悬停我")
    ShadcnTooltip { text: qsTr("这是一个简单的提示") }
}
```

- 实现是 `Item` 子组件：向上查找第一个带 `hovered` 的祖先（Button 的 contentItem 没有），hover 300ms 后经 `QQC.Popup` 显示在父元素下方 6px，离开 100ms 后消失
- 12px `theme.popoverForeground`，最大宽 200px 自动换行；`text` 为空不显示
- **坑**：`ShadcnTooltip.text: qsTr("…")` 这种附着写法会报 `Non-existent attached object`（它是 `Item` 子类，不是 `QQC.ToolTip` 子类）—— 文档站 `24.tooltip.md` 的示例仍是这种错误写法，别照抄

## ShadcnDropdownMenu

Trigger + Content + Item 组合，菜单渲染在 `QQC.Popup`（Overlay 层，天然置顶）。

```qml
ShadcnDropdownMenu {
    ShadcnDropdownMenuTrigger { text: qsTr("打开菜单"); variant: ShadcnButton.Variant.Outline }

    ShadcnDropdownMenuContent {
        ShadcnDropdownMenuLabel { text: qsTr("我的账号") }
        ShadcnDropdownMenuGroup {
            ShadcnDropdownMenuItem { text: qsTr("个人中心"); iconName: "user"; shortcut: "⇧⌘P" }
            ShadcnDropdownMenuItem { text: qsTr("设置"); iconName: "settings" }
        }
        ShadcnDropdownMenuSeparator { }
        ShadcnDropdownMenuItem { text: qsTr("退出登录"); iconName: "log-out"; variant: ShadcnDropdownMenuItem.Variant.Destructive }
    }
}
```

| 组件 | 要点 |
|------|------|
| `ShadcnDropdownMenu` | `open` 属性可双向控制；ESC / 点击外部关闭 |
| `ShadcnDropdownMenuTrigger` | 基于 `ShadcnButton`，支持 `variant` / `size` / `iconName` |
| `ShadcnDropdownMenuContent` | Rectangle + MultiEffect 阴影，圆角跟 `theme.radius`；进入/退出 opacity + scale（100ms） |
| `ShadcnDropdownMenuItem` | `text` / `iconName` / `shortcut`（**仅展示，不注册真实键绑定**）/ `variant`（`Default` / `Destructive`）/ `clicked()` 信号 |
| `ShadcnDropdownMenuGroup` / `ShadcnDropdownMenuLabel` / `ShadcnDropdownMenuSeparator` / `ShadcnDropdownMenuShortcut` | 分组、小标题、分隔线、快捷键文本，纯容器，无公开 API |

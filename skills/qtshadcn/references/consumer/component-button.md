---
name: button-components
description: ShadcnButton / ShadcnButtonGroup / ShadcnToggle / ShadcnToggleGroup / ShadcnSpinner 用法与属性。
---

# Button 系列（M2）

基于 QQC.Button / AbstractButton（Basic style），只替换视觉与 API，保留键盘导航 / Focus / 无障碍。

## ShadcnButton

```qml
ShadcnButton {
    text: qsTr("Deploy")
    variant: ShadcnButton.Variant.Primary   // Primary / Secondary / Outline / Ghost / Destructive / Link
    size: ShadcnButton.Size.Medium          // ExtraSmall / Small / Medium / Large / Icon
    iconName: ""                            // lucide 图标（16px，随文字色）
    loading: false                          // Spinner + 禁用交互
    onClicked: console.log("clicked")
}
```

- **variant**：Primary 实心主色 / Secondary 次色 / Outline 描边 / Ghost 幽灵 / Destructive 危险 / Link（hover 下划线）
- **size**：XS=32 / Small=36 / Medium=40 / Large=44 / Icon=40（对齐 shadcn/ui）
- **hover**：实心变体混入亮度（hover:bg-*/90）；outline/ghost hover 用 accent 底 + accentForeground
- **focus**：3px ring 焦点环；**disabled**：opacity 50%
- **配色映射**集中在 `VariantTokens`（`vt.button[variant]`），新增 variant 只需枚举 + 映射各加一项

## ShadcnButtonGroup

```qml
ShadcnButtonGroup {
    ShadcnButton { text: "A" }
    ShadcnButton { text: "B" }
    ShadcnButton { text: "C" }
}
```

- 组内 `spacing: -1` 合并边框；无 border variant 中间自动 1px 分隔线
- 圆角只留两端（`_groupPosition` first/middle/last）

## ShadcnToggle / ShadcnToggleGroup

```qml
ShadcnToggle { text: "粗体"; checked: true }

ShadcnToggleGroup {                 // 多选（默认 exclusive:false）
    ShadcnToggle { text: "左" }
    ShadcnToggle { text: "中"; checked: true }
}

ShadcnToggleGroup { exclusive: true }  // 单选
```

- outline 样式 + checkable，选中 accent 背景
- 组内互斥由 QQC ButtonGroup 提供（onCompleted 手动收集子项）

## ShadcnSpinner

```qml
ShadcnSpinner { width: 14; height: 14; color: theme.foreground }
```

- 圆环旋转动画；`ShadcnButton { loading: true }` 内部即用它

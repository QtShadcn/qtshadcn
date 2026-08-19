---
name: theme
description: QtShadcn Design Token 主题系统：ThemeManager（C++）、QtShadcnTheme、VariantTokens、明暗切换与运行时主色。
---

# Theme 系统

Design Token 驱动的主题引擎：C++ `ThemeManager` 持有 light/dark 两套 token，QML `QtShadcnTheme` 声明式绑定，所有组件绑定自动刷新。

## 架构

- `ThemeManager`（`src/core/thememanager.cpp`）：QML singleton，持有 token 字典；`mode` 明暗、`primary` 主色支持运行时改
- `QtShadcnTheme`（`src/qml/Theme/QtShadcnTheme.qml`）：声明式入口，绑定 C++ token，组件里 `QtShadcnTheme { id: theme }`
- `VariantTokens`（`src/qml/Theme/VariantTokens.qml`）：variant → token 映射表，按组件分数组（`vt.button[variant]`、`vt.badge[variant]` 等）

## 用法

```qml
Window {
    QtShadcnTheme { id: theme }

    color: theme.background            // 窗口底色跟主题走

    ShadcnButton {
        text: qsTr("切换")
        onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
    }
}
```

## Theme 属性（全部只读，组件直接绑定）

| 类别 | 属性 |
|------|------|
| 颜色 | `background` `foreground` `primary` `primaryForeground` `secondary` `secondaryForeground` `muted` `mutedForeground` `accent` `accentForeground` `destructive` `destructiveForeground` `border` `ring` `input` `card` `popover` |
| 形状 | `radius`（全局圆角） |
| 间距 | `spacingXs` `spacingSm` `spacingMd` `spacingLg` `spacingXl` |
| 原始字典 | `tokens`（动态索引，如 `theme.tokens["primary"]`） |

## 运行时改主色

```qml
ThemeManager.primary = "#2563eb"   // 空字符串 "" = 恢复默认主色
```

- 所有 `theme.tokens[...]` 绑定自动刷新（主色 / primaryForeground / accent 等随动）

## 设计决策

- **圆角体系**：控件 6px / 容器 8px / Badge 胶囊（不跟 shadcn v4 激进大圆角，遵循 M2 决策）
- **涨跌色**：金融场景沿用国内惯例（涨红跌绿），默认主题色不受影响
- token 命名对齐 shadcn CSS 变量（`--background` → `background` 等），前缀 `Shadcn` 区分 QQC 基类

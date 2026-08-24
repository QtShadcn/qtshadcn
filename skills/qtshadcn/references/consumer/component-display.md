---
name: display-components
description: ShadcnCard（Header/Content/Footer 组合）与 ShadcnBadge（6 variant 胶囊）用法。
---

# 布局与反馈（M3）

## ShadcnCard

纯组合组件：`Card = CardHeader / CardContent / CardFooter`。

```qml
ShadcnCard {
    width: 320
    // size: ShadcnCard.Size.Default（padding 24px）/ Small（16px）

    ShadcnCardHeader {
        ShadcnCardTitle { text: qsTr("Card Title") }
        ShadcnCardDescription { text: qsTr("Card Description") }
    }
    ShadcnCardContent { Text { text: qsTr("内容区") } }
    ShadcnCardFooter {
        ShadcnButton { text: qsTr("取消"); variant: ShadcnButton.Variant.Outline; size: ShadcnButton.Size.Small }
        ShadcnButton { text: qsTr("确定"); size: ShadcnButton.Size.Small }
    }
}
```

子组件：

| 组件 | 说明 |
|------|------|
| `ShadcnCardHeader` | Title（16px Medium）+ Description（14px mutedForeground）垂直堆叠（gap 6px） |
| `ShadcnCardTitle` / `ShadcnCardDescription` | 标题 / 描述 |
| `ShadcnCardContent` / `ShadcnCardFooter` | 内容区 / 底部按钮区（gap 8px） |

视觉：`bg-card` + 1px 前景色环（light 5% / dark 10%）+ `shadow-md` + `theme.radius` 圆角。

## ShadcnBadge

```qml
ShadcnBadge { text: "Default"; variant: ShadcnBadge.Variant.Default }
ShadcnBadge { text: "Secondary"; variant: ShadcnBadge.Variant.Secondary }
ShadcnBadge { text: "Destructive"; variant: ShadcnBadge.Variant.Destructive }
ShadcnBadge { text: "Outline"; variant: ShadcnBadge.Variant.Outline }
ShadcnBadge { text: "Ghost"; variant: ShadcnBadge.Variant.Ghost }
ShadcnBadge { text: "Link"; variant: ShadcnBadge.Variant.Link }
```

- 6 variant：default / secondary / destructive / outline / ghost / link
- 高 20px 胶囊（radius 999）+ 12px Medium
- destructive 是 v4 风格「透明底 + 红字」（非旧版实心红底白字）

## ShadcnAvatar

圆形头像，内容按优先级 `source` > `iconName` > `text`（取首字母大写）。右下角可叠加 `ShadcnStatusDot` 做在线状态指示。

```qml
// 首字母头像 + 在线状态
ShadcnAvatar {
    size: ShadcnAvatar.Size.Medium
    text: "Ryan"
    status: ShadcnStatusDot.Status.Online
}

// 图标头像
ShadcnAvatar { iconName: "user" }

// 图片头像
ShadcnAvatar {
    source: "file:/path/to/photo.png"
    size: ShadcnAvatar.Size.XLarge
}

// 自定义底色 + 文字色
ShadcnAvatar {
    text: "李"
    bgColor: theme.secondary
    textColor: theme.secondaryForeground
}
```

**API：**

| 属性 | 类型 | 说明 |
|------|------|------|
| `size` | enum | `XSmall(24)` / `Small(32)` / `Medium(44)` / `Large(56)` / `XLarge(72)`，默认 Medium |
| `source` | url | 图片源，`PreserveAspectCrop` + Retina 2× 采样 |
| `iconName` | string | 无图片时显示图标（lucide name） |
| `text` | string | 无图也无图标时取首字母大写 |
| `bgColor` / `textColor` / `iconColor` | color | 自定义颜色，默认 primary / primaryForeground |
| `status` | enum | 透传给右下角 `ShadcnStatusDot`，默认 `None` |

**Avatar Group（堆叠）**：外层 Row 设置 `spacing: -12`，每个头像右侧加 1px `theme.card` 色遮挡条即可产生 shadcn 风格的堆叠效果。

## ShadcnStatusDot

纯视觉语义色圆点。用户状态 + 服务健康状态通用；`status=None` 时 `visible=false`。

```qml
// 独立使用
ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 8 }

// 叠在 Avatar 等彩色背景上：border=true 用 theme.card 色描边，保证边缘清晰
ShadcnStatusDot {
    status: ShadcnStatusDot.Status.Success
    size: 12
    border: true
}
```

**Status 枚举 → 颜色映射：**

| Status | 颜色 | 语义 |
|--------|------|------|
| `Online` / `Success` | `#22c55e`（绿） | 在线 / 成功 |
| `Away` / `Busy` / `Warning` | `#f59e0b`（黄） | 离开 / 忙碌 / 警告 |
| `Danger` | `#ef4444`（红） | 危险 / 错误 |
| `Offline` | `theme.mutedForeground` | 离线（随主题自动适配） |
| `None` | 透明，隐藏 | 无状态 |

颜色直接写死 Tailwind 语义十六进制值（明暗对比度均 ≥ AA）；将来 `QtShadcnTheme` 补 `success/warning/danger` 语义 token 时，内部替换即可，API 保持不变。

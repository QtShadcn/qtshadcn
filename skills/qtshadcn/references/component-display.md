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

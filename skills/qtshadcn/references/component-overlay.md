---
name: overlay-components
description: ShadcnDialog（Base UI 规格 + sticky footer + 可滚动 body + 关闭钮）用法与实现坑。
---

# ShadcnDialog（M3）

基于 QQC.Dialog（Basic style），对齐 shadcn Base UI 默认规格：384px 宽 + rounded-xl(14px) + fade/zoom 动画 + ghost 关闭钮 + 可滚动 body + sticky muted footer。

## 用法

```qml
ShadcnButton { text: qsTr("打开"); onClicked: dialog.open() }

ShadcnDialog {
    id: dialog
    modal: true

    ShadcnDialogContent {
        ShadcnDialogHeader {
            ShadcnDialogTitle { text: qsTr("确认操作？") }
            ShadcnDialogDescription { text: qsTr("此操作不可撤销。") }
        }
        // 业务内容（超高时 body 内部滚动，footer 固定）
        ShadcnDialogFooter {
            ShadcnButton { text: qsTr("取消"); variant: ShadcnButton.Variant.Outline; onClicked: dialog.close() }
            ShadcnButton { text: qsTr("确认"); variant: ShadcnButton.Variant.Destructive; onClicked: dialog.close() }
        }
    }
}
```

## 子组件

| 组件 | 说明 |
|------|------|
| `ShadcnDialogContent` | 内容容器：可滚动 body + sticky muted footer 条；`maxHeight` 可自定义（默认 0.85×窗口高） |
| `ShadcnDialogHeader` | Title + Description 垂直堆叠 |
| `ShadcnDialogTitle` / `ShadcnDialogDescription` | 标题（text-base）/ 描述（mutedForeground） |
| `ShadcnDialogFooter` | 底部按钮区（右对齐，gap 8） |

## 属性

| 属性 | 说明 |
|------|------|
| `showCloseButton` | 右上角 ghost 关闭钮（默认 true） |
| `modal` | 模态遮罩（QQC 默认黑 50%） |
| `maxHeight` | Content 高度上限（超过 body 滚动、footer 固定），默认 0.85×窗口高 |

## 实现坑（务必注意）

1. **ScrollView 内 Column 取不到 implicitHeight**（被视口裁剪）→ `bodyColumn.height: implicitHeight` 固定自然高度
2. **关闭钮不能作为 Dialog 的第二个子节点**（破坏 contentItem 单子节点，popup 高度不塌缩）→ 关闭钮改由 `ShadcnDialogContent` 渲染 + `closeClicked` 信号回连 `dialog.close()`
3. 圆角 14px（`rounded-xl`，overlay > inline 容器惯例）；不跟 luma `rounded-4xl`(26px)

## 视觉

- content：`grid gap-4 rounded-xl bg-popover p-4 text-sm ring-1 ring-foreground/10(dark) sm:max-w-sm(384)`
- header：`flex flex-col gap-2`；title `text-base`
- footer：sticky muted 条（`-mx-4 -mb-4 rounded-b-xl border-t bg-muted/50 p-4`，按钮 `sm:flex-row` 右对齐）
- 关闭钮：ghost（`absolute top-2 right-2 size-7`，hover bg-muted）
- 动效：QQC enter/exit fade + zoom-95，100ms

import QtQuick

// shadcn/ui 风格 Dialog 底部：按钮区，右对齐、gap-2（对齐 shadcn cn-dialog-footer sm:justify-end）
// 通常作为 ShadcnDialogContent 的 footer 属性传入，渲染在固定 muted 条内
Row {
    id: root

    spacing: 8   // shadcn gap-2
    anchors.right: parent.right
}

import QtQuick

// shadcn/ui 风格 Dialog 底部：按钮区，水平排列、gap-2（对齐 shadcn cn-dialog-footer）
Row {
    id: root

    spacing: 8   // shadcn gap-2
    width: parent ? parent.width : implicitWidth
}

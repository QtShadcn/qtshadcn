import QtQuick

// shadcn/ui 风格 Dialog 头部：Title + Description 垂直堆叠（对齐 shadcn cn-dialog-header）
Column {
    id: root

    spacing: 8   // shadcn cn-dialog-header gap-2
    width: parent ? parent.width : implicitWidth
}

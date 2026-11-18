import QtQuick

// 卡片底部：按钮区，子项水平排列（对齐 shadcn cn-card-footer: flex items-center）
Row {
    id: root

    spacing: 8   // shadcn: gap-2
    width: parent ? parent.width : implicitWidth
}

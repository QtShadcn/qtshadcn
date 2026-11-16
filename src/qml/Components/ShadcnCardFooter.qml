import QtQuick
import QtQuick.Layouts

// 卡片底部：按钮区，子项水平排列（对齐 shadcn cn-card-footer: flex items-center）
// 宽度由 ShadcnCard 的 ColumnLayout 管理（Layout.fillWidth），不要自己写 width。
Row {
    id: root

    spacing: 8   // shadcn: gap-2

    Layout.fillWidth: true
}

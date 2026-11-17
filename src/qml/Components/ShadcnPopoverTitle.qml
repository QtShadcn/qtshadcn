// src/qml/Components/ShadcnPopoverTitle.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格 Popover 标题：font-medium（text-sm 由 Content 继承）
// 对齐 registry popover-title
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.popoverForeground
    font.pixelSize: 14      // text-sm（registry Content 的 text-sm 继承到 Title）
    font.weight: Font.Medium
    wrapMode: Text.WordWrap
    // 宽度取父项（Header 的 Column 被 Content 拉满 268px），但短标题保持自然宽，
    // 长标题在面板内换行
    width: parent ? Math.min(parent.width, implicitWidth) : implicitWidth
}

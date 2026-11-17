// src/qml/Components/ShadcnPopoverDescription.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格 Popover 描述：text-muted-foreground（text-sm 由 Content 继承）
// 对齐 registry popover-description
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 14
    wrapMode: Text.WordWrap
    width: parent ? Math.min(parent.width, implicitWidth) : implicitWidth
}

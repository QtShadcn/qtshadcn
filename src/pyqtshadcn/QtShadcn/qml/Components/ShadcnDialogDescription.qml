import QtQuick
import QtShadcn

// shadcn/ui 风格 Dialog 描述：text-sm + mutedForeground（对齐 shadcn cn-dialog-description）
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 14
    wrapMode: Text.WordWrap
}

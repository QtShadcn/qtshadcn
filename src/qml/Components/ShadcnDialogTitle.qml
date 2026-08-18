import QtQuick
import QtShadcn

// shadcn/ui 风格 Dialog 标题：text-base(16px) font-medium leading-none（对齐 shadcn cn-dialog-title）
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.popoverForeground
    font.pixelSize: 16
    font.weight: Font.Medium
    wrapMode: Text.WordWrap
}

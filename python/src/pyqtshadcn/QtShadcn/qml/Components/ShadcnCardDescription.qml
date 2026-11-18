import QtQuick
import QtShadcn

// 卡片描述：text-sm(14px) + mutedForeground，对齐 shadcn cn-card-description
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 14
    wrapMode: Text.WordWrap
}

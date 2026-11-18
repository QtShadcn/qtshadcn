import QtQuick
import QtShadcn

// 卡片标题：text-base(16px) + font-medium，对齐 shadcn cn-card-title
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.cardForeground
    font.pixelSize: 16
    font.weight: Font.Medium
}

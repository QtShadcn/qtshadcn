// src/qml/Components/ShadcnDropdownMenuLabel.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格菜单分组标题（M6）
// 规范：px-2 py-1.5 text-sm font-medium text-muted-foreground
// 用法:
//   ShadcnDropdownMenuLabel { text: "我的账号" }
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 12
    font.weight: Font.Medium

    leftPadding: 8    // px-2
    topPadding: 6     // py-1.5
    bottomPadding: 6
}

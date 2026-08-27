// src/qml/Components/ShadcnDropdownMenuSeparator.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格菜单分隔线（M6）
// 规范：my-1（垂直 margin 4px）
// 用法:
//   ShadcnDropdownMenuSeparator {}
Rectangle {
    id: root

    QtShadcnTheme { id: theme }

    height: 1
    color: theme.border
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 4   // my-1
    anchors.bottomMargin: 4
}

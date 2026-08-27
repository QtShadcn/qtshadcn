// src/qml/Components/ShadcnKbd.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格键盘快捷键标签（M6）
// 用法:
//   ShadcnKbd { text: "⌘K" }
//   ShadcnKbd { text: "Ctrl" }
Rectangle {
    id: root

    property string text: ""

    QtShadcnTheme { id: theme }

    radius: 4
    color: theme.muted
    border.width: 1
    border.color: theme.border
    implicitWidth: label.implicitWidth + 12
    implicitHeight: label.implicitHeight + 6

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: theme.foreground
        font.pixelSize: 11
        font.family: "SF Mono, Menlo, monospace"
    }
}

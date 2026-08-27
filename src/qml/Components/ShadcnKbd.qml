// src/qml/Components/ShadcnKbd.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格键盘快捷键标签（M6）
// 规范：inline-flex items-center justify-center kbd 样式
// 用法:
//   ShadcnKbd { text: "⌘K" }
//   ShadcnKbd { text: "Ctrl" }
//   ShadcnKbd { text: "Ctrl"; fontFamily: "Cascadia Code" }
Rectangle {
    id: root

    property string text: ""
    property string fontFamily: ""  // 空 = 系统 monospace fallback

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
        font.family: root.fontFamily !== "" ? root.fontFamily
                   : Qt.platform.os === "osx" ? "Menlo"
                   : "monospace"
    }
}

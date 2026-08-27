import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    QtShadcnTheme { id: theme }

    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40
        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnKbd")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("键盘快捷键标签：等宽字体 + 边框 + 圆角。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    ScrollView {
        id: sv
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            SectionTitle { text: qsTr("基础用法") }
            Flow {
                spacing: 8
                ShadcnKbd { text: "⌘K" }
                ShadcnKbd { text: "Ctrl" }
                ShadcnKbd { text: "C" }
                ShadcnKbd { text: "V" }
                ShadcnKbd { text: "⇧" }
                ShadcnKbd { text: "⌥" }
                ShadcnKbd { text: "Esc" }
                ShadcnKbd { text: "Enter" }
            }

            SectionTitle { text: qsTr("组合快捷键") }
            Row {
                spacing: 4
                ShadcnKbd { text: "⌘" }
                Text { text: "+"; color: theme.mutedForeground; anchors.verticalCenter: parent.verticalCenter }
                ShadcnKbd { text: "Shift" }
                Text { text: "+"; color: theme.mutedForeground; anchors.verticalCenter: parent.verticalCenter }
                ShadcnKbd { text: "P" }
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnKbd { text: \"⌘K\" }\nShadcnKbd { text: \"Ctrl\" }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

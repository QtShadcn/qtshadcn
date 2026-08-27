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
            text: qsTr("键盘快捷键标签：等宽字体 + 边框 + 圆角。支持 KbdGroup 组合多个快捷键。")
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

            SectionTitle { text: qsTr("KbdGroup 组合快捷键") }
            Row {
                spacing: 4
                ShadcnKbdGroup {
                    ShadcnKbd { text: "⌘" }
                    ShadcnKbd { text: "Shift" }
                    ShadcnKbd { text: "P" }
                }
            }
            Row {
                spacing: 4
                ShadcnKbdGroup {
                    ShadcnKbd { text: "Ctrl" }
                    ShadcnKbd { text: "B" }
                }
            }
            Row {
                spacing: 4
                ShadcnKbdGroup {
                    ShadcnKbd { text: "⌘" }
                    ShadcnKbd { text: "K" }
                }
            }

            SectionTitle { text: qsTr("场景：命令面板提示") }
            Row {
                spacing: 8
                ShadcnKbd { text: "⌘" }
                Text { text: "+"; color: theme.mutedForeground; anchors.verticalCenter: parent.verticalCenter }
                ShadcnKbd { text: "Shift" }
                Text { text: "+"; color: theme.mutedForeground; anchors.verticalCenter: parent.verticalCenter }
                ShadcnKbd { text: "P" }
                Text { text: qsTr("打开命令面板"); color: theme.mutedForeground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnKbdGroup {\n    ShadcnKbd { text: \"⌘\" }\n    ShadcnKbd { text: \"K\" }\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

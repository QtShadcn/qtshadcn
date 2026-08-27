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
            text: qsTr("ShadcnTooltip")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("悬停提示：鼠标悬停在元素上显示浮层提示。基于 Popup + HoverHandler 实现。")
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
            Row {
                spacing: 16
                ShadcnButton {
                    text: qsTr("悬停我")
                    ShadcnTooltip { text: qsTr("这是一个简单的提示") }
                }
                ShadcnButton {
                    text: qsTr("带说明")
                    variant: ShadcnButton.Variant.Outline
                    ShadcnTooltip { text: qsTr("提示可以包含更长的说明文字，自动换行显示") }
                }
                ShadcnButton {
                    text: qsTr("禁用按钮")
                    enabled: false
                    ShadcnTooltip { text: qsTr("禁用状态下的提示") }
                }
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnButton {\n    text: \"悬停我\"\n    ShadcnTooltip { text: \"这是提示\" }\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

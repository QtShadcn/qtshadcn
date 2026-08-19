import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Textarea 页：全状态展示
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnTextarea")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("基于 QQC.TextArea：min-h 64 + 6px 圆角 + bg-input/50 + 聚焦环；行数多时随内容增高。")
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

            SectionTitle { text: qsTr("默认") }
            ShadcnTextarea {
                width: 340
                placeholderText: qsTr("输入多行内容...")
            }

            SectionTitle { text: qsTr("带默认内容 / disabled") }
            Row {
                spacing: theme.spacingLg
                ShadcnTextarea {
                    width: 300
                    text: qsTr("这是一段多行文本，\n支持换行。")
                }
                ShadcnTextarea {
                    width: 300
                    text: qsTr("不可编辑")
                    enabled: false
                }
            }

            SectionTitle { text: qsTr("maxHeight 内部滚动（内容超高钳高）") }
            ShadcnTextarea {
                width: 340
                maxHeight: 120
                text: qsTr("第一行\n第二行\n第三行\n第四行\n第五行\n第六行\n第七行\n第八行\n第九行\n第十行\n超过 maxHeight 后内部滚动")
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnTextarea {\n    width: 340\n    placeholderText: \"输入多行内容...\"\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

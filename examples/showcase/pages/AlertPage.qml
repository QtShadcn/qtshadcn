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
            text: qsTr("ShadcnAlert")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("提示框：4 variant（Default / Destructive / Warning / Success），图标 + 标题 + 描述。")
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

            SectionTitle { text: qsTr("Variant") }
            Column {
                width: parent.width
                spacing: 12

                ShadcnAlert {
                    width: parent.width
                    title: qsTr("提示")
                    description: qsTr("这是一条普通提示信息。")
                }
                ShadcnAlert {
                    width: parent.width
                    title: qsTr("成功")
                    description: qsTr("操作已成功完成。")
                    variant: ShadcnAlert.Variant.Success
                }
                ShadcnAlert {
                    width: parent.width
                    title: qsTr("警告")
                    description: qsTr("请注意，此操作不可撤销。")
                    variant: ShadcnAlert.Variant.Warning
                }
                ShadcnAlert {
                    width: parent.width
                    title: qsTr("错误")
                    description: qsTr("发生错误，请稍后重试。")
                    variant: ShadcnAlert.Variant.Destructive
                }
            }

            SectionTitle { text: qsTr("仅标题") }
            ShadcnAlert {
                width: parent.width
                title: qsTr("网络连接已断开")
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnAlert {\n    title: \"错误\"\n    description: \"发生错误\"\n    variant: ShadcnAlert.Variant.Destructive\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

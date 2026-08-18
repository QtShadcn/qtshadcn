import QtQuick
import QtQuick.Layouts
import QtShadcn

// Switch 页：size / 状态 / 组合（Card + Switch + Label）
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnSwitch")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("基于 QQC.Switch（Basic style），胶囊轨道 + 滑块，size default 44×20 / small 28×16。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    SectionTitle { text: qsTr("Default Size") }
    Row {
        spacing: theme.spacingLg
        Row {
            spacing: theme.spacingSm
            ShadcnSwitch { }
            Text { text: qsTr("Off"); color: theme.foreground; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            spacing: theme.spacingSm
            ShadcnSwitch { checked: true }
            Text { text: qsTr("On"); color: theme.foreground; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    SectionTitle { text: qsTr("Small Size") }
    Row {
        spacing: theme.spacingLg
        Row {
            spacing: theme.spacingSm
            ShadcnSwitch { size: ShadcnSwitch.Size.Small }
            Text { text: qsTr("Off"); color: theme.foreground; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            spacing: theme.spacingSm
            ShadcnSwitch { size: ShadcnSwitch.Size.Small; checked: true }
            Text { text: qsTr("On"); color: theme.foreground; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    SectionTitle { text: qsTr("Disabled") }
    Row {
        spacing: theme.spacingLg
        ShadcnSwitch { enabled: false }
        ShadcnSwitch { enabled: false; checked: true }
    }

    SectionTitle { text: qsTr("组合（Card + Switch 列表）") }
    ShadcnCard {
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("通知设置") }
            ShadcnCardDescription { text: qsTr("选择你想接收的通知类型。") }
        }
        ShadcnCardContent {
            Column {
                width: parent.width
                spacing: theme.spacingMd
                Row {
                    width: parent.width
                    Text {
                        text: qsTr("邮件通知")
                        color: theme.foreground
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { Layout.fillWidth: true; width: 1 }
                    ShadcnSwitch { checked: true; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    width: parent.width
                    Text {
                        text: qsTr("推送通知")
                        color: theme.foreground
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { Layout.fillWidth: true; width: 1 }
                    ShadcnSwitch { anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    width: parent.width
                    Text {
                        text: qsTr("短信提醒")
                        color: theme.foreground
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { Layout.fillWidth: true; width: 1 }
                    ShadcnSwitch { anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnSwitch {\n    checked: true\n    size: ShadcnSwitch.Size.Default\n    onCheckedChanged: ...\n}"
    }
}

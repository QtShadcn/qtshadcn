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
            text: qsTr("ShadcnSeparator")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("分隔线：水平 / 竖直 / 带文字分隔。")
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

            SectionTitle { text: qsTr("水平分隔线") }
            Column {
                width: parent.width - 48
                spacing: 16
                Text { text: qsTr("上方内容"); color: theme.foreground; font.pixelSize: 13 }
                ShadcnSeparator { width: parent.width }
                Text { text: qsTr("下方内容"); color: theme.foreground; font.pixelSize: 13 }
            }

            SectionTitle { text: qsTr("带文字的分隔线") }
            ShadcnSeparator { text: qsTr("或"); width: parent.width - 48 }

            SectionTitle { text: qsTr("竖直分隔线") }
            Row {
                spacing: 24
                height: 60
                Text { text: qsTr("左"); color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                ShadcnSeparator { orientation: Qt.Vertical; height: parent.height }
                Text { text: qsTr("右"); color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnSeparator { }\nShadcnSeparator { text: \"或\" }\nShadcnSeparator { orientation: Qt.Vertical }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

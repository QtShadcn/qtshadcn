import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Progress 页：全状态展示
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
            text: qsTr("ShadcnProgress")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("12px muted 轨道 + primary 指示条（宽度动画）；showValue 显示百分比。")
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

            SectionTitle { text: qsTr("进度（0-1）") }
            ShadcnProgress {
                width: 360
                value: 0.6
            }

            SectionTitle { text: qsTr("带百分比") }
            ShadcnProgress {
                width: 360
                value: 0.3
                showValue: true
            }

            SectionTitle { text: qsTr("带动画演示（Timer 递增）") }
            ShadcnProgress {
                id: animProgress
                width: 360
                value: 0
                showValue: true
            }
            Timer {
                interval: 100
                repeat: true
                running: true
                onTriggered: animProgress.value = (animProgress.value + 0.01) % 1.0
            }

            RowLayout {
                spacing: theme.spacingSm
                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: qsTr("查看文档 ›")
                    color: theme.primary
                    font.pixelSize: 12
                    font.underline: docHover.containsMouse
                    MouseArea {
                        id: docHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/progress")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnProgress {\n    width: 360\n    value: 0.6        // 0..1\n    showValue: true  // 显示百分比\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

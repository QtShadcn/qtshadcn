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
            text: qsTr("ShadcnSkeleton")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("骨架屏：数据加载时的占位闪烁效果。")
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

            SectionTitle { text: qsTr("基础形状") }
            Flow {
                width: parent.width
                spacing: 12
                ShadcnSkeleton { width: 48; height: 48; radius: 24 }
                ShadcnSkeleton { width: 48; height: 48; radius: 8 }
                ShadcnSkeleton { width: 120; height: 16 }
                ShadcnSkeleton { width: 80; height: 16 }
                ShadcnSkeleton { width: 200; height: 12 }
            }

            SectionTitle { text: qsTr("卡片骨架屏示例") }
            ShadcnCard {
                width: 320
                ShadcnCardContent {
                    Column {
                        spacing: 12
                        Row {
                            spacing: 12
                            ShadcnSkeleton { width: 40; height: 40; radius: 20 }
                            Column {
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter
                                ShadcnSkeleton { width: 100; height: 14 }
                                ShadcnSkeleton { width: 60; height: 12 }
                            }
                        }
                        ShadcnSkeleton { width: 280; height: 12 }
                        ShadcnSkeleton { width: 240; height: 12 }
                        ShadcnSkeleton { width: 200; height: 12 }
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
                text: "ShadcnSkeleton { width: 200; height: 16 }\nShadcnSkeleton { width: 48; height: 48; radius: 24 }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

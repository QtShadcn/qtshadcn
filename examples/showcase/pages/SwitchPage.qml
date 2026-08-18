import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Switch 页：size / 状态 / 组合（Card + Switch + Label）
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

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
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
    // 注：height: parent.height - y 会因 y 自引用形成绑定循环（高度塌缩 implicitHeight）
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

            SectionTitle {
                text: qsTr("Default Size（点击切换）")
            }
            Row {
                spacing: theme.spacingSm
                ShadcnSwitch {
                    id: switchDefault
                }
                Text {
                    text: switchDefault.checked ? qsTr("开") : qsTr("关")
                    color: theme.foreground
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            SectionTitle {
                text: qsTr("Small Size（点击切换）")
            }
            Row {
                spacing: theme.spacingSm
                ShadcnSwitch {
                    id: switchSmall
                    size: ShadcnSwitch.Size.Small
                }
                Text {
                    text: switchSmall.checked ? qsTr("开") : qsTr("关")
                    color: theme.foreground
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            SectionTitle {
                text: qsTr("Disabled")
            }
            Row {
                spacing: theme.spacingLg
                ShadcnSwitch {
                    enabled: false
                }
                ShadcnSwitch {
                    enabled: false
                    checked: true
                }
            }

            SectionTitle {
                text: qsTr("组合（Card + Switch 列表）")
            }
            ShadcnCard {
                width: 420

                ShadcnCardHeader {
                    ShadcnCardTitle {
                        text: qsTr("通知设置")
                    }
                    ShadcnCardDescription {
                        text: qsTr("选择你想接收的通知类型。")
                    }
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
                            Item {
                                Layout.fillWidth: true
                                width: 1
                            }
                            ShadcnSwitch {
                                checked: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            width: parent.width
                            Text {
                                text: qsTr("推送通知")
                                color: theme.foreground
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Item {
                                Layout.fillWidth: true
                                width: 1
                            }
                            ShadcnSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            width: parent.width
                            Text {
                                text: qsTr("短信提醒")
                                color: theme.foreground
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Item {
                                Layout.fillWidth: true
                                width: 1
                            }
                            ShadcnSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            SectionTitle {
                text: qsTr("QML 用法")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnSwitch {\n    checked: true\n    size: ShadcnSwitch.Size.Default\n    onCheckedChanged: ...\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

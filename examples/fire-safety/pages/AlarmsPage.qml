import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// 告警管理：告警列表 + 「确认处理」Dialog + 模拟触发报警
// 数据由 Main.qml 注入（单一来源）；操作通过信号回传
Item {
    id: root

    // 由 Main.qml 注入（与总览页共享同一份 ListModel）
    property var alarms: null
    signal ackRequested(int index)
    signal triggerRequested()

    // 当前待确认的行（-1 = 无）
    property int ackIndex: -1

    // 用函数而非 onAckIndexChanged 开窗：重复点击同一行时属性值不变、
    // changed 信号不触发，弹窗就不会再开
    function openAck(index) {
        root.ackIndex = index
        ackDialog.open()
    }

    QtShadcnTheme {
        id: theme
    }

    // 标题区
    ColumnLayout {
        id: header

        anchors.left: parent.left
        anchors.margins: 24
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 40
        spacing: theme.spacingSm

        Text {
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
            text: qsTr("告警管理")
        }
        RowLayout {
            spacing: theme.spacingSm
            width: parent.width

            Text {
                color: theme.mutedForeground
                font.pixelSize: 13
                text: root.alarms ? qsTr("共 %1 条记录").arg(root.alarms.count) : ""
                Layout.fillWidth: true
            }
            ShadcnButton {
                iconName: "bell"
                size: ShadcnButton.Size.Small
                text: qsTr("模拟触发报警")
                variant: ShadcnButton.Variant.Outline

                onClicked: root.triggerRequested()
            }
        }
    }

    // 内容区（放不下才滚）
    ScrollView {
        id: sv

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 20
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            Repeater {
                model: root.alarms

                delegate: ShadcnCard {
                    id: alarmCard

                    required property int index
                    required property string time
                    required property string zone
                    required property string device
                    required property string level
                    required property bool handled

                    width: parent.width

                    ShadcnCardContent {
                        RowLayout {
                            width: parent.width - 8
                            spacing: theme.spacingMd

                            // 级别圆点：火警红 / 故障黄 / 屏蔽灰
                            ShadcnStatusDot {
                                status: alarmCard.level === "high" ? ShadcnStatusDot.Status.Danger : alarmCard.level === "fault" ? ShadcnStatusDot.Status.Warning : ShadcnStatusDot.Status.Offline
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                RowLayout {
                                    spacing: theme.spacingSm

                                    Text {
                                        color: theme.foreground
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        text: alarmCard.zone + " · " + alarmCard.type
                                    }
                                    ShadcnBadge {
                                        text: alarmCard.handled ? qsTr("已处理") : qsTr("未处理")
                                        variant: alarmCard.handled ? ShadcnBadge.Variant.Secondary : ShadcnBadge.Variant.Destructive
                                    }
                                    Item { Layout.fillWidth: true }
                                    ShadcnButton {
                                        enabled: !alarmCard.handled
                                        size: ShadcnButton.Size.Small
                                        text: alarmCard.handled ? qsTr("已确认") : qsTr("确认处理")
                                        variant: alarmCard.handled ? ShadcnButton.Variant.Secondary : ShadcnButton.Variant.Destructive

                                        onClicked: root.openAck(alarmCard.index)
                                    }
                                }
                                Text {
                                    color: theme.mutedForeground
                                    font.pixelSize: 12
                                    text: alarmCard.device + " · " + alarmCard.time
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 4 }
        }
    }

    // 确认处理对话框
    ShadcnDialog {
        id: ackDialog

        modal: true

        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle {
                    text: qsTr("确认处理该告警？")
                }
                ShadcnDialogDescription {
                    text: root.ackIndex >= 0 && root.alarms && root.ackIndex < root.alarms.count ? root.alarms.get(root.ackIndex).zone + " · " + root.alarms.get(root.ackIndex).device : ""
                }
            }
            footer: ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("取消")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Outline

                    onClicked: ackDialog.close()
                }
                ShadcnButton {
                    text: qsTr("确认处理")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Destructive

                    onClicked: {
                        root.ackRequested(root.ackIndex)
                        ackDialog.close()
                    }
                }
            }
        }
    }
}

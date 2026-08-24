import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// 监控总览：统计卡片 + 系统状态 + 回路健康度
// 数据由 Main.qml 注入（单一来源）；本页只读
Item {
    id: root

    // 由 Main.qml 注入
    property var alarms: null
    property int pendingCount: 0
    signal requestAlarm(string zone, string device)

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.left: parent.left
        anchors.margins: 24
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 40
        spacing: theme.spacingLg

        Text {
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
            text: qsTr("监控总览")
        }
        Row {
            spacing: theme.spacingSm

            ShadcnBadge {
                text: root.pendingCount > 0 ? qsTr("火警报警中") : qsTr("系统正常")
                variant: root.pendingCount > 0 ? ShadcnBadge.Variant.Destructive : ShadcnBadge.Variant.Secondary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: theme.mutedForeground
                font.pixelSize: 12
                text: qsTr("主机在线 · 2 回路 · 数据为模拟演示")
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

            // ── 统计卡片 ──
            Flow {
                width: parent.width
                spacing: 16

                StatCard {
                    desc: "烟感 / 温感 / 手报 / 声光"
                    title: qsTr("在线设备")
                    value: "128"
                }
                StatCard {
                    desc: "当前未处理告警"
                    title: qsTr("未处理告警")
                    value: String(root.pendingCount)
                }
                StatCard {
                    desc: "本月误报 3 次"
                    title: qsTr("今日报警")
                    value: "5"
                }
                StatCard {
                    desc: "屏蔽 / 故障设备合计"
                    title: qsTr("故障与屏蔽")
                    value: "2"
                }
            }

            // ── 系统状态 ──
            SectionTitle {
                text: qsTr("系统状态")
            }
            Row {
                spacing: 16

                StatusCard {
                    dotStatus: root.pendingCount > 0 ? ShadcnStatusDot.Status.Danger : ShadcnStatusDot.Status.Online
                    label: qsTr("火灾报警控制器")
                    value: root.pendingCount > 0 ? qsTr("报警中") : qsTr("正常运行")
                }
                StatusCard {
                    dotStatus: ShadcnStatusDot.Status.Warning
                    label: qsTr("消防电源")
                    value: qsTr("主电运行 · 备电正常")
                }
                StatusCard {
                    dotStatus: ShadcnStatusDot.Status.Offline
                    label: qsTr("气体灭火控制盘")
                    value: qsTr("未接入（预留）")
                }
            }

            // ── 回路健康度 ──
            SectionTitle {
                text: qsTr("回路健康度")
            }
            Row {
                spacing: 16

                LoopCard {
                    health: 0.96
                    loopNo: 1
                }
                LoopCard {
                    health: 0.88
                    loopNo: 2
                }
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    component StatCard: ShadcnCard {
        id: statCard

        required property string desc
        required property string title
        required property string value

        width: 210

        ShadcnCardContent {
            Column {
                spacing: 4

                Text {
                    color: theme.mutedForeground
                    font.pixelSize: 13
                    text: statCard.title
                }
                Text {
                    color: theme.foreground
                    font.bold: true
                    font.pixelSize: 28
                    text: statCard.value
                }
                Text {
                    color: theme.mutedForeground
                    font.pixelSize: 11
                    text: statCard.desc
                }
            }
        }
    }

    component StatusCard: ShadcnCard {
        id: statusCard

        required property int dotStatus
        required property string label
        required property string value

        width: 280

        ShadcnCardContent {
            Row {
                spacing: 10

                ShadcnStatusDot {
                    anchors.verticalCenter: parent.verticalCenter
                    size: 10
                    status: statusCard.dotStatus
                }
                Column {
                    spacing: 2

                    Text {
                        color: theme.foreground
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        text: statusCard.label
                    }
                    Text {
                        color: theme.mutedForeground
                        font.pixelSize: 12
                        text: statusCard.value
                    }
                }
            }
        }
    }

    component LoopCard: ShadcnCard {
        id: loopCard

        required property real health
        property int loopNo: 1

        width: 280

        ShadcnCardHeader {
            ShadcnCardTitle {
                text: qsTr("回路 %1").arg(loopCard.loopNo)
            }
            ShadcnCardDescription {
                text: qsTr("%1 个点位在线").arg(Math.round(loopCard.health * 64))
            }
        }
        ShadcnCardContent {
            ShadcnProgress {
                width: parent.width - 8
                showValue: true
                value: loopCard.health
            }
        }
    }
}

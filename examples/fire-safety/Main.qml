import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtShadcn

// 消防监控系统示例：左侧导航 + 右侧内容区（布局思路同 showcase）
// 告警数据模型集中在根窗口（单一来源）；页面通过属性读取、信号回传操作
// （跨文件 id 不可见）
Window {
    id: root

    property int currentIndex: 0
    property int pendingCount: 0
    property var menuItems: [
        { title: "监控总览", page: "" },
        { title: "告警管理", page: "AlarmsPage.qml" }
    ]

    color: theme.background
    height: 720
    title: qsTr("消防监控系统 · QtShadcn 示例")
    visible: true
    width: 980

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
        refreshPending()
    }

    QtShadcnTheme {
        id: theme
    }

    // ── 告警数据（模拟，单一来源）──
    // level: "high" 火警 / "fault" 故障 / "shield" 屏蔽；handled: 是否已处理
    ListModel {
        id: alarmModel

        ListElement {
            time: "14:32:05"
            zone: "3F 东侧走廊"
            device: "烟感探测器 SS-017"
            type: "火警"
            level: "high"
            handled: false
        }
        ListElement {
            time: "14:30:12"
            zone: "B1 车库 B 区"
            device: "声光警报器 SL-006"
            type: "故障"
            level: "fault"
            handled: false
        }
        ListElement {
            time: "13:58:47"
            zone: "5F 弱电井"
            device: "温感探测器 WS-023"
            type: "屏蔽"
            level: "shield"
            handled: true
        }
        ListElement {
            time: "11:20:33"
            zone: "2F 西侧楼梯间"
            device: "手动报警按钮 SB-009"
            type: "火警"
            level: "high"
            handled: true
        }
        ListElement {
            time: "09:05:18"
            zone: "1F 大堂"
            device: "烟感探测器 SS-002"
            type: "火警"
            level: "high"
            handled: true
        }
    }

    function refreshPending() {
        var n = 0
        for (var i = 0; i < alarmModel.count; ++i) {
            if (!alarmModel.get(i).handled)
                n++
        }
        root.pendingCount = n
    }

    // 页面回传的操作
    function ackAlarm(index) {
        if (index < 0 || index >= alarmModel.count)
            return
        alarmModel.setProperty(index, "handled", true)
        refreshPending()
    }

    function triggerAlarm(zone, device, levelName) {
        var now = new Date()
        var hh = String(now.getHours()).padStart(2, "0")
        var mm = String(now.getMinutes()).padStart(2, "0")
        var ss = String(now.getSeconds()).padStart(2, "0")
        alarmModel.insert(0, {
            time: hh + ":" + mm + ":" + ss,
            zone: zone,
            device: device,
            type: "火警",
            level: levelName,
            handled: false
        })
        refreshPending()
    }

    // ── 左侧菜单 ──
    Rectangle {
        id: menuArea

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        color: theme.background
        width: 190

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.top: parent.top
            color: theme.border
            width: 1
        }

        Column {
            id: menuHeader

            anchors.left: parent.left
            anchors.margins: 12
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 4

            Row {
                leftPadding: 8
                spacing: 6
                topPadding: 8

                ShadcnIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.primary
                    name: "shield"
                    size: 18
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.foreground
                    font.bold: true
                    font.pixelSize: 15
                    text: qsTr("消防监控系统")
                }
            }
            Text {
                color: theme.mutedForeground
                font.pixelSize: 12
                leftPadding: 8
                text: qsTr("演示示例 · 模拟数据")
            }
            Item { height: 12 }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: menuHeader.bottom
            spacing: 4

            Repeater {
                model: root.menuItems

                delegate: Rectangle {
                    id: menuItem

                    required property int index
                    required property var modelData

                    color: root.currentIndex === index ? theme.accent : itemHover.containsMouse ? theme.muted : "transparent"
                    height: 34
                    radius: 6
                    width: parent.width

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.currentIndex === index ? theme.accentForeground : theme.foreground
                        font.bold: root.currentIndex === index
                        font.pixelSize: 13
                        text: modelData.title
                    }
                    // 未处理告警数角标（仅告警管理项）
                    ShadcnBadge {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.pendingCount > 0 ? String(root.pendingCount) : ""
                        variant: ShadcnBadge.Variant.Destructive
                        visible: root.pendingCount > 0 && index === 1
                    }
                    MouseArea {
                        id: itemHover

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.currentIndex = index
                    }
                }
            }
        }

        // 底部明暗切换（图标按钮，hover muted）
        Rectangle {
            id: modeBtn

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 12
            color: modeHover.containsMouse ? theme.muted : "transparent"
            height: 24
            radius: 6
            width: 24

            ShadcnIcon {
                anchors.centerIn: parent
                color: theme.foreground
                name: theme.mode === "dark" ? "sun" : "moon"
                size: 16
            }
            MouseArea {
                id: modeHover

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
            }
        }
    }

    // ── 右侧内容区 ──（滚动由页面内部各自管理；StackLayout 用显式宽高绑定，
    // 高度减 16 留底部白，页面滚到底不与窗口底边贴死）
    Rectangle {
        id: contentArea

        anchors.bottom: parent.bottom
        anchors.left: menuArea.right
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        color: theme.background

        StackLayout {
            currentIndex: root.currentIndex
            height: parent.height - 16
            width: parent.width

            DashboardPage {
                alarms: alarmModel
                pendingCount: root.pendingCount
            }
            AlarmsPage {
                alarms: alarmModel
                onAckRequested: index => root.ackAlarm(index)
                onTriggerRequested: () => root.triggerAlarm("4F 会议室 A", "烟感探测器 SS-031", "high")
            }
        }
    }
}

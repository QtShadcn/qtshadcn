import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtShadcn

// BMS EOL 调试工具示例：左侧导航 + 右侧内容区（布局思路同 showcase）
// 电芯数据模型集中在根窗口（单一来源）；EOL 测试流程状态在测试页内部
Window {
    id: root

    property int currentIndex: 0
    property var menuItems: [
        { title: "EOL 测试", page: "" },
        { title: "电芯监控", page: "CellsPage.qml" }
    ]

    color: theme.background
    height: 720
    title: qsTr("BMS EOL 调试工具 · QtShadcn 示例")
    visible: true
    width: 980

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    QtShadcnTheme {
        id: theme
    }

    // ── 电芯数据（模拟 CAN 上报，单一来源）──
    // 16 串磷酸铁锂；11 号电芯偏低用于演示压差告警
    ListModel {
        id: cellsModel

        ListElement { no: 1;  mv: 3342; temp: 31 }
        ListElement { no: 2;  mv: 3338; temp: 32 }
        ListElement { no: 3;  mv: 3341; temp: 30 }
        ListElement { no: 4;  mv: 3339; temp: 31 }
        ListElement { no: 5;  mv: 3344; temp: 33 }
        ListElement { no: 6;  mv: 3340; temp: 31 }
        ListElement { no: 7;  mv: 3337; temp: 30 }
        ListElement { no: 8;  mv: 3343; temp: 32 }
        ListElement { no: 9;  mv: 3339; temp: 34 }
        ListElement { no: 10; mv: 3341; temp: 32 }
        ListElement { no: 11; mv: 3218; temp: 36 }
        ListElement { no: 12; mv: 3340; temp: 31 }
        ListElement { no: 13; mv: 3343; temp: 30 }
        ListElement { no: 14; mv: 3338; temp: 32 }
        ListElement { no: 15; mv: 3341; temp: 31 }
        ListElement { no: 16; mv: 3339; temp: 30 }
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
                    name: "monitor"
                    size: 18
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: theme.foreground
                    font.bold: true
                    font.pixelSize: 15
                    text: qsTr("BMS EOL 工具")
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

            EolTestPage {
                cells: cellsModel
            }
            CellsPage {
                cells: cellsModel
            }
        }
    }
}

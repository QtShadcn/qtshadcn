import QtQuick
import QtQuick.Layouts
import QtShadcn

// 左侧导航栏：Logo + 导航项 + 底部信息块（QtShadcn 无 Sidebar 组件，用 ShadcnIcon + 自定义组合）
Rectangle {
    id: sidebar

    property int currentIndex: 0

    property real navItemHeight: 36
    property real navGap: 8

    QtShadcnTheme { id: theme }

    // 作为 RowLayout 子项：用 implicit 尺寸 + fillHeight，避免侧栏高度塌缩、菜单悬在中间
    implicitWidth: 220
    Layout.fillHeight: true
    color: theme.card

    // 导航项数据：新增导航 = 数组加一项
    readonly property var items: [
        { label: qsTr("首页"), icon: "home" },
        { label: qsTr("项目"), icon: "folder" },
        { label: qsTr("设置"), icon: "settings" }
    ]

    // 右侧分隔线
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: theme.border
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingMd
        spacing: theme.spacingMd

        // Logo
        Row {
            Layout.fillWidth: true
            spacing: theme.spacingSm

            ShadcnIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "sparkles"
                size: 20
                color: theme.primary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("AI Studio")
                color: theme.foreground
                font.pixelSize: 16
                font.bold: true
            }
        }

        // 导航项：Column（定位器）负责 Repeater，ColumnLayout 只排这一整块
        Column {
            Layout.fillWidth: true
            spacing: sidebar.navGap

            Repeater {
                model: sidebar.items

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    width: parent.width
                    height: sidebar.navItemHeight
                    radius: theme.radius
                    color: sidebar.currentIndex === index ? theme.accent
                           : navMouse.containsMouse ? theme.muted : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: theme.spacingSm

                        ShadcnIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: modelData.icon
                            size: 16
                            color: sidebar.currentIndex === index ? theme.accentForeground : theme.foreground
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: sidebar.currentIndex === index ? theme.accentForeground : theme.foreground
                            font.pixelSize: 13
                            font.bold: sidebar.currentIndex === index
                        }
                    }

                    MouseArea {
                        id: navMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sidebar.currentIndex = index
                    }
                }
            }
        }

        // 弹性占位：把顶部内容顶上去、底部信息块压到底，避免左侧菜单下大片空白
        Item {
            Layout.fillHeight: true
        }

        // 明暗主题切换
        ThemeToggle {
            Layout.fillWidth: true
        }

        // 底部信息块
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: theme.radius
            color: theme.muted

            RowLayout {
                anchors.fill: parent
                anchors.margins: theme.spacingSm
                spacing: theme.spacingSm

                ShadcnIcon {
                    name: "user"
                    size: 16
                    color: theme.foreground
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: qsTr("本地工作区")
                        color: theme.foreground
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("v0.1 · 体验版")
                        color: theme.mutedForeground
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
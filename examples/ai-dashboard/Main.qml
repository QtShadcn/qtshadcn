import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtShadcn

// AI 助手 Dashboard：左侧导航 + 顶部用户区 + 按导航切换的主内容区
Window {
    id: root
    width: 1080
    height: 720
    visible: true
    title: qsTr("AI 助手 Dashboard")

    QtShadcnTheme { id: theme }
    color: theme.background

    // 当前导航页（对应 Sidebar 的导航项索引）
    property int currentNav: 0

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧导航
        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            onCurrentIndexChanged: root.currentNav = sidebar.currentIndex
        }

        // 右侧主内容
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: theme.spacingLg
            spacing: theme.spacingLg

            // 顶部：用户卡片
            RowLayout {
                Layout.fillWidth: true
                spacing: theme.spacingMd

                UserCard { Layout.fillWidth: true }
            }

            // 内容区：随导航切换
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.currentNav

                // 首页：AI 对话
                AIChatCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // 项目页：项目列表
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: theme.spacingMd

                    // 项目列表标题
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: qsTr("项目")
                            color: theme.foreground
                            font.pixelSize: 16
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        ShadcnButton {
                            text: qsTr("新建")
                            size: ShadcnButton.Size.Small
                            iconName: "plus"
                        }
                    }

                    // 项目列表
                    ListView {
                        id: projectList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: theme.spacingMd
                        model: projectModel

                        delegate: ProjectCard {
                            required property string name
                            required property string description
                            required property string status

                            width: projectList.width
                            projectName: name
                            projectDescription: description
                            projectStatus: status
                        }
                    }
                }

                // 设置页：占位
                // 注：ShadcnCard 内部用 Column 堆叠子项，直接子项禁用
                // centerIn/fill/top/bottom 等 anchors，居中用 x/y 绑定
                ShadcnCard {
                    id: settingsCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        x: (settingsCard.width - width) / 2
                        y: (settingsCard.height - height) / 2
                        spacing: theme.spacingMd

                        ShadcnIcon {
                            Layout.alignment: Qt.AlignHCenter
                            name: "settings"
                            size: 40
                            color: theme.mutedForeground
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("设置")
                            color: theme.foreground
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("更多设置项即将上线")
                            color: theme.mutedForeground
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }

    // 项目数据
    ListModel {
        id: projectModel
        ListElement { name: "QtShadcn 组件库"; description: "对齐 shadcn/ui 的 Qt6/QML 组件库"; status: "进行中" }
        ListElement { name: "AI Dashboard"; description: "AI 助手数据看板"; status: "进行中" }
        ListElement { name: "图标系统"; description: "lucide 图标打包与主题变色"; status: "已完成" }
        ListElement { name: "移动端适配"; description: "响应式布局改造"; status: "待开始" }
    }
}
import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import QtQuick.Window
import QtShadcn

// QtShadcn 组件展示（菜单化：左侧导航 + 右侧内容区，每个组件一个页面便于维护）
Window {
    id: root

    // 当前选中菜单项（0 = 总览）
    property int currentIndex: 0
    // 菜单项：新增组件 = 加一个页面 + 此处加一项 + StackLayout 加一页
    // page 为对应页面文件名（总览页 navigateTo 信号按此映射跳转）
    property var menuItems: [
        {
            title: "总览",
            page: ""
        },
        {
            title: "Theme",
            page: "ThemePage.qml"
        },
        {
            title: "Button",
            page: "ButtonPage.qml"
        },
        {
            title: "ButtonGroup",
            page: "ButtonGroupPage.qml"
        },
        {
            title: "Toggle",
            page: "TogglePage.qml"
        },
        {
            title: "Spinner",
            page: "SpinnerPage.qml"
        },
        {
            title: "Card",
            page: "CardPage.qml"
        },
        {
            title: "Input",
            page: "InputPage.qml"
        },
        {
            title: "Badge",
            page: "BadgePage.qml"
        },
        {
            title: "Switch",
            page: "SwitchPage.qml"
        },
        {
            title: "Tabs",
            page: "TabsPage.qml"
        },
        {
            title: "Dialog",
            page: "DialogPage.qml"
        },
        {
            title: "Icon",
            page: "IconPage.qml"
        },
        {
            title: "Textarea",
            page: "TextareaPage.qml"
        },
        {
            title: "Checkbox",
            page: "CheckboxPage.qml"
        },
        {
            title: "Radio",
            page: "RadioPage.qml"
        },
        {
            title: "Slider",
            page: "SliderPage.qml"
        },
        {
            title: "Progress",
            page: "ProgressPage.qml"
        },
        {
            title: "Select",
            page: "SelectPage.qml"
        },
        {
            title: "InputGroup",
            page: "InputGroupPage.qml"
        },
        {
            title: "Form",
            page: "FormPage.qml"
        },
    ]

    // 文件名 → 菜单/StackLayout index（总览页卡片跳转用；未匹配回退总览）
    function findPageIndex(page) {
        for (var i = 0; i < root.menuItems.length; ++i) {
            if (root.menuItems[i].page === page)
                return i;
        }
        return 0;
    }

    color: theme.background
    height: 720
    title: qsTr("QtShadcn Showcase")
    visible: true
    width: 980

    // 启动居中：避免 macOS 窗口位置记忆导致窗口漂移出屏幕
    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    QtShadcnTheme {
        id: theme
    }

    // ── 左侧菜单 ──
    Rectangle {
        id: menuArea

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        color: theme.background
        width: 190

        // 右侧分隔线
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.top: parent.top
            color: theme.border
            width: 1
        }
        // 标题区（固定，不随菜单滚动）
        Column {
            id: menuHeader

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 4

            Text {
                color: theme.foreground
                font.bold: true
                font.pixelSize: 16
                leftPadding: 8
                text: "QtShadcn"
                topPadding: 8
            }
            Text {
                color: theme.mutedForeground
                font.pixelSize: 12
                leftPadding: 8
                text: "Showcase"
            }
            Item {
                height: 12
            }
        }

        // 菜单项（可滚动：组件多了窗口放不下时滚）
        QQC.ScrollView {
            id: menuScroll

            anchors.top: menuHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 12

            clip: true
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            QQC.ScrollBar.vertical.policy: QQC.ScrollBar.AsNeeded

            Column {
                width: menuScroll.availableWidth
                spacing: 4

                // 菜单项：选中 accent 背景 + accentForeground 文字；hover muted
                Repeater {
                    model: root.menuItems

                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        color: root.currentIndex === index ? theme.accent : mouseArea.containsMouse ? theme.muted : "transparent"
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
                            id: mouseArea

                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: root.currentIndex = index
                        }
                    }
                }
            }
        }
    }

    // ── 右侧内容区 ──
    // 滚动由页面内部各自管理（参考 OverviewPage：标题固定 + 内容区 ScrollView
    // AsNeeded，放不下才滚）—— 外层 ScrollView 曾导致 contentHeight 恒定最大页高，
    // 内容放得下的页面也出现滚动条
    Rectangle {
        id: contentArea

        anchors.bottom: parent.bottom
        anchors.left: menuArea.right
        anchors.right: parent.right
        anchors.top: parent.top
        clip: true
        color: theme.background

        // 注：StackLayout 属 QQuickLayout 系列，anchors 定位不可靠；
        // 位置用属性绑定（x/y 默认 0 = 内容区原点），宽高显式绑定
        StackLayout {
            id: contentStack

            currentIndex: root.currentIndex
            width: parent.width
            height: parent.height

            OverviewPage {
                // 总览页卡片跳转：文件名 → 菜单 index（显式参数，隐式注入已废弃）
                onNavigateTo: page => root.currentIndex = root.findPageIndex(page)
            }
            ThemePage {}
            ButtonPage {}
            ButtonGroupPage {}
            TogglePage {}
            SpinnerPage {}
            CardPage {}
            InputPage {}
            BadgePage {}
            SwitchPage {}
            TabsPage {}
            DialogPage {}
            IconPage {}
            TextareaPage {}
            CheckboxPage {}
            RadioPage {}
            SliderPage {}
            ProgressPage {}
            SelectPage {}
            InputGroupPage {}
            FormPage {}
        }
    }

    // ── 右上角工具条：主题色切换 + 明暗切换 ──
    Row {
        id: themeBar

        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 12
        height: 32
        spacing: theme.spacingSm

        // ------------------------------------------------------------
        // 预设主色
        // ------------------------------------------------------------

        Repeater {
            model: [
                {
                    name: "默认",
                    color: ""
                },
                {
                    name: "蓝",
                    color: "#2563eb"
                },
                {
                    name: "绿",
                    color: "#16a34a"
                },
                {
                    name: "紫",
                    color: "#7c3aed"
                },
                {
                    name: "红",
                    color: "#dc2626"
                },
                {
                    name: "橙",
                    color: "#ea580c"
                }
            ]

            delegate: Rectangle {

                // ----------------------------------------------------
                // 默认主题：左右两种颜色
                // ----------------------------------------------------

                property Gradient autoGradient: Gradient {
                    GradientStop {
                        color: "#18181b"
                        position: 0.0
                    }
                    GradientStop {
                        color: "#18181b"
                        position: 0.5
                    }
                    GradientStop {
                        color: "#fafafa"
                        position: 0.5
                    }
                    GradientStop {
                        color: "#fafafa"
                        position: 1.0
                    }
                }
                required property var modelData

                anchors.verticalCenter: parent.verticalCenter
                border.color: ThemeManager.primary === modelData.color ? theme.ring : theme.border

                // ----------------------------------------------------
                // Border
                // ----------------------------------------------------

                border.width: ThemeManager.primary === modelData.color ? 2 : 1
                color: modelData.color === "" ? "transparent" : modelData.color
                gradient: modelData.color === "" ? autoGradient : null
                height: 24
                opacity: hoverArea.containsMouse ? 0.75 : 1.0
                radius: 6
                width: 24

                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                    }
                }

                MouseArea {
                    id: hoverArea

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        ThemeManager.primary = modelData.color;
                    }
                }
            }
        }
        ShadcnButton {
            anchors.verticalCenter: parent.verticalCenter
            size: ShadcnButton.Size.Small
            text: theme.mode === "dark" ? qsTr("☀") : qsTr("☾")
            variant: ShadcnButton.Variant.Outline

            onClicked: {
                theme.mode = theme.mode === "dark" ? "light" : "dark";
            }
        }
    }
}

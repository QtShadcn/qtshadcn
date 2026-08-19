import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Effects
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
        // 位置用属性绑定（x/y 默认 0 = 内容区原点），宽高显式绑定。
        // height 减 16：内容区底部留白（页面滚到底不与窗口底边贴死）
        StackLayout {
            id: contentStack

            currentIndex: root.currentIndex
            width: parent.width
            height: parent.height - 16

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

        // 明暗切换：纯图标 24×24，hover muted
        Rectangle {
            id: modeBtn
            width: 24
            height: 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: modeHover.containsMouse ? theme.muted : "transparent"

            ShadcnIcon {
                anchors.centerIn: parent
                name: theme.mode === "dark" ? "sun" : "moon"
                size: 16
                color: theme.foreground
            }
            MouseArea {
                id: modeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
            }
        }

        // 颜色选择器：调色板图标 → 弹出面板（扩展色板 + 自定义 hex）
        Rectangle {
            id: paletteBtn
            width: 24
            height: 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: paletteHover.containsMouse || colorPopup.opened ? theme.muted : "transparent"

            ShadcnIcon {
                anchors.centerIn: parent
                name: "palette"
                size: 16
                color: theme.foreground
            }
            MouseArea {
                id: paletteHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: colorPopup.open()
            }
        }

        // GitHub 跳转：点击打开仓库
        Rectangle {
            id: githubBtn
            width: 24
            height: 24
            radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: githubHover.containsMouse ? theme.muted : "transparent"

            ShadcnIcon {
                anchors.centerIn: parent
                name: "github"
                size: 16
                color: theme.foreground
            }
            MouseArea {
                id: githubHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://github.com/QtShadcn/qtshadcn")
            }
        }

        // ── 颜色选择面板 ──
        QQC.Popup {
            id: colorPopup
            x: paletteBtn.x - width + paletteBtn.width   // 右缘对齐调色板按钮
            y: paletteBtn.y + paletteBtn.height + 8
            padding: 12
            closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutside

            contentItem: Column {
                spacing: 10

                Text {
                    text: qsTr("选择主色")
                    color: theme.foreground
                    font.pixelSize: 13
                    font.bold: true
                }

                // 预设色板（含默认）
                Flow {
                    width: 208   // 8 列 × 24 + 间距 8
                    spacing: 8

                    Repeater {
                        model: [
                            { name: "默认", color: "" },
                            { name: "蓝", color: "#2563eb" },
                            { name: "天蓝", color: "#0ea5e9" },
                            { name: "青", color: "#06b6d4" },
                            { name: "绿", color: "#16a34a" },
                            { name: "黄绿", color: "#84cc16" },
                            { name: "黄", color: "#f59e0b" },
                            { name: "橙", color: "#ea580c" },
                            { name: "红", color: "#dc2626" },
                            { name: "粉", color: "#ec4899" },
                            { name: "紫", color: "#7c3aed" },
                            { name: "紫蓝", color: "#8b5cf6" },
                            { name: "灰", color: "#64748b" },
                            { name: "玫红", color: "#ef4444" }
                        ]

                        delegate: Rectangle {
                            required property var modelData

                            property Gradient defaultGradient: Gradient {
                                GradientStop { color: "#18181b"; position: 0.0 }
                                GradientStop { color: "#18181b"; position: 0.5 }
                                GradientStop { color: "#fafafa"; position: 0.5 }
                                GradientStop { color: "#fafafa"; position: 1.0 }
                            }

                            width: 24
                            height: 24
                            radius: 6
                            border.width: ThemeManager.primary === modelData.color ? 2 : 1
                            border.color: ThemeManager.primary === modelData.color ? theme.ring : theme.border
                            color: modelData.color === "" ? "transparent" : modelData.color
                            gradient: modelData.color === "" ? defaultGradient : null

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ThemeManager.primary = modelData.color
                            }
                        }
                    }
                }

                // 自定义 hex
                Row {
                    spacing: 6
                    ShadcnInput {
                        id: hexInput
                        width: 130
                        placeholderText: "#2563eb"
                        font.pixelSize: 13
                        // 内联逻辑（不能用 contentItem 内的 function：QQC Popup 的
                        // contentItem 属性值组件在 qmlcache 下其 function 不进子对象
                        // 作用域链 → ReferenceError）
                        onAccepted: {
                            var t = hexInput.text.trim()
                            if (/^#[0-9a-fA-F]{6}$/.test(t))
                                ThemeManager.primary = t
                            else
                                hexInput.text = ThemeManager.primary
                        }
                    }
                    ShadcnButton {
                        text: qsTr("应用")
                        size: ShadcnButton.Size.Small
                        onClicked: {
                            var t = hexInput.text.trim()
                            if (/^#[0-9a-fA-F]{6}$/.test(t))
                                ThemeManager.primary = t
                            else
                                hexInput.text = ThemeManager.primary
                        }
                    }
                }
            }

            background: Rectangle {
                radius: 8
                color: theme.popover
                border.width: 1
                border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b,
                                      theme.mode === "dark" ? 0.10 : 0.05)
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.5
                    shadowVerticalOffset: 4
                    shadowColor: Qt.rgba(0, 0, 0, 0.18)
                }
            }
        }
    }
}

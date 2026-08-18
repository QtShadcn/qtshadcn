import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import QtQuick.Window
import QtShadcn

// QtShadcn 组件展示（菜单化：左侧导航 + 右侧内容区，每个组件一个页面便于维护）
Window {
    id: root
    width: 980
    height: 720
    visible: true
    title: qsTr("QtShadcn Showcase")

    QtShadcnTheme {
        id: theme
    }

    // 启动居中：避免 macOS 窗口位置记忆导致窗口漂移出屏幕
    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    color: theme.background

    // 当前选中菜单项（0 = 总览）
    property int currentIndex: 0
    // 菜单项：新增组件 = 加一个页面 + 此处加一项 + StackLayout 加一页
    // page 为对应页面文件名（总览页 navigateTo 信号按此映射跳转）
    property var menuItems: [
        { title: "总览", page: "" },
        { title: "Theme", page: "ThemePage.qml" },
        { title: "Button", page: "ButtonPage.qml" },
        { title: "ButtonGroup", page: "ButtonGroupPage.qml" },
        { title: "Toggle", page: "TogglePage.qml" },
        { title: "Spinner", page: "SpinnerPage.qml" },
    ]

    // 文件名 → 菜单/StackLayout index（总览页卡片跳转用；未匹配回退总览）
    function findPageIndex(page) {
        for (var i = 0; i < root.menuItems.length; ++i) {
            if (root.menuItems[i].page === page)
                return i
        }
        return 0
    }

    // ── 左侧菜单 ──
    Rectangle {
        id: menuArea
        width: 190
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: theme.background

        // 右侧分隔线
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: theme.border
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            // 标题区
            Text {
                text: "QtShadcn"
                color: theme.foreground
                font.pixelSize: 16
                font.bold: true
                leftPadding: 8
                topPadding: 8
            }
            Text {
                text: "Showcase"
                color: theme.mutedForeground
                font.pixelSize: 12
                leftPadding: 8
            }
            Item { height: 12 }

            // 菜单项：选中 accent 背景 + accentForeground 文字；hover muted
            Repeater {
                model: root.menuItems

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: menuArea.width - 24
                    height: 34
                    radius: 6
                    color: root.currentIndex === index ? theme.accent
                        : mouseArea.containsMouse ? theme.muted : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.title
                        color: root.currentIndex === index ? theme.accentForeground : theme.foreground
                        font.pixelSize: 13
                        font.bold: root.currentIndex === index
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

    // ── 右侧内容区（StackLayout 静态实例化，切换瞬时）──
    // 注：不用 ScrollView —— 内容宽度绑定与 Flickable 尺寸互相依赖会触发 polish 循环；
    // 当前各页内容高度均 < 窗口高，直接铺满即可，后续页面超长再加滚动
    Rectangle {
        id: contentArea
        anchors.left: menuArea.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: theme.background
        clip: true

        // 注：StackLayout 属 QQuickLayout 系列，anchors 定位不可靠（anchors.fill 只生效尺寸），
        // 位置用属性绑定（x/y 默认 0 = contentArea 原点）
        StackLayout {
            id: contentStack
            width: parent.width
            height: parent.height
            currentIndex: root.currentIndex

            OverviewPage {
                // 总览页卡片跳转：文件名 → 菜单 index（显式参数，隐式注入已废弃）
                onNavigateTo: (page) => root.currentIndex = root.findPageIndex(page)
            }
            ThemePage {}
            ButtonPage {}
            ButtonGroupPage {}
            TogglePage {}
            SpinnerPage {}
        }
    }

    // ── 右上角工具条：主题色切换 + 明暗切换（全局生效，跨页面共享）──
    Row {
        id: themeBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        spacing: theme.spacingSm

        // 预设主色色块（第一个「默认」= 内置色，随模式 light 深/dark 浅）
        Repeater {
            model: [
                { name: "默认", color: "" },
                { name: "蓝", color: "#2563eb" },
                { name: "绿", color: "#16a34a" },
                { name: "紫", color: "#7c3aed" },
                { name: "红", color: "#dc2626" },
                { name: "橙", color: "#ea580c" },
            ]

            delegate: Rectangle {
                required property var modelData
                width: 24
                height: 24
                radius: 6
                // 默认色块画成左深右浅（表示内置色随模式）
                property Gradient autoGradient: Gradient {
                    GradientStop { position: 0.0; color: "#18181b" }
                    GradientStop { position: 0.5; color: "#18181b" }
                    GradientStop { position: 0.5; color: "#fafafa" }
                    GradientStop { position: 1.0; color: "#fafafa" }
                }
                // 选中：ring 描边
                border.width: ThemeManager.primary === modelData.color ? 2 : 1
                border.color: ThemeManager.primary === modelData.color ? theme.ring : theme.border
                gradient: modelData.color === "" ? autoGradient : null
                color: modelData.color === "" ? "transparent" : modelData.color
                opacity: hoverArea.hovered ? 0.75 : 1.0

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: ThemeManager.primary = modelData.color
                }
            }
        }

        // 明暗切换
        ShadcnButton {
            text: theme.mode === "dark" ? qsTr("☀ 浅色") : qsTr("☾ 深色")
            variant: ShadcnButton.Variant.Outline
            size: ShadcnButton.Size.Small
            onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
        }
    }
}

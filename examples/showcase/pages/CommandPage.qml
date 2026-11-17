// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Command 页：⌘K 命令面板（issue #5）
//
// 演示三件事：
//   1. ⌘K / Ctrl+K 全局快捷键打开面板（Shortcut 挂在页面上 —— 组件不管全局键，
//      键位归宿主，见 ShadcnCommand.qml 文件头「边界」一节）
//   2. CommandDialog 内嵌模式（官方唯一形态）
//   3. 独立 Command 面板（不套 Dialog，直接嵌在页面里，用于侧栏/内联搜索）
Item {
    id: root

    QtShadcnTheme { id: theme }

    // 最近执行过的命令（页面底部回显，证明 activated 真的通了）
    property string lastCommand: ""

    // ── 截图模式：默认把面板打开 ────────────────────────────────
    // 照 DialogPage 的写法：**必须判 visible**。showcase 启动时会实例化所有页面，
    // Popup 渲染在 window overlay 层、不受父项 visible 约束，不判就会把面板
    // 叠到别的组件效果图上（串页）。
    function maybeShowInScreenshot() {
        if (ThemeManager.screenshotMode() && visible)
            palette.open()
    }

    Component.onCompleted: maybeShowInScreenshot()
    onVisibleChanged: if (visible) maybeShowInScreenshot()

    // ── 全局快捷键：⌘K（macOS 用 Meta，其它平台 Ctrl）──────────
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: palette.open()
    }
    Shortcut {
        sequence: "Meta+K"
        onActivated: palette.open()
    }

    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnCommand")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("⌘K 命令面板。声明式组合（Command / Input / List / Group / Item / Shortcut / Separator / Empty），"
                       + "过滤沿用 cmdk 的子序列打分（大小写与中文不敏感、按命中强度排序），"
                       + "↑↓ 跳过隐藏与禁用项、Enter 执行。全局快捷键由宿主用 Shortcut 注册。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

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

            // ── 1. 命令面板（Dialog 模式）──────────────────────
            SectionTitle {
                text: qsTr("Command Dialog（⌘K）")
            }

            RowLayout {
                spacing: theme.spacingSm

                ShadcnButton {
                    text: qsTr("打开命令面板")
                    onClicked: palette.open()
                }
                Text {
                    text: qsTr("或按 ⌘K / Ctrl+K")
                    color: theme.mutedForeground
                    font.pixelSize: 12
                }
                Item {
                    Layout.fillWidth: true
                }
            }

            ShadcnCommandDialog {
                id: palette

                ShadcnCommand {
                    ShadcnCommandInput {
                        placeholderText: qsTr("输入命令或搜索…")
                    }

                    ShadcnCommandList {
                        ShadcnCommandEmpty {
                            text: qsTr("没有匹配的命令")
                        }

                        ShadcnCommandGroup {
                            heading: qsTr("建议")

                            ShadcnCommandItem {
                                text: qsTr("新建文件")
                                iconName: "file"
                                shortcut: "⌘N"
                                keywords: ["new", "create", "新建"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("搜索表情")
                                iconName: "search"
                                keywords: ["emoji"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("插入图片")
                                iconName: "image"
                                keywords: ["image", "photo"]
                                onActivated: root.lastCommand = text
                            }
                        }

                        ShadcnCommandSeparator {}

                        ShadcnCommandGroup {
                            heading: qsTr("设置")

                            ShadcnCommandItem {
                                text: qsTr("个人资料")
                                iconName: "user"
                                keywords: ["profile", "account"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("切换主题")
                                iconName: "sun"
                                shortcut: "⌘⇧D"
                                keywords: ["theme", "dark", "light"]
                                onActivated: {
                                    root.lastCommand = text
                                    // 真的开关：showcase 的主题模式是绑定到
                                    // ThemeManager.mode 的，直接赋值即可（不写
                                    // ThemeManager.setMode —— 那是 C++ 的 setter，
                                    // QML 侧走属性赋值才符合本库的用法约定）
                                    ThemeManager.mode = ThemeManager.mode === "light" ? "dark" : "light"
                                }
                            }
                            ShadcnCommandItem {
                                text: qsTr("键盘快捷键")
                                iconName: "key"
                                shortcut: "⌘,"
                                keywords: ["shortcut", "key"]
                                onActivated: root.lastCommand = text
                            }
                        }

                        ShadcnCommandSeparator {}

                        ShadcnCommandGroup {
                            heading: qsTr("危险操作")

                            ShadcnCommandItem {
                                text: qsTr("复制项目链接")
                                iconName: "link"
                                keywords: ["copy", "url"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("归档项目")
                                iconName: "folder"
                                keywords: ["archive"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("删除项目")
                                iconName: "trash-2"
                                destructive: true
                                keywords: ["delete", "remove"]
                                onActivated: root.lastCommand = text
                            }
                            ShadcnCommandItem {
                                text: qsTr("删除账户")
                                iconName: "trash-2"
                                destructive: true
                                enabled: false
                                // 演示禁用项：不可选中、Enter 不执行
                                onActivated: root.lastCommand = text
                            }
                        }
                    }
                }
            }

            // 执行回显
            Row {
                spacing: theme.spacingSm
                visible: root.lastCommand !== ""

                Text {
                    text: qsTr("最近执行：")
                    color: theme.mutedForeground
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
                ShadcnBadge {
                    text: root.lastCommand
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ── 2. 独立面板（不套 Dialog）────────────────────────
            SectionTitle {
                text: qsTr("Inline Command（独立面板，不套 Dialog）")
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Command 本体不依赖 Dialog，可以直接嵌进页面或 Popup。下面这块是常驻面板，"
                           + "焦点落在搜索框即可用 ↑↓ 与 Enter。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }

            ShadcnCommand {
                id: inlineCmd
                width: 340

                ShadcnCommandInput {
                    placeholderText: qsTr("筛选视图…")
                }

                ShadcnCommandList {
                    maxHeight: 160

                    ShadcnCommandEmpty {
                        text: qsTr("无匹配视图")
                    }

                    ShadcnCommandGroup {
                        heading: qsTr("视图")

                        ShadcnCommandItem { text: qsTr("看板"); iconName: "grid" }
                        ShadcnCommandItem { text: qsTr("时间线"); iconName: "clock" }
                        ShadcnCommandItem { text: qsTr("表格"); iconName: "table" }
                        ShadcnCommandItem { text: qsTr("日历"); iconName: "calendar" }
                        ShadcnCommandItem { text: qsTr("甘特图"); iconName: "columns" }
                    }
                }
            }

            // ── 3. 自定义内容条目 ───────────────────────────────
            SectionTitle {
                text: qsTr("自定义内容（CommandShortcut 子项写法）")
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("条目内容不必是纯文本：可以套 ShadcnCommandShortcut，或任意 Item。"
                           + "keywords 里的词不显示但参与匹配（下面这块试 \"beta\"）。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }

            ShadcnCommand {
                id: customCmd
                width: 340

                ShadcnCommandInput {
                    placeholderText: qsTr("搜索组件…")
                }

                ShadcnCommandList {
                    maxHeight: 160

                    ShadcnCommandEmpty {
                        text: qsTr("无匹配组件")
                    }

                    ShadcnCommandItem {
                        value: "button"
                        keywords: ["按钮", "alpha"]
                        Text {
                            text: "Button"
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                        ShadcnCommandShortcut {
                            text: "UI"
                        }
                    }
                    ShadcnCommandItem {
                        value: "beta-input"
                        keywords: ["输入框"]
                        Text {
                            text: "Input"
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                        ShadcnCommandShortcut {
                            text: "FORM"
                        }
                    }
                    ShadcnCommandItem {
                        text: qsTr("已多选")
                        checked: true
                    }
                }
            }

            // ── 4. API ─────────────────────────────────────────
            RowLayout {
                spacing: theme.spacingSm

                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: qsTr("查看文档 ›")
                    color: theme.primary
                    font.pixelSize: 12
                    font.underline: docHover.containsMouse

                    MouseArea {
                        id: docHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/command")
                    }
                }
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnCommandDialog {\n    id: palette\n    ShadcnCommand {\n        ShadcnCommandInput { placeholderText: \"输入命令或搜索…\" }\n        ShadcnCommandList {\n            ShadcnCommandEmpty { text: \"没有匹配的命令\" }\n            ShadcnCommandGroup {\n                heading: \"设置\"\n                ShadcnCommandItem { text: \"切换主题\"; shortcut: \"⌘⇧D\"; keywords: [\"theme\"] }\n            }\n            ShadcnCommandSeparator {}\n        }\n    }\n}\n// 全局键由宿主注册（组件不抢键）\nShortcut { sequence: \"Ctrl+K\"; onActivated: palette.open() }"
            }

            Item {
                width: 1
                height: theme.spacingXl
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

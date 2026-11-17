// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    QtShadcnTheme { id: theme }

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
            font.bold: true
            font.pixelSize: 20
            text: qsTr("ShadcnHoverCard")
        }
        Text {
            color: theme.mutedForeground
            font.pixelSize: 13
            text: qsTr("悬停浮出的预览卡片（shadcn Hover Card / Base UI Preview Card）：与 Popover 共用同一套弹层，差别只在触发方式。delay 打开延时防误弹，closeDelay 让指针能移进卡片。Esc 或点击外部关闭。")
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }

    ScrollView {
        id: sv
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.top: header.bottom
        anchors.topMargin: 20
        clip: true

        Column {
            spacing: theme.spacingLg
            width: sv.availableWidth

            SectionTitle { text: qsTr("基础用法（悬停链接）") }
            Text {
                color: theme.mutedForeground
                font.pixelSize: 13
                text: qsTr("把鼠标停在下面的名字上 —— 卡片在 delay（默认 600ms）后浮出；移出后 closeDelay（300ms）才收起，指针可以直接移进卡片里。")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            // 截图示例单独占一行：卡片 256px 宽从触发链接左缘展开（align=start），
            // 与同行右侧的示例重叠，效果图会糊在一起
            Row {
                spacing: 20
                ShadcnHoverCard {
                    // 截图模式下自动展开首个示例，否则文档效果图只有触发链接
                    open: ThemeManager.screenshotMode()
                    ShadcnHoverCardTrigger { text: qsTr("@bailicangdu") }
                    ShadcnHoverCardContent {
                        // 同 PopoverPage：截图示例靠左缘，align=start 才不被裁
                        align: "start"
                        RowLayout {
                            spacing: 10
                            ShadcnAvatar {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                iconName: "user"
                            }
                            Column {
                                spacing: 2
                                Text {
                                    text: qsTr("白里苍渡")
                                    color: theme.foreground
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: qsTr("@bailicangdu · 前端工程师")
                                    color: theme.mutedForeground
                                    font.pixelSize: 12
                                }
                            }
                        }
                        Text {
                            text: qsTr("专注 Qt / QML 与组件库设计，偶尔写点渲染相关的东西。")
                            color: theme.mutedForeground
                            font.pixelSize: 13
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Row {
                            spacing: 6
                            ShadcnBadge { text: "Qt" }
                            ShadcnBadge { text: "QML"; variant: ShadcnBadge.Variant.Secondary }
                        }
                    }
                }

            }

            Row {
                spacing: 20
                ShadcnHoverCard {
                    // 截图模式下强制展开的卡片画在 overlay 层，会盖住本行右侧的
                    // 第二个示例（露出半个 @ 字形像渲染瑕疵）；截图时干脆隐藏它
                    visible: !ThemeManager.screenshotMode()
                    ShadcnHoverCardTrigger { text: qsTr("@someone") }
                    ShadcnHoverCardContent {
                        ShadcnPopoverHeader {
                            // Header/Title/Description 是 Popover 的组合件，样式同源，可复用
                            ShadcnPopoverTitle { text: qsTr("另一个示例") }
                            ShadcnPopoverDescription { text: qsTr("内容就是任意 QML —— 这里直接用了 Popover 的 Header / Title / Description。") }
                        }
                    }
                }
            }

            // 截图模式下强制展开的卡片画在 overlay 层，会盖住下方内容
            // （@someone 的左半个 @ 字形会从面板左缘露出来，看着像渲染瑕疵）。
            // 截图时在这段下面垫一块空白，让被盖的行退到面板之下。
            Item { width: 1; height: ThemeManager.screenshotMode() ? 110 : 0 }

            SectionTitle { text: qsTr("自定义延时") }
            Row {
                spacing: 20
                ShadcnHoverCard {
                    delay: 100
                    closeDelay: 60
                    ShadcnHoverCardTrigger { text: qsTr("秒开（delay=100）") }
                    ShadcnHoverCardContent {
                        Text {
                            text: qsTr("几乎立刻浮出，适合密集列表里的预览。")
                            color: theme.foreground
                            font.pixelSize: 13
                        }
                    }
                }
                ShadcnHoverCard {
                    delay: 1200
                    closeDelay: 500
                    ShadcnHoverCardTrigger { text: qsTr("慢开（delay=1200）") }
                    ShadcnHoverCardContent {
                        Text {
                            text: qsTr("悬停够久才出现，不会扫过就弹。")
                            color: theme.foreground
                            font.pixelSize: 13
                        }
                    }
                }
            }

            SectionTitle { text: qsTr("方向与对齐（side / align / alignOffset）") }
            Row {
                spacing: 20
                ShadcnHoverCard {
                    ShadcnHoverCardTrigger { text: qsTr("side=top") }
                    ShadcnHoverCardContent {
                        side: "top"
                        Text {
                            text: qsTr("优先在触发项上方浮出；放不下才翻到下方。")
                            color: theme.foreground
                            font.pixelSize: 13
                        }
                    }
                }
                ShadcnHoverCard {
                    ShadcnHoverCardTrigger { text: qsTr("align=start") }
                    ShadcnHoverCardContent {
                        align: "start"
                        alignOffset: 0
                        Text {
                            text: qsTr("左缘对齐触发项（registry 默认 alignOffset=4）。")
                            color: theme.foreground
                            font.pixelSize: 13
                        }
                    }
                }
                ShadcnHoverCard {
                    ShadcnHoverCardTrigger { text: qsTr("w-72 宽卡片") }
                    ShadcnHoverCardContent {
                        panelWidth: 288
                        Text {
                            text: qsTr("面板宽度默认 256（registry w-64），panelWidth 可覆盖。")
                            color: theme.foreground
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }

            SectionTitle { text: qsTr("程序化显示（无鼠标场景）") }
            Row {
                spacing: 16
                ShadcnHoverCard {
                    id: forcedCard
                    open: forceSwitch.checked
                    ShadcnHoverCardTrigger { text: qsTr("被开关强制显示") }
                    ShadcnHoverCardContent {
                        Text {
                            text: qsTr("open: true 忽略悬停计时直接显示，用于演示与截图。")
                            color: theme.foreground
                            font.pixelSize: 13
                        }
                    }
                }
                ShadcnSwitch { id: forceSwitch }
            }

            Item { width: 1; height: theme.spacingXl }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

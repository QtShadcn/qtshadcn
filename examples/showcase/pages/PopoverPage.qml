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
            text: qsTr("ShadcnPopover")
        }
        Text {
            color: theme.mutedForeground
            font.pixelSize: 13
            text: qsTr("点击触发的气泡弹层：Trigger + Content 组合，可放任意内容（表单 / 输入框）。支持 side / align / alignOffset / sideOffset，贴边自动翻转。点击外部或按 ESC 关闭。")
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

            SectionTitle { text: qsTr("基础用法（Header / Title / Description）") }
            // 截图示例单独占一行：面板 288px 宽从触发项左缘展开（align=start），
            // 与同行右侧的示例必然重叠，效果图会糊在一起
            Row {
                spacing: 16
                ShadcnPopover {
                    // 截图模式下自动展开首个示例，否则文档效果图只有触发按钮
                    open: ThemeManager.screenshotMode()
                    ShadcnPopoverTrigger { text: qsTr("编辑资料"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        // 截图示例靠左缘，用 align=start 让面板贴着触发项展开，
                        // 否则 288px 宽居中会把左半截伸进导航栏被裁掉
                        align: "start"
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("更新头像") }
                            ShadcnPopoverDescription { text: qsTr("头像将显示在你的个人资料中。") }
                        }
                        ShadcnInput { placeholderText: qsTr("输入新头像 URL") }
                        ShadcnButton { text: qsTr("提交"); Layout.fillWidth: true }
                    }
                }
            }

            Row {
                spacing: 16
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("筛选"); variant: ShadcnButton.Variant.Secondary; iconName: "filter" }
                    ShadcnPopoverContent {
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("通知设置") }
                        }
                        Repeater {
                            model: [qsTr("邮件提醒"), qsTr("桌面推送"), qsTr("每周摘要")]
                            Item {
                                id: row
                                required property int index
                                required property string modelData
                                // Layout 子项不写裸 width/height（Quick.layout-positioning）
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 8
                                    ShadcnCheckbox { checked: row.index === 0 }
                                    ShadcnLabel { text: row.modelData; Layout.fillWidth: true }
                                }
                            }
                        }
                    }
                }
            }

            // 同 HoverCardPage：截图模式下面板画在 overlay 层、不占布局，
            // 会盖住紧随其后的标题与示例行。垫一块 ≈ 面板高的空白把它们推开。
            Item { width: 1; height: ThemeManager.screenshotMode() ? 160 : 0 }

            SectionTitle { text: qsTr("方向与对齐（side / align）") }
            Row {
                spacing: 16
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("side=top"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        side: "top"
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("在上方打开") }
                            ShadcnPopoverDescription { text: qsTr("side=\"top\"：优先放在触发项上方，放不下才翻到下方。") }
                        }
                    }
                }
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("align=start"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        align: "start"
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("左对齐触发项") }
                            ShadcnPopoverDescription { text: qsTr("align=\"start\"：面板左缘对齐触发项左缘（默认 center）。") }
                        }
                    }
                }
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("align=end"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        align: "end"
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("右对齐触发项") }
                            ShadcnPopoverDescription { text: qsTr("align=\"end\"：面板右缘对齐触发项右缘，溢出时钳回窗口内。") }
                        }
                    }
                }
            }

            SectionTitle { text: qsTr("自定义宽度与间距") }
            Row {
                spacing: 16
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("w-64"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        panelWidth: 256
                        panelPadding: 12
                        contentSpacing: 6
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("窄面板") }
                            ShadcnPopoverDescription { text: qsTr("panelWidth=256 / panelPadding=12 / contentSpacing=6") }
                        }
                    }
                }
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("宽面板 + sideOffset"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        panelWidth: 360
                        sideOffset: 12
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("360px 宽") }
                            ShadcnPopoverDescription { text: qsTr("sideOffset=12：与触发项拉开距离。") }
                        }
                    }
                }
            }

            // 故意留出长空白：把这行滚到窗口底部再点，才会看到翻转
            Item { width: 1; height: 200 }

            SectionTitle { text: qsTr("贴近窗口底部（自动翻转到上方）") }
            Text {
                color: theme.mutedForeground
                font.pixelSize: 13
                text: qsTr("把页面滚到底，让触发按钮贴近窗口下沿 —— 下方放不下时定位器会把面板翻到上方（placement.resolvedSide = \"top\"）。")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            Row {
                ShadcnPopover {
                    ShadcnPopoverTrigger { text: qsTr("贴底触发"); variant: ShadcnButton.Variant.Outline }
                    ShadcnPopoverContent {
                        ShadcnPopoverHeader {
                            ShadcnPopoverTitle { text: qsTr("已自动翻转") }
                            ShadcnPopoverDescription { text: qsTr("这就是 ShadcnPopupPosition 的边界翻转，Popover 免费送。") }
                        }
                    }
                }
            }

            // 底部只留 ~60px：滚到底时触发项下方放不下面板 → 必然翻转
            Item { width: 1; height: 60 }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

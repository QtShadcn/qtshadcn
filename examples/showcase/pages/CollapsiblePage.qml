// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtShadcn

// Collapsible 页：三段式 / Item 变体 / 受控 open / 表单里的用法 + 代码块
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnCollapsible")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("可折叠内容：单块开合区。官方 registry 里 Collapsible 三件套是零样式透传，所以 Trigger/Content 直接复用 Accordion 的同源实现（双 chevron、高度动画、收起后不可交互），这里只多一个 open 布尔量。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）
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

            // ── 基本（默认收起）──
            SectionTitle {
                text: qsTr("基本（open 受控，这里初始展开）")
            }
            ShadcnCollapsible {
                objectName: "colBasic"
                open: true
                width: 460

                ShadcnCollapsibleTrigger { text: qsTr("筛选条件") }
                ShadcnCollapsibleContent {
                    ColumnLayout {
                        spacing: theme.spacingSm

                        RowLayout {
                            spacing: theme.spacingSm

                            Text {
                                text: qsTr("关键词")
                                color: theme.mutedForeground
                                font.pixelSize: 13
                            }
                            ShadcnInput {
                                Layout.fillWidth: true
                                placeholderText: qsTr("搜索…")
                            }
                        }
                        RowLayout {
                            spacing: theme.spacingSm

                            Text {
                                text: qsTr("状态")
                                color: theme.mutedForeground
                                font.pixelSize: 13
                            }
                            ShadcnBadge { text: qsTr("Active") }
                            ShadcnBadge { text: qsTr("Draft") }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
            }

            // ── 默认展开 ──
            SectionTitle {
                text: qsTr("open: true（默认展开）")
            }
            ShadcnCollapsible {
                open: true
                width: 460

                ShadcnCollapsibleTrigger { text: qsTr("部署选项") }
                ShadcnCollapsibleContent {
                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("open 是受控布尔量：宿主写 open = true 初始即展开，点标题同样回写 open。收起时内容高 0 且不可交互。")
                        color: theme.mutedForeground
                        font.pixelSize: 14
                    }
                }
            }

            // ── Item 变体（带分隔线）──
            SectionTitle {
                text: qsTr("行变体（内部套 AccordionItem，末行有分隔线语义）")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("想要官方 accordion 那种底部分隔线时，套一层 ShadcnAccordionItem 即可，展开语义仍由 Collapsible.open 决定。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }
            ShadcnCollapsible {
                open: true
                width: 460

                ShadcnAccordionItem {
                    ShadcnAccordionTrigger { text: qsTr("高级设置") }
                    ShadcnAccordionContent {
                        ColumnLayout {
                            spacing: theme.spacingSm

                            RowLayout {
                                spacing: theme.spacingMd

                                Text {
                                    Layout.fillWidth: true
                                    text: qsTr("启用实验性渲染")
                                    color: theme.foreground
                                    font.pixelSize: 14
                                }
                                ShadcnSwitch {}
                            }
                            RowLayout {
                                spacing: theme.spacingMd

                                Text {
                                    Layout.fillWidth: true
                                    text: qsTr("详细日志")
                                    color: theme.foreground
                                    font.pixelSize: 14
                                }
                                ShadcnSwitch {}
                            }
                        }
                    }
                }
            }

            // ── 受控 open ──
            SectionTitle {
                text: qsTr("受控 open + toggled 信号")
            }
            RowLayout {
                spacing: theme.spacingSm

                Text {
                    text: qsTr("当前状态：") + (colControlled.open ? "展开" : "收起")
                    color: theme.mutedForeground
                    font.pixelSize: 12
                }
                ShadcnButton {
                    text: qsTr("展开")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Outline
                    onClicked: colControlled.open = true
                }
                ShadcnButton {
                    text: qsTr("收起")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Ghost
                    onClicked: colControlled.open = false
                }
                Item { Layout.fillWidth: true }
            }
            ShadcnCollapsible {
                id: colControlled

                objectName: "colControlled"
                width: 460

                ShadcnCollapsibleTrigger { text: qsTr("点标题或用上面的按钮") }
                ShadcnCollapsibleContent {
                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("toggled(opened) 只在用户点击时发；宿主直接写 open 不发信号（受控写入不算用户动作）。")
                        color: theme.mutedForeground
                        font.pixelSize: 14
                    }
                }
            }

            // ── QML 用法 ──
            RowLayout {
                spacing: theme.spacingSm

                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item { Layout.fillWidth: true }
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/collapsible")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnCollapsible {\n    width: 460\n    open: false                  // 受控布尔量\n    onToggled: opened => console.log(opened)\n\n    ShadcnCollapsibleTrigger { text: \"筛选条件\" }\n    ShadcnCollapsibleContent {\n        Text { Layout.fillWidth: true; color: theme.mutedForeground; text: \"……\" }\n    }\n}\n\n// 想要行分隔线时：\nShadcnCollapsible {\n    ShadcnAccordionItem {\n        ShadcnAccordionTrigger { text: \"高级设置\" }\n        ShadcnAccordionContent { /* …… */ }\n    }\n}"
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

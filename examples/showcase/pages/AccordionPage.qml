// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtShadcn

// Accordion 页：单选 / collapsible=true / multiple / 禁用项 + 用法代码块
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
            text: qsTr("ShadcnAccordion")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("手风琴：Accordion（根，纵向列）+ AccordionItem（行，除末行外底部分隔线）+ AccordionTrigger（行头，双 chevron 互斥切换）+ AccordionContent（内容，高度 0↔自然高动画 + clip）。multiple / collapsible / value 三个语义与 Base UI 对齐。")
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

            // ── 默认：单选 + collapsible=false ──
            SectionTitle {
                text: qsTr("默认（单选 · collapsible=false）")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("点一行会收起上一行；点已展开的那行不会收起（至少保持一项展开）。value 初始为空 = 全收起，这里为截图先展开第一项。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }
            ShadcnAccordion {
                objectName: "accSingle"
                value: "faq1"
                width: 460

                ShadcnAccordionItem {
                    value: "faq1"
                    ShadcnAccordionTrigger { text: qsTr("QtShadcn 是什么？") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("一套 shadcn/ui 风格（base-nova 口径）的 Qt Quick 组件库：QML 管 UI、C++ 管能力，颜色全部走 design token。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "faq2"
                    ShadcnAccordionTrigger { text: qsTr("展开动画怎么实现的？") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("Qt 没有 CSS 的 grid-template-rows 0fr→1fr。外层 clip + 动画自己的 height，内容宿主固定自然高，依赖单向，不会被布局接管。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "faq3"
                    ShadcnAccordionTrigger { text: qsTr("支持暗色吗？") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("支持。分隔线取 theme.border、内容文字取 theme.mutedForeground，右上角切换明暗整块跟着走。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // ── collapsible=true ──
            SectionTitle {
                text: qsTr("collapsible: true（点已展开项可收起）")
            }
            ShadcnAccordion {
                collapsible: true
                width: 460

                ShadcnAccordionItem {
                    value: "c1"
                    ShadcnAccordionTrigger { text: qsTr("允许全收起") }
                    ShadcnAccordionContent {
                        RowLayout {
                            spacing: theme.spacingSm
                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: qsTr("再点一次标题就会收起来，value 变回空字符串。")
                                color: theme.mutedForeground
                                font.pixelSize: 14
                            }
                            ShadcnButton {
                                text: qsTr("动作")
                                size: ShadcnButton.Size.Small
                                variant: ShadcnButton.Variant.Outline
                            }
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "c2"
                    ShadcnAccordionTrigger { text: qsTr("第二项") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("内容里放按钮也能点：展开态内容可交互。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // ── multiple ──
            SectionTitle {
                text: qsTr("multiple: true（多开，value 是 string[]）")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("多选时收起某一项不影响其它项；value 读写都是数组。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }
            ShadcnAccordion {
                multiple: true
                value: ["m1"]
                width: 460

                ShadcnAccordionItem {
                    value: "m1"
                    ShadcnAccordionTrigger { text: qsTr("通知设置") }
                    ShadcnAccordionContent {
                        ColumnLayout {
                            spacing: theme.spacingSm
                            ShadcnCheckbox { text: qsTr("邮件通知") }
                            ShadcnCheckbox { text: qsTr("桌面推送") }
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "m2"
                    ShadcnAccordionTrigger { text: qsTr("隐私设置") }
                    ShadcnAccordionContent {
                        ColumnLayout {
                            spacing: theme.spacingSm
                            ShadcnCheckbox { text: qsTr("匿名使用统计") }
                            ShadcnCheckbox { text: qsTr("崩溃报告") }
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "m3"
                    ShadcnAccordionTrigger { text: qsTr("高级") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("三行同时展开也互不影响。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // ── 受控 value ──
            SectionTitle {
                text: qsTr("受控 value（宿主写入即生效）")
            }
            RowLayout {
                spacing: theme.spacingSm

                Text {
                    text: qsTr("当前展开：") + (accControlled.value === "" ? "（无）" : accControlled.value)
                    color: theme.mutedForeground
                    font.pixelSize: 12
                }
                ShadcnButton {
                    text: qsTr("展开全部")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Outline
                    onClicked: accControlled.value = "s1"
                }
                ShadcnButton {
                    text: qsTr("切到 s2")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Ghost
                    onClicked: accControlled.value = "s2"
                }
                ShadcnButton {
                    text: qsTr("全收")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Ghost
                    onClicked: accControlled.value = ""
                }
            }
            ShadcnAccordion {
                id: accControlled

                collapsible: true
                width: 460

                ShadcnAccordionItem {
                    value: "s1"
                    ShadcnAccordionTrigger { text: qsTr("Section 1") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("内容由上面的按钮通过 value 控制。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "s2"
                    ShadcnAccordionTrigger { text: qsTr("Section 2") }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("点击标题同样会回写 value（两向同步）。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // ── 禁用项 ──
            SectionTitle {
                text: qsTr("禁用项（aria-disabled → opacity-50）")
            }
            ShadcnAccordion {
                collapsible: true
                value: "d1"
                width: 460

                ShadcnAccordionItem {
                    value: "d1"
                    ShadcnAccordionTrigger {
                        text: qsTr("可以打开")
                    }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("正常行。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
                    }
                }
                ShadcnAccordionItem {
                    value: "d2"
                    ShadcnAccordionTrigger {
                        text: qsTr("禁用行（点不动）")
                        enabled: false
                    }
                    ShadcnAccordionContent {
                        Text {
                            Layout.fillWidth: true
                            text: qsTr("不会被展开。")
                            color: theme.mutedForeground
                            font.pixelSize: 14
                        }
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/accordion")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnAccordion {\n    width: 460\n    multiple: false            // true = 多开，value 为 string[]\n    collapsible: false           // 单选时点已展开项是否可收起\n    value: \"\"                    // 受控：string / string[]\n    onToggled: (value, opened) => console.log(value, opened)\n\n    ShadcnAccordionItem {\n        value: \"faq1\"\n        ShadcnAccordionTrigger { text: \"QtShadcn 是什么？\" }\n        ShadcnAccordionContent {\n            Text { Layout.fillWidth: true; color: theme.mutedForeground; text: \"……\" }\n        }\n    }\n}"
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

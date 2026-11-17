// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// ScrollArea + ScrollBar 展示页
Item {
    id: root

    QtShadcnTheme { id: theme }

    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40
        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnScrollArea / ShadcnScrollBar")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("滚动区域：对齐 shadcn 的 w-2.5 + p-px —— 轨道 10px、thumb 8px、全圆角、颜色取 theme.border。"
                       + "ShadcnScrollBar 可单独 attach 到任意 Flickable / TableView / ListView"
                       + "（但不要 attach 到 ScrollView：Qt 不会拉伸它的几何，滚动条会缩成一个小点）。")
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

            // ── 基础：竖直滚动 ──
            SectionTitle { text: qsTr("基础用法（竖直滚动）") }

            DemoFrame {
                width: 320
                height: 180
                ShadcnScrollArea {
                    anchors.fill: parent
                    Column {
                        width: 318
                        Repeater {
                            model: 20
                            delegate: Item {
                                id: listItem
                                required property int index
                                width: parent.width
                                height: 36
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: qsTr("列表项 %1").arg(listItem.index + 1)
                                    color: theme.foreground
                                    font.pixelSize: 13
                                }
                            }
                        }
                    }
                }
            }

            // ── 横向滚动 ──
            SectionTitle { text: qsTr("横向滚动") }

            DemoFrame {
                width: 320
                height: 70
                ShadcnScrollArea {
                    anchors.fill: parent
                    Row {
                        height: 68
                        spacing: 8
                        Repeater {
                            model: 12
                            delegate: ShadcnBadge {
                                id: badgeItem
                                required property int index
                                text: qsTr("标签 %1").arg(badgeItem.index + 1)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // ── 双向滚动 ──
            SectionTitle { text: qsTr("双向滚动（内容同时超宽超高）") }

            DemoFrame {
                width: 320
                height: 160
                ShadcnScrollArea {
                    anchors.fill: parent
                    Grid {
                        columns: 12
                        spacing: 2
                        Repeater {
                            model: 288
                            delegate: Rectangle {
                                id: gridCell
                                required property int index
                                width: 56
                                height: 26
                                radius: 3
                                color: gridCell.index % 2 === 0 ? theme.muted : theme.accent
                                Text {
                                    anchors.centerIn: parent
                                    text: Math.floor(gridCell.index / 12) + "," + (gridCell.index % 12)
                                    color: theme.mutedForeground
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }
            }

            // ── 滚动条策略 ──
            SectionTitle { text: qsTr("滚动条策略") }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: theme.mutedForeground
                font.pixelSize: 13
                text: qsTr("verticalPolicy / horizontalPolicy 直接透传给内部 ScrollBar：AsNeeded（默认）/ AlwaysOn / AlwaysOff。\n"
                           + "注意 shadcn 的 ScrollArea 默认只挂竖直条，Qt 这边两向都默认 AsNeeded —— "
                           + "因为 Flickable 本来就支持横向拖动，隐藏条而不禁拖动会变成「能滚但看不见」。")
            }

            Row {
                spacing: 12
                Column {
                    spacing: 6
                    Text { text: "AlwaysOn"; color: theme.mutedForeground; font.pixelSize: 12 }
                    DemoFrame {
                        width: 150
                        height: 100
                        ShadcnScrollArea {
                            anchors.fill: parent
                            verticalPolicy: ScrollBar.AlwaysOn
                            Column {
                                width: 148
                                Rectangle { width: 148; height: 40; color: theme.muted }
                            }
                        }
                    }
                }
                Column {
                    spacing: 6
                    Text { text: "AlwaysOff"; color: theme.mutedForeground; font.pixelSize: 12 }
                    DemoFrame {
                        width: 150
                        height: 100
                        ShadcnScrollArea {
                            anchors.fill: parent
                            verticalPolicy: ScrollBar.AlwaysOff
                            Column {
                                width: 148
                                Repeater {
                                    model: 10
                                    delegate: Rectangle {
                                        required property int index
                                        width: 148
                                        height: 20
                                        color: index % 2 === 0 ? theme.muted : "transparent"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── 独立使用 ScrollBar ──
            SectionTitle { text: qsTr("单独 attach ShadcnScrollBar") }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: theme.mutedForeground
                font.pixelSize: 13
                text: qsTr("Textarea / Dialog 弹层 / Table 的滚动条都已换成这个组件，样式只在 ShadcnScrollBar 里定义一处。")
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "Flickable {\n    ScrollBar.vertical: ShadcnScrollBar { policy: ScrollBar.AsNeeded }\n}\n\n"
                      + "ShadcnScrollArea {\n    width: 320; height: 180\n    Column { /* 单个内容根 */ }\n}"
            }

            Item { width: 1; height: 8 }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // shadcn 的示例写法：rounded-md + border，内容在框内滚动
    component DemoFrame: Rectangle {
        radius: 6
        color: "transparent"
        border.width: 1
        border.color: theme.border
        clip: true
        default property alias content: frameInner.data

        Item {
            id: frameInner
            anchors.fill: parent
            anchors.margins: 1
        }
    }
}

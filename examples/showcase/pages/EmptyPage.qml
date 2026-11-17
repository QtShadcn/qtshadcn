import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Empty 页：组合结构 / Media 两变体 / 虚线描边开关 / 真实业务示例全展示
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
            text: qsTr("ShadcnEmpty")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("空状态占位：Empty = Header（Media + Title + Description）+ Content。居中列 + p-6 内边距 + rounded-xl；虚线描边用 Shape 实现（Rectangle 的 border 只有实线）。")
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

            // ── 基础结构（官方默认：无描边）──
            SectionTitle {
                text: qsTr("基础结构（官方默认无描边）")
            }
            ShadcnEmpty {
                width: 420
                height: 240

                ShadcnEmptyHeader {
                    ShadcnEmptyMedia {
                        variant: ShadcnEmptyMedia.Variant.Icon
                        iconName: "inbox"
                    }
                    ShadcnEmptyTitle {
                        text: qsTr("No data")
                    }
                    ShadcnEmptyDescription {
                        text: qsTr("You do not have any notifications.")
                    }
                }
                ShadcnEmptyContent {
                    ShadcnButton {
                        text: qsTr("Add data")
                    }
                }
            }

            // ── 虚线描边（官方 Outlined 示例 = border + border-dashed）──
            SectionTitle {
                text: qsTr("虚线描边（bordered: true）")
            }
            ShadcnEmpty {
                width: 420
                height: 240
                bordered: true

                ShadcnEmptyHeader {
                    ShadcnEmptyMedia {
                        variant: ShadcnEmptyMedia.Variant.Icon
                        iconName: "search"
                    }
                    ShadcnEmptyTitle {
                        text: qsTr("No results")
                    }
                    ShadcnEmptyDescription {
                        text: qsTr("试试换个关键词，或清空筛选条件。")
                    }
                }
                ShadcnEmptyContent {
                    ShadcnButton {
                        text: qsTr("清空筛选")
                        variant: ShadcnButton.Variant.Outline
                    }
                }
            }

            // ── 实线对照（dashed: false）──
            Row {
                spacing: theme.spacingMd

                Column {
                    spacing: theme.spacingSm

                    SectionTitle {
                        text: qsTr("dashed: false（实线对照）")
                    }
                    ShadcnEmpty {
                        width: 260
                        height: 160
                        bordered: true
                        dashed: false

                        ShadcnEmptyHeader {
                            ShadcnEmptyTitle {
                                text: qsTr("实线描边")
                            }
                        }
                    }
                }

                Column {
                    spacing: theme.spacingSm

                    SectionTitle {
                        text: qsTr("带底色（bg-muted/30）")
                    }
                    ShadcnEmpty {
                        width: 260
                        height: 160
                        bordered: true
                        color: theme.muted

                        ShadcnEmptyHeader {
                            ShadcnEmptyTitle {
                                text: qsTr("带底色")
                            }
                        }
                    }
                }
            }

            // ── EmptyMedia 两变体 ──
            SectionTitle {
                text: qsTr("EmptyMedia 变体")
            }
            Row {
                spacing: theme.spacingXl

                Column {
                    spacing: theme.spacingSm

                    Text {
                        text: qsTr("variant: Default（无底色）")
                        color: theme.mutedForeground
                        font.pixelSize: 12
                    }
                    ShadcnEmpty {
                        width: 200
                        height: 120

                        ShadcnEmptyHeader {
                            ShadcnEmptyMedia {
                                iconName: "inbox"
                            }
                            ShadcnEmptyTitle {
                                text: qsTr("Default")
                            }
                        }
                    }
                }

                Column {
                    spacing: theme.spacingSm

                    Text {
                        text: qsTr("variant: Icon（size-8 带底色方块）")
                        color: theme.mutedForeground
                        font.pixelSize: 12
                    }
                    ShadcnEmpty {
                        width: 200
                        height: 120

                        ShadcnEmptyHeader {
                            ShadcnEmptyMedia {
                                variant: ShadcnEmptyMedia.Variant.Icon
                                iconName: "inbox"
                            }
                            ShadcnEmptyTitle {
                                text: qsTr("Icon")
                            }
                        }
                    }
                }

                Column {
                    spacing: theme.spacingSm

                    Text {
                        text: qsTr("Media 内放头像")
                        color: theme.mutedForeground
                        font.pixelSize: 12
                    }
                    ShadcnEmpty {
                        width: 200
                        height: 120

                        ShadcnEmptyHeader {
                            ShadcnEmptyMedia {
                                ShadcnAvatar {
                                    text: "CN"
                                    size: ShadcnAvatar.Size.Large
                                }
                            }
                            ShadcnEmptyTitle {
                                text: qsTr("Avatar")
                            }
                        }
                    }
                }
            }

            // ── 仅 Header / 仅 Content ──
            SectionTitle {
                text: qsTr("任意组合")
            }
            Row {
                spacing: theme.spacingMd

                ShadcnEmpty {
                    width: 200
                    height: 110
                    bordered: true

                    ShadcnEmptyHeader {
                        ShadcnEmptyTitle {
                            text: qsTr("仅 Header")
                        }
                        ShadcnEmptyDescription {
                            text: qsTr("无操作区")
                        }
                    }
                }

                ShadcnEmpty {
                    width: 200
                    height: 110
                    bordered: true

                    ShadcnEmptyContent {
                        ShadcnButton {
                            text: qsTr("仅 Content")
                            size: ShadcnButton.Size.Small
                        }
                    }
                }
            }

            // ── 真实业务：列表空状态 ──
            SectionTitle {
                text: qsTr("业务示例（撑满容器）")
            }
            Rectangle {
                width: 420
                height: 260
                color: theme.card
                radius: theme.radius
                border.width: 1
                border.color: theme.border

                ShadcnEmpty {
                    anchors.fill: parent
                    anchors.margins: 1
                    bordered: true

                    ShadcnEmptyHeader {
                        ShadcnEmptyMedia {
                            variant: ShadcnEmptyMedia.Variant.Icon
                            iconName: "folder-open"
                        }
                        ShadcnEmptyTitle {
                            text: qsTr("暂无项目")
                        }
                        ShadcnEmptyDescription {
                            text: qsTr("你还没有创建任何项目。创建第一个项目后，这里会显示项目列表。")
                        }
                    }
                    ShadcnEmptyContent {
                        Row {
                            spacing: theme.spacingSm

                            ShadcnButton {
                                text: qsTr("新建项目")
                                size: ShadcnButton.Size.Small
                            }
                            ShadcnButton {
                                text: qsTr("导入")
                                variant: ShadcnButton.Variant.Outline
                                size: ShadcnButton.Size.Small
                            }
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/empty")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnEmpty {\n    bordered: true\n    ShadcnEmptyHeader {\n        ShadcnEmptyMedia { variant: ShadcnEmptyMedia.Variant.Icon; iconName: \"inbox\" }\n        ShadcnEmptyTitle { text: \"暂无数据\" }\n        ShadcnEmptyDescription { text: \"先创建一条吧。\" }\n    }\n    ShadcnEmptyContent {\n        ShadcnButton { text: \"新建\" }\n    }\n}"
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

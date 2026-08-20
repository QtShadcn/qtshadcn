import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// StatusDot 页：全部 Status 枚举 / 尺寸 / border 模式 / 文本标签组合
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
            text: qsTr("ShadcnStatusDot")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("状态小圆点，语义色映射：Online/Success（绿）、Away/Busy/Warning（黄）、Danger（红）、Offline（mutedForeground）。可独立使用，也常作为 Avatar 的右下角覆盖层。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区
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

            // ── 全部 Status 枚举 ──
            SectionTitle {
                text: qsTr("Status 枚举（默认 size=8px）")
            }
            Column {
                spacing: theme.spacingSm

                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Online }
                    Text { text: "Online / Success (绿 #22c55e)"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Away }
                    Text { text: "Away / Busy / Warning (黄 #f59e0b)"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Danger }
                    Text { text: "Danger (红 #ef4444)"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Offline }
                    Text { text: "Offline (theme.mutedForeground)"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Success }
                    Text { text: "Success — 与 Online 同色（语义区分）"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                Row {
                    spacing: theme.spacingMd
                    ShadcnStatusDot { status: ShadcnStatusDot.Status.Warning }
                    Text { text: "Warning — 与 Away/Busy 同色（语义区分）"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // ── Size 对比 ──
            SectionTitle {
                text: qsTr("Size 自定义（6 / 8 / 12 / 16 / 24）")
            }
            Row {
                spacing: theme.spacingMd

                ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 6 }
                ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 8 }
                ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 12 }
                ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 16 }
                ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; size: 24 }
            }

            // ── Border 模式（叠在彩色背景上） ──
            SectionTitle {
                text: qsTr("Border 模式（叠放在彩色背景上用描边区分）")
            }
            Row {
                spacing: theme.spacingSm

                // 无 border：叠在彩色底上边缘糊
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: theme.primary
                    ShadcnStatusDot {
                        status: ShadcnStatusDot.Status.Online
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        size: 12
                    }
                }

                // 有 border：卡片底色描边，边缘清晰
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: theme.primary
                    ShadcnStatusDot {
                        status: ShadcnStatusDot.Status.Online
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        size: 12
                        border: true
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: theme.primary
                    ShadcnStatusDot {
                        status: ShadcnStatusDot.Status.Danger
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        size: 12
                        border: true
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: theme.primary
                    ShadcnStatusDot {
                        status: ShadcnStatusDot.Status.Warning
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        size: 12
                        border: true
                    }
                }
            }

            // ── 行内状态标签 ──
            SectionTitle {
                text: qsTr("行内状态（列表项左侧指示点）")
            }
            ShadcnCard {
                width: 420
                ShadcnCardContent {
                    Column {
                        width: parent.width
                        spacing: theme.spacingSm

                        Row {
                            width: parent.width
                            spacing: theme.spacingSm
                            ShadcnStatusDot { status: ShadcnStatusDot.Status.Online; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "alice@qt.io"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                            Item { Layout.fillWidth: true; width: 1 }
                            Text { text: "2 分钟前"; color: theme.mutedForeground; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Row {
                            width: parent.width
                            spacing: theme.spacingSm
                            ShadcnStatusDot { status: ShadcnStatusDot.Status.Away; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "bob@qt.io"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                            Item { Layout.fillWidth: true; width: 1 }
                            Text { text: "15 分钟前"; color: theme.mutedForeground; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Row {
                            width: parent.width
                            spacing: theme.spacingSm
                            ShadcnStatusDot { status: ShadcnStatusDot.Status.Offline; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "carol@qt.io"; color: theme.foreground; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                            Item { Layout.fillWidth: true; width: 1 }
                            Text { text: "1 小时前"; color: theme.mutedForeground; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            SectionTitle {
                text: qsTr("QML 用法")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "// 独立使用\nShadcnStatusDot {\n    status: ShadcnStatusDot.Status.Online\n    size: 8\n}\n\n// 叠在彩色背景（Avatar / Card 底）上，开 border\nShadcnStatusDot {\n    status: ShadcnStatusDot.Status.Success\n    size: 12\n    border: true   // 用 theme.card 做 1px 描边\n}\n\n// 组合 Avatar 右下角（Avatar 内置此能力）\nShadcnAvatar {\n    text: \"Ryan\"\n    status: ShadcnStatusDot.Status.Online\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Avatar 页：5 种尺寸 / 三种内容模式（图片/图标/首字母）/ StatusDot 覆盖层
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
            text: qsTr("ShadcnAvatar")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("圆形头像组件：支持图片 / 图标 / 首字母三选一（优先级 source > iconName > text），5 种尺寸，右下角可叠加 StatusDot 状态点。")
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

            // ── Size 全尺寸 ──
            SectionTitle {
                text: qsTr("Size（XSmall → XLarge）")
            }
            Row {
                spacing: theme.spacingMd

                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.XSmall; text: "A" }
                    Text { text: "24px"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Small; text: "B" }
                    Text { text: "32px"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Medium; text: "C" }
                    Text { text: "44px"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "D" }
                    Text { text: "56px"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.XLarge; text: "E" }
                    Text { text: "72px"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // ── 三种内容模式 ──
            SectionTitle {
                text: qsTr("内容模式（优先级：source > iconName > text）")
            }
            Row {
                spacing: theme.spacingMd

                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; iconName: "user" }
                    Text { text: qsTr("图标"); color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "Ryan" }
                    Text { text: qsTr("首字母"); color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar {
                        size: ShadcnAvatar.Size.Large
                        bgColor: theme.secondary
                        textColor: theme.secondaryForeground
                        text: "李"
                    }
                    Text { text: qsTr("自定义颜色"); color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // ── StatusDot 叠加 ──
            SectionTitle {
                text: qsTr("Status 覆盖层（与 ShadcnStatusDot 联动）")
            }
            Row {
                spacing: theme.spacingMd

                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "在线"; status: ShadcnStatusDot.Status.Online }
                    Text { text: "Online"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "离开"; status: ShadcnStatusDot.Status.Away }
                    Text { text: "Away"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "忙碌"; status: ShadcnStatusDot.Status.Busy }
                    Text { text: "Busy"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "离线"; status: ShadcnStatusDot.Status.Offline }
                    Text { text: "Offline"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
                Column {
                    spacing: 4
                    ShadcnAvatar { size: ShadcnAvatar.Size.Large; text: "危险"; status: ShadcnStatusDot.Status.Danger }
                    Text { text: "Danger"; color: theme.mutedForeground; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                }
            }

            // ── 头像组（堆叠组） ──
            SectionTitle {
                text: qsTr("Avatar Group（堆叠显示）")
            }
            Row {
                spacing: -12   // 负值让头像互相叠加

                ShadcnAvatar {
                    size: ShadcnAvatar.Size.Medium
                    text: "A"
                    bgColor: "#2563eb"
                    Rectangle {
                        // 右边叠一层描边遮挡下一个头像（比 z 更稳）
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: theme.card
                    }
                }
                ShadcnAvatar {
                    size: ShadcnAvatar.Size.Medium
                    text: "B"
                    bgColor: "#0ea5e9"
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: theme.card
                    }
                }
                ShadcnAvatar {
                    size: ShadcnAvatar.Size.Medium
                    text: "C"
                    bgColor: "#16a34a"
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: theme.card
                    }
                }
                ShadcnAvatar {
                    size: ShadcnAvatar.Size.Medium
                    text: "+5"
                    bgColor: theme.muted
                    textColor: theme.mutedForeground
                }
            }

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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/avatar")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "// 基础首字母头像\nShadcnAvatar {\n    size: ShadcnAvatar.Size.Medium\n    text: \"Ryan\"\n}\n\n// 图标头像 + 在线状态\nShadcnAvatar {\n    size: ShadcnAvatar.Size.Large\n    iconName: \"user\"\n    status: ShadcnStatusDot.Status.Online\n}\n\n// 图片头像\nShadcnAvatar {\n    source: \"file:/path/to/photo.png\"\n    size: ShadcnAvatar.Size.XLarge\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Badge 页：6 variant 全展示
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
            text: qsTr("ShadcnBadge")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("胶囊形徽标，6 种 variant。注意 destructive 是 v4 新风格「透明底红字」（旧版是实心红底白字）。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
    // 注：height: parent.height - y 会因 y 自引用形成绑定循环（高度塌缩 implicitHeight）
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

            SectionTitle {
                text: qsTr("Variant")
            }
            Flow {
                width: parent.width - 48
                spacing: theme.spacingSm

                ShadcnBadge {
                    text: qsTr("Default")
                    variant: ShadcnBadge.Variant.Default
                }
                ShadcnBadge {
                    text: qsTr("Secondary")
                    variant: ShadcnBadge.Variant.Secondary
                }
                ShadcnBadge {
                    text: qsTr("Destructive")
                    variant: ShadcnBadge.Variant.Destructive
                }
                ShadcnBadge {
                    text: qsTr("Outline")
                    variant: ShadcnBadge.Variant.Outline
                }
                ShadcnBadge {
                    text: qsTr("Ghost")
                    variant: ShadcnBadge.Variant.Ghost
                }
                ShadcnBadge {
                    text: qsTr("Link")
                    variant: ShadcnBadge.Variant.Link
                }
            }

            SectionTitle {
                text: qsTr("组合（Card Header + Badge）")
            }
            ShadcnCard {
                width: 420

                ShadcnCardHeader {
                    ShadcnCardTitle {
                        text: qsTr("功能开关")
                    }
                    ShadcnCardDescription {
                        text: qsTr("实验性新功能，默认关闭。")
                    }
                }
                ShadcnCardContent {
                    Row {
                        spacing: theme.spacingSm
                        ShadcnBadge {
                            text: qsTr("Beta")
                            variant: ShadcnBadge.Variant.Secondary
                        }
                        ShadcnBadge {
                            text: qsTr("New")
                            variant: ShadcnBadge.Variant.Default
                        }
                        ShadcnBadge {
                            text: qsTr("Deprecated")
                            variant: ShadcnBadge.Variant.Destructive
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
                text: "ShadcnBadge {\n    text: \"New\"\n    variant: ShadcnBadge.Variant.Default\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

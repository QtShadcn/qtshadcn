import QtQuick
import QtQuick.Controls
import QtShadcn

// ButtonGroup 页：按钮组（边框合并 + 分隔线 + 圆角只留两端）
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
            text: qsTr("ShadcnButtonGroup")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("相邻按钮间距 -1 合并边框、圆角只留两端；无边框 variant（如 Primary）中间自动加 1px 分隔线（按钮前景色 15%）。")
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
                text: qsTr("Primary 组（无边框，分隔线）")
            }
            ShadcnButtonGroup {
                ShadcnButton {
                    text: "A"
                    variant: ShadcnButton.Variant.Primary
                }
                ShadcnButton {
                    text: "B"
                    variant: ShadcnButton.Variant.Primary
                }
                ShadcnButton {
                    text: "C"
                    variant: ShadcnButton.Variant.Primary
                }
            }

            SectionTitle {
                text: qsTr("Outline 组（各自边框合并）")
            }
            ShadcnButtonGroup {
                ShadcnButton {
                    text: "A"
                    variant: ShadcnButton.Variant.Outline
                }
                ShadcnButton {
                    text: "B"
                    variant: ShadcnButton.Variant.Outline
                }
                ShadcnButton {
                    text: "C"
                    variant: ShadcnButton.Variant.Outline
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
                text: "ShadcnButtonGroup {\n    ShadcnButton { text: \"A\"; variant: ShadcnButton.Variant.Primary }\n    ShadcnButton { text: \"B\"; variant: ShadcnButton.Variant.Primary }\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

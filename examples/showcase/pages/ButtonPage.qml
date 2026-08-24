import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Button 页：variant × size × 状态全展示
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
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
            text: qsTr("ShadcnButton")
        }
        Text {
            color: theme.mutedForeground
            font.pixelSize: 13
            text: qsTr("基于 QQC Button（Basic style），6 种 variant × 5 种 size，支持 loading / disabled / 键盘焦点环。")
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
    // 注：height: parent.height - y 会因 y 自引用形成绑定循环（高度塌缩 implicitHeight）
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

            // ── variant ──
            SectionTitle {
                text: qsTr("Variant")
            }
            Row {
                spacing: theme.spacingSm

                ShadcnButton {
                    text: qsTr("Primary")
                    variant: ShadcnButton.Variant.Primary
                }
                ShadcnButton {
                    text: qsTr("Secondary")
                    variant: ShadcnButton.Variant.Secondary
                }
                ShadcnButton {
                    text: qsTr("Outline")
                    variant: ShadcnButton.Variant.Outline
                }
                ShadcnButton {
                    text: qsTr("Ghost")
                    variant: ShadcnButton.Variant.Ghost
                }
                ShadcnButton {
                    text: qsTr("Destructive")
                    variant: ShadcnButton.Variant.Destructive
                }
                ShadcnButton {
                    text: qsTr("Link")
                    variant: ShadcnButton.Variant.Link
                }
            }

            // ── size ──
            SectionTitle {
                text: qsTr("Size")
            }
            Row {
                spacing: theme.spacingSm

                ShadcnButton {
                    size: ShadcnButton.Size.ExtraSmall
                    text: qsTr("XS")
                }
                ShadcnButton {
                    size: ShadcnButton.Size.Small
                    text: qsTr("Small")
                }
                ShadcnButton {
                    size: ShadcnButton.Size.Medium
                    text: qsTr("Medium")
                }
                ShadcnButton {
                    size: ShadcnButton.Size.Large
                    text: qsTr("Large")
                }
                ShadcnButton {
                    size: ShadcnButton.Size.Icon
                    text: qsTr("＋")
                }
            }

            // 显式拉宽时文字仍居中（验证 contentItem 居中锚点）
            ShadcnButton {
                text: qsTr("拉伸宽度仍居中")
                width: 240
            }

            // ── disabled / loading ──
            SectionTitle {
                text: qsTr("Disabled / Loading")
            }
            Row {
                spacing: theme.spacingSm

                ShadcnButton {
                    enabled: false
                    text: qsTr("Disabled")
                }
                ShadcnButton {
                    enabled: false
                    text: qsTr("Disabled Outline")
                    variant: ShadcnButton.Variant.Outline
                }
                ShadcnButton {
                    loading: true
                    text: qsTr("Loading")
                }
                ShadcnButton {
                    loading: true
                    text: qsTr("Loading Ghost")
                    variant: ShadcnButton.Variant.Ghost
                }
            }

            // ── checkable（Toggle 基座）──
            SectionTitle {
                text: qsTr("Checkable")
            }
            Row {
                spacing: theme.spacingSm

                ShadcnButton {
                    checkable: true
                    checked: true  // 默认选中，不需要时可删除此行
                    text: checked ? qsTr("已选中") : qsTr("未选中")
                }
                ShadcnButton {
                    checkable: true
                    checked: true
                    text: qsTr("选中 Outline")
                    variant: ShadcnButton.Variant.Outline
                }
            }
            RowLayout {
                spacing: theme.spacingSm

                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    color: theme.primary
                    font.pixelSize: 12
                    font.underline: docHover.containsMouse
                    text: qsTr("查看文档 ›")

                    MouseArea {
                        id: docHover

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/button")
                    }
                }
            }
            Text {
                color: theme.mutedForeground
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                text: "ShadcnButton {\n    text: \"Deploy\"\n    variant: ShadcnButton.Variant.Primary\n    size: ShadcnButton.Size.Medium\n    loading: false\n    onClicked: { ... }\n}"
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.bold: true
        font.pixelSize: 15
    }
}

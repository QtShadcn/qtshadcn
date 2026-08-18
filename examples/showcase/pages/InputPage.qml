import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Input 页：基础 / 尺寸 / 状态 / 组合（结合 Card）
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
            text: qsTr("ShadcnInput")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("基于 QQC.TextField（Basic style）：h-9(36px) + 6px 圆角 + bg-input/50 + 聚焦 border-ring + 3px 焦点环。")
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

            // ── 基础 ──
            SectionTitle {
                text: qsTr("Basic")
            }
            ShadcnInput {
                width: 320
                placeholderText: qsTr("请输入用户名")
            }

            // ── Disabled ──
            SectionTitle {
                text: qsTr("Disabled")
            }
            ShadcnInput {
                width: 320
                enabled: false
                placeholderText: qsTr("禁用状态")
            }

            // ── 组合（Input 嵌入 Card）──
            SectionTitle {
                text: qsTr("Card + Input + Button 组合")
            }
            ShadcnCard {
                width: 420

                ShadcnCardHeader {
                    ShadcnCardTitle {
                        text: qsTr("登录")
                    }
                    ShadcnCardDescription {
                        text: qsTr("输入账号密码后提交。")
                    }
                }
                ShadcnCardContent {
                    Column {
                        width: parent.width
                        spacing: theme.spacingSm
                        ShadcnInput {
                            width: parent.width
                            placeholderText: qsTr("邮箱")
                        }
                        ShadcnInput {
                            width: parent.width
                            placeholderText: qsTr("密码")
                            echoMode: TextInput.Password
                        }
                    }
                }
                ShadcnCardFooter {
                    ShadcnButton {
                        text: qsTr("忘记密码")
                        variant: ShadcnButton.Variant.Link
                        size: ShadcnButton.Size.Small
                    }
                    Item {
                        Layout.fillWidth: true
                    }   // 占位推右
                    ShadcnButton {
                        text: qsTr("登录")
                        size: ShadcnButton.Size.Small
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
                text: "ShadcnInput {\n    placeholderText: \"请输入\"\n    echoMode: TextInput.Password\n    onAccepted: ...\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

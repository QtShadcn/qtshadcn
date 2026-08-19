import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window 2.15
import QtShadcn

// Dialog 页：基础对话框、确认对话框、自定义内容
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
            text: qsTr("ShadcnDialog")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("基于 QQC.Dialog，max-w-sm(384px) + 圆角 14 + bg-popover + 阴影 + 居中 + fade/zoom 100ms 动画；内置关闭钮、可滚动 body、底部 sticky muted footer。")
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

            // ── 基础对话框 ──
            SectionTitle {
                text: qsTr("Basic")
            }
            ShadcnButton {
                text: qsTr("打开对话框")
                onClicked: basicDialog.open()
            }
            ShadcnDialog {
                id: basicDialog
                ShadcnDialogContent {
                    ShadcnDialogHeader {
                        ShadcnDialogTitle {
                            text: qsTr("欢迎使用 QtShadcn")
                        }
                        ShadcnDialogDescription {
                            text: qsTr("这是一个基于 shadcn/ui 规范的对话框组件。")
                        }
                    }
                    footer: ShadcnDialogFooter {
                        ShadcnButton {
                            text: qsTr("关闭")
                            size: ShadcnButton.Size.Small
                            variant: ShadcnButton.Variant.Outline
                            onClicked: basicDialog.close()
                        }
                        ShadcnButton {
                            text: qsTr("好的")
                            size: ShadcnButton.Size.Small
                            onClicked: basicDialog.close()
                        }
                    }
                }
            }

            // ── 确认对话框（删除等危险操作）──
            SectionTitle {
                text: qsTr("Confirm（危险操作）")
            }
            ShadcnButton {
                text: qsTr("删除账户")
                variant: ShadcnButton.Variant.Destructive
                onClicked: confirmDialog.open()
            }
            ShadcnDialog {
                id: confirmDialog
                ShadcnDialogContent {
                    ShadcnDialogHeader {
                        ShadcnDialogTitle {
                            text: qsTr("确认删除账户？")
                        }
                        ShadcnDialogDescription {
                            text: qsTr("此操作不可撤销。账户所有数据将被永久删除。")
                        }
                    }
                    footer: ShadcnDialogFooter {
                        ShadcnButton {
                            text: qsTr("取消")
                            size: ShadcnButton.Size.Small
                            variant: ShadcnButton.Variant.Outline
                            onClicked: confirmDialog.close()
                        }
                        ShadcnButton {
                            text: qsTr("确认删除")
                            size: ShadcnButton.Size.Small
                            variant: ShadcnButton.Variant.Destructive
                            onClicked: confirmDialog.close()
                        }
                    }
                }
            }

            // ── 表单对话框（Card + Input + Button 组合）──
            SectionTitle {
                text: qsTr("Form（组合 Input）")
            }
            ShadcnButton {
                text: qsTr("新建项目")
                onClicked: formDialog.open()
            }
            ShadcnDialog {
                id: formDialog
                ShadcnDialogContent {
                    ShadcnDialogHeader {
                        ShadcnDialogTitle {
                            text: qsTr("新建项目")
                        }
                        ShadcnDialogDescription {
                            text: qsTr("为你的项目起个名字。")
                        }
                    }
                    Column {
                        width: parent.width
                        spacing: theme.spacingSm
                        Text {
                            text: qsTr("项目名称")
                            color: theme.popoverForeground
                            font.pixelSize: 13
                        }
                        ShadcnInput {
                            width: parent.width
                            placeholderText: qsTr("my-awesome-project")
                        }
                    }
                    footer: ShadcnDialogFooter {
                        ShadcnButton {
                            text: qsTr("取消")
                            size: ShadcnButton.Size.Small
                            variant: ShadcnButton.Variant.Outline
                            onClicked: formDialog.close()
                        }
                        ShadcnButton {
                            text: qsTr("创建")
                            size: ShadcnButton.Size.Small
                            onClicked: formDialog.close()
                        }
                    }
                }
            }

            // ── 可滚动对话框（长内容：body 滚动、footer 固定）──
            SectionTitle {
                text: qsTr("Scrollable（长内容）")
            }
            ShadcnButton {
                text: qsTr("打开长内容对话框")
                onClicked: scrollDialog.open()
            }
            ShadcnDialog {
                id: scrollDialog
                ShadcnDialogContent {
                    // 固定高度演示滚动：固高 420，且不超过页面(窗口)高 - 边距，避免弹窗超出页面
                    maxHeight: {
                        var wh = (Window.window && Window.window.height > 0) ? Window.window.height : 800
                        return Math.max(160, Math.min(420, wh - 48))
                    }
                    ShadcnDialogHeader {
                        ShadcnDialogTitle {
                            text: qsTr("条款与条件")
                        }
                        ShadcnDialogDescription {
                            text: qsTr("内容过长时 body 滚动，底部 footer 固定不动。")
                        }
                    }
                    Column {
                        width: parent.width
                        spacing: theme.spacingSm
                        Repeater {
                            model: 20
                            Text {
                                width: parent.width
                                wrapMode: Text.WordWrap
                                text: qsTr("第 %1 条：示例条款文本，用于演示对话框内容过长时 body 滚动、footer 固定的效果。").arg(index + 1)
                                color: theme.popoverForeground
                                font.pixelSize: 13
                            }
                        }
                    }
                    footer: ShadcnDialogFooter {
                        ShadcnButton {
                            text: qsTr("同意")
                            size: ShadcnButton.Size.Small
                            onClicked: scrollDialog.close()
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
                text: "ShadcnDialog {\n    id: dialog\n    ShadcnDialogContent {\n        ShadcnDialogHeader {\n            ShadcnDialogTitle { text: \"...\" }\n            ShadcnDialogDescription { text: \"...\" }\n        }\n        footer: ShadcnDialogFooter { ShadcnButton { ... } }\n    }\n}\n// open: dialog.open()"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

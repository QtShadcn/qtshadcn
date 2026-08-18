import QtQuick
import QtQuick.Layouts
import QtShadcn

// Dialog 页：基础对话框、确认对话框、自定义内容
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnDialog")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("基于 QQC.Dialog，max-w-md(448px) + bg-popover + 阴影 + 居中 + fade/zoom 100ms 动画。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // ── 基础对话框 ──
    SectionTitle { text: qsTr("Basic") }
    ShadcnButton { text: qsTr("打开对话框"); onClicked: basicDialog.open() }
    ShadcnDialog {
        id: basicDialog
        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle { text: qsTr("欢迎使用 QtShadcn") }
                ShadcnDialogDescription { text: qsTr("这是一个基于 shadcn/ui 规范的对话框组件。") }
            }
            ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("关闭")
                    variant: ShadcnButton.Variant.Outline
                    onClicked: basicDialog.close()
                }
                ShadcnButton { text: qsTr("好的"); onClicked: basicDialog.close() }
            }
        }
    }

    // ── 确认对话框（删除等危险操作）──
    SectionTitle { text: qsTr("Confirm（危险操作）") }
    ShadcnButton {
        text: qsTr("删除账户")
        variant: ShadcnButton.Variant.Destructive
        onClicked: confirmDialog.open()
    }
    ShadcnDialog {
        id: confirmDialog
        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle { text: qsTr("确认删除账户？") }
                ShadcnDialogDescription { text: qsTr("此操作不可撤销。账户所有数据将被永久删除。") }
            }
            ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("取消")
                    variant: ShadcnButton.Variant.Outline
                    onClicked: confirmDialog.close()
                }
                ShadcnButton {
                    text: qsTr("确认删除")
                    variant: ShadcnButton.Variant.Destructive
                    onClicked: confirmDialog.close()
                }
            }
        }
    }

    // ── 表单对话框（Card + Input + Button 组合）──
    SectionTitle { text: qsTr("Form（组合 Input）") }
    ShadcnButton {
        text: qsTr("新建项目")
        onClicked: formDialog.open()
    }
    ShadcnDialog {
        id: formDialog
        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle { text: qsTr("新建项目") }
                ShadcnDialogDescription { text: qsTr("为你的项目起个名字。") }
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
            ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("取消")
                    variant: ShadcnButton.Variant.Outline
                    onClicked: formDialog.close()
                }
                ShadcnButton {
                    text: qsTr("创建")
                    onClicked: formDialog.close()
                }
            }
        }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnDialog {\n    id: dialog\n    ShadcnDialogContent {\n        ShadcnDialogHeader {\n            ShadcnDialogTitle { text: \"...\" }\n            ShadcnDialogDescription { text: \"...\" }\n        }\n        ShadcnDialogFooter { ShadcnButton { ... } }\n    }\n}\n// open: dialog.open()"
    }
}

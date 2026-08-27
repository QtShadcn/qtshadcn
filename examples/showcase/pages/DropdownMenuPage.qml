import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    QtShadcnTheme { id: theme }

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
            text: qsTr("ShadcnDropdownMenu")
        }
        Text {
            color: theme.mutedForeground
            font.pixelSize: 13
            text: qsTr("基于 Popup 的下拉菜单，支持 Trigger + Content + Item 组合，hover accent、Destructive 变体。点击外部或按 ESC 关闭。")
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }

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

            SectionTitle { text: qsTr("基础用法") }
            Row {
                spacing: 16
                ShadcnDropdownMenu {
                    ShadcnDropdownMenuTrigger { text: qsTr("打开菜单") }
                    ShadcnDropdownMenuContent {
                        ShadcnDropdownMenuItem { text: qsTr("个人中心"); iconName: "user" }
                        ShadcnDropdownMenuItem { text: qsTr("设置"); iconName: "settings" }
                        ShadcnDropdownMenuItem { text: qsTr("退出登录"); iconName: "log-out"; variant: ShadcnDropdownMenuItem.Variant.Destructive }
                    }
                }
                ShadcnDropdownMenu {
                    ShadcnDropdownMenuTrigger { text: qsTr("更多操作"); variant: ShadcnButton.Variant.Outline }
                    ShadcnDropdownMenuContent {
                        ShadcnDropdownMenuItem { text: qsTr("编辑"); iconName: "pencil" }
                        ShadcnDropdownMenuItem { text: qsTr("复制"); iconName: "copy" }
                        ShadcnDropdownMenuItem { text: qsTr("删除"); iconName: "trash-2"; variant: ShadcnDropdownMenuItem.Variant.Destructive }
                    }
                }
            }

            SectionTitle { text: qsTr("带图标 + 禁用") }
            ShadcnDropdownMenu {
                ShadcnDropdownMenuTrigger { text: qsTr("文件操作"); iconName: "file" }
                ShadcnDropdownMenuContent {
                    ShadcnDropdownMenuItem { text: qsTr("新建"); iconName: "plus" }
                    ShadcnDropdownMenuItem { text: qsTr("打开"); iconName: "folder-open" }
                    ShadcnDropdownMenuItem { text: qsTr("保存"); iconName: "save" }
                    ShadcnDropdownMenuItem { text: qsTr("另存为..."); iconName: "file-plus"; enabled: false }
                }
            }

            SectionTitle { text: qsTr("分组 + 标签 + 分隔线") }
            ShadcnDropdownMenu {
                ShadcnDropdownMenuTrigger { text: qsTr("账户菜单"); variant: ShadcnButton.Variant.Outline }
                ShadcnDropdownMenuContent {
                    ShadcnDropdownMenuGroup {
                        ShadcnDropdownMenuLabel { text: qsTr("我的账号") }
                        ShadcnDropdownMenuItem { text: qsTr("个人中心"); iconName: "user" }
                        ShadcnDropdownMenuItem { text: qsTr("设置"); iconName: "settings" }
                    }
                    ShadcnDropdownMenuSeparator {}
                    ShadcnDropdownMenuGroup {
                        ShadcnDropdownMenuItem { text: qsTr("团队"); iconName: "users" }
                        ShadcnDropdownMenuItem { text: qsTr("订阅"); iconName: "credit-card" }
                    }
                    ShadcnDropdownMenuSeparator {}
                    ShadcnDropdownMenuItem { text: qsTr("退出登录"); iconName: "log-out"; variant: ShadcnDropdownMenuItem.Variant.Destructive }
                }
            }

            SectionTitle { text: qsTr("快捷键提示") }
            ShadcnDropdownMenu {
                ShadcnDropdownMenuTrigger { text: qsTr("编辑菜单"); variant: ShadcnButton.Variant.Outline }
                ShadcnDropdownMenuContent {
                    ShadcnDropdownMenuItem { text: qsTr("撤销"); shortcut: "⌘Z" }
                    ShadcnDropdownMenuItem { text: qsTr("重做"); shortcut: "⌘⇧Z" }
                    ShadcnDropdownMenuSeparator {}
                    ShadcnDropdownMenuItem { text: qsTr("剪切"); shortcut: "⌘X" }
                    ShadcnDropdownMenuItem { text: qsTr("复制"); shortcut: "⌘C" }
                    ShadcnDropdownMenuItem { text: qsTr("粘贴"); shortcut: "⌘V" }
                }
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

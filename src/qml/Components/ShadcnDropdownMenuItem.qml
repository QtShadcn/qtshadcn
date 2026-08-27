// src/qml/Components/ShadcnDropdownMenuItem.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格菜单项（M6）
// 规范：rounded-sm px-2 py-1.5 text-sm gap-2, hover bg-accent text-accent-foreground
//       disabled: opacity-50 + pointer-events-none
// 用法:
//   ShadcnDropdownMenuItem { text: "编辑"; iconName: "pencil" }
//   ShadcnDropdownMenuItem { text: "删除"; variant: ShadcnDropdownMenuItem.Variant.Destructive }
//   ShadcnDropdownMenuItem { text: "复制"; ShadcnDropdownMenuShortcut { text: "⌘C" } }
Item {
    id: root

    enum Variant { Default, Destructive }

    property string text: ""
    property string iconName: ""
    property int variant: ShadcnDropdownMenuItem.Variant.Default
    property string shortcut: ""

    // 快捷键子组件容器
    default property alias contentChildren: _contentRow.data

    signal clicked()

    implicitWidth: 200   // min-w-[8rem]=128, 留余量
    height: 32          // py-1.5(6px)×2 + text-sm(14px) ≈ 26, 取 32 留呼吸
    opacity: root.enabled ? 1.0 : 0.5

    QtShadcnTheme { id: theme }

    // 背景：hover → accent
    Rectangle {
        anchors.fill: parent
        radius: 4   // radius-sm
        color: mouseArea.containsMouse && root.enabled ? theme.accent : "transparent"
    }

    RowLayout {
        id: _contentRow
        anchors.fill: parent
        anchors.leftMargin: 8    // px-2
        anchors.rightMargin: 8
        anchors.topMargin: 6     // py-1.5
        anchors.bottomMargin: 6
        spacing: 8               // gap-2

        ShadcnIcon {
            visible: root.iconName !== ""
            name: root.iconName
            size: 16
            color: root.variant === ShadcnDropdownMenuItem.Variant.Destructive
                   ? theme.destructive : theme.mutedForeground
        }
        Text {
            Layout.fillWidth: true
            text: root.text
            color: !root.enabled ? theme.mutedForeground
                  : root.variant === ShadcnDropdownMenuItem.Variant.Destructive ? theme.destructive
                  : mouseArea.containsMouse ? theme.accentForeground : theme.foreground
            font.pixelSize: 14   // text-sm
            elide: Text.ElideRight
        }
        // 内置 shortcut 属性兜底（用户也可通过子组件传入）
        Text {
            visible: root.shortcut !== ""
            text: root.shortcut
            color: theme.mutedForeground
            font.pixelSize: 12
            font.letterSpacing: 1
            Layout.alignment: Qt.AlignRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        onClicked: root.clicked()
    }
}

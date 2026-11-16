// src/qml/Components/ShadcnDropdownMenuShortcut.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格快捷键提示（M6）
// 规范：ml-auto text-xs tracking-widest text-muted-foreground
//
// 容器必须是 Layout（如 ShadcnDropdownMenuItem 的 _contentRow 是 RowLayout）。
// 放在 RowLayout 里时 anchors 是非法的，所以这里只用 Layout.*，
// 不要再加 anchors.verticalCenter（LAY-1：anchors 与 Layout 同时写会冲突）。
//
// 用法:
//   ShadcnDropdownMenuItem {
//       text: "复制"
//       ShadcnDropdownMenuShortcut { text: "⌘C" }
//   }
Text {
    id: root

    color: theme.mutedForeground
    font.pixelSize: 12
    font.letterSpacing: 1   // tracking-widest

    // ml-auto：靠右，剩余宽度留给菜单项文本
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

    QtShadcnTheme { id: theme }
}

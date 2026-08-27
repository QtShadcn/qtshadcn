// src/qml/Components/ShadcnDropdownMenuShortcut.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格快捷键提示（M6）
// 规范：ml-auto text-xs tracking-widest text-muted-foreground
// 用法:
//   ShadcnDropdownMenuItem { text: "复制" }
//       ShadcnDropdownMenuShortcut { text: "⌘C" }
//   }
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 12
    font.letterSpacing: 1   // tracking-widest
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignRight
    anchors.verticalCenter: parent.verticalCenter
}

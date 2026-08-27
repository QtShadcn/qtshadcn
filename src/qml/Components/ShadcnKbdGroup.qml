// src/qml/Components/ShadcnKbdGroup.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格键盘快捷键组合容器（M6）
// 规范：inline-flex items-center gap-1
// 用法:
//   ShadcnKbdGroup {
//       ShadcnKbd { text: "Ctrl" }
//       ShadcnKbd { text: "B" }
//   }
Row {
    id: root
    spacing: 4
    layoutDirection: Qt.LeftToRight
}

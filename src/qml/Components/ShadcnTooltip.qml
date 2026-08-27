// src/qml/Components/ShadcnTooltip.qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// shadcn/ui 风格悬停提示（M6）
// 用法:
//   ShadcnButton { text: "悬停我"
//       ShadcnTooltip.text: "这是提示"
//   }
// 或:
//   ShadcnTooltip { text: "提示内容"; visible: true }
QQC.ToolTip {
    id: root

    QtShadcnTheme { id: theme }

    implicitWidth: Math.min(contentItem.implicitWidth + 16, 200)
    implicitHeight: contentItem.implicitHeight + 8

    contentItem: Text {
        text: root.text
        color: theme.popoverForeground
        font.pixelSize: 12
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        color: theme.popover
        radius: theme.radius
        border.width: 1
        border.color: theme.border
    }
}

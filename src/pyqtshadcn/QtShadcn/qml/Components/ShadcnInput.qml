import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格文本输入
// 基于 QQC.TextField（Basic style），替换背景 + 聚焦环，对齐 shadcn input 规范：
// - h-9(36px) + rounded-md(6px) + bg-input/50 + 聚焦 border-ring + 3px ring-ring/30
//
// 用法:
//   ShadcnInput { placeholderText: "请输入"; onAccepted: ... }
TextField {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    font.pixelSize: 14
    selectByMouse: true

    // 内容边距：shadcn px-3 py-1
    leftPadding: 12
    rightPadding: 12
    topPadding: 4
    bottomPadding: 4

    // 高度锁 36px（h-9），与 QQC TextField 默认 content 高度无关
    implicitHeight: 36
    // 输入框默认宽度：shadcn 无默认宽，w-full 由外部决定
    implicitWidth: 240

    background: Rectangle {
        radius: 6   // shadcn button/控件圆角
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.5)   // bg-input/50
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"

        Behavior on border.color { ColorAnimation { duration: 120 } }

        // 键盘焦点环：activeFocus 时 3px 外环（shadcn focus-visible:ring-3 ring-ring/30）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 9
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // 禁用态：opacity 50%（shadcn disabled:opacity-50）
    opacity: !enabled ? 0.5 : 1
}

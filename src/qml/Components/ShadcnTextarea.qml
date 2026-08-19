import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格多行文本输入
// 基于 QQC.TextArea（Basic style），对齐 shadcn textarea 规范：
// - min-h-16(64) + px-3 py-3 + rounded-md(6px) + bg-input/50 + 聚焦 border-ring + 3px ring
// （luma rounded-2xl 大圆角不跟，沿用 M2 控件 6px 圆角决策）
//
// 用法:
//   ShadcnTextarea { placeholderText: "请输入"; onAccepted: ... }
TextArea {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    font.pixelSize: 14
    selectByMouse: true
    wrapMode: TextEdit.Wrap

    // 内容边距：shadcn px-3 py-3
    leftPadding: 12
    rightPadding: 12
    topPadding: 12
    bottomPadding: 12

    // 最小高度 64（min-h-16）；行数多时随内容增高
    implicitHeight: 64
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

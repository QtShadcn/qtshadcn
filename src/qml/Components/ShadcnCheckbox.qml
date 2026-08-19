import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格复选框
// 基于 QQC.CheckBox（Basic style），自定义 indicator，对齐 shadcn checkbox 规范：
// - 16px + rounded 5px + border + bg-input/90；checked → bg-primary + primaryForeground
//   check 图标(14px)；聚焦 border-ring + 3px ring；disabled opacity 50%
//
// 用法:
//   ShadcnCheckbox { text: "同意条款" }
//   ShadcnCheckbox { checked: true; onToggled: ... }
CheckBox {
    id: root

    QtShadcnTheme { id: theme }

    // 文本（indicator 右侧，QQC 自动布局）

    // ── 方框（16px，rounded 5px）──
    indicator: Rectangle {
        id: box
        // 关键：override indicator 后必须自带定位（QQC 模板的 x/y 在默认组件内部，
        // 不自动应用；否则方框停在 (0,0)，与文本错位不对齐）
        x: root.text ? (root.mirrored ? root.width - width - root.rightPadding : root.leftPadding)
                     : root.leftPadding + (root.availableWidth - width) / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 5   // shadcn rounded-[5px]

        color: root.checked
               ? theme.primary
               : Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.9)
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"

        // check 图标（shadcn CheckIcon size-3.5=14px，text-current → primaryForeground）
        ShadcnIcon {
            anchors.centerIn: parent
            visible: root.checked
            name: "check"
            size: 14
            color: theme.primaryForeground
        }

        // 键盘焦点环（activeFocus，3px ring-ring/30）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 8
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

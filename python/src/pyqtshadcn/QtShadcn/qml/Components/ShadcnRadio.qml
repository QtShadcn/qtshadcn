import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格单选按钮（radio item）
// 基于 QQC.RadioButton（Basic style），自定义 indicator，对齐 shadcn radio-group-item 规范：
// - 16px 正圆 + border + bg-input/90；checked → bg-primary + 内圆点 primaryForeground
//   （8px，dark 10px）；聚焦 border-ring + 3px ring
// - 文本 label 用 text 属性（RadioButton 自带 indicator + text 布局）
//
// 用法（配合 ShadcnRadioGroup 互斥）:
//   ShadcnRadioGroup {
//       ShadcnRadio { text: "默认"; checked: true }
//       ShadcnRadio { text: "自定义" }
//   }
RadioButton {
    id: root

    QtShadcnTheme { id: theme }

    // 文本 label 用 text 属性：QQC RadioButton 默认 contentItem 会在 indicator 右侧渲染

    // ── 圆点（16px 正圆）──
    indicator: Rectangle {
        id: dot
        // 关键：override indicator 后必须自带定位（QQC 模板的 x/y 在默认组件内部，
        // 不自动应用；否则圆点停在 (0,0)，与文本错位不对齐）
        x: root.text ? (root.mirrored ? root.width - width - root.rightPadding : root.leftPadding)
                     : root.leftPadding + (root.availableWidth - width) / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8   // rounded-full

        color: root.checked
               ? theme.primary
               : Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.9)
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"

        // 内圆点（checked）：primaryForeground，8px（dark 10px 用 token 区分可后续加）
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            visible: root.checked
            color: theme.primaryForeground
        }

        // 键盘焦点环（activeFocus，3px ring-ring/30）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 11
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

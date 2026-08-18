import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtShadcn

// shadcn/ui 风格对话框
// 基于 QQC.Dialog（Basic style），modal=true；替换 background + Overlay
// 对齐 shadcn v4：max-w-md(448px) + bg-popover + 圆角 + 阴影 + 居中 + fade/zoom 动画
//
// 用法:
//   ShadcnDialog {
//       id: dialog
//       ShadcnDialogContent {
//           ShadcnDialogHeader { ShadcnDialogTitle { ... }; ShadcnDialogDescription { ... } }
//           Text { ... }
//           ShadcnDialogFooter { ShadcnButton { ... } }
//       }
//   }
//   ShadcnButton { text: "Open"; onClicked: dialog.open() }
Dialog {
    id: root

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // 隐藏 QQC 默认 header（让用户用 ShadcnDialogHeader）
    header: Item { visible: false }
    // 不使用 QQC 标准按钮（用 ShadcnDialogFooter + ShadcnButton）
    standardButtons: Dialog.NoButton

    // 居中 + 宽度约束：max-w-md(448px) / 小屏 (parent.width - 32)
    width: Math.min(implicitWidth, 448)
    // 居中由 Popup 默认处理（anchors.centerIn: Overlay.overlay）

    QtShadcnTheme { id: theme }

    // 背景：bg-popover + 圆角 + 1px ring + shadow-xl
    background: Rectangle {
        color: theme.popover
        radius: theme.radius
        border.width: 1
        border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b,
                              theme.mode === "dark" ? 0.10 : 0.05)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.5
            shadowVerticalOffset: 8
            shadowColor: Qt.rgba(0, 0, 0, 0.18)
        }
    }

    // 模态遮罩：QQC.Dialog 默认 modal=true 会自动加 dim 遮罩（Basic 样式下约黑 50%）；
    // 自定义遮罩需动态管理 Overlay.overlay children（QML 6 attached property 只读），
    // 当前接受 QQC 默认 50% 透明度，比 shadcn 的 30% 略深但视觉差异不大

    // 动画：fade-in + zoom-in-95（duration 100ms）
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 100 }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 100; easing.type: Easing.OutCubic }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 100; easing.type: Easing.InCubic }
        }
    }
}

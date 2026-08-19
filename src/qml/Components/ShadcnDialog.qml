import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtShadcn

// shadcn/ui 风格对话框
// 基于 QQC.Dialog（Basic style），modal=true；替换 background + Overlay
// 对齐 shadcn Base UI 默认产物：max-w-sm(384px) + bg-popover + 圆角 14 + 阴影 + 居中 + fade/zoom 动画
// 内置 ghost 关闭钮（showCloseButton 控制，默认 true）
//
// 用法:
//   ShadcnDialog {
//       id: dialog
//       ShadcnDialogContent {
//           ShadcnDialogHeader { ShadcnDialogTitle { ... }; ShadcnDialogDescription { ... } }
//           Text { ... }
//           footer: ShadcnDialogFooter { ShadcnButton { ... } }
//       }
//   }
//   ShadcnButton { text: "Open"; onClicked: dialog.open() }
Dialog {
    id: root

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // 是否显示 ghost 关闭钮（对齐 shadcn showCloseButton，默认 true）
    property bool showCloseButton: true

    // 隐藏 QQC 默认 header（让用户用 ShadcnDialogHeader）
    header: Item { visible: false }
    // 不使用 QQC 标准按钮（用 ShadcnDialogFooter + ShadcnButton）
    standardButtons: Dialog.NoButton

    // 关键：T.Dialog 默认 padding=12 会把 contentItem 向内缩 12px，
    // 导致 footer muted 条四周出现 12px 空隙（看起来像「外面有 padding、很丑」）。
    // 设 0 让内容铺满背景，footer/body 的留白由组件自己用 _pad 控制。
    padding: 0

    // 居中 + 宽度约束：max-w-sm(384px)，小屏取 (parent.width - 32)
    // 注意：不能依赖 implicitWidth —— ShadcnDialogContent.width 绑定 parent.width，
    // 会形成「content 等 dialog 宽 / dialog 宽等 content 隐式宽」的循环，导致宽度塌缩成 ~24px
    width: Math.min((parent && parent.width ? parent.width : 100000) - 32, 384)
    // 相对整个窗口居中（而非声明它的 page）——showcase 有左侧导航栏，
    // 默认 Popup 居中在 page（右侧内容区）会让对话框相对全窗口偏右
    anchors.centerIn: Overlay.overlay

    QtShadcnTheme { id: theme }

    // 背景：bg-popover + 圆角(14, rounded-xl) + 1px ring + shadow-xl
    background: Rectangle {
        color: theme.popover
        radius: 14
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

    // 关闭钮（ghost）由 ShadcnDialogContent 渲染（保持 contentItem 单子节点，
    // 否则 QQC Popup 无法从 content.implicitHeight 推导 dialog 高度）。
    // 这里把 showCloseButton 透传下去，并把 content.closeClicked 接到 close()。
    Component.onCompleted: {
        for (var i = 0; i < contentItem.children.length; ++i) {
            var child = contentItem.children[i]
            if (typeof child.closeClicked === "function") {
                child.closeClicked.connect(root.close)
                child.showCloseButton = Qt.binding(function() { return root.showCloseButton })
            }
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

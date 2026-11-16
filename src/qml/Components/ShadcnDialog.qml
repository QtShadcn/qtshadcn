pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格对话框
// 基于 QQC.Dialog（Basic style），modal=true；替换 background + Overlay
// 对齐 shadcn v4 base 规格（.cn-dialog-*）：
//   content: bg-popover + rounded-xl(12) + ring-1 ring-foreground/10 + p-4 + gap-4
//            + max-w-[calc(100%-2rem)] sm:max-w-sm(384) + text-sm
//   overlay: bg-black/10（+ backdrop-blur-xs，Qt 无 backdrop-filter，不实现）
//   动画:    fade + zoom-95，duration-100
// 注意：新版已用 1px ring 取代旧的 shadow-xl，本组件因此不再使用 layer/MultiEffect
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

    // 遮罩不透明度（对齐 .cn-dialog-overlay 的 bg-black/10）。
    // 不能叫 dim：QQuickPopup 已有 FINAL 属性 dim（Imagine 样式用），覆盖会编译失败。
    // Qt 侧没有 backdrop-filter，做不了 shadcn 的 backdrop-blur-xs；
    // 若某些配色下 10% 太浅，调用方可自行调高（如 overlayOpacity: 0.3）。
    property real overlayOpacity: 0.10

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

    // 背景：bg-popover + rounded-xl(12) + ring-1 ring-foreground/10
    // 新版 shadcn 用 1px ring 取代旧的 shadow-xl，因此这里不再需要 layer + MultiEffect
    // （顺带消掉了「离屏渲染下 MultiEffect 让内容整块空白」的老问题）
    background: Rectangle {
        color: theme.popover
        radius: 12
        border.width: 1
        // ring-foreground/10：前景色 10% 透明，light/dark 同一档（旧实现 light 用了 5%）
        border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.10)
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

    // 模态遮罩：覆盖 Qt Basic 样式默认的 50% 黑，对齐 shadcn 的 bg-black/10。
    // Overlay.modal 是 Popup 的 attached property，可赋一个 Item 作为遮罩
    // （旧注释曾说「QML 6 attached property 只读」，那是错的：只读的是 Overlay.overlay）。
    // 注意：attached property 的对象字面量是独立组件作用域，里面读 root.overlayOpacity
    // 属于外层 id 访问，靠文件头的 pragma ComponentBehavior: Bound 才不报 UnqualifiedAccess。
    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, root.overlayOpacity)
    }

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

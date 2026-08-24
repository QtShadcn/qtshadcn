import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Window
import QtShadcn

// shadcn/ui Base UI 风格 Dialog 内容容器
// 对齐默认产物 DOM:
//   grid gap-4 rounded-xl bg-popover p-4 text-sm ... 动画 fade/zoom-95 100ms
//   footer: -mx-4 -mb-4 rounded-b-xl border-t bg-muted/50 p-4（固定底部、满宽 muted 条）
// 布局: 可滚动 body（顶部 padding）+ 固定在底部的 footer 条
//        —— body 超高时滚动，footer 不动（sticky）；内容短时整框随内容高度
Item {
    id: root

    // 用户内容（header + body）进入可滚动区（默认属性）
    default property alias content: bodyColumn.data
    // 可选 footer（ShadcnDialogFooter），固定底部、满宽 muted 条
    property alias footer: footerSlot.data
    // 关闭钮开关（由 ShadcnDialog 透传），默认 true
    property bool showCloseButton: true
    // 关闭钮被点击时发出，由 ShadcnDialog 接去 close()
    signal closeClicked()
    // 内容区高度上限（超过则 body 滚动、footer 固定）；可自定义。
    // 以「所在窗口(页面)高度」为基准（0.85×窗口高），而非整块屏幕，
    // 避免高分屏/多屏下 Screen.height 过大导致弹窗超出页面；窗口未就绪时回退 Screen。
    // 例：ShadcnDialogContent { maxHeight: 360 ; ... } 让长文本弹窗固定更矮
    property int maxHeight: ((root.Window.window && root.Window.window.height > 0)
        ? root.Window.window.height : (Screen.height > 0 ? Screen.height : 600)) * 0.85

    QtShadcnTheme { id: theme }

    readonly property int _pad: 16        // p-4
    readonly property int _gap: 16        // gap-4
    readonly property int _radius: 14     // rounded-xl（Base UI 默认；overlay 比 inline 容器略大）

    // 宽度由 Dialog 固定（384，见 ShadcnDialog），content 直接撑满 parent.width。
    // 注意：不能在此绑定 implicitWidth（会读 bodyColumn.implicitWidth → ScrollView.implicitWidth
    // → 又读回 bodyColumn.implicitWidth，造成 ScrollView 的 implicitWidth binding loop）。
    width: parent ? parent.width : 320

    // 关键：bodyColumn.height 固定为自身 implicitHeight，使「自然内容高度」独立于滚动视口高度，
    // 避免 ScrollView 把 bodyColumn 压成视口高 → childrenRect 失真 → implicitHeight 塌缩的循环
    readonly property int _footerH: footerSlot.children.length > 0
        ? footerSlot.childrenRect.height + _pad * 2 : 0
    implicitHeight: Math.min(bodyColumn.implicitHeight + _pad * 2 + _footerH, maxHeight)

    // ── 可滚动 body ──────────────────────────────
    ScrollView {
        id: bodyScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: footerBar.top
        anchors.bottomMargin: _footerH > 0 ? 0 : _pad
        // 注意：不要写 contentWidth: width —— 那会让内容宽=整个 ScrollView 宽(含 padding 区)，
        // 比 body 实际可用宽多出一截 → ScrollView 误判需要水平滚动条 → 滚动条又挤占可用宽 →
        // 反复横跳，产生 implicitWidth binding loop（并表现为「左右乱跳/不支持滑动」）。
        // 去掉后由 bodyColumn.width(=availableWidth) 决定内容宽，无水平溢出、无水平滚动条。
        contentHeight: bodyColumn.implicitHeight
        clip: true
        topPadding: _pad
        leftPadding: _pad
        rightPadding: _pad
        bottomPadding: _footerH > 0 ? _gap : _pad
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        background: Item {}

        Column {
            id: bodyColumn
            spacing: _gap
            width: bodyScroll.availableWidth
            height: implicitHeight   // 固定为自然高度，供 ScrollView 滚动 + 供外层 implicitHeight 计算
        }
    }

    // ── footer 固定条（满宽 muted）──────────────────────────
    // 内缩 1px（= 对话框 background 的 border.width），使灰色条的圆角(radius=_radius)
    // 与对话框背景「内边缘」圆角对齐，否则 footer 圆角比内边缘大 1px → 底部两角露出方角
    Item {
        id: footerBar
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        height: _footerH
        visible: _footerH > 0
        clip: true

        // bg-muted/50（半透明 muted 底）——仅底部圆角（与对话框 rounded-b-xl 对齐），
        // 顶边直角：向上延展 _radius 再靠 footerBar.clip 把顶角裁掉，避免顶部出现难看圆角缺口
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.topMargin: -_radius
            color: theme.muted
            opacity: 0.5
            radius: _radius
        }
        // border-t（顶部分隔线）
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: theme.border
        }
        // footer 内容（带 padding，底部留白给 rounded-b 圆角）
        Item {
            id: footerSlot
            x: _pad
            y: _pad
            width: parent.width - _pad * 2
            height: footerSlot.childrenRect.height
            clip: false
        }
    }

    // ── 关闭钮（ghost）：absolute top-2/right-2，size-7(28)，hover bg-muted ──
    Item {
        id: closeButton
        visible: root.showCloseButton
        width: 28
        height: 28
        x: root.width - 28 - 8
        y: 8
        z: 10
        property bool _hovered: false
        Rectangle {
            anchors.fill: parent
            radius: Math.min(theme.radius, 12)
            color: closeButton._hovered ? theme.muted : "transparent"
        }
        Text {
            anchors.centerIn: parent
            text: "✕"
            color: theme.mutedForeground
            font.pixelSize: 14
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: closeButton._hovered = true
            onExited: closeButton._hovered = false
            onClicked: root.closeClicked()
        }
    }
}

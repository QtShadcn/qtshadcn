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
    readonly property int _radius: 12     // rounded-xl（Tailwind v4 = 0.75rem），与 ShadcnDialog 背景一致

    // 宽度由 Dialog 固定（384，见 ShadcnDialog），content 直接撑满 parent.width。
    // 注意：不能在此绑定 implicitWidth（会读 bodyColumn.implicitWidth → 滚动视口的
    // implicitWidth → 又读回 bodyColumn.implicitWidth，造成 implicitWidth binding loop）。
    width: parent ? parent.width : 320

    // 关键：bodyColumn.height 固定为自身 implicitHeight，使「自然内容高度」独立于滚动视口高度，
    // 避免滚动容器把 bodyColumn 压成视口高 → childrenRect / implicitHeight 塌缩的循环
    readonly property int _footerH: footerSlot.children.length > 0
        ? footerSlot.childrenRect.height + _pad * 2 : 0
    // footerBar 自身向下留了 1px（bottomMargin，见下方圆角对齐说明），这段空间也是
    // 布局真实消耗掉的。不计进来会让「自然高度」比实际需要少 1px → 视口比 contentHeight
    // 矮 1px → 内容明明放得下却冒出滚动条（8px 竖条贴着右边框）。
    readonly property int _footerBlock: _footerH > 0 ? _footerH + 1 : 0
    implicitHeight: Math.min(bodyColumn.implicitHeight + _pad * 2 + _footerBlock, maxHeight)

    // ── 可滚动 body ──────────────────────────────
    //
    // 基座是 Flickable 而不是 ScrollView：ScrollView **不会拉伸它 attached 的
    // ScrollBar**（实测 bar.height 停在 implicitHeight=10px，于是 thumb 高度
    // = size×10，内容再长也只有几像素，视觉上是个小圆点）。连 Qt 自带的
    // Basic ScrollBar 也一样。Flickable 下 bar 随视口高拉伸，thumb 才按比例。
    //
    // 代价是 padding 要自己算（ScrollView 有 topPadding/leftPadding），
    // 下面用内容偏移 + contentHeight 补足，视觉效果与原版一致。
    Flickable {
        id: bodyScroll
        objectName: "bodyScroll"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        // 无 footer 时直接贴底（footerBar 那时高度为 0，但仍有 1px bottomMargin，
        // 会白占视口 1px → contentHeight 比视口多 1px → 又冒出滚动条）
        anchors.bottom: root._footerH > 0 ? footerBar.top : parent.bottom
        // 不留 bottomMargin：底部留白由 contentHeight 里的 _padBottom 提供。
        // 早先这里在「无 footer」时留了 _pad，结果是视口比内容矮 16px →
        // 内容明明放得下也永远能滚一下（滚轮能推动文字，很怪）。
        anchors.bottomMargin: 0

        readonly property int _padTop: root._pad
        readonly property int _padBottom: root._footerH > 0 ? root._gap : root._pad

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // 内容宽 = 视口宽（bodyColumn 自己再内缩 padding），不会产生横向溢出。
        // 注意这里不能像 ScrollView 那样用 availableWidth：Flickable 没有这个属性，
        // 而滚动条是 overlay、不挤占宽度，所以 contentWidth: width 是安全的
        // （这正是原来那段「不要写 contentWidth: width」警告的适用前提不同之处）。
        contentWidth: width
        contentHeight: _padTop + bodyColumn.implicitHeight + _padBottom

        ScrollBar.vertical: ShadcnScrollBar {
            policy: ScrollBar.AsNeeded
            parent: bodyScroll
        }

        Column {
            id: bodyColumn
            x: root._pad
            y: bodyScroll._padTop
            width: bodyScroll.width - root._pad * 2
            spacing: root._gap
            height: implicitHeight   // 固定为自然高度，供滚动 + 供外层 implicitHeight 计算
        }
    }

    // ── footer 固定条（满宽 muted）──────────────────────────
    // 内缩 1px（= 对话框 background 的 border.width），使灰色条的圆角(radius=_radius)
    // 与对话框背景「内边缘」圆角对齐，否则 footer 圆角比内边缘大 1px → 底部两角露出方角
    Item {
        id: footerBar
        objectName: "footerBar"
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        height: root._footerH
        visible: root._footerH > 0
        clip: true

        // bg-muted/50（半透明 muted 底）——仅底部圆角（与对话框 rounded-b-xl 对齐），
        // 顶边直角：向上延展 _radius 再靠 footerBar.clip 把顶角裁掉，避免顶部出现难看圆角缺口
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.topMargin: -root._radius
            color: theme.muted
            opacity: 0.5
            radius: root._radius
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
            x: root._pad
            y: root._pad
            width: parent.width - root._pad * 2
            height: footerSlot.childrenRect.height
            clip: false
        }
    }

    // ── 关闭钮（ghost）：absolute top-2/right-2，size-7(28)，hover bg-muted ──
    Item {
        id: closeButton
        objectName: "closeButton"
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
        // 官方用 lucide XIcon（size-4 = 16px，currentColor 取 button 前景色）
        ShadcnIcon {
            anchors.centerIn: parent
            name: "x"
            size: 16
            color: theme.foreground
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

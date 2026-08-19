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

    QtShadcnTheme { id: theme }

    readonly property int _pad: 16        // p-4
    readonly property int _gap: 16        // gap-4
    readonly property int _radius: 14     // rounded-xl（Base UI 默认；overlay 比 inline 容器略大）

    // 宽度撑满 Dialog；implicit 宽度取 body / footer 中较宽者 + 左右 padding
    width: parent ? parent.width : implicitWidth
    implicitWidth: Math.max(
        bodyColumn.implicitWidth + _pad * 2,
        footerSlot.childrenRect.width + _pad * 2
    )

    // 高度上限：超出视口 85% 时 body 滚动、footer 固定（兜底 600 防 offscreen Screen=0）
    // 关键：bodyColumn.height 固定为自身 implicitHeight，使「自然内容高度」独立于滚动视口高度，
    // 避免 ScrollView 把 bodyColumn 压成视口高 → childrenRect 失真 → implicitHeight 塌缩的循环
    readonly property int _maxH: (Screen.height > 0 ? Screen.height : 600) * 0.85
    readonly property int _footerH: footerSlot.children.length > 0
        ? footerSlot.childrenRect.height + _pad * 2 : 0
    implicitHeight: Math.min(bodyColumn.implicitHeight + _pad * 2 + _footerH, _maxH)

    // ── 可滚动 body ──────────────────────────────
    ScrollView {
        id: bodyScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: footerBar.top
        anchors.bottomMargin: _footerH > 0 ? 0 : _pad
        contentWidth: width
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
    Item {
        id: footerBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: _footerH
        visible: _footerH > 0
        clip: true

        // bg-muted/50（半透明 muted 底）
        Rectangle {
            anchors.fill: parent
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

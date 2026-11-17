// src/qml/Components/ShadcnHoverCard.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格悬浮卡片（Hover Card，issue #5）
//
// 用法:
//   ShadcnHoverCard {
//       ShadcnHoverCardTrigger { text: "@用户名" }
//       ShadcnHoverCardContent {
//           Text { text: "个人简介…" }
//       }
//   }
//
// 与 Popover 的关系：官方 hover-card.json 与 popover.json 是**同一套 Portal +
// Positioner + Popup**，只差触发方式 —— Popover 是点击（受控），HoverCard 是悬停 +
// 延时。所以这里复用 ShadcnPopoverPopup（定位 / 动画 / 祖先链可见性 / setSurface
// 全在那里面）与 ShadcnPopoverContent（样式继承，见 ShadcnHoverCardContent），
// 本组件只做「悬停计时」这一件事。
//
// 延时语义取自 Base UI PreviewCard 默认值（官方 trigger 的 delay / closeDelay）：
//   delay      600ms  指针停在触发项上多久才打开（防「扫过一串链接」乱弹）
//   closeDelay 300ms  离开后多久才关 —— 给「从链接移进卡片」那段空白留缓冲，
//                      指针一进内容区（surfaceHovered）就取消关闭计时器
// 关闭途径：离开且 closeDelay 到、Esc、点击外部。Esc / 外点后本轮不再自动重开，
// 必须移开再移回来（否则鼠标还在触发项上会立刻弹回，形成关不掉的抖动）。
Item {
    id: root

    // ── 公开 API ──
    /// 强制显示（演示 / 截图等无鼠标场景；与 ShadcnTooltip.open 同语义）
    property bool open: false
    /// 打开延时 ms（Base UI PreviewCard delay 默认 600）
    property int delay: 600
    /// 关闭延时 ms（Base UI PreviewCard closeDelay 默认 300）
    property int closeDelay: 300

    /// 无障碍：减弱动画（调用方接线，与 ShadcnPopover.reducedMotion 同语义）
    property bool reducedMotion: false

    /// 悬停计时已到位（真正由 hover 驱动的显示状态）
    readonly property bool hovered: _hovered
    /// 指针当前在触发项或卡片内容区之上（计时器的输入信号）
    readonly property alias pointerInside: root._pointerInside
    /// 实际显示状态 = 强制 open 或悬停计时
    readonly property bool showing: open || _hovered
    /// 触发项（ShadcnHoverCardTrigger）
    readonly property alias trigger: root._triggerItem
    /// 内容面板（ShadcnHoverCardContent）
    readonly property alias content: root._contentItem
    /// 定位结果（resolvedSide / clamped / availableHeight / x / y）
    readonly property alias placement: _surface.placement
    /// 弹层本体
    readonly property alias popup: _surface.popup
    /// 弹层过渡实际时长 ms（durationInstant token 折算，reducedMotion 时为 0）
    readonly property alias transitionDurationMs: _surface.transitionDurationMs

    implicitWidth: _triggerItem ? _triggerItem.implicitWidth : 120
    implicitHeight: _triggerItem ? _triggerItem.implicitHeight : 36

    default property alias hoverCardChildren: root._children
    property list<QtObject> _children

    property ShadcnHoverCardTrigger _triggerItem: null
    property ShadcnHoverCardContent _contentItem: null

    QtShadcnTheme { id: theme }

    // ── 悬停状态 ──
    // 指针在「触发项 或 卡片内容区」任一之上。两者都可能是 null（尚未收集 /
    // 弹层未创建），三元兜底；属性绑定自带 notify，变化即触发下面的 handler。
    readonly property bool _pointerInside: (_triggerItem ? _triggerItem.hovered : false)
                                           || _surface.surfaceHovered
    on_PointerInsideChanged: _onPointer(_pointerInside)

    property bool _hovered: false
    // Esc / 点外后本轮抑制，直到指针离开过一次
    property bool _dismissed: false

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: {
            root._hovered = true
            root._dismissed = false
        }
    }
    Timer {
        id: closeTimer
        interval: root.closeDelay
        onTriggered: root._hovered = false
    }

    function _onPointer(inside) {
        if (inside) {
            // 已在卡片或触发项上：取消关闭计时；还没到 delay 就重新起算
            closeTimer.stop()
            if (!root._dismissed && !root._hovered)
                showTimer.restart()
        } else {
            // 离开：允许下一轮重新计时
            root._dismissed = false
            showTimer.stop()
            if (root._hovered)
                closeTimer.restart()
        }
    }

    // ── 弹层（与 Popover 共用同一件）──
    ShadcnPopoverPopup {
        id: _surface
        width: 0
        height: 0
        anchor: root._triggerItem
        open: root.showing
        // 悬停语义不该抢焦点（页面里正在输入的字段会被打断），Esc 走 Shortcut
        takeFocus: false
        reducedMotion: root.reducedMotion
        side: root._contentItem ? root._contentItem.side : "bottom"
        align: root._contentItem ? root._contentItem.align : "center"
        alignOffset: root._contentItem ? root._contentItem.alignOffset : 4
        sideOffset: root._contentItem ? root._contentItem.sideOffset : 4
        // Esc / 点击外部：立即收，并抑制本轮重开
        onDismissed: {
            showTimer.stop()
            closeTimer.stop()
            root._hovered = false
            root._dismissed = true
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < root._children.length; ++i) {
            var child = root._children[i]
            var name = child.objectName || ""
            if (name === "trigger") {
                root._triggerItem = child
                child.parent = root
            } else if (name === "content") {
                root._contentItem = child
                _surface.setSurface(child)
            }
        }
        // 指针可能在组件完成前就已停在触发项上（测试 / 布局后移入）：
        // hovered 的初值 true 不会产生 changed 信号，这里补一次入口判断。
        if (_pointerInside)
            _onPointer(true)
    }
}

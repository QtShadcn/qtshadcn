// src/qml/Components/ShadcnPopoverPopup.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// Popover / HoverCard 共用的弹层承载件（库内部件，不建议直接使用）
//
// 官方 registry 里 popover.json 与 hover-card.json 用的是**同一套 Portal + Positioner
// + Popup**，差别只在触发方式（click vs hover + delay）。所以把「弹层本体」抽成公共件，
// ShadcnPopover / ShadcnHoverCard 各自只负责触发语义：
//
//   - 定位：ShadcnPopupPosition（side / align / sideOffset 透传，贴边自动翻转 / 钳高）
//   - 动画：ShadcnFadeZoomTransition（fade + zoom-95，时长走 durationInstant token）
//   - 关闭：点击外部 / Esc（Popup closePolicy 内置）→ 发出 dismissed()
//   - 内容：setSurface(item) 把用户的 XxxContent 挂进内容区（仿 DropdownMenu 收集模式）
//
// 祖先链可见性也放在这里，而不是两个根组件各抄一份：本件是根组件的子项，沿
// **自己的 parent 链**往上走 = 把根组件那条链走了一遍。Popup 渲染在 window overlay
// 层，**不受父项 visible 约束**，不检查的话隐藏页（StackLayout 非当前页）里的浮层会
// 幽灵般继续显示、甚至串到别的页面截图上（DropdownMenu / Tooltip 实测踩过）。
//
// surfaceHovered 把内容区的悬停状态暴露给外层：HoverCard 靠它实现
// 「指针从触发项移进卡片时不关闭」（Base UI closeDelay 的原始动机）。
Item {
    id: root

    // ── 输入 ──
    /// 定位锚（触发项）。null 时定位器退化为「不翻转」，挂上后自动重算
    property Item anchor: null
    /// 期望方向："bottom" | "top"（registry 同名属性）
    property string side: "bottom"
    /// 横向对齐："start" | "center" | "end"（registry 同名属性）
    property string align: "center"
    /// 横向对齐偏移（registry alignOffset；定位器没有这个输入，在定位结果上叠加后再钳回边界）
    property real alignOffset: 0
    /// 与触发项的间距（registry sideOffset）
    property real sideOffset: 4
    /// 开关（外层根组件驱动）
    property bool open: false
    /// 打开时是否抢焦点（= 用 Popup 自带 CloseOnEscape；false 走 Shortcut 接 Esc）
    property bool takeFocus: true
    /// 无障碍：减弱动画（与 QtShadcnTheme.reducedMotion 同名同义，由外层根组件传入）
    property bool reducedMotion: false

    // ── 输出 ──
    /// 内容区被悬停
    readonly property bool surfaceHovered: surfaceHover.hovered
    // 祖先链可见性：**必须写成内联绑定而不是调函数** —— 绑定依赖捕获只登记绑定
    // 体里直接读到的属性，与 ShadcnDropdownMenu._ancestorsVisible 同一写法（先例验证过）。
    // Popup 渲染在 window overlay 层不受父项 visible 约束，不查这条链，隐藏页
    // （StackLayout 非当前页）里的浮层会幽灵般继续显示、甚至串到别的页面截图上。
    readonly property bool hostVisible: {
        var p = root.parent
        while (p) {
            if (p.visible === false)
                return false
            p = p.parent
        }
        return true
    }
    /// 定位结果（resolvedSide / clamped / availableHeight / x / y）
    readonly property alias placement: _placement
    /// 弹层本体（读几何 / 可见性用）
    readonly property alias popup: _popup

    /// 弹层过渡的实际时长：时长走 durationInstant token，经 motionDuration 折算
    /// （reducedMotion 打开时归零）。公开出来供测试与调用方读取。
    readonly property int transitionDurationMs:
        _theme.motionDuration(_theme.durationInstant)

    /// 弹层自己关掉了（点击外部 / Esc）→ 外层据此复位自己的状态
    signal dismissed()

    // Overlay.overlay 必须在 Item 作用域里取（QtObject 里恒为 null —— attached
    // property 需要有 Item 上下文）。取一次，交给定位器当坐标系 + 碰撞边界。
    readonly property Item _overlay: QQC.Overlay.overlay

    // 挂在弹层里的用户内容（Content 本体）。弹层尺寸显式取自它 —— Content 自己
    // 有确定 width/height，比 childrenRect 少一层间接（也不依赖子项布局时机）。
    property Item _surfaceItem: null

    ShadcnPopupPosition {
        id: _placement
        anchor: root.anchor
        container: root._overlay
        popupWidth: _popup.implicitWidth
        popupHeight: _popup.implicitHeight
        side: root.side
        align: root.align
        sideOffset: root.sideOffset
    }

    QQC.Popup {
        id: _popup
        padding: 0
        // 坐标系与定位器一致（都在 overlay 层），x/y 才能直接赋值
        parent: _placement.frame
        // alignOffset 在定位结果上叠加（registry 的 offset 只作用于交叉轴 = 横向）。
        // 叠加后可能推出边界，所以在这里按定位器同一规则钳回一次 ——
        // registry hover-card 默认 alignOffset=4，贴右缘时不钳就会把卡片顶出窗口。
        x: root._clampedX()
        y: _placement.y
        // 两侧都放不下时钳到可用高度（内容区 clip 裁掉溢出）
        height: _placement.clamped ? _placement.height : implicitHeight
        visible: root.open && root.hostVisible
        // Popover 打开时进焦点链（内容里点输入框能直接打字）；
        // HoverCard 不抢焦点（纯指针语义，抢焦点会打断页面正在输入的字段）。
        focus: root.takeFocus && root.open
        closePolicy: QQC.Popup.CloseOnPressOutside

        // Esc 走 Shortcut 而不是 Popup.CloseOnEscape：后者依赖弹层在焦点链里
        // （focus 默认 false 时键盘事件根本不路由到 overlay 层的弹层 —— 实测
        // HoverCard 不抢焦点就关不掉），而 WindowShortcut 在按键到达焦点项之前
        // 就被处理，两种语义下都稳。sequence 用 "Escape" 而不是 StandardKey.Cancel
        // （Cancel 有多个绑定，只绑一个会打告警）。
        Shortcut {
            enabled: _popup.visible
            sequence: "Escape"
            // 只发信号，不改 _popup.visible —— 可见性由 root.open && hostVisible
            // 的绑定驱动，外层在 dismissed() 里复位状态，弹层随绑定关闭。
            onActivated: root.dismissed()
        }
        onClosed: root.dismissed()
        background: Rectangle { color: "transparent" }

        // 内容挂接点：setSurface() 把 Content 移到 (0,0)，这里只负责给它一个
        // 等大的坐标系 + 悬停探测。
        contentItem: Item {
            id: holder
            objectName: "popoverHolder"
            implicitWidth: root._surfaceItem ? root._surfaceItem.width : 0
            implicitHeight: root._surfaceItem ? root._surfaceItem.height : 0
            // 只在钳高时裁切（溢出内容不该画到背景之外）；平时不 clip ——
            // Content 的 shadow-md 由 layer 外扩绘制，常驻 clip 会把阴影切掉
            clip: _placement.clamped

            // HoverHandler 派生自 QObject（QQuickSinglePointHandler），**不是 Item**：
            // 没有 anchors / x / y / width / height，命中面就是它 parent 项的矩形，
            // 所以空声明即可，别试图给它铺几何。
            HoverHandler {
                id: surfaceHover
            }
        }

        // fade + zoom-95（对齐 registry 的 data-open:fade-in-0 / zoom-in-95 + duration-100）
        // 时长只在这里折算一次（transitionDurationMs），Transition 本身不再判 reducedMotion
        enter: ShadcnFadeZoomTransition {
            shown: true
            durationMs: root.transitionDurationMs
        }
        exit: ShadcnFadeZoomTransition {
            shown: false
            durationMs: root.transitionDurationMs
        }
    }

    QtShadcnTheme {
        id: _theme
        // 全局减弱动画开关从外层传入（QtShadcnTheme 是每组件一个实例，
        // 跨实例不共享，所以必须显式接线）
        reducedMotion: root.reducedMotion
    }

    /// 把用户的 Content（Content 自身，不是它的子项）挂进弹层内容区
    function setSurface(item) {
        root._surfaceItem = item
        item.parent = _popup.contentItem
    }

    /// 定位器 x + alignOffset，钳回 overlay 边界内（collisionPadding 与定位器同为 8）
    function _clampedX() {
        var f = _placement.frame
        var x = _placement.x + root.alignOffset
        if (!f || f.width <= 0)
            return x
        var pad = 8
        var maxX = f.width - pad - _popup.width
        return (maxX <= pad) ? pad : Math.max(pad, Math.min(x, maxX))
    }
}

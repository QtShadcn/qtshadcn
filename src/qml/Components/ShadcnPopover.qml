// src/qml/Components/ShadcnPopover.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格弹出层（Popover，issue #5）
//
// 组合式 API（与 ShadcnDropdownMenu 同形 —— 仓库里点击触发弹层的既有先例）：
//   ShadcnPopover {
//       ShadcnPopoverTrigger { text: "打开" }
//       ShadcnPopoverContent {
//           ShadcnPopoverHeader {
//               ShadcnPopoverTitle { text: "标题" }
//               ShadcnPopoverDescription { text: "描述" }
//           }
//           ShadcnInput { placeholderText: "输入…" }
//       }
//   }
//
// 为什么组合式而不是属性驱动：Popover 的内容本质是「任意业务 QML」（表单 / 输入框 /
// 日期选择），属性驱动要么塞 Component、要么让用户手写 Popup，都比「声明子项、根组件
// 按 objectName 收集」更绕。官方 registry 导出的也是六个组件，组合式是 1:1 对齐。
//
// 交互：点击 Trigger 开合；点击外部 / Esc 关闭（Popup closePolicy 内置）。
// 弹层的定位 / 动画 / 祖先链可见性与 HoverCard 共用 ShadcnPopoverPopup。
Item {
    id: root

    /// 是否打开（可双向绑定；点击外部 / Esc 关闭后自动复位）
    property bool open: false

    /// 无障碍：减弱动画（与 ShadcnFadeZoomTransition.reducedMotion 同语义，手动
    /// 同步 —— QtShadcnTheme 是每组件一个实例，全局开关需调用方接线，
    /// 例：reducedMotion: pageTheme.reducedMotion）
    property bool reducedMotion: false

    /// 触发按钮（ShadcnPopoverTrigger）；未收集到时为 null
    readonly property alias trigger: root._triggerItem
    /// 内容面板（ShadcnPopoverContent）；被移入 Popup 后仍指向同一对象
    readonly property alias content: root._contentItem
    /// 定位结果（resolvedSide / clamped / availableHeight / x / y）
    readonly property alias placement: _surface.placement
    /// 弹层本体（读几何 / 可见性用）
    readonly property alias popup: _surface.popup

    /// 内容区被悬停（与 HoverCard 对称，调用方想做「hover 不关」时可用）
    readonly property bool hovered: _surface.surfaceHovered
    /// 弹层过渡实际时长 ms（durationInstant token 经 motionDuration 折算；
    /// reducedMotion 打开时为 0）。公开出来供测试与调用方读取。
    readonly property alias transitionDurationMs: _surface.transitionDurationMs

    implicitWidth: _triggerItem ? _triggerItem.implicitWidth : 120
    implicitHeight: _triggerItem ? _triggerItem.implicitHeight : 36

    // 收集用户声明的 Trigger / Content（Popup 等内部对象不进此列表）
    default property alias popoverChildren: root._children
    property list<QtObject> _children

    // 两个子件用具体类型，绑定里才能静态读到它们的 objectName / API
    property ShadcnPopoverTrigger _triggerItem: null
    property ShadcnPopoverContent _contentItem: null

    QtShadcnTheme { id: theme }

    // ── 弹层：定位 / 动画 / 内容承载 / 祖先链可见性都在公共件里 ──
    // 本件是根组件的子项（parent 链即祖先链），但不占布局：内容活在 Popup 的
    // overlay 层里，这个壳只是坐标 / 动画的持有者。
    ShadcnPopoverPopup {
        id: _surface
        width: 0
        height: 0
        anchor: root._triggerItem
        open: root.open
        takeFocus: true
        reducedMotion: root.reducedMotion
        // registry 这四个定位参数属于 Content，根组件从收集到的 Content 读走透传
        side: root._contentItem ? root._contentItem.side : "bottom"
        align: root._contentItem ? root._contentItem.align : "center"
        alignOffset: root._contentItem ? root._contentItem.alignOffset : 0
        sideOffset: root._contentItem ? root._contentItem.sideOffset : 4
        onDismissed: root.open = false
    }

    Component.onCompleted: {
        for (var i = 0; i < root._children.length; ++i) {
            var child = root._children[i]
            var name = child.objectName || ""
            if (name === "trigger") {
                root._triggerItem = child
                child.parent = root
                child.clicked.connect(function() { root.open = !root.open })
            } else if (name === "content") {
                root._contentItem = child
                _surface.setSurface(child)
            }
        }
    }
}

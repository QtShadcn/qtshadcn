// src/qml/Components/ShadcnDropdownMenu.qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// shadcn/ui 风格下拉菜单（M6）
// 用 QQC.Popup 承载弹层：Popup 渲染在 Window Overlay 层，天然置顶，
// 不会被页面其他元素（图标按钮等）遮挡
// 交互：点击外部 / ESC 关闭（QQC.Popup closePolicy 内置）
// 用法:
//   ShadcnDropdownMenu {
//       ShadcnDropdownMenuTrigger { text: "打开" }
//       ShadcnDropdownMenuContent {
//           ShadcnDropdownMenuItem { text: "个人中心" }
//       }
//   }
Item {
    id: root

    property bool open: false

    implicitWidth: 120
    implicitHeight: 36

    // 收集用户声明的 Trigger / Content（Popup 等内部对象不进此列表）
    default property alias menuChildren: root._children
    property list<QtObject> _children

    QtShadcnTheme { id: theme }

    // 祖先链可见性：Popup 在 window overlay 层，不受父项 visible 约束，
    // 隐藏页/隐藏容器里的菜单会幽灵显示（截图串页的根源）。
    readonly property bool _ancestorsVisible: {
        var p = root.parent
        while (p) {
            if (p.visible === false)
                return false;
            p = p.parent;
        }
        return true;
    }

    // Overlay.overlay 必须在 Item 作用域里取（QtObject 里是 null，attached property
    // 需要有 Item 上下文）。这里只做一次，供下面的定位器当坐标系 / 碰撞边界。
    readonly property Item _overlay: QQC.Overlay.overlay

    // 对外暴露定位结果（只读引用）：resolvedSide / clamped / availableHeight
    // 供调用方在翻转后反转入场动画方向、或据此给内容区加滚动（issue #16 的输出要求）
    readonly property alias placement: _placement

    // ── 定位：与 tooltip / select 共用同一套边界翻转（issue #16）──
    ShadcnPopupPosition {
        id: _placement
        anchor: null            // Component.onCompleted 里找到 trigger 后赋值
        container: root._overlay
        popupWidth: popup.implicitWidth
        popupHeight: popup.implicitHeight
        side: "bottom"
        sideOffset: 4           // 原硬编码 +4
    }

    // ── 弹层：Overlay 层，天然置顶 ──
    QQC.Popup {
        id: popup
        padding: 0
        // 坐标系与定位器一致（overlay 层），_placement.x/y 才能直接用
        parent: _placement.frame
        x: _placement.x
        y: _placement.y
        // 两侧都放不下时钳到可用高度（内容区 clip + 可滚动，见 contentItem）
        height: _placement.clamped ? _placement.height : implicitHeight
        visible: root.open && root._ancestorsVisible
        // 点击外部关闭 + ESC 关闭
        closePolicy: QQC.Popup.CloseOnPressOutside | QQC.Popup.CloseOnEscape
        onClosed: { root.open = false }

        background: Rectangle { color: "transparent" }
        // clip：两侧都放不下被钳高时，多出来的条目不应画到弹层背景之外。
        // 菜单项数量少、场景罕见，这里只做裁切不做滚动（滚动留给 issue #14 的动画批）：
        // 给 Column 套 Flickable 会让 popup.implicitWidth 失去来源（子项 Rectangle
        // 没有 implicitWidth，Column.implicitWidth 恒为 0 → 弹层宽度塌成 0）。
        contentItem: Column { id: popupColumn; spacing: 2; clip: true }

        enter: ShadcnFadeZoomTransition { shown: true }
        exit: ShadcnFadeZoomTransition { shown: false }
    }

    Component.onCompleted: {
        var trig = null
        var content = null
        for (var i = 0; i < root._children.length; ++i) {
            var child = root._children[i]
            var name = child.objectName || ""
            if (name === "trigger") {
                trig = child
                child.parent = root
                child.clicked.connect(function() { root.open = !root.open })
            } else if (name === "content") {
                content = child
                child.parent = popupColumn
            }
        }
        if (trig) {
            // 容器尺寸跟随 trigger；弹层定位交给 _placement（自动翻转 / 钳制）
            root.implicitWidth = trig.implicitWidth
            root.implicitHeight = trig.implicitHeight
            _placement.anchor = trig
        }
    }
}

// src/qml/Components/ShadcnTooltip.qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// shadcn/ui 风格悬停提示（M6）
// 用法（作为子组件自动绑定父 hover）:
//   ShadcnButton { text: "悬停我"
//       ShadcnTooltip { text: "这是提示" }
//   }
// 程序化显示（演示页 / 截图等无鼠标场景）: ShadcnTooltip { text: "..."; open: true }
Item {
    id: root

    property string text: ""
    // 强制显示：忽略 hover 与计时器，用于演示 / 截图等无鼠标场景
    property bool open: false
    // hover 命中状态，由下面两个 Timer 驱动（与 open 取或）
    property bool _hovered: false

    QtShadcnTheme { id: theme }

    // 祖先链可见性：Popup 渲染在 window overlay 层，**不受父项 visible 约束**。
    // 若不检查，被隐藏的页面（如 StackLayout 非当前页）里的浮层会幽灵般继续显示，
    // 甚至串到别的页面截图上。沿 parent 链读 visible，任一为 false 即视为不可见。
    readonly property bool _ancestorsVisible: {
        var p = root.parent
        while (p) {
            if (p.visible === false)
                return false;
            p = p.parent;
        }
        return true;
    }

    Timer {
        id: showTimer
        interval: 300
        onTriggered: root._hovered = true
    }
    Timer {
        id: hideTimer
        interval: 100
        onTriggered: root._hovered = false
    }

    // ── hover 探测 ────────────────────────────────────────
    // hovered 是运行期才在 QQuickItem 上出现的动态属性，静态分析看不到，因此下面
    // 这一小段用动态属性访问（p.hovered）时必然报 missing-property，局部关闭该告警。
    // 注意：qmllint 会把注释里的「qmllint + 词」误解析成指令，别在行首写这个词。
    // 关闭范围：findHoverTarget → Connections → Component.onCompleted
    //
    // qmllint disable missing-property
    function findHoverTarget() {
        var p = root.parent
        while (p) {
            if (p.hovered !== undefined) return p
            p = p.parent
        }
        return null
    }

    // 绑定到找到的祖先的 hovered 属性
    Connections {
        id: hoverConn
        target: null
        function onHoveredChanged() {
            if (hoverConn.target && hoverConn.target.hovered) {
                hideTimer.stop()
                showTimer.restart()
            } else {
                showTimer.stop()
                hideTimer.restart()
            }
        }
    }

    Component.onCompleted: {
        var t = findHoverTarget()
        if (t) {
            hoverConn.target = t
            // 初始状态检查
            if (t.hovered) {
                showTimer.restart()
            }
        }
    }
    // qmllint enable missing-property

    // ── 弹层定位：边界翻转 / 钳制（issue #16）──
    // 原实现是一套手写的横向 Math.min/max clamp + 纵向硬编码在触发项下方；
    // 现在统一交给 ShadcnPopupPosition，三处弹层只有一份规则。
    readonly property Item _overlay: QQC.Overlay.overlay

    // 触发项 = 声明这个 tooltip 的父项（hover 也绑在它身上）
    readonly property Item _trigger: root.parent

    // 对外暴露定位结果（只读引用）与气泡本体：Item 基类没有 popup 属性，
    // 但消费方 / 测试需要读气泡的实际几何
    readonly property alias placement: _placement
    readonly property alias popup: _popup

    ShadcnPopupPosition {
        id: _placement
        anchor: root._trigger
        container: root._overlay
        // 尺寸必须取 popup 自身的 implicit*（含 padding）：只取 contentItem 的
        // 隐式尺寸会漏掉四周留白，气泡会画到 trigger 上（实测差 24px 上下/左右）
        popupWidth: _popup.implicitWidth
        popupHeight: _popup.implicitHeight
        side: "bottom"
        sideOffset: 6           // 原硬编码 +6
        // 气泡比触发项宽时居中于触发项（原实现的居中语义）
        align: "center"
    }

    QQC.Popup {
        id: _popup
        // 坐标系 = overlay 层；parent 用 _placement.frame 保证与 x/y 同一坐标系
        parent: _placement.frame
        x: _placement.x
        y: _placement.y
        // 钳制时按可用高度收窄，内容区 wrapMode 会自动多折一行
        height: _placement.clamped ? _placement.height : implicitHeight
        visible: (root.open || root._hovered) && root.text !== "" && root._ancestorsVisible
        closePolicy: QQC.Popup.NoAutoClose

        background: Rectangle {
            color: theme.popover
            radius: theme.radius
            border.width: 1
            border.color: theme.border
        }

        contentItem: Item {
            implicitWidth: Math.min(_tipText.implicitWidth + 16, 200)
            implicitHeight: _tipText.implicitHeight + 8

            Text {
                id: _tipText
                anchors.centerIn: parent
                text: root.text
                color: theme.popoverForeground
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                width: Math.min(implicitWidth, 200 - 16)
            }
        }
    }
}

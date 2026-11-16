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

    QQC.Popup {
        id: _popup
        parent: root.parent
        visible: (root.open || root._hovered) && root.text !== "" && root._ancestorsVisible
        closePolicy: QQC.Popup.NoAutoClose

        // x 居中于触发器内容区；气泡比触发器宽时两侧都会溢出，
        // 做一次 clamp 把它拉回父容器内（与 Radix 的 shift 行为一致），否则长文本
        // 气泡会跑出可视区左边缘
        x: {
            if (!root.parent)
                return 0;
            var centered = Math.round((root.parent.width - width) / 2);
            return Math.max(0, Math.min(centered, root.parent.width - width));
        }
        y: root.parent ? root.parent.height + 6 : 0

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

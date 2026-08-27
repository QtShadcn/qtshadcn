// src/qml/Components/ShadcnTooltip.qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// shadcn/ui 风格悬停提示（M6）
// 用法（作为子组件自动绑定父 hover）:
//   ShadcnButton { text: "悬停我"
//       ShadcnTooltip { text: "这是提示" }
//   }
Item {
    id: root

    property string text: ""
    property bool _showing: false

    QtShadcnTheme { id: theme }

    Timer {
        id: showTimer
        interval: 300
        onTriggered: root._showing = true
    }
    Timer {
        id: hideTimer
        interval: 100
        onTriggered: root._showing = false
    }

    // 向上查找有 hovered 属性的祖先（Button 的 contentItem 没有 hovered）
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
            if (target && target.hovered) {
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

    QQC.Popup {
        id: _popup
        parent: root.parent
        visible: root._showing && root.text !== ""
        closePolicy: QQC.Popup.NoAutoClose

        x: root.parent ? Math.round((root.parent.width - width) / 2) : 0
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

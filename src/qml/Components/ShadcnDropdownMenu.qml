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

    // ── 弹层：Overlay 层，天然置顶 ──
    QQC.Popup {
        id: popup
        padding: 0
        visible: root.open
        // 点击外部关闭 + ESC 关闭
        closePolicy: QQC.Popup.CloseOnPressOutside | QQC.Popup.CloseOnEscape
        onClosed: { root.open = false }

        background: Rectangle { color: "transparent" }
        contentItem: Column { id: popupColumn; spacing: 2 }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 100 }
                NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 100; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
                NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 100; easing.type: Easing.InCubic }
            }
        }
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
            // 容器尺寸跟随 trigger，Popup 定位到 trigger 正下方
            root.implicitWidth = trig.implicitWidth
            root.implicitHeight = trig.implicitHeight
            popup.y = Qt.binding(function() { return trig.height + 4 })
        }
    }
}

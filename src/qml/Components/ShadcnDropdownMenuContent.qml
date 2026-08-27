// src/qml/Components/ShadcnDropdownMenuContent.qml
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格菜单弹层容器（M6）
// 作为 ShadcnDropdownMenu 的直接子项使用
Rectangle {
    id: root
    objectName: "content"

    // 必须显式绑定宽高：layer FBO 按实际尺寸渲染，0×0 会导致内容不可见
    width: menuCol.implicitWidth + 8
    height: menuCol.implicitHeight + 8

    radius: theme.radius
    color: theme.popover
    border.width: 1
    border.color: theme.border
    z: 1000

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.5
        shadowVerticalOffset: 4
        shadowColor: Qt.rgba(0, 0, 0, 0.18)
    }

    QtShadcnTheme { id: theme }

    Column {
        id: menuCol
        anchors.fill: parent
        anchors.margins: 4
        spacing: 2
    }

    // 所有子项自动进入 menuCol
    default property alias contentChildren: menuCol.children
}

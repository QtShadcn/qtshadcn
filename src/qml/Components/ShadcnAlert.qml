// src/qml/Components/ShadcnAlert.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格提示框（M6）
// 规范：variant=default/destructive（shadcn 原生）；Warning/Success 为项目扩展
// 子组件：AlertTitle + AlertDescription + AlertAction（右上角操作按钮）
// 用法:
//   ShadcnAlert { title: "提示"; description: "操作成功" }
//   ShadcnAlert { title: "错误"; description: "发生错误"; variant: ShadcnAlert.Variant.Destructive }
//   ShadcnAlert { title: "确认"; ShadcnAlertAction { ShadcnButton { text: "知道了" } } }
Rectangle {
    id: root

    enum Variant { Default, Destructive, Warning, Success }

    property string title: ""
    property string description: ""
    property int variant: ShadcnAlert.Variant.Default
    property string iconName: ""

    // AlertAction slot：用户在内部放 ShadcnButton 等操作元素
    default property alias actionChildren: _actionLayout.data

    QtShadcnTheme { id: theme }

    radius: theme.radius
    border.width: 1
    implicitWidth: layout.implicitWidth + 24
    implicitHeight: Math.max(layout.implicitHeight + 24, _actionLayout.visible ? _actionLayout.implicitHeight + 24 : 0)

    // 配色：全部走 token，不再硬编码 Qt.rgba
    readonly property color _fg: variant === ShadcnAlert.Variant.Destructive ? theme.destructive
                              : variant === ShadcnAlert.Variant.Warning ? theme.warning
                              : variant === ShadcnAlert.Variant.Success ? theme.success
                              : theme.foreground

    readonly property color _bg: variant === ShadcnAlert.Variant.Destructive ? Qt.alpha(theme.destructive, 0.1)
                             : variant === ShadcnAlert.Variant.Warning ? Qt.alpha(theme.warning, 0.1)
                             : variant === ShadcnAlert.Variant.Success ? Qt.alpha(theme.success, 0.1)
                             : theme.muted

    readonly property color _border: variant === ShadcnAlert.Variant.Destructive ? Qt.alpha(theme.destructive, 0.3)
                                  : variant === ShadcnAlert.Variant.Warning ? Qt.alpha(theme.warning, 0.3)
                                  : variant === ShadcnAlert.Variant.Success ? Qt.alpha(theme.success, 0.3)
                                  : theme.border

    color: _bg
    border.color: _border

    RowLayout {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: _actionLayout.visible ? _actionLayout.left : parent.right
        anchors.rightMargin: 12
        spacing: 10

        ShadcnIcon {
            name: root.iconName || (variant === ShadcnAlert.Variant.Destructive ? "alert-circle"
                       : variant === ShadcnAlert.Variant.Warning ? "alert-triangle"
                       : variant === ShadcnAlert.Variant.Success ? "check-circle"
                       : "info")
            size: 16
            color: root._fg
        }

        ColumnLayout {
            spacing: 2

            Text {
                text: root.title
                color: root._fg
                font.pixelSize: 14
                font.bold: true
                visible: root.title !== ""
            }

            Text {
                text: root.description
                color: root._fg
                font.pixelSize: 13
                visible: root.description !== ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

    // AlertAction：右上角操作按钮区域
    RowLayout {
        id: _actionLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 8
        visible: children.length > 0
    }
}

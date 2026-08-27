// src/qml/Components/ShadcnAlert.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格提示框（M6）
// 用法:
//   ShadcnAlert { title: "提示"; description: "操作成功" }
//   ShadcnAlert { title: "错误"; description: "发生错误"; variant: ShadcnAlert.Variant.Destructive }
Rectangle {
    id: root

    enum Variant { Default, Destructive, Warning, Success }

    property string title: ""
    property string description: ""
    property int variant: ShadcnAlert.Variant.Default
    property string iconName: ""

    QtShadcnTheme { id: theme }

    radius: theme.radius
    border.width: 1
    implicitWidth: layout.implicitWidth + 24
    implicitHeight: layout.implicitHeight + 24

    // 配色
    readonly property color _bg: variant === ShadcnAlert.Variant.Destructive ? Qt.rgba(theme.destructive.r, theme.destructive.g, theme.destructive.b, 0.1)
                             : variant === ShadcnAlert.Variant.Warning ? Qt.rgba(0xf5, 0x9e, 0x0b, 0.1)
                             : variant === ShadcnAlert.Variant.Success ? Qt.rgba(0x16, 0xa3, 0x4a, 0.1)
                             : theme.muted
    readonly property color _border: variant === ShadcnAlert.Variant.Destructive ? Qt.rgba(theme.destructive.r, theme.destructive.g, theme.destructive.b, 0.3)
                                  : variant === ShadcnAlert.Variant.Warning ? Qt.rgba(0xf5, 0x9e, 0x0b, 0.3)
                                  : variant === ShadcnAlert.Variant.Success ? Qt.rgba(0x16, 0xa3, 0x4a, 0.3)
                                  : theme.border
    readonly property color _fg: variant === ShadcnAlert.Variant.Destructive ? theme.destructive
                              : variant === ShadcnAlert.Variant.Warning ? Qt.rgba(0xf5, 0x9e, 0x0b, 1)
                              : variant === ShadcnAlert.Variant.Success ? Qt.rgba(0x16, 0xa3, 0x4a, 1)
                              : theme.foreground

    color: _bg
    border.color: _border

    RowLayout {
        id: layout
        anchors.centerIn: parent
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
            }
        }
    }
}

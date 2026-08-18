import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格 Tab 按钮（基于 QQC.TabButton）
// variant 由 ShadcnTabsList 自动同步（default/line）
// - default：选中态 bg-background 白底 + 6px 圆角
// - line：选中态 2px 下划线指示器（bottom -5px）
TabButton {
    id: root

    property string variant: "default"   // "default" | "line"（由 ShadcnTabsList 同步）

    QtShadcnTheme { id: theme }
    readonly property bool _isLine: variant === "line"

    // 内容：text-sm(14px) Medium
    contentItem: Text {
        text: root.text
        color: root.checked
            ? theme.foreground
            : Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.6)
        font.pixelSize: 14
        font.weight: Font.Medium
        anchors.centerIn: parent
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // 背景：default 选中态白底（shadcn: data-active:bg-background），line 透明
    background: Rectangle {
        radius: root._isLine ? 0 : 6
        color: (root.checked && !root._isLine) ? theme.background : "transparent"

        // line variant 选中态：2px 下划线（shadcn: after:bottom-[-5px] after:h-0.5）
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -5
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 2
            color: theme.foreground
            visible: root._isLine && root.checked
            opacity: root.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // 关闭 QQC.TabButton 默认 indicator（底部下划线）
    indicator: Item {}
}

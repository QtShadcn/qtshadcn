import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// ShadcnTabsTrigger
// 职责：
//   TabButton          → 交互 / checked / hovered / focus / keyboard
//   contentItem        → 文字
//   background         → 默认背景 / active 背景 / dark border
//   focusRing          → 键盘焦点
//   lineIndicator      → line variant 下划线
//   indicator          → 关闭 Qt Quick Controls 默认 indicator

TabButton {
    id: root

    readonly property bool _isLine: variant === "line"

    // "default" | "line"
    // 通常由 ShadcnTabsList 统一设置。
    property string variant: "default"

    implicitHeight: 25
    leftPadding: 12
    rightPadding: 12

    // ============================================================
    // Background
    // ============================================================
    //
    // 这里只负责：
    //
    // 1. default variant 背景
    // 2. selected 背景
    // 3. dark mode selected border
    //

    background: Rectangle {
        id: backgroundRect

        // 最外层默认透明
        color: "transparent"
        radius: root._isLine ? 0 : 6

        // ========================================================
        // Selected Background
        // ========================================================

        Rectangle {
            id: selectedBackground

            anchors.fill: parent
            color: theme.mode === "dark" ? Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.3) : theme.background
            opacity: root.checked ? 1 : 0
            radius: backgroundRect.radius
            visible: !root._isLine

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        // ========================================================
        // Dark Mode Border
        // ========================================================

        Rectangle {
            id: darkBorder

            anchors.fill: parent
            border.color: theme.input
            border.width: 1
            color: "transparent"
            radius: backgroundRect.radius
            visible: root.checked && !root._isLine && theme.mode === "dark"
        }
    }
    contentItem: Text {
        color: root.checked || root.hovered ? theme.foreground : Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.6)
        elide: Text.ElideRight
        font.pixelSize: 14
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    // ============================================================
    // Disable Qt Quick Controls default indicator
    // ============================================================
    //
    // Qt Quick Controls 的 TabButton 可能有自己的 indicator。
    //
    // QtShadcn 自己处理视觉，所以关闭它。
    //

    indicator: Item {
    }

    QtShadcnTheme {
        id: theme
    }

    // ============================================================
    // Focus Ring
    // ============================================================
    // focus-visible:

    // 使用 activeFocus，而不是 checked。
    Rectangle {
        id: focusRing

        anchors.fill: root
        anchors.margins: -3
        border.color: theme.ring
        border.width: 2
        color: "transparent"
        opacity: 0.7
        radius: root._isLine ? 0 : 9
        visible: root.activeFocus
        z: 10
    }

    // ============================================================
    // Line Variant Indicator
    // ============================================================
    //
    // variant = "line" 时：
    //
    // Tab A       Tab B       Tab C
    // ─────
    //
    // 只有 checked 的 Tab 显示下划线。
    //

    Rectangle {
        id: lineIndicator

        anchors.bottom: root.bottom
        anchors.bottomMargin: -5
        anchors.horizontalCenter: root.horizontalCenter
        color: theme.foreground
        height: 2
        opacity: root.checked ? 1 : 0
        visible: root._isLine
        width: root.width
        z: 5

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
}

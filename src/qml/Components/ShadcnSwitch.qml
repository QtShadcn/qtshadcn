import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格开关
// 基于 QQC.Switch（Basic style），替换 background(轨道) + indicator(滑块)
// 对齐 shadcn v4：胶囊轨道，default 44×20 / small 28×16，滑块位移 16/8 px
//
// 用法:
//   ShadcnSwitch { checked: true; size: ShadcnSwitch.Size.Default }
Switch {
    id: root

    enum Size { Default, Small }

    property int size: ShadcnSwitch.Size.Default

    QtShadcnTheme { id: theme }

    // 尺寸：default 44×20 / small 28×16（shadcn: w-11 h-5 / w-7 h-4）
    readonly property int _w: size === ShadcnSwitch.Size.Small ? 28 : 44
    readonly property int _h: size === ShadcnSwitch.Size.Small ? 16 : 20
    // 滑块：default 24×16 / small 16×12（shadcn: w-6 h-4 / w-4 h-3）
    readonly property int _tw: size === ShadcnSwitch.Size.Small ? 16 : 24
    readonly property int _th: size === ShadcnSwitch.Size.Small ? 12 : 16
    readonly property int _border: 2   // shadcn: border-2

    implicitWidth: _w
    implicitHeight: _h

    // ── 轨道（background）──
    background: Rectangle {
        radius: root._h / 2
        // checked: bg-primary + primary 边框；unchecked: bg-input/90 + 透明边框
        color: root.checked
            ? theme.primary
            : Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.9)
        border.width: root._border
        border.color: root.checked ? theme.primary : "transparent"

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // 焦点环：activeFocus 时 3px 外环（与 Input 一致）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: (root._h / 2) + 3
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // ── 滑块（indicator）──
    indicator: Rectangle {
        implicitWidth: root._tw
        implicitHeight: root._th
        radius: implicitHeight / 2
        color: theme.background   // shadcn: bg-background（dark checked 用 primaryForeground，省略：bg-background 在两套主题下均为浅色，与 dark 模式高对比度）

        // 水平位置：unchecked = border(2) / checked = _w - tw - border(2)
        // shadcn: translate-x-[calc(100%-8px)] ＝ tw - 8 = 默认 16 / 小 8
        x: root.checked ? root._w - implicitWidth - root._border : root._border
        y: (root._h - implicitHeight) / 2

        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    // 禁用态：opacity 50%（shadcn: disabled:opacity-50）
    opacity: !enabled ? 0.5 : 1
}

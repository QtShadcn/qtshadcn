import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格开关
// 基于 QQC.Switch（Basic style），替换 background(轨道) + indicator(滑块)
// 对齐 shadcn v4：轨道 default 32×18 / sm 24×14，滑块正圆 16 / 12（size-4 / size-3），
// 位移 translate-x-[calc(100%-2px)]（checked 右侧留 2px），unchecked 滑块 x=0
//
// 用法:
//   ShadcnSwitch { checked: true; size: ShadcnSwitch.Size.Default }
Switch {
    id: root

    enum Size { Default, Small }

    property int size: ShadcnSwitch.Size.Default

    QtShadcnTheme { id: theme }

    // 尺寸：v4 轨道 default 32×18 / sm 24×14（shadcn: h-[18.4px] w-[32px] / h-3.5 w-6）
    readonly property int _w: size === ShadcnSwitch.Size.Small ? 24 : 32
    readonly property int _h: size === ShadcnSwitch.Size.Small ? 14 : 18
    // 滑块：正圆 size-4 / size-3 = 16 / 12（v4 官方；旧版 h-4 w-6=16×24 胶囊已弃）
    readonly property int _tw: size === ShadcnSwitch.Size.Small ? 12 : 16
    readonly property int _th: size === ShadcnSwitch.Size.Small ? 12 : 16
    readonly property int _gap: 2   // checked 右侧留 2px（shadcn: translate-x-[calc(100%-2px)]）

    implicitWidth: _w
    implicitHeight: _h

    // ── 轨道（background）──
    background: Rectangle {
        radius: root._h / 2
        // checked: bg-primary；unchecked: bg-input（dark: bg-input/80）
        color: root.checked
            ? theme.primary
            : theme.mode === "dark"
                ? Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.8)
                : theme.input
        border.width: 0   // v4: border border-transparent（无可见边框）

        Behavior on color { ColorAnimation { duration: 150 } }

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
        // v4 滑块色：light = background；dark = checked?primaryForeground : foreground
        // （dark unchecked 用浅色滑块保证深轨道上可见，bg-background 会深底深色看不见）
        color: theme.mode === "dark"
            ? (root.checked ? theme.primaryForeground : theme.foreground)
            : theme.background

        // 水平位置：unchecked x=0 / checked 位移 tw-2（= _w - tw - gap）
        x: root.checked ? root._w - root._tw - root._gap : 0
        y: (root._h - implicitHeight) / 2

        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    // 禁用态：opacity 50%（shadcn: disabled:opacity-50）
    opacity: !enabled ? 0.5 : 1
}

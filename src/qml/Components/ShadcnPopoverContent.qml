// src/qml/Components/ShadcnPopoverContent.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格 Popover 内容面板（issue #5）
//
// 对齐 registry popover.json 的 popover-content：
//   w-72(288) + rounded-lg(=theme.radiusLg) + bg-popover + p-2.5(10) + gap-2.5(10)
//   + text-sm(14) + ring-1 ring-foreground/10 + shadow-md，fade/zoom-95 100ms（在弹层件里）
//
// 关于 shadow-md：这一版 registry 的 popover / hover-card **确实还带 shadow-md**
// （Dialog 那版才是「用 ring 取代 shadow」），所以照 ShadcnDropdownMenuContent 的
// 先例做 layer + MultiEffect；ring 也同时保留 —— 两者都是官方 class 原文。
// layer + MultiEffect 是 GPU 特效，offscreen 软件渲染不支持 → 截图模式下关 layer，
// 否则整块内容空白（见 ShadcnDropdownMenuContent 同处注释）。
//
// side / align / alignOffset / sideOffset 挂在 Content 上（官方 PopoverContent 的
// props 就是 Positioner 那四个），由 ShadcnPopover / ShadcnHoverCard 根组件读走，
// 透传给 ShadcnPopupPosition。
//
// 用法见 ShadcnPopover / ShadcnHoverCard。
Rectangle {
    id: root

    // ── 定位参数（透传给 ShadcnPopupPosition）──
    /// 期望方向："top" | "bottom"（registry 默认 bottom）
    property string side: "bottom"
    /// 横向对齐："start" | "center" | "end"（registry 默认 center）
    property string align: "center"
    /// 横向对齐偏移（registry 默认 0）
    property real alignOffset: 0
    /// 与触发项的间距（registry 默认 4）
    property real sideOffset: 4

    // ── 外观参数（registry 锚点，可覆盖）──
    /// 面板宽度（registry w-72 = 288）
    property real panelWidth: 288
    /// 内边距（registry p-2.5 = 10）
    property real panelPadding: 10
    /// 子项间距（registry gap-2.5 = 10）
    property real contentSpacing: 10

    // 由 ShadcnPopover / ShadcnHoverCard 按 objectName 收集并挂进 Popup
    objectName: "content"

    width: panelWidth
    height: contentColumn.implicitHeight + panelPadding * 2

    // 业务子项（Header / Title / Description / 任意内容）进内容列。
    // 必须声明在**根**上：写在 ColumnLayout 内部时它是布局自己的 default 属性，
    // 用户子项会掉进 Rectangle 而不被布局（实测 Header 宽度塌成 0）。
    default property alias content: contentColumn.data

    radius: theme.radiusLg      // rounded-lg
    color: theme.popover        // bg-popover

    // ring-1：1px 描边。与 DropdownMenuContent 一致走 border（theme.border 太浅，
    // 官方是 foreground 10% 透明，Dialog 用的就是这个写法，这里同源）
    border.width: 1
    border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.10)

    QtShadcnTheme { id: theme }

    layer.enabled: !ThemeManager.screenshotMode()
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.5
        shadowVerticalOffset: 4
        shadowColor: Qt.rgba(0, 0, 0, 0.18)
    }

    // 内容列：ColumnLayout 而不是 Column —— 业务子项（表单、卡片）需要 Layout.fillWidth。
    ColumnLayout {
        id: contentColumn
        x: root.panelPadding
        y: root.panelPadding
        width: root.width - root.panelPadding * 2
        // gap-2.5
        spacing: root.contentSpacing
    }
}

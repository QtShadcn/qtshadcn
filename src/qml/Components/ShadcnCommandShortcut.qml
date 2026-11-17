pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui CommandShortcut —— 右侧快捷键提示
//
// 对齐 registry 的 CommandShortcut：`ml-auto text-xs tracking-widest
//   text-muted-foreground group-data-selected/command-item:text-foreground`
//
// ── 两种写法都支持，效果一致（ml-auto 靠右）───────────────────
// 1. 简写（推荐）：直接用 CommandItem 的 shortcut 属性
//      ShadcnCommandItem { text: "复制"; shortcut: "⌘C" }
// 2. 组合写法（贴官方 JSX）：作为子项写进 CommandItem
//      ShadcnCommandItem {
//          Text { text: "复制" }
//          ShadcnCommandShortcut { text: "⌘C" }
//      }
// 写进 CommandItem 的子项默认落在「内容行」，本组件用 _isCommandShortcut 标记
// 自己，CommandItem 见到就把它搬到右侧插槽 —— Qt 没有 Web 的 slot 投射，
// 只能显式 relocation，视觉结果与 ml-auto 相同。
//
// 选中态提亮由父项（CommandItem）的 selected 驱动：本组件不猜父项类型，
// 用 CommandItem 注入的 _selectedByParent 读（父项是 CommandItem 时才有值）。
Text {
    id: root

    /// 供 CommandItem 识别「这是 shortcut，要搬到右侧插槽」（鸭子类型）
    readonly property bool _isCommandShortcut: true

    /// 由 CommandItem 置位的选中态（脱离 CommandItem 单用时保持 false）
    property bool _selected: false

    color: root._selected ? theme.foreground : theme.mutedForeground
    font.pixelSize: 12          // text-xs
    font.letterSpacing: 1       // tracking-widest

    QtShadcnTheme { id: theme }
}

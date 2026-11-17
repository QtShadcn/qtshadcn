// src/qml/Components/ShadcnHoverCardContent.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格 HoverCard 内容面板（issue #5）
//
// 直接**继承 ShadcnPopoverContent** —— 官方 hover-card.json 与 popover.json 的
// content 是同一套 Portal+Positioner+Popup，样式差异只有三处（从 registry 核实）：
//   w-64(256) 而不是 w-72(288)
//   没有 flex-col gap-2.5（普通块级布局，子项自己排）→ contentSpacing 归 0
//   alignOffset 默认 4 而不是 0
// rounded-lg / bg-popover / p-2.5 / text-sm / ring-1 ring-foreground/10 / shadow-md
// 与 popover 完全一致，全部继承复用，不再抄一遍。
//
// registry 的 hover-card 只导出 Root / Trigger / Content 三件（没有 Header/Title/
// Description —— 那是 Popover 的表单结构），这里保持同样的粒度。
ShadcnPopoverContent {
    panelWidth: 256        // w-64
    contentSpacing: 0      // hover-card content 不是 flex-col，没有 gap-2.5
    alignOffset: 4         // registry 默认 alignOffset = 4
}

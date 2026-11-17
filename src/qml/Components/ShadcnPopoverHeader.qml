// src/qml/Components/ShadcnPopoverHeader.qml
import QtQuick
import QtQuick.Layouts

// shadcn/ui 风格 Popover 头部：Title + Description 垂直堆叠
// 对齐 registry popover-header：flex flex-col gap-0.5 text-sm
//
// 用法:
//   ShadcnPopoverHeader {
//       ShadcnPopoverTitle { text: "标题" }
//       ShadcnPopoverDescription { text: "描述" }
//   }
// 宽度由 ShadcnPopoverContent 的 ColumnLayout 管理（Layout.fillWidth），不要自己写 width。
Column {
    id: root

    spacing: 2   // registry gap-0.5

    Layout.fillWidth: true
}

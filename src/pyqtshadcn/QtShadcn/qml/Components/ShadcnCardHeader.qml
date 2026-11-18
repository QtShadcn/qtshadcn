import QtQuick

// 卡片头部：Title + Description 垂直堆叠（对齐 shadcn: gap-1.5 / grid 布局）
// 用法:
//   ShadcnCardHeader {
//       ShadcnCardTitle { text: "标题" }
//       ShadcnCardDescription { text: "描述" }
//   }
Column {
    id: root

    spacing: 6   // shadcn: gap-1.5
    width: parent ? parent.width : implicitWidth
}

// src/qml/Components/ShadcnDropdownMenuGroup.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格菜单分组容器（M6）
// 纯语义分组，无视觉样式；视觉分隔由 ShadcnDropdownMenuSeparator 提供
// 用法:
//   ShadcnDropdownMenuGroup {
//       ShadcnDropdownMenuLabel { text: "我的账号" }
//       ShadcnDropdownMenuItem { text: "个人中心" }
//       ShadcnDropdownMenuItem { text: "设置" }
//   }
Column {
    id: root
    spacing: 2
    topPadding: 4
}

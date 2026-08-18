import QtQuick
import QtShadcn

// shadcn/ui 风格 Tabs 内容容器（与 StackLayout 配合使用）
// 用法:
//   StackLayout {
//       currentIndex: tabs.currentIndex
//       ShadcnTabsContent { /* 内容 1 */ }
//       ShadcnTabsContent { /* 内容 2 */ }
//   }
Item {
    id: root

    default property alias content: contentItem.data

    QtShadcnTheme { id: theme }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}

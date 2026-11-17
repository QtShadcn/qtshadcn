// src/qml/Components/ShadcnHoverCardTrigger.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格 HoverCard 触发项（issue #5）
//
// 官方 hover-card-trigger 是「可悬停的链接 / 按钮」，Qt 侧复用 ShadcnButton：
//   - hovered 是 AbstractButton 的**声明属性**，根组件可以直接静态绑定，
//     不需要 Tooltip 那种运行期动态属性探测（Tooltip 的宿主可能是任意 Item）；
//   - variant 默认 Link —— 官方文档的 HoverCard 触发项就是带下划线的链接。
//
// 根组件（ShadcnHoverCard）按 objectName 收集它并绑定 hovered。
ShadcnButton {
    id: root

    objectName: "trigger"
    variant: ShadcnButton.Variant.Link
}

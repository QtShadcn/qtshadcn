// ShadcnCollapsibleContent —— Collapsible 的可折叠内容区。
// 官方 registry 的 CollapsibleContent 是无样式透传（零 className）；展开动画与
// Accordion 的 Panel 完全同源（overflow-hidden + 高度 0↔自然高），本项目把这套
// 实现收进 ShadcnAccordionContent（含 clip / contentHost / 收起后不可交互），
// 这里复用而不是复制 —— 两处的动画行为永远一致。高度动画的取舍说明读
// ShadcnAccordionContent 文件头。
// 用法:
//   ShadcnCollapsible {
//       ShadcnCollapsibleTrigger { text: qsTr("筛选条件") }
//       ShadcnCollapsibleContent {
//           Text { text: "..." ; Layout.fillWidth: true }
//       }
//   }
import QtQuick
import QtShadcn

Item {
    id: root

    /// 内容色（官方 text-muted-foreground 是 CSS 继承，QML 的 Text 不吃继承，
    /// 宿主侧写 `color: content.textColor`）
    readonly property color textColor: inner.textColor
    /// 展开态（只读，来自 ShadcnCollapsible.open）
    readonly property bool expanded: inner.expanded
    /// 内部动画容器（测试/宿主取动画中间值用）
    property alias panel: inner

    default property alias content: inner.content

    width: parent !== null && parent.width > 0 ? parent.width : 240
    // 坑：Item 默认 height 不取 implicitHeight —— 外层高度跟内部动画高度走
    height: inner.height
    implicitWidth: width
    implicitHeight: height
    // 与内部动画容器一致（官方 overflow-hidden）：外层也裁剪，测试/宿主读到的
    // 就是这一层的 clip
    clip: true

    ShadcnAccordionContent {
        id: inner

        objectName: "collapsibleInnerContent"
        width: root.width
    }
}

// ShadcnCollapsibleTrigger —— Collapsible 的开合按钮。
// 官方 registry 的 CollapsibleTrigger 是无样式透传（零 className），样式写在示例里，
// 与 Accordion 的 trigger 同源 —— 本项目把这套视觉收进 ShadcnAccordionTrigger，
// 这里直接复用它（组合而不是复制代码），保证两处永远一致：
//   同一套 rounded-lg / py-2.5 / text-sm font-medium / hover:underline /
//   focus-visible ring / 双 chevron 互斥（展开态换图标，不旋转）
// 用法:
//   ShadcnCollapsible {
//       ShadcnCollapsibleTrigger { text: qsTr("筛选条件") }
//       ShadcnCollapsibleContent { ... }
//   }
// 需要自定义触发区内容时覆盖 `trigger` 的 contentItem：
//   ShadcnCollapsibleTrigger { trigger.contentItem: myRow }
import QtQuick
import QtShadcn

Item {
    id: root

    /// 触发区文本（转发给内部 AccordionTrigger）
    property alias text: inner.text
    /// 展开态（只读，来自 ShadcnCollapsible.open）
    readonly property bool expanded: inner.expanded
    /// 内部按钮（需要覆盖视觉/加图标/接 hovered 时用）
    property alias trigger: inner

    width: parent !== null && parent.width > 0 ? parent.width : inner.implicitWidth
    // 坑：Item 默认 height 不取 implicitHeight —— 外层高度必须跟内部按钮走，
    // 否则父级 Column 排出来的 y 全错
    height: inner.height
    implicitWidth: width
    implicitHeight: height

    ShadcnAccordionTrigger {
        id: inner

        objectName: "collapsibleInnerTrigger"
        // 向上认亲会跳过本包装层找到 ShadcnCollapsible（见 AccordionTrigger 的 __item），
        // 所以这里只管铺满包装层
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.width
    }
}

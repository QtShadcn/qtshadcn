// ShadcnCollapsible —— 单块可开合区域（官方 registry 里是 21 行极薄封装：
// Collapsible / CollapsibleTrigger / CollapsibleContent 三件套，全部零 className
// 透传到 Base UI 的 CollapsiblePrimitive，样式全靠调用方加）。
// Qt 侧照此实现：本文件只负责「open 状态 + 纵向排布 + 宽度下传」，
// Trigger/Content 的视觉复用 Accordion 同源实现（见那两个文件的注释），
// 官方未给出 Collapsible 的默认样式，「与 accordion 同源」是本项目采纳的假设。
//
// 用法:
//   ShadcnCollapsible {
//       width: 420
//       ShadcnCollapsibleTrigger { text: qsTr("筛选条件") }
//       ShadcnCollapsibleContent {
//           Text { text: "..." ; Layout.fillWidth: true }
//       }
//   }
// 也可以在内部套一层 ShadcnAccordionItem（想要行分隔线时），语义一样：
//   ShadcnCollapsible {
//       ShadcnAccordionItem {
//           ShadcnAccordionTrigger { text: "..." }
//           ShadcnAccordionContent { ... }
//       }
//   }
// 排布同 Accordion：Column（positioner）而不是 ColumnLayout —— Layout 会接管
// 子项 height，展开动画会被布局覆盖掉（实测坑）。
import QtQuick
import QtShadcn

Item {
    id: root

    // 子项认亲标记（等价 data-slot="collapsible"）
    readonly property bool __isShadcnCollapsible: true

    /// 展开态（受控：写入即生效，点击 trigger 同样回写）
    property bool open: false

    /// 用户开合触发
    signal toggled(bool opened)

    default property alias content: stack.data

    QtShadcnTheme {
        id: theme
    }

    // 官方 w-full：取父项宽，父项无宽度时 240 兜底
    width: parent !== null && parent.width > 0 ? parent.width : 240
    // 坑：Item 默认 height 不取 implicitHeight —— 显式写回
    height: stack.implicitHeight
    implicitWidth: 240
    implicitHeight: stack.implicitHeight

    // 行列表（内部若包了 ShadcnAccordionItem，用它判断 not-last）
    readonly property var __items: {
        var out = [];
        const kids = stack.children;
        for (var i = 0; i < kids.length; ++i) {
            const c = kids[i];
            if (c !== null && c.__isShadcnAccordionItem === true)
                out.push(c);
        }
        return out;
    }

    /// Trigger 的点击入口（与 AccordionItem._activate 同一约定）
    function _activate() {
        root._toggle();
    }

    function _toggle() {
        root.open = !root.open;
        root.toggled(root.open);
    }

    Column {
        id: stack

        width: root.width
        spacing: 0
    }
}

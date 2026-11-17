// ShadcnAccordionItem —— 手风琴单行（官方 `not-last:border-b`）。
// 一行 = 一个 Trigger + 一个 Content，声明顺序即视觉顺序：
//   ShadcnAccordionItem {
//       value: "a"
//       ShadcnAccordionTrigger { text: qsTr("Item A") }
//       ShadcnAccordionContent { Text { text: "..." ; Layout.fillWidth: true } }
//   }
// 排布用 Column（positioner）而不是 ColumnLayout：Column 只管子项 x/y，尺寸归子项
// 自己管；Layout 会接管子项 height，Content 的展开动画就被布局覆盖掉了（实测坑）。
// Column 按子项高度依次排 y，Content 的高度就是它自己正在动画的值，于是
// 「内容变高 → 本行变高 → 下一行下移」是一条单向派生链，不成环。
// 收起态 = 本行只剩 trigger（+ 分隔线）高，等价官方 Panel 的 grid-rows 0fr→1fr
// 加 overflow-hidden（外层裁剪见 ShadcnAccordionContent）。
import QtQuick
import QtShadcn

Item {
    id: root

    // 子项认亲标记（等价 data-slot="accordion-item"）
    readonly property bool __isShadcnAccordionItem: true

    // ── 公开 API ─────────────────────────────────────────
    /// 行标识：归属 ShadcnAccordion 时，展开态由根的 value 决定；留空 = 该行不可开合
    property string value: ""

    /// 展开态（只读派生，宿主勿覆盖）：
    ///   在 ShadcnAccordion 内 → 跟根的 value（单一事实来源）
    ///   在 ShadcnCollapsible 内 → 跟根的 open
    ///   都没有（单独摆一个 Item）→ 用 localExpanded，可独立开合（最小用法）
    readonly property bool expanded: __accordion !== null
        ? __accordion._isOpen(root.value)
        : __collapsible !== null
            ? __collapsible.open
            : root.localExpanded

    /// 无归属容器时的本地展开态（仅单独使用 Item 时生效）
    property bool localExpanded: false

    default property alias content: row.data

    QtShadcnTheme {
        id: theme
    }

    // 宽度由归属容器逐级下传（Qt 没有 CSS 的级联宽度）
    width: __accordion !== null ? __accordion.width
        : __collapsible !== null ? __collapsible.width : 240
    // 坑：Item 默认 height 不取 implicitHeight —— 显式写回。
    // 分隔线在 Column 之外（锚行底），所以行高要手工加上可见的那 1px
    height: row.implicitHeight + (separator.visible ? separator.height : 0)
    implicitWidth: 240
    implicitHeight: height

    // 最近归属容器（property var 存指针：qmllint 因此不校验成员，运行时是真实
    // QObject，绑定照常建立依赖 —— 同 ShadcnFieldLabel 的 __fieldOwner 手法）
    property var __accordion: {
        var o = root.parent;
        while (o !== null && !("__isShadcnAccordion" in o))
            o = o.parent;
        return o;
    }
    property var __collapsible: {
        var o = root.parent;
        while (o !== null && !("__isShadcnCollapsible" in o))
            o = o.parent;
        return o;
    }

    /// Trigger 的点击入口：有归属容器就交给容器（value / open 是唯一事实来源），
    /// 否则翻本地态
    function _activate() {
        if (__accordion !== null)
            __accordion._toggle(root.value);
        else if (__collapsible !== null)
            __collapsible._toggle();
        else
            root.localExpanded = !root.localExpanded;
    }

    // 官方 `not-last`：归属容器的最后一项不画分隔线
    readonly property bool __isLast: {
        var a = root.__accordion;
        if (a !== null) {
            var list = a.__items;
            return list.length > 0 && list[list.length - 1] === root;
        }
        var c = root.__collapsible;
        if (c !== null) {
            var clist = c.__items;
            return clist.length > 0 && clist[clist.length - 1] === root;
        }
        // 无归属容器：单行即末行
        return true;
    }

    Column {
        id: row

        // 坑：分隔线不能塞进这个 Column —— Column 的 data 就是本组件的 default
        // 属性，声明顺序会变成「分隔线 → trigger → content」，线跑到行顶。
        width: root.width
        y: 0
        spacing: 0
    }

    // 官方 not-last:border-b —— 行底 1px theme.border；末行 visible:false。
    // 用 visible 而不是 height:0（测试分别断言 separator.visible 与 height），
    // 且 Column 之外这根线不占行高以外的空间：行高公式里加了它。
    Rectangle {
        id: separator

        objectName: "separator"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: theme.border
        visible: !root.__isLast
    }
}

// ShadcnAccordion —— 手风琴根容器（官方 `flex w-full flex-col`：纵向列、零自绘样式，
// 分隔线全在 Item 上）。语义对齐 base-ui Accordion.Root：
//   - multiple: false（默认）单选：点另一项自动收起前项
//   - multiple: true          多选：value 为 string[]
//   - collapsible: false（默认）单选时点已展开项**不**收起（至少保持一项展开）
//   - collapsible: true       单选时点已展开项可收起（可全收）
//   - value                   受控值：单选 string / 多选 string[]；默认 [] = 全收起
// 用法:
//   ShadcnAccordion {
//       width: 420
//       ShadcnAccordionItem {
//           value: "a"
//           ShadcnAccordionTrigger { text: qsTr("Item A") }
//           ShadcnAccordionContent {
//               Text { text: "..." ; Layout.fillWidth: true; color: theme.mutedForeground }
//           }
//       }
//   }
// 注意:
//   - 一行 = 一个 Trigger + 一个 Content（官方 Panel 也是单个）。
//   - **Item 内不要用 Repeater**：异步创建打乱视觉顺序。动态行在宿主侧声明或用 Loader。
//   - value 两向同步：宿主写入即生效，用户点击同样回写本属性（可绑外部状态）。
//   - 移除已展开的行后请把 value 写回不含该值的集合（根不监听子项增删，免得读
//     子项属性形成依赖环）。
//   - 排布用 Column（positioner）而不是 ColumnLayout：Column 只写子项 x/y、height
//     归子项自己管；Layout 会接管子项 height，展开动画会被布局覆盖掉（实测坑）。
//   - 官方 `w-full` 在 Qt 没有级联宽度：纵向链路上每层都 width: parent.width，
//     宿主给 ShadcnAccordion 一个宽度即可（放进 ColumnLayout 时用 Layout.fillWidth）。
import QtQuick
import QtShadcn

Item {
    id: root

    // 子项认亲标记（等价 data-slot="accordion"）
    readonly property bool __isShadcnAccordion: true

    // ── 公开 API ─────────────────────────────────────────
    property bool multiple: false
    property bool collapsible: false
    // 默认 "" = 全收起。单选时是 string，多选时是 string[]；多选读到非数组按 [] 处理，
    // 所以初始不区分两种模式都能正确判空
    property var value: ""

    /// 用户开合触发（v = 行 value；opened = true 展开 / false 收起）
    signal toggled(string value, bool opened)

    default property alias content: stack.data

    QtShadcnTheme {
        id: theme
    }

    // 官方 w-full 在 Qt 没有级联宽度：取父项宽，父项无宽度时 240 兜底
    // （放进 ColumnLayout 时给本组件 Layout.fillWidth / Layout.preferredWidth）
    width: parent !== null && parent.width > 0 ? parent.width : 240
    // 坑：Item 默认 height 不取 implicitHeight —— 显式写回，否则整体塌成 0
    height: stack.implicitHeight
    implicitWidth: 240
    implicitHeight: stack.implicitHeight

    // 行列表（Item 判断 not-last 用）。依赖 stack.childrenChanged：增删行即重算
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

    function _isOpen(v) {
        if (v === undefined || v === null || v === "")
            return false;
        if (root.multiple) {
            const arr = Array.isArray(root.value) ? root.value : [];
            return arr.indexOf(v) >= 0;
        }
        return root.value === v;
    }

    // 唯一切换入口（由 Item 转发）。单选/多选 + collapsible 语义集中在这里。
    function _toggle(v) {
        if (v === undefined || v === null || v === "")
            return;
        // collapsible=false + 单选：点已展开项 = 无事发生（base-ui 默认语义）
        if (!root.multiple && !root.collapsible && root.value === v)
            return;
        if (!root.multiple) {
            // 单选：value 只有 ""（全收）与该行 v 两种取值，天然互斥，
            // 不用遍历收起其它行 —— 其它行的 expanded 由这里派生
            root.value = root.value === v ? "" : v;
        } else {
            const arr = Array.isArray(root.value) ? root.value.slice() : [];
            const idx = arr.indexOf(v);
            if (idx >= 0)
                arr.splice(idx, 1);
            else
                arr.push(v);
            root.value = arr;
        }
        root.toggled(v, root._isOpen(v));
    }

    Column {
        id: stack

        width: root.width
        spacing: 0
    }
}

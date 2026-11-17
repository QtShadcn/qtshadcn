pragma ComponentBehavior: Bound

import QtQuick

// ShadcnCommandColumn —— Command 家族的可重排内容列
//
// ── 为什么不用 QQC Column / Layouts.Column ─────────────────────────
// cmdk 的过滤不是「把不匹配项藏起来」就完事，还要**按匹配分数重排**
// （输入 "new" 时 "New file" 要排到 "Review PR" 前面）。Web 侧靠 appendChild
// 移动 DOM 节点，Qt 侧这条路不通 —— 探针实测：
//   · `item.parent = item.parent`（同父重新赋值）在 QQuickItem::setParent 里
//     直接 return，**是空操作**，顺序动不了；
//   · 跨父赋值虽然有效（等价 appendChild），但会把 item ↔ Command 的注册链和
//     `width: parent.width` 一起打断，代价太大（重排一次就得重挂一次所有绑定）。
// 而 Column / Layouts.Column 会在任何子项变化时按 **children 声明顺序**重算
// 全部 y，把手工赋值冲掉。
//
// 结论：容器必须是「不接管几何」的裸 Item，顺序由这里自己赋 x / y。
// 这里不声明 default property —— Item 自带的 `data` 就是默认属性，子项天然
// 父化到本列、`children` 实时可遍历。（探针实测：改用 `property list<Item>`
// 收子项的话 children 恒为 0，**子项不会被父化，整块内容不渲染** —— 所以
// 注册表那种「只收集不渲染」的列表用 JS 数组，绝不用 list<>。）
//
// ── 高度用声明式求和，不用命令式累加 ─────────────────────────────
// 探针实测 `childrenRect.height` **包含不可见子项**（隐藏项照旧计高），
// Column.implicitHeight 才排除。裸 Item 两个都不能直接用，所以把
// 「可见子项高度求和」写成绑定：读 children + 每项 visible + 每项 height，
// 三个 notify 都会让它重算。
// 命令式累加就必须保证「每次子项高度变化都重跑」，漏一处即「过滤掉了但面板
// 不缩短」，而且命令式代码不可能在条目文字换行变高时自己醒来。
//
// 依赖严格单向，不成环（DialogContent 的 contentWidth 链式循环是同类问题）：
//   item.height（常量/文本）→ 本列 implicitHeight → CommandList height(≤288)
//     → 外层列 implicitHeight → Command implicitHeight
// 本列从不把自己的高度赋给子项，只碰子项的 x / y。
Item {
    id: root

    /// 子项间距（cmdk 的 group-items 无间距 → 0）
    property int spacing: 0

    /// 当前顺序（Command 打分后传入；null/空 = 按 children 声明顺序）
    property var order: null

    /// 所属 Command（由外壳注入）。不在场时本列按声明顺序自排；
    /// 在场时把「子项增删」上报给 Command，由它统一打分重排 ——
    /// 这样动态往里塞 CommandItem / CommandGroup 会自动参与过滤。
    property var command: null

    // ⚠ implicitWidth 一律**不**从 children 反推 —— 与 ShadcnDialogContent 同一条
    //   纪律（「不能在此绑定 implicitWidth」）。本族的宽度自上而下给
    //   （Dialog / Popup / 页面定宽），若让 implicitWidth 读子项宽，而子项又写
    //   `width: parent.width` / `implicitWidth: parent.width + 8`，就是
    //   「列宽 ← 子宽 ← 列宽」的绑定循环（实测 QML 直接报
    //   Binding loop detected for property "implicitWidth"）。
    implicitWidth: 240
    implicitHeight: root._flowTick

    width: parent ? parent.width : implicitWidth

    // ── 唯一的布局触发器 ────────────────────────────────────────
    // 读遍每个子项的 visible + height，把三种变化（增删 / 显隐 / 高度变化）
    // 全转成一个数字。它同时是 implicitHeight（可见项高度之和）与
    // 「该重排了」的信号 —— 不需要外部记得调用 relayout。
    // 绑定里读 `root.children` 会把 childrenChanged 也纳入依赖，动态加条目同样生效。
    readonly property real _flowTick: {
        var kids = root.children;
        var h = 0;
        var first = true;
        for (var i = 0; i < kids.length; ++i) {
            var c = kids[i];
            if (!root._layoutable(c) || c.visible === false)
                continue;
            h += c.height + (first ? 0 : root.spacing);
            first = false;
        }
        return h;
    }

    // 位置在下一帧赋：childrenChanged 触发时新子项的 height 常常还是 0
    // （它的 implicitHeight 尚未求值），同帧赋值会少算一段。
    on_FlowTickChanged: Qt.callLater(root.apply)
    onChildrenChanged: {
        if (root.command && typeof root.command.refresh === "function")
            root.command.refresh();
        else
            Qt.callLater(root.apply);
    }
    onOrderChanged: Qt.callLater(root.apply)

    /// 设置顺序并立刻排布（units 传 null = 声明顺序）
    function relayout(units) {
        root.order = units;
        return root.apply();
    }

    /// 按 root.order 赋 x / y，返回内容总高
    function apply() {
        var list = (root.order && root.order.length > 0) ? root.order : root.children;
        var y = 0;
        var first = true;
        for (var i = 0; i < list.length; ++i) {
            var u = list[i];
            if (!root._layoutable(u) || u.visible === false)
                continue;
            // x 尊重子项自报的 _layoutX（CommandSeparator 用 -4 复刻 CSS 的 -mx-1）
            u.x = (u._layoutX !== undefined) ? u._layoutX : 0;
            u.y = y;
            y += u.height + (first ? 0 : root.spacing);
            first = false;
        }
        return y;
    }

    // 只有 Item 派生才能摆位置；用户往里塞 QtObject / 字符串时不炸
    function _layoutable(c) {
        return c !== null && c !== undefined && c.x !== undefined;
    }

}

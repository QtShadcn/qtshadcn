pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui 风格 Command（⌘K 命令面板）根容器 —— issue #5
//
// 官方实现是 cmdk（`CommandPrimitive`）的薄封装；Qt 没有对应运行时，所以这里
// 按语义移植 cmdk 的三件核心事：
//   1) 声明式子项 + 过滤 + 按分数重排 —— 本文件 + CommandItem / CommandGroup /
//      ShadcnCommandColumn
//   2) 模糊匹配打分                   —— C++ CommandFilter（cmdk commandScore 移植）
//   3) 键盘导航                        —— 本文件的 Keys.*
//
// ── 结构（对齐官方 DOM）──────────────────────────────────────────
//   Command                 bg-popover rounded-xl p-1（本组件）
//   ├── CommandInput        搜索框（InputGroup 皮肤 + search 图标）
//   └── CommandList         纵向滚动，max-h-72(288)
//       ├── CommandEmpty    无匹配且有输入时显示
//       ├── CommandGroup    heading + items，p-1
//       └── CommandSeparator  搜索时隐藏（cmdk 只在 !search 时渲染）
//
// ── 设计决策 A：声明式子项，而不是 model 驱动 ────────────────────
// cmdk 的语义是「写在哪就在哪」：Group 包 Item、Item 里再套 Shortcut / 图标 /
// 任意自定义内容；过滤 = 隐藏不匹配项 + 按匹配分数重排。这套组合语义正是组件的
// 灵魂，model 化（items: [{value,label,group}]）会整个丢掉它 —— 退化成「一个带
// 搜索框的 ListView」：丢掉嵌套分组、丢掉自定义内容、丢掉与官方一致的写法。
//
// 反直觉的地方是：**过滤在声明式下反而更好实现，也更难写错**。Web 侧靠 appendChild
// 移动节点，Qt 侧这条路不通（探针实测 `item.parent = item.parent` 是空操作，跨父
// 赋值又会打断 item ↔ Command 的 parent 链），而 Column 会按 children 声明顺序
// 重算全部 y、把手工赋值冲掉。所以顺序由 ShadcnCommandColumn 自己赋 y，
// 「排序数组 → 逐个赋 y」一次线性遍历，比维护 model 索引 ↔ delegate 索引的
// 映射表短得多。
//
// ── ⌘K 全局快捷键的边界 ─────────────────────────────────────────
// 组件**不管全局键**，cmdk 自己也不管（官方 README 是在应用层 useKeybinding 里
// setOpen(true)）。Qt 侧由宿主在 Window 里挂：
//     Shortcut { sequence: "Ctrl+K"; onActivated: palette.open() }
// 组件内部抢全局键的话，同一窗口放不下两个面板，宿主也没法换键位（macOS 上
// ⌘K 常被编辑器的「删除行」占用）。CommandPage.qml 演示了这个写法。
//
// 用法（独立面板，不套 Dialog）:
//   ShadcnCommand {
//       ShadcnCommandInput {}
//       ShadcnCommandList {
//           ShadcnCommandEmpty { text: "无匹配结果" }
//           ShadcnCommandGroup {
//               heading: "建议"
//               ShadcnCommandItem { text: "新建文件"; shortcut: "⌘N" }
//           }
//       }
//   }
Item {
    id: root

    // ── 对外 API（对齐 cmdk 的 CommandRoot props）────────────────
    /// 当前搜索词。ShadcnCommandInput 与之双向同步；不用输入框也能自己驱动。
    property string search: ""
    /// 键盘/指针选中项的 value（cmdk 的 value）。无选中项时为空串。
    readonly property string value: root._activeItem ? root._activeItem._matchValue : ""
    /// 匹配到的条目数（ShadcnCommandEmpty 据此显示）
    readonly property int matchCount: root._matchedCount
    /// 当前选中的条目对象（可能为 null）
    readonly property alias activeItem: root._activeItem
    /// 选中项变化（cmdk 的 onValueChange 回调）。
    /// ⚠ 不能叫 valueChanged —— 那会与 readonly property string value 自己的
    ///   属性变化信号重名，QML 编译报 "Duplicate signal name: invalid override"
    ///   （实测）。cmdk 那边是 onValueChange prop，不是 React 信号，语义无冲突。
    signal selectedValueChanged(string value)
    /// Enter 命中 / 点击当前项。参数是被执行条目的 value。
    signal activated(string value)

    /// 关掉过滤（cmdk 的 shouldFilter=false）：全部匹配，只按声明顺序排
    property bool shouldFilter: true
    /// 自定义打分函数 function(value, search, keywords) → number（>0 视为匹配）。
    /// 留空用 C++ CommandFilter。
    property var filter: null
    /// 首项 ↔ 末项之间循环（cmdk 的 loop，默认关：到头停住）
    property bool loop: false
    /// 内嵌在 Dialog 里（ShadcnCommandDialog 置位）。官方条目在 dialog-content 内
    /// 圆角升一档 rounded-sm → rounded-lg，下发给每个 CommandItem。
    property bool inDialog: false

    // ── 内部注册表 ─────────────────────────────────────────────
    // cmdk 靠 MutationObserver 遍历 DOM；Qt 侧没有 DOM，改成子项主动注册。
    // 数组**只用于打分遍历**；「谁属于哪个容器、声明顺序如何」一律以
    // 列的 children 为准遍历（见 _units），这样注册先后（Component.onCompleted
    // 的父子完成顺序不保证）不会影响视觉顺序 —— 顺序的唯一来源是声明顺序。
    property var _items: []
    property var _groups: []
    property var _empties: []
    property var _separators: []
    /// 承载条目列的容器（ShadcnCommandList 注册进来）
    property ShadcnCommandColumn listColumn: null
    /// 面板本体（ShadcnCommandList 注册进来）—— 滚动选中项要调它的 scrollToItem
    property ShadcnCommandList commandList: null
    /// 搜索框内部 TextField（ShadcnCommandInput 注册进来）
    property Item inputField: null
    /// 打开面板时要聚焦的对象（Popup/Dialog 的 onOpened 调 focusInput()）
    property var _focusTarget: null

    property ShadcnCommandItem _activeItem: null
    property int _matchedCount: 0
    /// 键盘导航用的「可见 + 可用」条目数组（下标 = 视觉顺序）
    property var _nav: []
    /// 合并标志：启动期每个子项注册都会请求重算，一帧内只真跑一次
    property bool _pending: false

    implicitWidth: 360
    // 面板高 = 内容列高 + p-1 上下（4×2）。列高是「可见子项高度求和」的绑定，
    // 探针实测 childrenRect 包含不可见子项，用错就会「过滤掉了但面板不缩短」。
    implicitHeight: innerColumn.implicitHeight + 8

    /// 子项（CommandInput / CommandList）进入内部列。
    /// 本文件正文声明的 Rectangle / Column 不受这条别名影响 —— 别名只作用于
    /// **外部实例化时**写的子项（探针实测确认，与 ShadcnDialogContent 同构）。
    default property alias commandChildren: innerColumn.data

    QtShadcnTheme { id: theme }

    // bg-popover + rounded-xl（官方 flex flex-col overflow-hidden rounded-xl! p-1）
    Rectangle {
        anchors.fill: parent
        radius: theme.radiusXl
        color: theme.popover
    }

    ShadcnCommandColumn {
        id: innerColumn
        objectName: "commandColumn"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 4   // p-1
        spacing: 0
    }

    // ── 过滤 + 重排 ────────────────────────────────────────────
    // 只有一个触发点：search 变化（输入每个字符 = 一次全量重算）。
    // 复杂度 O(n log n)：一遍打分 + 一遍稳定插入排序 + 两遍线性赋坐标。
    // 绝不在 delegate 里各自遍历全体条目（那是 O(n²)），也不把高度写成
    // 相互引用的链式绑定（仓库历史教训：DialogContent 的 contentWidth 循环）。
    // 搜索每个字符都会走到这里。真正的重算排在下一帧：注册期可能有十几次
    // 请求（每个子项的 onCompleted 各一次），合并成一次，避免 O(n) 次全量重排。
    onSearchChanged: root._schedule()

    // 面板从「隐藏」变「可见」时必须重算一次。
    // 场景：Command 装在 Popup / Dialog 里，未打开时整棵子树的 visible 都是
    // false，_recompute 建出来的导航表 _nav 是空的；打开后若没人再算一次，
    // ↑↓ 就永远没有候选（实测：独立用没事，Dialog 模式一打开就复现）。
    // 宿主即使已经调了 refresh()，_schedule 的合并标志也不会让它重复跑。
    onVisibleChanged: root._schedule()

    Component.onCompleted: root._schedule()

    /// 强制重算（外部改条目 value / 动态增删条目后可调；正常路径不需要手动调）
    function refresh() {
        root._schedule();
    }

    function _schedule() {
        if (root._pending)
            return;
        root._pending = true;
        Qt.callLater(root._recompute);
    }

    function _score(value, keywords) {
        if (!root.shouldFilter || root.search === "")
            return 1.0;
        if (root.filter)
            return root.filter(value, root.search, keywords);
        return CommandFilter.score(value, root.search, root._keywordList(keywords));
    }

    // keywords 允许写成 JS 数组或单个字符串
    function _keywordList(kw) {
        if (kw === undefined || kw === null)
            return [];
        if (Array.isArray(kw))
            return kw;
        return [String(kw)];
    }

    function _recompute() {
        var i;
        root._pending = false;

        // 1) 逐条打分（空查询 / 关过滤 → 全部 1.0，等于保持声明顺序）
        var items = root._items;
        for (i = 0; i < items.length; ++i) {
            var it = items[i];
            it._score = root._score(it._matchValue, it.keywords);
            it._match = (it._score > 0);
        }

        // 2) Separator：搜索时隐藏（cmdk 只在 !search 时渲染 separator）
        for (i = 0; i < root._separators.length; ++i)
            root._separators[i]._match = (root.search === "");

        // 3) 分组：组分数 = 组内最高分；组内一个都不匹配 → 整组隐藏
        //    （cmdk 的 filtered.groups；组标题随之消失，不是留个光杆标题）
        root._matchedCount = root._countMatches();
        var groups = root._childUnits(root.listColumn);
        // 组 → 排好序的组内条目。**必须用平行数组**：QML Item 当 JS 对象 key
        // 会被 toString 折叠成同一个字符串键，多个组互相覆盖（实测踩到）
        var orderedGroups = [];
        var groupPlans = [];
        for (i = 0; i < groups.length; ++i) {
            var g = groups[i];
            if (g._isCommandGroup !== true)
                continue;
            var members = root._childItems(g.column);
            var best = 0.0;
            for (var j = 0; j < members.length; ++j) {
                if (members[j]._match && members[j]._score > best)
                    best = members[j]._score;
            }
            g._score = best;
            g._match = (best > 0);
            var orderedMembers = root._ordered(members);
            g.column.relayout(orderedMembers);
            groupPlans.push(orderedMembers);
            orderedGroups.push(g);
        }

        // 4) Empty：匹配数 0 **且有输入**才显示
        for (i = 0; i < root._empties.length; ++i)
            root._empties[i]._match = (root._matchedCount === 0 && root.search !== "");

        // 5) 列表级重排：组 + 散落条目 + Empty + Separator 一起按分数排
        var units = root._childUnits(root.listColumn);
        var orderedUnits = root._ordered(units);
        if (root.listColumn)
            root.listColumn.relayout(orderedUnits);

        // 6) 键盘导航表（严格按排序后的视觉顺序）
        var nav = [];
        for (i = 0; i < orderedUnits.length; ++i) {
            var u = orderedUnits[i];
            if (u === null || u === undefined || u.visible === false)
                continue;
            var gi = orderedGroups.indexOf(u);
            if (gi >= 0) {
                var mm = groupPlans[gi];
                for (var k = 0; k < mm.length; ++k) {
                    if (mm[k].visible && mm[k].enabled)
                        nav.push(mm[k]);
                }
            } else if (u._isCommandItem === true && u.visible && u.enabled) {
                nav.push(u);
            }
        }
        root._nav = nav;

        // 7) 选中项兜底（可能被过滤掉了）
        root._fixupActive();

        // 8) 外层列排布（Input / List）。List 的高度由它自己的绑定给出，
        //    这里不反向赋值，避免「列高 ← 内容高 ← 列高」的环。
        innerColumn.relayout(null);
    }

    function _countMatches() {
        var n = 0;
        for (var i = 0; i < root._items.length; ++i) {
            if (root._items[i]._match)
                ++n;
        }
        return n;
    }

    // 某列里「参与排序的单元」：分组 / 散落条目 / Empty / Separator。
    // 以 children 为准 → 顺序 = 声明顺序，且与注册先后无关。
    function _childUnits(col) {
        var out = [];
        if (!col)
            return out;
        var kids = col.children;
        for (var i = 0; i < kids.length; ++i) {
            var c = kids[i];
            if (c._isCommandGroup === true || c._isCommandItem === true
                    || c._isCommandEmpty === true || c._isCommandSeparator === true)
                out.push(c);
        }
        return out;
    }

    // 某列里的全部条目
    function _childItems(col) {
        var out = [];
        if (!col)
            return out;
        var kids = col.children;
        for (var i = 0; i < kids.length; ++i) {
            if (kids[i]._isCommandItem === true)
                out.push(kids[i]);
        }
        return out;
    }

    // 稳定排序：有搜索词时按分数降序，否则按声明顺序（数组下标即声明顺序）。
    // 插入排序（命令面板量级是十几到几十条），同分保持原序 —— 与 cmdk
    // 「按分数 appendChild、同分维持原序」等价。
    function _ordered(list) {
        var out = list.slice();
        var byScore = (root.search !== "" && root.shouldFilter);
        if (!byScore)
            return out;
        for (var i = 1; i < out.length; ++i) {
            var cur = out[i];
            var j = i - 1;
            while (j >= 0 && out[j]._score < cur._score) {
                out[j + 1] = out[j];
                --j;
            }
            out[j + 1] = cur;
        }
        return out;
    }

    // ── 选中态 / 键盘导航 ─────────────────────────────────────
    // 索引映射方案：不维护「可见索引 ↔ 条目」双向表，每次重算生成一个**按视觉
    // 顺序排好的数组 _nav**（只含可见 + 可用条目）。↑↓ 就是在这个数组里走下标：
    // 隐藏项 / 禁用项天然不在表里，打分重排改了顺序也不会错位。
    // （cmdk 同理 —— 它的 getItem() 也是现取「非 disabled 的条目列表」。）
    function setActive(item) {
        if (!item || item === root._activeItem)
            return;
        root._activeItem = item;
        root._syncSelected();
        root.selectedValueChanged(root.value);
        root._scrollIntoView(item);
    }

    function _syncSelected() {
        var items = root._items;
        for (var i = 0; i < items.length; ++i)
            items[i]._isSelected = (items[i] === root._activeItem);
    }

    // 选中项被过滤掉 / 变禁用 → 落到第一个可见可用项（cmdk 的 selectFirstItem）
    function _fixupActive() {
        if (root._nav.indexOf(root._activeItem) >= 0) {
            root._syncSelected();
            return;
        }
        root._activeItem = root._nav.length > 0 ? root._nav[0] : null;
        root._syncSelected();
        root.selectedValueChanged(root.value);
    }

    /// ↑/↓。dir = +1 下、-1 上。跳过隐藏与禁用项。
    function moveActive(dir) {
        var nav = root._nav;
        if (nav.length === 0)
            return;
        var at = nav.indexOf(root._activeItem);
        if (at < 0) {
            root.setActive(nav[0]);
            return;
        }
        var next = nav[at + dir];
        if (next === undefined) {
            if (!root.loop)
                return;                 // 到头停住（cmdk 默认不 loop）
            next = nav[(at + dir + nav.length) % nav.length];
        }
        root.setActive(next);
    }

    /// Home / End
    function setActiveIndex(i) {
        var nav = root._nav;
        if (nav.length === 0)
            return;
        var idx = (i < 0) ? 0 : (i >= nav.length ? nav.length - 1 : i);
        root.setActive(nav[idx]);
    }

    /// Enter：执行当前选中项。禁用项不执行（cmdk 只给非禁用项挂 onSelect）。
    function activateCurrent() {
        var a = root._activeItem;
        if (!a || !a.enabled || !a._match)
            return false;
        if (a.activateFromKeyboard()) {
            root.activated(a._matchValue);
            return true;
        }
        return false;
    }

    /// 清空搜索词（常用于每次打开面板时重置）。
    /// 只写 search：输入框那边的 Connections 会把它同步过去。
    function clearSearch() {
        root.search = "";
    }

    /// 打开面板时把焦点交给搜索框（官方 autofocus）
    function focusInput() {
        if (root._focusTarget && typeof root._focusTarget.focusSearch === "function")
            root._focusTarget.focusSearch();
        else if (root.inputField)
            root.inputField.forceActiveFocus();
    }

    /// 供 ShadcnCommandList 的 scrollToItem 转发（选中项移出视口时滚过去）
    function _scrollIntoView(item) {
        // 注意是 commandList（ShadcnCommandList 自己实现的方法），不是它的父项
        // Flickable —— 后者只有 scrollToContent，写错就是静默不滚动（实测踩过）。
        if (root.commandList)
            root.commandList.scrollToItem(item);
    }

    // ── 键盘导航 ──────────────────────────────────────────────
    // 焦点始终留在搜索框里（cmdk 的手感：继续打字 = 继续过滤，方向键 = 移动选中项）。
    // Qt 的按键路由是「焦点项 → 祖先链」，**焦点项自己没有该键 handler 时祖先的
    // Keys handler 会收到**（探针实测：TextField 持有焦点时祖先收到 Down/Up/
    // Return/Escape）；若用户自己在条目上写了 Keys.onDownPressed，则由它接管
    // （子级优先）。所以挂在 Command 根上：既能穿透内部 TextField，又不跟自定义
    // 内容抢键。Tab 不拦（焦点照常移出 = 「Tab 不进列表」）。
    Keys.enabled: true
    Keys.onDownPressed: function(event) {
        event.accepted = true;
        root.moveActive(1);
    }
    Keys.onUpPressed: function(event) {
        event.accepted = true;
        root.moveActive(-1);
    }
    Keys.onReturnPressed: function(event) {
        event.accepted = true;
        root.activateCurrent();
    }
    Keys.onEnterPressed: function(event) {
        event.accepted = true;
        root.activateCurrent();
    }
    // ⚠ Home / End / PageUp / PageDown **没有** Keys.onXxxPressed 便捷 handler
    //   （Keys 附加类型只列了 38 个：down/up/left/right/return/enter/escape/tab/
    //   space/delete/menu… —— 实测 qmltypes 里搜不到 pageUpPressed / homePressed）。
    //   统一走 onPressed 按 key 码分派，缺一个分支就是死键。
    Keys.onPressed: function(event) {
        switch (event.key) {
        case Qt.Key_Home:
            event.accepted = true;
            root.setActiveIndex(0);
            return;
        case Qt.Key_End:
            event.accepted = true;
            root.setActiveIndex(root._nav.length - 1);
            return;
        case Qt.Key_PageDown:
            event.accepted = true;
            root.moveActive(5);
            return;
        case Qt.Key_PageUp:
            event.accepted = true;
            root.moveActive(-5);
            return;
        }
        // Ctrl+N / Ctrl+J / Ctrl+P —— cmdk 的 vim 键位
        // （Ctrl+K 留给宿主做全局开关：组件不抢 ⌘K，见文件头「边界」一节）
        if (!(event.modifiers & Qt.ControlModifier))
            return;
        if (event.key === Qt.Key_N || event.key === Qt.Key_J) {
            event.accepted = true;
            root.moveActive(1);
        } else if (event.key === Qt.Key_P) {
            event.accepted = true;
            root.moveActive(-1);
        }
    }

    // ── 子项注册接口（只维护「打分要遍历谁」，不管顺序）────────
    function registerItem(item) {
        if (root._items.indexOf(item) < 0)
            root._items.push(item);
        root._schedule();
    }

    function unregisterItem(item) {
        var i = root._items.indexOf(item);
        if (i >= 0)
            root._items.splice(i, 1);
        if (root._activeItem === item)
            root._activeItem = null;
        root._schedule();
    }

    function registerEmpty(e) {
        if (root._empties.indexOf(e) < 0)
            root._empties.push(e);
        root._schedule();
    }

    function unregisterEmpty(e) {
        var i = root._empties.indexOf(e);
        if (i >= 0)
            root._empties.splice(i, 1);
        root._schedule();
    }

    function registerSeparator(s) {
        if (root._separators.indexOf(s) < 0)
            root._separators.push(s);
        root._schedule();
    }

    function unregisterSeparator(s) {
        var i = root._separators.indexOf(s);
        if (i >= 0)
            root._separators.splice(i, 1);
        root._schedule();
    }

    // 分组：注册只是为了「脱离列表列的组」也能被重算扫到；
    // 顺序仍以 listColumn 的 children 为准（见 _childUnits）。
    function registerGroup(g) {
        if (root._groups.indexOf(g) < 0)
            root._schedule();
    }

    function unregisterGroup(g) {
        var i = root._groups.indexOf(g);
        if (i >= 0)
            root._groups.splice(i, 1);
        root._schedule();
    }

    function registerList(col, list) {
        root.listColumn = col;
        root.commandList = list !== undefined ? list : null;
        root._schedule();
    }

    function registerInput(field, focusTarget) {
        root.inputField = field;
        root._focusTarget = focusTarget;
    }
}

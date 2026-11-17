pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui CommandItem —— 命令面板里的一个可选项
//
// 对齐 registry 的 CommandItem：
//   flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm select-none
//   data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground
//   data-[disabled=true]:pointer-events-none + opacity-50
//   [&_svg:not([class*='size-'])]:size-4              → 图标 16px
//   in-data-[slot=dialog-content]:rounded-lg!         → 内嵌 Dialog 时圆角升一档
//   尾部内置 check：有 CommandShortcut 子项时隐藏，checked 时显示
//
// ── 设计决策 A：声明式子项 ──────────────────────────────────────
// 用户写进来的子项就是这个项的视觉内容（Text / 图标 / CommandShortcut）。
// 过滤时本项只做一件事：`visible` 跟着 `_match` 走。顺序与 y 坐标由
// ShadcnCommandColumn 按分数统一赋值 —— Qt 不能像 DOM 那样移动节点，
// 原因和替代方案写在那个文件的头部注释里。
//
// 用法:
//   ShadcnCommandItem { text: "新建文件"; shortcut: "⌘N"; iconName: "file-plus" }
//   ShadcnCommandItem {
//       value: "theme"
//       keywords: ["dark", "外观"]
//       Text { text: "切换主题"; font.pixelSize: 14 }
//       ShadcnCommandShortcut { text: "⌘⇧T" }
//       onActivated: ThemeManager.toggle()
//   }
Item {
    id: root

    // ── 对外 API ──────────────────────────────────────────────
    /// 参与过滤的文本。留空时依次回退到 text → 子项文本
    /// （cmdk 的 value 缺省就是取 children 的 textContent）。
    property string value: ""
    /// 主标签（最常用写法）。留空则不渲染内置标签，内容完全交给子项。
    property string text: ""
    /// 快捷键提示（等价于再写一个 ShadcnCommandShortcut 子项）
    property string shortcut: ""
    /// lucide 图标名，画在左侧 size-4(16px)。留空不显示。
    property string iconName: ""
    /// 附加关键词：不显示、只参与匹配（cmdk 的 keywords）。
    /// 例：{ text: "主题", keywords: ["theme", "dark"] }，输入 theme 也命中。
    property var keywords: []
    /// 危险操作（删除等）：文字走 destructive 色
    property bool destructive: false
    /// 选中态打勾（cmdk 的 data-checked），开关类条目用
    property bool checked: false
    /// 当前是否被键盘/指针选中（由所属 ShadcnCommand 维护）
    readonly property bool selected: root._isSelected
    /// 是否被当前查询匹配（由所属 ShadcnCommand 维护）。
    /// ⚠ 自己写 `visible:` 会覆盖这条内部绑定 —— 那是 Qt 的属性覆盖语义，
    ///   表示该项显隐由你自己负责、不再参与过滤。需要额外条件时写
    ///   `visible: matched && 你的条件`。
    readonly property bool matched: root._match
    /// Enter 命中 / 点击本项（cmdk 的 onSelect）。禁用项不会发出。
    signal activated()

    /// 用户声明的子项。别名指向内容行的 data：**这样写进来的子项才真会被
    /// 父化并渲染**（`list<Item>` 只收对象不父化，自定义内容会整块消失）。
    /// CommandShortcut 例外：本组件把它搬到右侧插槽 —— Qt 没有 Web 的 slot
    /// 投射机制，只能显式 relocation；视觉结果与官方 `ml-auto` 一致。
    default property alias itemChildren: contentRow.data

    // ── 内部状态（由所属 ShadcnCommand 驱动，不要在外部赋值）─────
    property bool _match: true
    property bool _isSelected: false
    property real _score: 1.0
    /// 供 Command 认「这是条目」（鸭子类型：类型判断会形成循环 import）
    readonly property bool _isCommandItem: true
    /// 所属 Command
    property var command: null
    /// 声明时所在的列（重排据此判断该回到哪个容器）

    implicitWidth: 240
    // py-1.5(6) ×2 + text-sm 行高 20 = 32
    implicitHeight: 32
    // 铺满所属列（条目宽度由容器给，与官方 flex 项一致）
    width: parent ? parent.width : implicitWidth
    // 过滤不匹配 → 隐藏
    visible: root._match

    QtShadcnTheme { id: theme }

    readonly property int _padX: 8     // px-2
    readonly property int _gap: 8      // gap-2

    // rounded-sm；Command 内嵌 Dialog 时 rounded-lg
    // （官方 in-data-[slot=dialog-content]:rounded-lg!）
    readonly property int _radius: root.inDialog ? theme.radiusLg : theme.radiusSm
    /// 由 Command / CommandDialog 下发（对齐官方的 data-slot 上下文感知）
    property bool inDialog: root.command ? root.command.inDialog : false

    // 真正参与匹配的文本
    readonly property string _matchValue: {
        if (root.value !== "")
            return root.value;
        if (root.text !== "")
            return root.text;
        return root._childText();
    }

    // ── 背景：选中 → muted ─────────────────────────────────────
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root._radius
        color: root.selected && root.enabled ? theme.muted : "transparent"
        Behavior on color {
            ColorAnimation { duration: theme.motionDuration(theme.durationInstant) }
        }
    }

    // ── 左侧：图标 + 标签 + 用户自定义内容 ──────────────────────
    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.right: tailRow.left
        anchors.rightMargin: root._gap
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: root._padX
        spacing: root._gap

        ShadcnIcon {
            id: icon
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 16
            // [&_svg]:pointer-events-none + 选中时提亮
            color: root.selected && root.enabled ? theme.foreground : theme.mutedForeground
        }

        Text {
            id: label
            visible: root.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root._textColor()
            font.pixelSize: 14   // text-sm
        }

        // 用户子项由 Row 直接渲染：声明顺序 = 视觉顺序（贴 cmdk 的写在哪就在哪）
    }

    // ── 右侧插槽：ml-auto（shortcut + check）───────────────────
    Row {
        id: tailRow
        anchors.right: parent.right
        anchors.rightMargin: root._padX
        anchors.verticalCenter: parent.verticalCenter
        spacing: root._gap

        Text {
            id: builtinShortcut
            visible: root.shortcut !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.shortcut
            // group-data-selected:*:text-foreground（选中时 shortcut 一起提亮）
            color: root.selected ? theme.foreground : theme.mutedForeground
            font.pixelSize: 12
            font.letterSpacing: 1   // tracking-widest
        }

        // 内置 check：写了 ShadcnCommandShortcut 时隐藏
        // （对齐 group-has-data-[slot=command-shortcut]:hidden）
        ShadcnIcon {
            id: checkMark
            visible: root.checked && !root._hasUserShortcut()
            anchors.verticalCenter: parent.verticalCenter
            name: "check"
            size: 16
            color: theme.mutedForeground
        }
    }

    // ── 指针交互 ────────────────────────────────────────────────
    MouseArea {
        id: pointer
        anchors.fill: parent
        // disabled 时不可点（cmdk 的 pointer-events-none）
        enabled: root.enabled
        hoverEnabled: true
        // 悬停即选中（cmdk 的 onPointerMove → setState("value")）
        onEntered: {
            if (root.enabled && root.command)
                root.command.setActive(root);
        }
        onClicked: {
            if (!root.enabled)
                return;
            if (root.command)
                root.command.setActive(root);
            root.activated();
        }
    }

    // ── 注册 / 搬迁子项 ────────────────────────────────────────
    Component.onCompleted: {
        root.command = root._resolveCommand(root.parent);
        root._relocateShortcuts();
        if (root.command)
            root.command.registerItem(root);
    }

    Component.onDestruction: {
        if (root.command)
            root.command.unregisterItem(root);
    }

    // 用户后来追加的子项也要搬到右侧
    onItemChildrenChanged: {
        root._relocateShortcuts();
    }

    // 选中态下发给右侧的 shortcut 子项（官方 group-data-selected/command-item:
    // text-foreground）。脱离 CommandItem 单用时 _selected 保持 false，
    // 表现与 ShadcnDropdownMenuShortcut 一致。
    onSelectedChanged: root._syncShortcutState()

    function _syncShortcutState() {
        var kids = tailRow.children;
        for (var i = 0; i < kids.length; ++i) {
            if (kids[i] && kids[i]._isCommandShortcut === true)
                kids[i]._selected = root.selected;
        }
    }

    // ── 辅助 ────────────────────────────────────────────────────
    function _textColor() {
        if (!root.enabled)
            return theme.mutedForeground;
        if (root.destructive)
            return theme.destructive;
        return theme.foreground;
    }

    // 沿 parent 链找 Command（鸭子类型：有 registerItem 的就是 Command）。
    // 不用类型判断：Command ↔ Item 互相引用会是循环 import。
    function _resolveCommand(from) {
        var p = from;
        while (p) {
            if (typeof p.registerItem === "function")
                return p;
            p = p.parent;
        }
        return null;
    }

    // 本条目「声明时」真正所在的列 = CommandItem 的 parent
    // （contentRow 是内部行，注册时要的是外面那个列）
    function _outerColumn() {
        return root.parent;
    }

    /// 供 Command 的 Enter 调用：禁用项不执行（cmdk 只给非禁用项挂 onSelect）
    function activateFromKeyboard() {
        if (!root.enabled)
            return false;
        root.activated();
        return true;
    }

    /// 由 Command 在重排时调用：把自己挂回声明列（Qt 不能靠赋 y 改变
    /// children 顺序，移动 parent 是唯一手段；同父赋值是空操作，跨父才有效）
    function _moveTo(col) {
        if (col && root.parent !== col)
            root.parent = col;
    }

    // 声明在 itemChildren 里的 CommandShortcut 搬到 tailRow（ml-auto 语义）
    function _relocateShortcuts() {
        for (var i = 0; i < contentRow.children.length; ++i) {
            var c = contentRow.children[i];
            if (c && c._isCommandShortcut === true && c.parent !== tailRow)
                c.parent = tailRow;
        }
        root._syncShortcutState();
    }

    function _hasUserShortcut() {
        for (var i = 0; i < tailRow.children.length; ++i) {
            if (tailRow.children[i] && tailRow.children[i]._isCommandShortcut === true)
                return true;
        }
        return false;
    }

    // 子项里的纯文本（value 缺省来源；cmdk 用 textContent）
    function _childText() {
        var parts = [];
        var kids = contentRow.children;
        for (var i = 0; i < kids.length; ++i) {
            var c = kids[i];
            if (!c || c._isCommandShortcut === true)
                continue;
            // 内置图标与标签不算「用户文本」（它们已经分别由 iconName/text 表达）
            if (c === icon || c === label)
                continue;
            if (typeof c.text === "string" && c.text !== "")
                parts.push(c.text);
        }
        return parts.join(" ").trim();
    }
}

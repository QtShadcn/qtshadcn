pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui CommandSeparator —— 面板内的分隔线
//
// 对齐 registry 的 CommandSeparator：`-mx-1 h-px bg-border`
//   h-px = 1px；bg-border = theme.border；-mx-1 = 左右各外扩 4px，
//   越过 Command 的 p-1 内缩，让线与面板内边缘齐平。
//   （Qt 侧的负 margin 由 ShadcnCommandColumn.relayout 读 `_layoutX` 实现 ——
//   它给本项赋 x = -4，等价于 CSS 的 -mx-1；宽度同时 +8 补回。）
//
// ⚠ cmdk 的 Separator **只在没有搜索词时渲染**（源码里
//   `useCommandState(s => !s.search)`，false 就 return null）。所以过滤时这条线
//   会消失 —— 不是 bug，是官方行为：搜索后的结果列表里插分隔线只会干扰排序。
//   Qt 侧照样对齐：visible 绑到 _match，由 ShadcnCommand 在重算时置位。
//   自己写 `visible:` 会覆盖这条内部绑定（Qt 的属性覆盖语义）。
//
// 用法（放在两个 CommandGroup 之间，作为 CommandList 的直接子项）:
//   ShadcnCommandGroup { heading: "建议"; ShadcnCommandItem { text: "搜索" } }
//   ShadcnCommandSeparator {}
//   ShadcnCommandGroup { heading: "设置"; ShadcnCommandItem { text: "主题" } }
Item {
    id: root

    /// 是否参与显示（搜索时隐藏；由 ShadcnCommand 驱动）
    readonly property bool matched: root._match
    property bool _match: true
    property real _score: 1.0
    /// 供 Command 认「这是分隔线」（鸭子类型：类型判断会形成循环 import）
    readonly property bool _isCommandSeparator: true
    /// 左侧外扩 4px（CSS 的 -mx-1）；ShadcnCommandColumn 排布时读它
    readonly property int _layoutX: -4

    /// 所属 Command
    property var command: null

    implicitWidth: parent ? parent.width + 8 : 240
    implicitHeight: 1                        // h-px

    width: implicitWidth
    visible: root._match

    QtShadcnTheme { id: theme }

    Rectangle {
        anchors.fill: parent
        color: theme.border                  // bg-border（无字面量）
    }

    Component.onCompleted: {
        root.command = root._resolveCommand(root.parent);
        if (root.command)
            root.command.registerSeparator(root);
    }

    Component.onDestruction: {
        if (root.command)
            root.command.unregisterSeparator(root);
    }

    function _resolveCommand(from) {
        var p = from;
        while (p) {
            if (typeof p.registerItem === "function")
                return p;
            p = p.parent;
        }
        return null;
    }
}

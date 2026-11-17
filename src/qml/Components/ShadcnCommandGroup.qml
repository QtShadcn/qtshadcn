pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui CommandGroup —— 命令面板的分组容器
//
// 对齐 registry 的 CommandGroup：`overflow-hidden p-1 text-foreground`
//   + heading（cmdk 的 `heading` prop 渲染成 [cmdk-group-heading]，registry 用
//     `**:[[cmdk-group-heading]]:` 选择器给它上样式）：
//     `px-2 py-1.5 text-xs font-medium text-muted-foreground`
//
// 过滤语义（cmdk 的 filtered.groups）：组内**一个都不匹配**时整组隐藏，标题跟着
// 消失 —— 而不是只藏条目、留一个光杆标题。组的排序分 = 组内最高分，所以搜索时
// 「有强匹配项的组」整体前移（cmdk 的 sortGroups 把组连同标题一起移动）。
//
// ── 内部为什么是 Column + 一个可重排列 ─────────────────────────
// 标题与「条目列」的相对位置固定（标题在上），交给 Column 管；条目列**内部**的
// 顺序才需要按分数重排，由 ShadcnCommandColumn 手工赋 y。两层各管一层不冲突：
// 外层 Column 只给「条目列」这一个子项赋 y，不会去动条目列的孩子。
//
// 用法:
//   ShadcnCommandGroup {
//       heading: "建议"
//       ShadcnCommandItem { text: "新建文件"; shortcut: "⌘N" }
//       ShadcnCommandItem { text: "搜索" }
//   }
Item {
    id: root

    /// 分组标题（cmdk 的 heading）。留空则不渲染标题行。
    property string heading: ""

    /// 是否被当前查询匹配（组内全无匹配 → false；由 ShadcnCommand 驱动）
    readonly property bool matched: root._match

    // ── 内部（Command 驱动）──────────────────────────────────
    property bool _match: true
    property real _score: 1.0
    /// 供 Command 认「这是分组容器」（鸭子类型：类型判断会形成循环 import）
    readonly property bool _isCommandGroup: true
    /// 组内条目列（Command 往这里取 children、往这里赋 y）
    readonly property ShadcnCommandColumn column: _items
    /// 所属 Command
    property var command: null

    /// 组内条目（ShadcnCommandItem）。别名指向条目列的 data —— 探针实测
    /// 「文件正文里声明的子项」不会被外部实例化的子项抢走（与
    /// ShadcnDialogContent 同构）。
    default property alias groupChildren: _items.data

    implicitWidth: 240
    implicitHeight: root._pad * 2 + _interior.implicitHeight

    width: parent ? parent.width : implicitWidth
    visible: root._match
    // 条目少于一屏时不裁剪；组内条目超出组高（罕见）时被 clip 挡住 —— 官方
    // 也是 overflow-hidden
    clip: true

    QtShadcnTheme { id: theme }

    readonly property int _pad: 4        // p-1

    Column {
        id: _interior
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root._pad
        spacing: 0

        // 标题：px-2 py-1.5 text-xs font-medium text-muted-foreground
        // 用 Item 包一层补 py —— Text 没有 padding，且 Text.implicitHeight 只读
        // （仓库开发坑表第 9 条：不能赋值）
        Item {
            id: headingBox
            objectName: "commandGroupHeading"
            visible: root.heading !== ""
            width: _interior.width
            height: root.heading === "" ? 0 : headingText.implicitHeight + 12   // py-1.5 ×2

            Text {
                id: headingText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8    // px-2
                anchors.rightMargin: 8
                text: root.heading
                color: theme.mutedForeground
                font.pixelSize: 12       // text-xs
                font.bold: true          // font-medium
            }
        }

        // 条目列：顺序与 y 由 Command 打分后赋值
        ShadcnCommandColumn {
            id: _items
            objectName: "commandGroupItems"
            width: _interior.width
            spacing: 0                   // cmdk 的 group-items 无间距
            command: root.command        // 动态加条目时上报
        }
    }

    Component.onCompleted: {
        root.command = root._resolveCommand(root.parent);
        if (root.command)
            root.command.registerGroup(root);
    }

    Component.onDestruction: {
        if (root.command)
            root.command.unregisterGroup(root);
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

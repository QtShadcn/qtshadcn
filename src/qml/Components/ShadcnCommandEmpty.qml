pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui CommandEmpty —— 「无匹配结果」占位
//
// 对齐 registry 的 CommandEmpty：`py-6 text-center text-sm`
//   py-6 = 上下各 24；text-center；text-sm = 14
//
// 显示条件（cmdk 源码 `useCommandState(s => s.filtered.count === 0)`）：
//   **匹配条目数 == 0 且当前有搜索词**。
// 后半句容易被忽略：官方在空查询时即使一个条目都没有也不渲染 Empty ——
// 刚打开的空面板就该是空的（闪一句「无结果」是错的）。这条判断由
// ShadcnCommand 在重算时写进 _match，本组件只负责把 visible 绑上去。
//
// ⚠ 这里不写 `visible:` 的自定义值 —— 覆盖了内部绑定就等于放弃参与过滤
//   （Qt 的属性覆盖语义）。需要额外条件时写 `visible: matched && 你的条件`。
//
// ⚠ 基类是 Item 而不是 Text：Text.implicitHeight **只读**（仓库开发坑表第 9 条），
//   而 py-6 要的「文本高 + 上下 48」必须能设 implicitHeight，所以外层 Item
//   承担高度与注册，内层 Text 只管排版（与 ShadcnCommandGroup 的标题同一手法）。
//
// 用法:
//   ShadcnCommandList {
//       ShadcnCommandEmpty { text: "没有找到匹配的命令" }
//       ShadcnCommandGroup { ... }
//   }
Item {
    id: root

    /// 占位文案（官方默认 "No results found."）
    property string text: qsTr("No results found.")

    /// 是否处于「该显示」状态（由 ShadcnCommand 驱动）
    readonly property bool matched: root._match
    property bool _match: false
    property real _score: 1.0
    /// 供 Command 认「这是 Empty」（鸭子类型：类型判断会形成循环 import）
    readonly property bool _isCommandEmpty: true

    /// 所属 Command
    property var command: null

    implicitWidth: 200
    // py-6(24×2) + text-sm 行高 20
    implicitHeight: 68

    width: parent ? parent.width : implicitWidth
    visible: root._match

    QtShadcnTheme { id: theme }

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        horizontalAlignment: Text.AlignHCenter   // text-center
        wrapMode: Text.WordWrap
        color: theme.mutedForeground
        font.pixelSize: 14                       // text-sm
    }

    Component.onCompleted: {
        root.command = root._resolveCommand(root.parent);
        if (root.command)
            root.command.registerEmpty(root);
    }

    Component.onDestruction: {
        if (root.command)
            root.command.unregisterEmpty(root);
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

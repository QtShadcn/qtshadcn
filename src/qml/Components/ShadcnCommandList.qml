pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui CommandList —— 命令条目区（纵向滚动）
//
// 对齐 registry 的 CommandList：`no-scrollbar max-h-72 scroll-py-1
//   overflow-x-hidden overflow-y-auto outline-none`
//   max-h-72 = 288px 高度上限；超出才滚；scroll-py-1 = 键盘滚动时上下留 4px
//   no-scrollbar = 隐藏滚动条（官方是 CSS 工具类，把 scrollbar-width 归零）
//
// ── Qt 侧的两处偏离，都注明 ───────────────────────────────────
// 1. 滚动条：`no-scrollbar` 的字面语义是「不留视觉条但仍可滚」。Qt 的 Flickable
//    本来就不自绘滚动条，所以这里**默认不挂 ScrollBar** —— 与官方视觉一致。
//    需要可见条时 `showScrollBar: true`（用 ShadcnScrollBar）。
// 2. 基座用 Flickable 而不是 ScrollView：仓库既有结论（见 ShadcnDialogContent
//    同处注释）—— ScrollView 不会拉伸它 attached 的 ScrollBar，thumb 会退化
//    成几像素的小圆点。Flickable 下条随视口高拉伸，比例才对。
//
// ⚠ 高度依赖方向（防链式绑定循环）：
//   listColumn.implicitHeight（可见条目求和）→ 本组件 height = min(…, 288)
//   → Command.implicitHeight。本组件**不**把 height 回灌给 listColumn
//   （只给它 width，宽度由外部对话框定，不由内容反推），所以没有
//   「列高 ← 内容高 ← 列高」的环。
//
// 用法:
//   ShadcnCommandList {
//       ShadcnCommandEmpty { text: "无匹配结果" }
//       ShadcnCommandGroup { heading: "建议"; ShadcnCommandItem { text: "搜索" } }
//   }
Item {
    id: root

    /// 条目区高度上限（max-h-72 = 288）。条目少时随内容收缩。
    property int maxHeight: 288

    /// 显示滚动条（默认关，对齐 no-scrollbar）
    property bool showScrollBar: false

    /// 承载条目的列（Command 注册进来做打分重排）
    readonly property alias column: listColumn

    /// 所属 ShadcnCommand
    property var command: null

    /// 用户子项（Empty / Group / Separator / 散落 Item）
    default property alias listChildren: listColumn.data

    implicitWidth: 340
    // 视口高 = min(内容高, 上限)。内容少时整块收缩（官方 max-h + 无固定高）。
    implicitHeight: Math.min(listColumn.implicitHeight, root.maxHeight)

    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    QtShadcnTheme { id: theme }

    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        // 横向永不滚（overflow-x-hidden）
        contentWidth: width
        contentHeight: listColumn.implicitHeight

        ShadcnCommandColumn {
            id: listColumn
            objectName: "commandListColumn"
            width: flick.width
            spacing: 0
        }

        ScrollBar.vertical: ShadcnScrollBar {
            visible: root.showScrollBar
            policy: ScrollBar.AsNeeded
        }
    }

    Component.onCompleted: {
        var cmd = root._resolveCommand(root.parent);
        if (cmd) {
            root.command = cmd;
            listColumn.command = cmd;
            cmd.registerList(listColumn, root);
        }
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

    /// 把条目滚进视口（Command 在选中项变化时调用；block:"nearest" 语义）
    function scrollToItem(item) {
        if (item === null || item === undefined)
            return;
        var top = item.y;
        var bottom = item.y + item.height;
        var view = flick.contentY;
        var pad = 4;   // scroll-py-1
        if (top - pad < view)
            flick.contentY = Math.max(0, top - pad);
        else if (bottom + pad > view + flick.height)
            flick.contentY = bottom + pad - flick.height;
    }
}

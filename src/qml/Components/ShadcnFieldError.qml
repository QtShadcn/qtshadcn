pragma ComponentBehavior: Bound

import QtQuick
import QtShadcn

// shadcn/ui 风格字段错误提示（FieldError）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldError —— 关键行为有三条，都对齐了：
//   1) 没有内容就**完全不渲染**（原生 return null），不是渲染一个空占位
//   2) 同一句错误只渲染一次：官方用 `new Map(errors.map(e => [e.message, e]))`
//      按 message 去重（后出现的覆盖前面的，顺序按首次出现）
//   3) 去重后只有一条 → 直接输出该 message；多条 → <ul class="list-disc"> 列表
// 另有 role="alert"（无障碍立即播报）与 text-sm text-destructive 配色。
//
// 用法:
//   ShadcnFieldError { text: "用户名已被占用" }
//   ShadcnFieldError { errors: ["用户名已被占用", "用户名已被占用", "不能包含空格"] }
//   // errors 也接受 { message: "..." } 形式的对象数组（对齐 react-hook-form 产出）
//
// 渲染规则（与官方一致）:
//   text 非空        → 只显示 text（等价官方 children 优先）
//   errors 非空      → 去重后 1 条显示单行，多条显示项目符号列表
//   都为空           → visible: false 且高度为 0（不占位）
Item {
    id: root

    // 直接文案（等价官方 children）
    property string text: ""
    // 错误数组：string[] 或 { message }[]（等价官方 errors）
    property var errors: []

    QtShadcnTheme { id: theme }

    // ── 去重后的最终文案 ──
    readonly property var messages: {
        if (root.text.length > 0)
            return [root.text]
        if (!root.errors || root.errors.length === undefined)
            return []
        var seen = []
        var out = []
        for (var i = 0; i < root.errors.length; ++i) {
            var e = root.errors[i]
            var msg = typeof e === "string" ? e : (e && e.message !== undefined ? e.message : "")
            if (!msg || msg.length === 0)
                continue
            // 官方 Map 语义：同 message 只留一条（保留首次出现的顺序）
            if (seen.indexOf(msg) !== -1)
                continue
            seen.push(msg)
            out.push(msg)
        }
        return out
    }

    readonly property bool _hasContent: root.messages.length > 0
    readonly property bool _isList: root.messages.length > 1

    visible: root._hasContent
    implicitHeight: root._hasContent ? contentColumn.implicitHeight : 0

    // 官方 role="alert"
    Accessible.role: Accessible.AlertMessage
    Accessible.name: root.messages.join("；")

    Column {
        id: contentColumn

        // 多条目时官方是 <ul class="ml-4 list-disc">，整体右移 16px 给项目符号留位
        x: root._isList ? theme.spacingLg : 0
        width: root.width - x
        spacing: theme.spacingXs   // list gap-1 = 4px

        // 单条：纯文本
        Text {
            visible: !root._isList
            width: contentColumn.width
            text: root.messages.length > 0 ? root.messages[0] : ""
            color: theme.destructive
            font.pixelSize: 14   // text-sm
            wrapMode: Text.WordWrap
            lineHeightMode: Text.FixedHeight
            lineHeight: 18
        }

        // 多条：项目符号列表（等价 list-disc）
        Repeater {
            model: root._isList ? root.messages : []

            delegate: Row {
                id: errorRow

                required property string modelData

                width: contentColumn.width
                spacing: theme.spacingXs

                Text {
                    text: "•"
                    color: theme.destructive
                    font.pixelSize: 14
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 18
                }
                Text {
                    width: parent.width - theme.spacingXs - 8
                    text: errorRow.modelData
                    color: theme.destructive
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 18
                }
            }
        }
    }
}

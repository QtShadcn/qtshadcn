import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格多行文本输入（可内部滚动）
// Flickable + TextEdit + ScrollBar —— Qt 官方可滚动 TextArea 模式。
// 为什么不用 QQC.TextArea：Basic TextArea 内部没有 Flickable，TextEdit 原生不处理
// 滚轮滚动内容，内容超高时无法内部滚动；Flickable 提供滚轮/触摸滚动 + 可见滚动条。
//
// 规范对齐：
// - min-h-16(64) + px-3 py-3 + rounded-md(6px) + bg-input/50 + 聚焦 border-ring + 3px ring
// - maxHeight：内容超高钳住高度 → Flickable 内部滚动；0 = 不限高（随内容增高）
//
// 用法:
//   ShadcnTextarea { placeholderText: "请输入" }
//   ShadcnTextarea { maxHeight: 150; text: "长内容内部滚动" }
Item {
    id: root

    QtShadcnTheme { id: theme }

    // ── 兼容 QQC.TextArea 的 API ──
    // 注意：placeholderText 不用 alias（QtQuick.TextEdit 的 placeholderText 是 FINAL，
    // alias 会报 Invalid alias target location；且无 placeholderTextColor 属性）
    // → 显式属性 + 自绘 placeholder（颜色可控为 mutedForeground）
    property alias text: edit.text
    property alias selectByMouse: edit.selectByMouse
    property alias font: edit.font
    property string placeholderText: ""
    signal textEdited(string editedText)

    // 高度上限（px）：内容超过则内部滚动；0 = 不限高
    property int maxHeight: 200

    implicitWidth: 240

    // 高度：min-h-16(64) 起，内容多时自然增高，超过 maxHeight 钳住 → 内部滚动。
    // 注意：不能用 readonly property 引用子对象 edit（readonly 绑定在对象创建时立即
    // 求值，此时 edit 尚未创建 → null 崩溃）；且 contentHeight 早期可能是 undefined，
    // Math.min/max 遇 NaN 会传播 → 全部用守卫兜底
    implicitHeight: {
        var eh = edit && edit.implicitHeight > 0 ? edit.implicitHeight : 0
        return Math.max(64, maxHeight > 0 ? Math.min(eh, maxHeight) : eh)
    }

    // ── 占位文本（自绘：TextEdit 无 placeholderTextColor，用 mutedForeground）──
    Text {
        id: placeholder
        x: 12   // 对齐 edit.leftPadding
        y: 12   // 对齐 edit.topPadding
        width: root.width - 24
        visible: edit.length === 0 && root.placeholderText.length > 0
        text: root.placeholderText
        color: theme.mutedForeground
        font: edit.font
        wrapMode: Text.Wrap
    }

    // ── 背景（最底层，不挡文本）──
    Rectangle {
        id: bg
        anchors.fill: parent
        z: -1
        radius: 6   // shadcn button/控件圆角
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.5)   // bg-input/50
        border.width: 1
        border.color: edit.activeFocus ? theme.ring : "transparent"

        Behavior on border.color { ColorAnimation { duration: 120 } }

        // 键盘焦点环：activeFocus 时 3px 外环（shadcn focus-visible:ring-3 ring-ring/30）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 9
            visible: edit.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // ── 可滚动内容区 ──
    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: edit.width
        contentHeight: edit.implicitHeight

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            parent: flick
        }

        TextEdit {
            id: edit
            width: flick.width
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            color: theme.foreground
            font.pixelSize: 14
            selectByMouse: true
            // 内容边距：shadcn px-3 py-3（TextEdit 自带 padding，滚动含 padding 区）
            leftPadding: 12
            rightPadding: 12
            topPadding: 12
            bottomPadding: 12
            // 注意：不要用 onTextEdited: root.textEdited(editedText) ——
            // Qt 6.11 qmlcache 下内联 handler 拿不到信号参数 editedText（ReferenceError），
            // 改用 text（编辑后的当前值，一定可用）转发
            onTextEdited: root.textEdited(text)
        }
    }

    // 禁用态：opacity 50%（shadcn disabled:opacity-50）
    opacity: !enabled ? 0.5 : 1
}

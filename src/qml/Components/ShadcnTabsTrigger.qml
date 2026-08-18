import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui v4 TabsTrigger（对齐官方源码）：
//   <button role="tab" class="relative inline-flex h-[calc(100%-1px)] flex-1 items-center
//        justify-center gap-1.5 rounded-md border border-transparent px-1.5 py-0.5 text-sm
//        font-medium whitespace-nowrap text-foreground/60 hover:text-foreground
//        focus-visible:border-ring focus-visible:ring ... data-active:bg-background
//        data-active:text-foreground ...">
// - flex-1：TabBar 内均分宽度
// - default：选中 bg-background 白底 + text-foreground；未选中 60% foreground
// - line：透明底 + 2px 下划线指示器（after: bottom -5px，opacity 过渡）
TabButton {
    id: root

    property string variant: "default"   // "default" | "line"（由 ShadcnTabsList 同步）

    QtShadcnTheme { id: theme }
    readonly property bool _isLine: variant === "line"

    // h-[calc(100%-1px)]：TabBar 内容高 26 → 25；宽度 TabBar 自动均分（flex-1）
    implicitHeight: 25

    // shadcn v4: px-3（水平 12px 内边距）——按钮之间靠此 padding 提供视觉间距
    leftPadding: 12
    rightPadding: 12

    // 内容：text-sm(14px) Medium；未选中 foreground 60%，选中/hover 100%
    contentItem: Text {
        text: root.text
        color: root.checked || root.hovered
            ? theme.foreground
            : Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.6)
        font.pixelSize: 14
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // 背景：对齐 shadcn v4
    // - default 选中态：light bg-background（白底）/ dark bg-input/30 + border-input
    //   （dark 模式 background=#09090b 近黑，在 muted 灰容器上无对比度，官方用 input/30 + 边框区分）
    // - line：透明底
    background: Rectangle {
        radius: root._isLine ? 0 : 6
        color: {
            if (root._isLine || !root.checked)
                return "transparent"
            // default variant 选中态
            if (theme.mode === "dark")
                return Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.3)   // dark: bg-input/30
            return theme.background   // light: bg-background（白底）
        }
        // dark 模式选中态加 border-input（官方 dark:data-active:border-input）
        border.width: root.checked && !root._isLine && theme.mode === "dark" ? 1 : 0
        border.color: theme.input

        Behavior on color { ColorAnimation { duration: 120 } }

        // 焦点环（focus-visible:ring）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: root._isLine ? 0 : 9
            visible: root.activeFocus
            color: "transparent"
            border.width: 2
            border.color: theme.ring
            opacity: 0.7
        }

        // line variant 选中态：2px 下划线（after: bottom -5px）
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -5
            width: parent.width
            height: 2
            color: theme.foreground
            visible: root._isLine
            opacity: root.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // 关闭 QQC.TabButton 默认 indicator（底部下划线）
    indicator: Item {}
}

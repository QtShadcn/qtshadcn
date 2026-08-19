import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格滑块（对齐 Base UI 默认变体，用户贴的 DOM 为权威）：
// - 容器：mx-auto w-full max-w-xs（宽度由外部决定）
// - track：h-1(4px) rounded-full bg-muted（非 luma 的 h-2 bg-input）
// - range：bg-primary，从 0 起宽 = position%
// - thumb：size-3(12px) 正圆 rounded-full border border-ring bg-white；
//   hover/focus/active ring-3 ring-ring/50；thumb 中心对齐位置（translate: -50% -50%）
//
// 用法:
//   ShadcnSlider { from: 0; to: 100; value: 40 }
Slider {
    id: root

    QtShadcnTheme { id: theme }

    // 关键：QQC Basic Slider 默认 padding:6 → track 被缩进 6px、两侧出现空白。
    // 设 0 让 track 撑满（shadcn w-full），留白由外部容器控制
    padding: 0

    // 整体高度 = thumb(12) + hover ring 外扩(3×2) = 18，避免 ring 被裁切；
    // 外部可直接设置 height 覆盖（track/thumb 基于 availableHeight 自适应居中）
    implicitHeight: 18

    // 轨道厚度（shadcn h-1 = 4px；可自定义）
    property int trackThickness: 4

    // ── 轨道（track bg-muted + range bg-primary）──
    // 注意：override background 后模板的定位绑定不自动应用，必须自带 x/y/width
    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2   // 垂直居中
        width: root.availableWidth                                 // 撑满（padding=0 → 全宽）
        height: root.trackThickness
        radius: root.trackThickness / 2                            // rounded-full
        color: theme.muted                                         // bg-muted

        // 已填充部分（range bg-primary，从 0 起）
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: theme.primary
            visible: root.visualPosition > 0
        }
    }

    // ── 滑块（thumb：12px 正圆，中心对齐位置）──
    handle: Rectangle {
        id: thumb
        // override handle 必须自带定位（QQC 模板不自动应用）：
        // 中心对齐（等效 translate: -50% -50%）；padding=0 时 availableWidth = width
        x: root.visualPosition * root.availableWidth - width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 12
        implicitHeight: 12
        radius: 6   // rounded-full（正圆）

        color: "white"
        border.width: 1
        border.color: theme.ring   // border border-ring

        // hover / focus / pressed：ring-3 ring-ring/50（shadcn hover/focus-visible/active:ring-3）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 9
            visible: root.hovered || root.activeFocus || root.pressed
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.5)
        }
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

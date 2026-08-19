import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtShadcn

// shadcn/ui 风格滑块
// 基于 QQC.Slider（Basic style），对齐 shadcn slider 规范：
// - track：h-2(8px) rounded-full bg-input/90；已填充 range：bg-primary
// - thumb：16×24 白色胶囊 + ring-1 ring-black/10 + shadow；hover/focus ring-4 ring-ring/30
//
// 用法:
//   ShadcnSlider { from: 0; to: 100; value: 40; onValueChanged: ... }
Slider {
    id: root

    QtShadcnTheme { id: theme }

    implicitHeight: 16   // 高度容纳 thumb（h-4）

    // ── 轨道（track + range）──
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 8    // h-2
        radius: 4            // rounded-full
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.9)   // bg-input/90

        // 已填充部分（shadcn cn-slider-range bg-primary）
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: theme.primary
            visible: root.visualPosition > 0
        }
    }

    // ── 滑块（thumb）：16×24 白色胶囊 ──
    handle: Rectangle {
        id: thumb
        // 关键：override handle 后必须自带定位（QQC 默认模板的 x/y 不会自动应用），
        // 否则 thumb 停在 (0,0) 不动
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 24
        implicitHeight: 16
        radius: 8   // rounded-full（胶囊）

        color: "white"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.1)   // ring-black/10

        // shadow-md：胶囊投影
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.4
            shadowVerticalOffset: 2
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
        }

        // hover / focus：ring-4 ring-ring/30（shadcn hover:ring-4 focus-visible:ring-4）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: 12
            visible: root.hovered || root.activeFocus
            color: "transparent"
            border.width: 4
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

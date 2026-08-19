import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格下拉选择（Select / Combobox）
// 基于 QQC.ComboBox（Basic style），对齐 shadcn select 规范：
// - trigger：h-9(36px) + rounded-md(6px) + bg-input/50 + border；右侧 chevron-down(16px,
//   mutedForeground)；聚焦 border-ring + 3px ring
// - 弹层：bg-popover + ring-1 + shadow-lg + p-1.5(6px) + rounded-md；item hover accent、
//   选中项右侧 check 图标；label text-xs mutedForeground；separator border
// - sm 尺寸：h-8(32px)（size: ShadcnSelect.Size.Sm）
//
// 用法:
//   ShadcnSelect {
//       model: ["苹果", "香蕉", "橙子"]
//       onActivated: (index) => console.log(currentText)
//   }
ComboBox {
    id: root

    enum Size { Default, Sm }

    QtShadcnTheme { id: theme }

    property int size: ShadcnSelect.Size.Default

    readonly property int _ctrlH: size === ShadcnSelect.Size.Sm ? 32 : 36
    implicitHeight: _ctrlH
    implicitWidth: 200

    // 内容边距：左右 px-3(12)；上下 0（contentItem 占满全高 → 文本垂直居中）。
    // 注意不能四边都设 12（如 padding: 12）——上下也 12 会让 contentItem 高只剩
    // 36-24=12px，文本被挤压偏上（表现为"没垂直居中"）
    leftPadding: 12
    rightPadding: 12
    topPadding: 0
    bottomPadding: 0

    // 隐藏 QQC 默认 indicator（double-arrow.png）——右侧图标用自定义 chevron-down，
    // 否则会同时出现两个箭头；visible:false 也让模板的 left/rightPadding 不再叠加 indicator 宽度
    indicator: Item {
        visible: false
    }

    // ── trigger 内容：文本 + chevron-down ──
    contentItem: RowLayout {
        spacing: 6   // gap-1.5

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.displayText
            color: root.currentIndex < 0 ? theme.mutedForeground : theme.foreground
            font.pixelSize: 14
            elide: Text.ElideRight
        }
        ShadcnIcon {
            Layout.alignment: Qt.AlignVCenter
            name: "chevron-down"
            size: 16
            color: theme.mutedForeground   // cn-select-trigger-icon text-muted-foreground
        }
    }

    // ── trigger 背景 ──
    background: Rectangle {
        radius: 6
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.5)   // bg-input/50
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"
        Behavior on border.color { ColorAnimation { duration: 120 } }

        // 聚焦环
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 9
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // ── 弹层（bg-popover + ring + shadow + padding）──
    popup: Popup {
        y: root.height + 4   // sideOffset 4
        width: root.width
        padding: 6           // p-1.5

        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            radius: 6
            color: theme.popover
            border.width: 1
            border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b,
                                  theme.mode === "dark" ? 0.10 : 0.05)   // ring-foreground/5·10
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.5
                shadowVerticalOffset: 4
                shadowColor: Qt.rgba(0, 0, 0, 0.18)   // shadow-lg
            }
        }

        // 进出动画（shadcn data-open:animate-in fade/zoom 100ms）
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 100 }
                NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 100; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
                NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 100; easing.type: Easing.InCubic }
            }
        }
    }

    // ── 列表项（hover accent + 选中 check）──
    delegate: ItemDelegate {
        required property var modelData
        // 注意：不要声明 required property bool checked —— checked 是 AbstractButton 的
        // FINAL 属性，声明即 override 会报 "Cannot override FINAL property"；
        // delegate 上下文本身已注入 checked/highlighted，直接使用即可。

        width: root.width - root.popup.padding * 2
        height: 32   // py-2 + text-sm ≈ 32

        readonly property string _text: root.textRole
            ? (Array.isArray(root.model) ? String(modelData) : String(model[root.textRole]))
            : String(modelData)

        // contentItem 用 anchors 而非 RowLayout：RowLayout 高度取决于内容，
        // 在 QQC contentItem 区里垂直居中不可靠；QQC 会把 contentItem 填满 content 区，
        // anchors.verticalCenter 保证文本/图标绝对垂直居中
        contentItem: Item {
            Text {
                anchors.left: parent.left
                anchors.right: arrow.left
                anchors.verticalCenter: parent.verticalCenter
                text: parent.parent._text
                color: (parent.parent.hovered || parent.parent.highlighted)
                       ? theme.accentForeground : theme.foreground
                font.pixelSize: 14
                font.weight: Font.Medium   // font-medium
                elide: Text.ElideRight
            }
            ShadcnIcon {
                id: arrow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.parent.highlighted || parent.parent.checked
                name: "check"
                size: 14
                color: (parent.parent.highlighted) ? theme.accentForeground : theme.foreground
            }
        }

        background: Rectangle {
            radius: 4
            color: (parent.hovered || parent.highlighted) ? theme.accent : "transparent"
        }
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

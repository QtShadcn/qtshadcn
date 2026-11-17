// ShadcnAccordionTrigger —— 手风琴行头（按钮）。放在 ShadcnAccordionItem 内，
// 展开态与切换都由所属 Item 决定（Item 又由根 Accordion 的 value 决定）。
// 对齐官方 Trigger DOM：
//   flex flex-1 items-start justify-between rounded-lg border border-transparent
//   py-2.5 text-left text-sm font-medium hover:underline
//   focus-visible:border-ring + ring-3 ring-ring/50
//   aria-disabled:pointer-events-none aria-disabled:opacity-50
//   图标（size-4=16 / text-muted-foreground / ml-auto）：**双图标互斥显示**，
//   展开态 ChevronDown 隐藏、ChevronUp 显示（官方就是换图标，不是旋转动画）
// 基于 QQC Button（Basic style）：键盘 Enter/Space 切换 + Tab 可达 + focus 态白拿，
// 只替换视觉，不重造交互。
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtShadcn

Button {
    id: root

    // 子项认亲标记（等价 data-slot="accordion-trigger"）
    readonly property bool __isShadcnAccordionTrigger: true

    // 行标题文本：直接用基类 Button.text（Qt 6.8 起该属性是 FINAL，
    // 自己再声明一个同名 property 会编译失败）

    QtShadcnTheme {
        id: theme
    }

    // 所属 Item（向上认亲，同 ShadcnFieldLabel 的 __fieldOwner 手法）。
    // 兼容直接放进 ShadcnCollapsible（无 Item 层）的用法：那种情况下
    // __item 为 null，展开态改取 Collapsible 根的 open。
    property var __item: {
        var o = root.parent;
        while (o !== null && !("__isShadcnAccordionItem" in o)
                && !("__isShadcnCollapsible" in o))
            o = o.parent;
        return o;
    }
    readonly property bool __isCollapsibleHost: __item !== null
        && "__isShadcnCollapsible" in __item

    /// 展开态（只读，跟宿主）
    readonly property bool expanded: __item !== null
        ? (__isCollapsibleHost ? __item.open : __item.expanded)
        : false

    // 官方 py-2.5 = 上下 10px；左右无内边距（flush 到行边）
    verticalPadding: Math.round(theme.spacingXs * 2.5)
    horizontalPadding: 0
    spacing: 0

    // 坑：Control 放进 Column（positioner）时高度仍取 implicitHeight，但宽度不会
    // 自动铺满 —— 官方 flex-1 justify-between 就是「撑满行宽、图标贴右」
    width: parent !== null ? parent.width : implicitWidth
    height: implicitHeight
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    implicitWidth: contentItem.implicitWidth

    // 官方 focus-visible（键盘焦点才有环）；鼠标点击不给焦点，符合 Base UI 语义
    focusPolicy: Qt.TabFocus
    hoverEnabled: true
    // 禁用（aria-disabled）：QQC 已挡事件，这里只补 pointer-events-none 的视觉
    opacity: enabled ? 1 : 0.5

    onClicked: {
        if (__item !== null)
            __item._activate();
    }

    // 键盘激活：Enter / Space 都切换（官方 button 语义）。
    // 自己接管这两个键而不是依赖基类：Basic style 的按钮在不同 Qt 版本上对
    // Enter 的处理不一致（6.11 实测只有 Space 触发 clicked），Keys 处理器把事件
    // accepted 后基类 keyPressEvent 不再执行，于是跨版本行为统一、也不会双触发。
    Keys.onReturnPressed: function(event) {
        event.accepted = true
        root._activateFromKey()
    }
    Keys.onEnterPressed: function(event) {
        event.accepted = true
        root._activateFromKey()
    }
    Keys.onSpacePressed: function(event) {
        event.accepted = true
        root._activateFromKey()
    }

    function _activateFromKey() {
        if (!root.enabled)
            return;
        root.clicked();
    }

    // 无障碍：Qt 的 Accessible 附加属性没有 stateDescription（那是 6.9+ 的
    // QAccessible 概念），展开态用 description 播报 —— 官方 aria-expanded 的等价物
    Accessible.description: root.expanded ? qsTr("expanded") : qsTr("collapsed")

    background: Rectangle {
        id: bg

        // rounded-lg + border border-transparent（focus-visible 时才变 ring 色）
        radius: theme.radiusLg
        color: "transparent"
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"

        Behavior on border.color {
            ColorAnimation {
                duration: theme.motionDuration(theme.durationQuick)
            }
        }

        // focus-visible:ring-3 ring-ring/50 —— 3px 半透明 ring（向外扩，
        // 故内缩会盖到相邻行：ring 只在焦点态短暂出现，可接受）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: bg.radius + 3
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.5)
            visible: root.activeFocus
        }
    }

    // 官方 items-start justify-between + 图标 ml-auto：文字贴左上、图标贴右上
    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: theme.spacingXs

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                text: root.text
                color: theme.foreground
                font.pixelSize: 14          // text-sm
                font.weight: Font.Medium    // font-medium
                // hover:underline
                font.underline: root.hovered
                wrapMode: Text.WordWrap
            }

            // 双图标互斥（官方 group-aria-expanded:hidden / :inline）
            ShadcnIcon {
                objectName: "chevronDown"
                Layout.alignment: Qt.AlignTop
                visible: !root.expanded
                name: "chevron-down"
                size: 16                    // size-4
                color: theme.mutedForeground
            }

            ShadcnIcon {
                objectName: "chevronUp"
                Layout.alignment: Qt.AlignTop
                visible: root.expanded
                name: "chevron-up"
                size: 16
                color: theme.mutedForeground
            }
        }
    }
}

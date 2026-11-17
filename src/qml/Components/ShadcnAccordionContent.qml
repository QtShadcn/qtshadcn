// ShadcnAccordionContent —— 手风琴内容区（可开合的那一块）。放在
// ShadcnAccordionItem 内与 Trigger 配对，展开态取所属 Item.expanded。
// 对齐官方 AccordionContent DOM：
//   Panel：overflow-hidden text-sm + animate-accordion-down/up（duration-200）
//   内层 div：pt-0 pb-2.5（只有底部留白 10px）
//
// ── 高度动画方案（本仓库第一次做，取舍记在这里）─────────────────────
// Qt 没有 CSS 的 grid-template-rows 0fr→1fr，等价实现是「外层裁剪 + 动画外层自己的高度」：
//   外层 root：clip: true（= overflow-hidden），height 在 0 ↔ 内容自然高之间动画
//   内容宿主 host：height = column.implicitHeight + 底部留白，**完全独立于外层动画高度**
// 为什么必须分出 host：
//   1. 若让内容直接 anchors.fill: 外层，外层每帧的动画中间值会挤扁内容 ——
//      ColumnLayout 按中间值重排后读回的 implicitHeight 也跟着变，等于「动画目标值
//      自己在动」（ShadcnDialogContent / ShadcnScrollArea 都实测过这类塌缩循环）。
//      host 把自然高固定成一条独立算式，外层只读它，依赖是单向的。
//   2. 不用 childrenRect 取自然高：childrenRect 会被子项的 anchors/尺寸反向影响，
//      内容里放 Flickable/ScrollView 时它给的是视口高而不是内容高。
//   3. 动画的对象必须是「外层 height」这一条独立属性，不能写成
//      `height: host.height` 再 Behavior —— 那样绑定会覆盖动画中间值，抽成 0/满格两帧。
// 收起态内容不可交互：host.visible = root.height > 0。clip 不参与命中测试，
// 只靠 clip「看不见」的内容照样吃掉点击（仓库既有实测坑），必须显式收可见性；
// 动画走完正好是 0，所以可见性切换不会截断动画本身。
import QtQuick
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    // 子项认亲标记（等价 data-slot="accordion-content"）
    readonly property bool __isShadcnAccordionContent: true

    /// 官方 text-muted-foreground 是 CSS 继承，QML 的 Text 不吃继承：
    /// 这里把它作为只读属性给出，宿主侧写 `color: content.textColor`（文档同此）
    readonly property color textColor: theme.mutedForeground

    default property alias content: column.data

    QtShadcnTheme {
        id: theme
    }

    // 向上找展开态宿主：ShadcnAccordionItem（手风琴行）或 ShadcnCollapsible
    property var __host: {
        var o = root.parent;
        while (o !== null && !("__isShadcnAccordionItem" in o)
                && !("__isShadcnCollapsible" in o))
            o = o.parent;
        return o;
    }
    readonly property bool __collapsibleHost: __host !== null
        && "__isShadcnCollapsible" in __host

    /// 展开态（只读，跟宿主）
    readonly property bool expanded: __host !== null
        ? (__collapsibleHost ? __host.open : __host.expanded)
        : false

    // 官方 pb-2.5（10px）：无顶部内边距
    readonly property int _padBottom: Math.round(theme.spacingXs * 2.5)

    width: parent !== null && parent.width > 0 ? parent.width : 240
    // 动画的就是这一层：0 ↔ 内容自然高
    height: expanded ? host.height : 0
    implicitWidth: width
    implicitHeight: height
    clip: true   // 官方 overflow-hidden

    Behavior on height {
        NumberAnimation {
            duration: theme.motionDuration(theme.durationSlow)   // 200ms
            easing.type: theme.easingOut
        }
    }

    Item {
        id: host

        objectName: "contentHost"
        // 收起（动画走完 height=0）后内容不可交互、不可聚焦
        visible: root.height > 0
        width: root.width
        // 自然高固定在这里，独立于外层动画高度（见文件头注释）
        height: column.implicitHeight + root._padBottom
        implicitHeight: height

        ColumnLayout {
            id: column

            width: host.width
            // 单向：显式写成自己的自然高（不是外层动画高），子项才能按自然尺寸排
            height: column.implicitHeight
            spacing: 0
        }
    }
}

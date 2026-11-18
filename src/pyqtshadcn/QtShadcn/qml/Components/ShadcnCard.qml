import QtQuick
import QtQuick.Effects
import QtShadcn

// shadcn/ui 风格卡片容器（纯组合组件，无 QQC 基类）
// 对齐 shadcn v4：bg-card + ring-1(前景色 5%/10%) + shadow-md + rounded + 内边距 spacing(6)/spacing(4)
//
// 用法:
//   ShadcnCard {
//       ShadcnCardHeader {
//           ShadcnCardTitle { text: "标题" }
//           ShadcnCardDescription { text: "描述" }
//       }
//       ShadcnCardContent { ... }
//       ShadcnCardFooter {
//           ShadcnButton { text: "确定" }
//       }
//   }
Rectangle {
    id: root

    enum Size { Default, Small }

    // ── 公开 API ──
    property int size: ShadcnCard.Size.Default

    QtShadcnTheme { id: theme }

    // 内边距：default 24px（spacing(6)）/ small 16px（spacing(4)），对齐 shadcn --card-spacing
    readonly property int padding: size === ShadcnCard.Size.Small ? 16 : 24

    // 子组件全部进 contentColumn 布局（Header/Content/Footer 垂直堆叠，间距 = 内边距，对齐 shadcn gap-(--card-spacing)）
    default property alias content: contentColumn.data

    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + root.padding * 2

    color: theme.card
    radius: theme.radius
    clip: true   // shadcn: overflow-hidden

    // 描边：ring-1 ring-foreground/5（dark 10%）
    border.width: 1
    border.color: Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b,
                          theme.mode === "dark" ? 0.10 : 0.05)

    // 阴影：shadow-md（dark 加深，light 浅黑）。
    // 注意：layer + MultiEffect 是 GPU 特效，offscreen 软件渲染不支持 → 卡片内容空白；
    // 截图模式（QTSHADCN_SCREENSHOT=1）下关闭 layer，正常 GUI 运行不受影响
    layer.enabled: !ThemeManager.screenshotMode()
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.4
        shadowVerticalOffset: 2
        shadowColor: Qt.rgba(0, 0, 0, theme.mode === "dark" ? 0.35 : 0.08)
    }

    Column {
        id: contentColumn

        // 注：Column 自身用 anchors.fill 合法；但放进本 Column 的子项
        // （Header/Content/Footer 及业务内容）不能用 top/bottom/fill/
        // verticalCenter/centerIn —— 否则报 "Cannot specify ... anchors
        // for items inside Column"。子项垂直位置一律由 Column 管理。
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.padding
    }
}

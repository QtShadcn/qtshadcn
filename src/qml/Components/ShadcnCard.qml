import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格卡片容器（纯组合组件，无 QQC 基类）
// 对齐 shadcn v4：bg-card + ring-1(前景色 5%/10%) + shadow-md + rounded + 内边距 spacing(6)/spacing(4)
//
// 内容容器是 ColumnLayout（不是 Column）：这样卡片内部可以放需要伸缩的内容，
// 子项用 Layout.fillHeight / Layout.fillWidth 即可，不用再手算
// 「卡片高 - Header - Footer」这类表达式。
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

    // 放进 Layout 时不要被 implicitWidth=320 顶住：Layout 默认拿 implicitWidth
    // 当 minimumWidth，一行 4 张卡 → 4×320+间距 = 1316px 最小宽，会把窗口顶宽。
    // 显式给 0 允许压缩；需要固定宽的下限时由调用方设 Layout.minimumWidth。
    Layout.minimumWidth: 0

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

    // 内容容器用 ColumnLayout：子项可用 Layout.fillWidth / Layout.fillHeight 参与
    // 布局。不再用 Column —— Column 既不吃 Layout.*，也不允许子项写竖向 anchors，
    // 会导致「卡片被压扁时内部固定高度子项冲出边框」。
    ColumnLayout {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.padding
    }
}

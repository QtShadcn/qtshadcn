import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtShadcn

// shadcn/ui 风格空状态容器（组合式，无 QQC 基类）
//
// 对齐 shadcn v4 base-nova（registry/styles/base-nova/ui/empty.tsx + style-nova.css）：
//   cn-empty          = flex flex-col items-center justify-center gap-4 rounded-xl
//                       border-dashed p-6 text-center text-balance
//   cn-empty-header   = flex max-w-sm flex-col items-center gap-2
//   cn-empty-media    = mb-2
//   cn-empty-title    = text-sm font-medium tracking-tight
//   cn-empty-desc     = text-sm/relaxed mutedForeground
//   cn-empty-content  = flex max-w-sm flex-col items-center gap-2.5 text-sm
//
// ── 虚线边框（Qt 没有直接对应物，方案见下）──
// Qt 的 Rectangle 只有实线 border（border.width / border.color），没有 dash 样式，
// BorderImage 也不支持描边。这里用 Shape + ShapePath 画圆角矩形描边：
//   strokeStyle: ShapePath.DashLine + dashPattern: [实线, 空白]
// 与 ShadcnSpinner 用 Shape 画弧线同一套思路；不使用 Canvas（仓库明文：Canvas 只允许
// 静态绘制，且 QML 层 JS 重绘在主线程；Shape 直接进场景图）。
// 两个必须处理的细节：
//   1. Shape 的描边以路径为中线、向两侧各展开 strokeWidth/2，路径不内缩就会有
//      一半落在容器外被裁掉 → 路径统一内缩 borderWidth/2；
//   2. QPainter 的 dash 长度会乘以 pen width，线宽 1 时 dashPattern [4,4] 就是 4px 实 4px 空。
//
// ⚠ 为什么默认 bordered: false：
//   官方 cn-empty 只写了 `border-dashed`，**没有写宽度**；Tailwind preflight 把
//   border-width 归零，所以官方默认渲染其实没有可见描边——官方文档里的
//   「Outlined」示例才额外加了 `border` 类（`border border-dashed`）。
//   Qt 侧照样对齐：默认不描边，需要虚线框时 bordered: true（= 官方那个 border 类）。
//   不做成「默认实线」也不偷偷改语义，开关与官方类名一一对应。
//
// 用法:
//   ShadcnEmpty {
//       bordered: true                        // 需要虚线框时打开（官方 Outlined 示例）
//       ShadcnEmptyHeader {
//           ShadcnEmptyMedia { variant: ShadcnEmptyMedia.Variant.Icon; iconName: "inbox" }
//           ShadcnEmptyTitle { text: qsTr("暂无数据") }
//           ShadcnEmptyDescription { text: qsTr("还没有任何内容，先创建一条吧。") }
//       }
//       ShadcnEmptyContent {
//           ShadcnButton { text: qsTr("新建") }
//       }
//   }
Rectangle {
    id: root

    QtShadcnTheme { id: theme }

    // ── 公开 API ──
    // 是否绘制描边（官方默认无边：cn-empty 只声明了 border-style，没有宽度）
    property bool bordered: false
    // 描边是否虚线（官方 border-dashed；关掉 = 实线，等价于只加 border）
    property bool dashed: true
    property color borderColor: theme.border
    property int borderWidth: 1
    // 虚线节拍 [实线, 空白]，单位 px（实际长度 = 值 × borderWidth，QPainter 规则）
    property list<double> dashPattern: [4, 4]

    // 内边距 p-6 = 6 × spacing 单位(4px) = 24
    property int padding: Math.round(theme.spacingXs * 6)
    // 直接子项间距 gap-4 = 4 × 4px = 16
    property int spacing: Math.round(theme.spacingXs * 4)

    // 组合式子项进 ColumnLayout（与 ShadcnCard 的 contentColumn 同一套路）
    default property alias content: column.data

    implicitWidth: 320
    implicitHeight: column.implicitHeight + root.padding * 2

    // 放进 Layout 时不要被 implicitWidth 顶住（同 ShadcnCard）
    Layout.minimumWidth: 0

    // cn-empty 无背景类：默认透明；官方 bg-muted/30 那种示例对应 color: theme.muted
    color: "transparent"
    // rounded-xl = radius × 1.4（v4 派生刻度）
    radius: theme.radiusXl

    // 内容列：水平铺满内边距内区域，垂直居中（justify-center）。
    // 内容高于容器时退回 padding 起点，不越界。
    ColumnLayout {
        id: column

        x: root.padding
        // 宽度可能短暂为负（父项还没定宽），clamp 掉免得触发绑定告警
        width: Math.max(0, root.width - root.padding * 2)
        y: Math.max(root.padding, (root.height - column.implicitHeight) / 2)
        spacing: root.spacing

        // CSS 的 items-center：直接子项默认水平居中。子项自己写过
        // Layout.alignment 时尊重它（如 Header/Content 的 max-w-sm 居中也是这么来的）。
        // QML 无法跨文件共享函数，ShadcnEmptyHeader / ShadcnEmptyContent 里是同名副本。
        function centerChildren() {
            for (let i = 0; i < column.children.length; ++i) {
                const child = column.children[i]
                if (!child.Layout.alignment)
                    child.Layout.alignment = Qt.AlignHCenter
            }
        }

        onChildrenChanged: centerChildren()
        Component.onCompleted: centerChildren()
    }

    // 虚线描边：画在内容之上（内容有 p-6 内边距，正常不会重叠）
    Shape {
        id: borderShape

        objectName: "borderShape"
        anchors.fill: parent
        antialiasing: true
        visible: root.bordered

        // 路径内缩半个线宽：描边居中在路径上，不内缩会有一半画到容器外被裁掉
        readonly property real _inset: root.borderWidth / 2
        // 圆角不能超过「短边一半 - 内缩」，否则半径退化、路径自交
        readonly property real _r: Math.max(0, Math.min(root.radius,
                                                        Math.min(width, height) / 2 - _inset))

        ShapePath {
            id: borderPath

            objectName: "borderPath"
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            strokeStyle: root.dashed ? ShapePath.DashLine : ShapePath.SolidLine
            dashPattern: root.dashPattern

            // 顺时针：上边 → 右上角 → 右边 → 右下角 → 下边 → 左下角 → 左边 → 左上角
            startX: borderShape._inset + borderShape._r
            startY: borderShape._inset

            PathLine {
                x: borderShape.width - borderShape._inset - borderShape._r
                y: borderShape._inset
            }
            PathArc {
                x: borderShape.width - borderShape._inset
                y: borderShape._inset + borderShape._r
                radiusX: borderShape._r
                radiusY: borderShape._r
            }
            PathLine {
                x: borderShape.width - borderShape._inset
                y: borderShape.height - borderShape._inset - borderShape._r
            }
            PathArc {
                x: borderShape.width - borderShape._inset - borderShape._r
                y: borderShape.height - borderShape._inset
                radiusX: borderShape._r
                radiusY: borderShape._r
            }
            PathLine {
                x: borderShape._inset + borderShape._r
                y: borderShape.height - borderShape._inset
            }
            PathArc {
                x: borderShape._inset
                y: borderShape.height - borderShape._inset - borderShape._r
                radiusX: borderShape._r
                radiusY: borderShape._r
            }
            PathLine {
                x: borderShape._inset
                y: borderShape._inset + borderShape._r
            }
            PathArc {
                x: borderShape._inset + borderShape._r
                y: borderShape._inset
                radiusX: borderShape._r
                radiusY: borderShape._r
            }
        }
    }
}

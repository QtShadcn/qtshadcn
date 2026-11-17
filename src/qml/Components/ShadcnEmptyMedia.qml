import QtQuick
import QtQuick.Layouts
import QtShadcn

// 空状态图示：图标 / 头像等视觉元素，默认无底色，variant = Icon 时是 size-8 的带底色方块
// 对齐 cn-empty-media:
//   base         = mb-2 flex shrink-0 items-center justify-center
//   variant 默认 = bg-transparent
//   variant icon = flex size-8 shrink-0 items-center justify-center rounded-lg
//                  bg-muted text-foreground [&_svg:not([class*='size-'])]:size-4
//   （size-8 = 32 / rounded-lg = theme.radiusLg / bg-muted / svg 默认 16 = size-4）
//
// 用法:
//   ShadcnEmptyMedia { variant: ShadcnEmptyMedia.Variant.Icon; iconName: "inbox" }
//   ShadcnEmptyMedia { ShadcnIcon { name: "inbox"; size: 16 } }   // 等价手写
//   ShadcnEmptyMedia { ShadcnAvatar { text: "CN" } }               // 默认变体放任意元素
//
// 只托一个视觉元素（官方也是单个 <svg> / <Avatar>）。放多个请自己套 Row/Column。
Item {
    id: root

    enum Variant { Default, Icon }

    // ── 公开 API ──
    property int variant: ShadcnEmptyMedia.Variant.Default
    // 便捷用法：直接给 lucide 图标名，内部用 ShadcnIcon 渲染（与 ShadcnAvatar.iconName 同风格）
    property string iconName: ""
    property color iconColor: theme.foreground

    QtShadcnTheme { id: theme }

    readonly property bool _isIcon: variant === ShadcnEmptyMedia.Variant.Icon

    // size-8 = 32（icon 变体方块边长）/ size-4 = 16（icon 变体里的 svg 尺寸）
    readonly property int _boxSize: 32
    // 默认变体的 svg 不受 size-4 限制，用 lucide 设计尺寸 24
    readonly property int _iconSize: root._isIcon ? 16 : 24

    // 是否塞了子项：决定要不要退回 iconName 便捷图标。
    // 不能读 root.content.length（default alias 指向 data，QQmlListProperty 的 length 不可靠），
    // 用子项数信号驱动才稳。
    property int _childCount: 0
    readonly property bool _autoIcon: root.iconName.length > 0 && root._childCount === 0

    // 尺寸：icon 变体是固定方块；默认变体跟随内容（便捷图标时就是图标尺寸）
    implicitWidth: root._isIcon ? root._boxSize
                                : (root._autoIcon ? root._iconSize : contentHost.width)
    implicitHeight: root._isIcon ? root._boxSize
                                 : (root._autoIcon ? root._iconSize : contentHost.height)

    // mb-2：与下一个子项之间留 8px（在 ColumnLayout 里生效；不在布局里时无副作用）
    Layout.bottomMargin: 8

    // 底色方块：只有 icon 变体有（default 是 bg-transparent）
    Rectangle {
        id: box

        objectName: "mediaBox"
        anchors.fill: parent
        color: theme.muted      // bg-muted
        radius: theme.radiusLg  // rounded-lg
        visible: root._isIcon
    }

    // 内容宿主：居中（items-center justify-center），尺寸跟随子项 → 调用方不用写 width/height。
    // 子项按 0,0 摆放（由 childrenRect 撑开宿主），宿主再整体锚在父项中心；
    // 单元素时「左上角对齐 = 居中」，且避免「anchors.centerIn 依赖父宽、父宽又依赖
    // childrenRect」的循环绑定（循环时几何恒为 0）。
    Item {
        id: contentHost

        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height

        onChildrenChanged: root._childCount = children.length
    }

    // 组合式：子项进 contentHost（与 ShadcnCard 的 content 别名同一套路）
    default property alias content: contentHost.data

    // 便捷图标：iconName 非空且没有塞子项时，自动渲染一个居中的 ShadcnIcon
    ShadcnIcon {
        objectName: "mediaIcon"
        anchors.centerIn: parent
        visible: root._autoIcon
        name: root.iconName
        size: root._iconSize
        color: root.iconColor
    }
}

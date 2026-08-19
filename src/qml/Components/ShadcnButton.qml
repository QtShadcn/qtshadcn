import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格按钮
// 基于 QQC Button（Basic style）：键盘导航 / Focus / 无障碍继承，只替换视觉与 API
// 注意：自定义 contentItem/background 的文件使用 style-specific import
// （QtQuick.Controls.Basic），锁定 Basic 风格是 token 自绘的前提
//
// 用法:
//   ShadcnButton {
//       text: "Deploy"
//       variant: ShadcnButton.Variant.Primary   // Primary/Secondary/Outline/Ghost/Destructive
//       size: ShadcnButton.Size.Medium          // Small/Medium/Large/Icon
//       loading: false
//       onClicked: ...
//   }
Button {
    id: root

    // 选中时 z 提升：组内 spacing:-1 相邻按钮重叠 1px（后声明者盖前者右缘），
    // 选中按钮盖住相邻按钮左缘，保证自身右缘描边完整（否则右缘 1px 被盖，
    // 曾表现为"选中项右侧边框不存在"）
    z: root._checked ? 1 : 0

    enum Variant { Primary, Secondary, Outline, Ghost, Destructive, Link }
    enum Size { ExtraSmall, Small, Medium, Large, Icon }

    // ── 公开 API ──
    property int variant: ShadcnButton.Variant.Primary
    property int size: ShadcnButton.Size.Medium
    property bool loading: false
    // 图标（lucide 名，见 IconRegistry.names）：显示在文本左侧（shadcn 带图标按钮）
    property string iconName: ""

    // ShadcnButtonGroup / ShadcnToggleGroup 内部使用：'only' | 'first' | 'middle' | 'last'
    property string _groupPosition: "only"

    QtShadcnTheme { id: theme }
    VariantTokens { id: vt }

    // ── 尺寸表（对齐 shadcn/ui：xs=32 / sm=36 / default=40 / lg=44 / icon=40）──
    readonly property int _ctrlHeight: size === ShadcnButton.Size.ExtraSmall ? 32
        : size === ShadcnButton.Size.Small ? 36
        : size === ShadcnButton.Size.Large ? 44 : 40   // Medium / Icon
    readonly property int _hPad: size === ShadcnButton.Size.ExtraSmall ? 10
        : size === ShadcnButton.Size.Small ? 12
        : size === ShadcnButton.Size.Large ? 32 : 16   // shadcn px-8=32 / px-4=16
    readonly property int _fontSize: size === ShadcnButton.Size.ExtraSmall ? 12
        : size === ShadcnButton.Size.Small ? 12 : 14   // text-sm
    readonly property bool _isIcon: size === ShadcnButton.Size.Icon

    implicitWidth: _isIcon ? _ctrlHeight : contentItem.implicitWidth + _hPad * 2
    implicitHeight: _ctrlHeight

    // ── 配色：variant → token 查表（映射集中在 VariantTokens，新增 variant
    //    只需枚举 + 映射表各加一项；token 名经 theme.tokens[] 查询保持绑定）──
    readonly property bool _checked: checkable && checked
    readonly property var _variantMap: vt.button[root.variant] ?? vt.button[0]
    // 背景 token 不随 checked 切换（选中态视觉由 background 内的覆盖层负责——
    // 教训：bg 在 accent↔transparent 间 color 动画会 RGBA 插值出中间灰，点击时闪烁）
    readonly property string _bgToken: _variantMap.bg
    // 前景色随选中切换（文字色，无动画，瞬间切换不闪）
    readonly property string _fgToken: _checked ? vt.checkedOverride.fg : _variantMap.fg
    readonly property color _baseBg: _bgToken === "" ? "transparent" : theme.tokens[_bgToken]
    // hover 文字色：outline/ghost hover 时用 accentForeground（shadcn: hover:text-accent-foreground）
    readonly property color _baseFg: (root.hovered && (variant === ShadcnButton.Variant.Outline
                                      || variant === ShadcnButton.Variant.Ghost))
        ? theme.accentForeground : theme.tokens[_fgToken]
    readonly property bool _showBorder: _variantMap.border
    // 边框宽（outline 等 border variant 才有；组内 spacing:-1 合并）
    readonly property int _borderW: root._showBorder ? 1 : 0

    // hover/pressed 混合底色：选中时用覆盖层色（accent），否则用 variant 底色。
    // 教训：_bgToken 不随 checked 后，选中按钮的实际背景是 accent 覆盖层，
    // 若用 primary 等深色 variant 底色混合会叠出深灰（"选中项 hover 变黑"）
    readonly property color _hoverBase: _checked
        ? theme.tokens[vt.checkedOverride.bg] : _baseBg

    // hover 背景：outline/ghost → accent 色（shadcn: hover:bg-accent）；
    // 其余 → 按钮色与页面背景按 hoverMix 混合（等效 shadcn hover:bg-*/90|80：
    // 深色按钮变浅、浅色变暗，随主题背景色自动适配）。
    // 教训：固定黑 8% 在 light 模式 primary(#18181b 近黑)上黑上加黑，肉眼不可见。
    readonly property color _hoverOverlay: {
        if (variant === ShadcnButton.Variant.Outline || variant === ShadcnButton.Variant.Ghost)
            return theme.accent
        return _mix(_hoverBase, theme.background, _variantMap.hoverMix)
    }
    // pressed：混合比例加重（按压反馈更深）；accent 上叠黑 15% 压暗
    readonly property color _pressedOverlay: {
        if (variant === ShadcnButton.Variant.Outline || variant === ShadcnButton.Variant.Ghost)
            return Qt.rgba(0, 0, 0, 0.15)
        return _mix(_hoverBase, theme.background, Math.min(0.25, _variantMap.hoverMix * 2))
    }

    // a 向 b 按 t 混合（t=0.1 等效 shadcn /90：0.9×a + 0.1×b）
    function _mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t, a.b * (1 - t) + b.b * t, 1)
    }

    // 圆角：shadcn button 用 rounded-md = 6px（theme.radius 8 用于卡片/容器）
    readonly property int _r: 6
    readonly property int _tl: _groupPosition === "only" || _groupPosition === "first" ? _r : 0
    readonly property int _tr: _groupPosition === "only" || _groupPosition === "last" ? _r : 0
    readonly property int _bl: _groupPosition === "only" || _groupPosition === "first" ? _r : 0
    readonly property int _br: _groupPosition === "only" || _groupPosition === "last" ? _r : 0

    // ── 背景 ────────────────────────────────────────
    background: Rectangle {
        topLeftRadius: root._tl
        topRightRadius: root._tr
        bottomLeftRadius: root._bl
        bottomRightRadius: root._br
        color: root._baseBg
        border.width: root._borderW
        // 选中态描边用 accentForeground（light 下深色描边圈住选中项，弥补 accent 背景对比度弱；
        // dark 下自动变白色描边。保持 border token 语义不变）
        border.color: root.activeFocus ? theme.ring
            : root._checked ? theme.accentForeground : theme.border

        Behavior on color { ColorAnimation { duration: 120 } }

        // 组内分隔线：middle/last 左侧 1px（仅无 border 的 variant，如 Primary）
        // 用按钮自身前景色（primary 组 = 白色 primaryForeground，深底上可见；
        // 教训：theme.foreground 在 light 模式是深色，叠深色按钮上不可见）
        Rectangle {
            visible: (root._groupPosition === "middle" || root._groupPosition === "last")
                     && !root._showBorder
            width: 1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: Qt.rgba(root._baseFg.r, root._baseFg.g, root._baseFg.b, 0.15)
        }

        // 选中态覆盖层（checkable 用）：accent 背景 + opacity 动画。
        // 教训：background.color 在 accent↔transparent 间 ColorAnimation 会 RGBA 插值
        // 出中间灰（半透明灰叠白底，点击切换时闪烁）；opacity 动画 RGB 恒定不闪灰。
        // 内缩边框宽：outline 选中时保留 1px 边框
        Rectangle {
            anchors.fill: parent
            anchors.margins: root._borderW
            topLeftRadius: Math.max(0, parent.topLeftRadius - root._borderW)
            topRightRadius: Math.max(0, parent.topRightRadius - root._borderW)
            bottomLeftRadius: Math.max(0, parent.bottomLeftRadius - root._borderW)
            bottomRightRadius: Math.max(0, parent.bottomRightRadius - root._borderW)
            visible: root.checkable
            color: theme.tokens[vt.checkedOverride.bg]
            opacity: root._checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        // hover / pressed：背景色叠加（outline/ghost → accent；其余按亮度黑/白；link 无）
        // anchors.margins = 边框宽：不盖住 outline 的 1px 边框（否则 hover 时边框视觉消失）
        Rectangle {
            anchors.fill: parent
            anchors.margins: root._borderW
            topLeftRadius: Math.max(0, parent.topLeftRadius - root._borderW)
            topRightRadius: Math.max(0, parent.topRightRadius - root._borderW)
            bottomLeftRadius: Math.max(0, parent.bottomLeftRadius - root._borderW)
            bottomRightRadius: Math.max(0, parent.bottomRightRadius - root._borderW)
            visible: root.hovered && root.variant !== ShadcnButton.Variant.Link
            color: root._hoverOverlay
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: root._borderW
            topLeftRadius: Math.max(0, parent.topLeftRadius - root._borderW)
            topRightRadius: Math.max(0, parent.topRightRadius - root._borderW)
            bottomLeftRadius: Math.max(0, parent.bottomLeftRadius - root._borderW)
            bottomRightRadius: Math.max(0, parent.bottomRightRadius - root._borderW)
            visible: root.pressed && root.variant !== ShadcnButton.Variant.Link
            color: root._pressedOverlay
        }

        // 键盘焦点环（activeFocus，Tab 可达）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: root._r + 3
            visible: root.activeFocus
            color: "transparent"
            border.width: 2
            border.color: theme.ring
            opacity: 0.7
        }
    }

    // ── 内容 ────────────────────────────────────────
    // Item 包装：contentItem 会被 QQC 拉伸到内容区全宽，RowLayout 必须居中于
    // Item（anchors.centerIn）才能保证文字水平+垂直都居中（按钮被拉伸时也成立）；
    // RowLayout 内部子项默认垂直居中
    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: theme.spacingXs

            ShadcnSpinner {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                visible: root.loading
                color: root._baseFg
            }

            // 图标（iconName，shadcn 带图标按钮：svg size-4=16px，随文字色）
            ShadcnIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: root.iconName.length > 0
                name: root.iconName
                size: 16
                color: root._baseFg
            }

            Text {
                visible: root.text.length > 0
                text: root.text
                // 组属性限制：font 整体赋值后不能局部覆盖，故逐项复制
                font.family: root.font.family
                font.pixelSize: root._fontSize
                font.weight: Font.Medium          // shadcn: font-medium
                // link variant：hover/聚焦时显示下划线（shadcn: hover:underline）
                font.underline: root.variant === ShadcnButton.Variant.Link
                                && (root.hovered || root.activeFocus)
                color: root._baseFg
                opacity: root.loading ? 0.6 : 1
            }
        }
    }

    // loading：禁用交互；disabled/loading 半透明（shadcn: disabled:opacity-50）
    enabled: !root.loading
    opacity: root.loading || !root.enabled ? 0.5 : 1
}

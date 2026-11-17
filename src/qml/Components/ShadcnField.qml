pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段容器（Field 组的核心）
//
// 对照来源：registry JSON `base-nova/ui/field.json` 的 field.tsx（Fetched 2026-11-17）
//   cva("group/field flex w-full gap-2 data-[invalid=true]:text-destructive")
//   orientation: vertical   -> "flex-col *:w-full"
//                horizontal -> "flex-row items-center
//                                has-[>[data-slot=field-content]]:items-start
//                                *:data-[slot=field-label]:flex-auto …"
//                responsive -> "@md/field-group:flex-row …"（容器查询）
//
// 职责边界：Field 只做「label / 控件 / 描述 / 错误」的排版与间距，不含任何输入逻辑。
// 与 ShadcnInputGroup（输入框**内部**的前后缀 addon）不是一回事，二者可叠加：
//   ShadcnField { ShadcnFieldLabel {...}; ShadcnInputGroup { prefixIcon: "search" } }
//
// 用法:
//   ShadcnField {
//       ShadcnFieldLabel { text: qsTr("用户名"); required: true }
//       ShadcnInput { placeholderText: qsTr("小写字母") }
//       ShadcnFieldDescription { text: qsTr("仅支持小写与数字") }
//       ShadcnFieldError { text: "已被占用" }
//   }
//   ShadcnField { orientation: ShadcnField.Orientation.Horizontal
//       ShadcnFieldLabel { text: qsTr("订阅更新") }
//       ShadcnSwitch {}
//   }
//
// ── 设计决策 ──────────────────────────────────────────────
// 1) 组合式（Item + 默认属性收子项），不是属性驱动。
//    官方 Field 就是 <Field>{label}{control}{description}</Field> 的组合语义，
//    子项顺序即视觉顺序；属性驱动（如 label/description/error 三个字符串属性）
//    会把「控件本身」挤出容器，调用方反而要多写一层，也无法表达 FieldContent。
//    与 ShadcnCard 同款思路，但基类用 GridLayout 而非 ColumnLayout（理由见 2）。
// 2) 基类用 GridLayout 而不是 ColumnLayout/RowLayout。
//    官方 orientation 是同一个元素换 flex-direction，子项顺序不变。GridLayout 把
//    columns 从 1 改成「可见子项数」就等价于 flex-col / flex-row 切换，隐式高度、
//    换行、尺寸都由布局引擎算，不用维护两套容器或手写两遍几何。
// 3) 子项的 Layout.fillWidth 由 Field 统一接管。
//    CSS 侧是 *:w-full / *:w-auto 通配选择器，语义是「父容器决定子项宽度」。
//    QML 没有通配布局，只能在 onChildrenChanged 里给直接子项写 Layout 附加属性。
//    因此 Field 的直接子项不要再自己写 Layout.fillWidth（会被父容器覆盖）。
// 4) 错误态不自动探测控件。
//    官方要求应用自己同时写 data-invalid（配色）与 aria-invalid（无障碍），
//    因为「是不是有效」只有业务知道。Qt 侧同样由调用方绑定：
//      invalid: input.text.length === 0 && touched
//    子组件（Label/Title/Description）通过祖先查找读 invalid，等价于 CSS 的
//    data-[invalid=true]:text-destructive 继承行为。
// 5) responsive 跟了，但不是照搬 768px。
//    Qt 没有 CSS 媒体查询，也没有容器查询。这里把「容器宽度 >= 阈值」当作
//    @container/field-group 的等价物：优先取最近 ShadcnFieldGroup 的宽度
//    （官方断点就是挂在 field-group 上的），不在组里则退回自身宽度。
//    官方 @md = 768px，但 Qt 的 Field 常被塞进 320~420px 宽的卡片，照搬会让
//    responsive 永远走纵向、等于没做；因此阈值开放成 responsiveBreakpoint。
GridLayout {
    id: root

    // 官方 Prop: orientation "vertical" | "horizontal" | "responsive"，默认 vertical
    enum Orientation { Vertical, Horizontal, Responsive }

    // ── 公开 API ──
    property int orientation: ShadcnField.Orientation.Vertical
    // 错误态（官方 data-invalid）：整块文字转 text-destructive
    property bool invalid: false
    // responsive 的切换阈值（px）。默认取官方 @md 断点 768；
    // 放在窄卡片里时按需调小（如 420）
    property int responsiveBreakpoint: 768

    QtShadcnTheme { id: theme }

    // 子组件向上认亲用的标记（CSS 的 group/field 语义）
    readonly property bool __isShadcnField: true

    // 当前生效的排布方向（responsive 按容器宽度解析成二者之一）
    readonly property int resolvedOrientation: {
        if (root.orientation !== ShadcnField.Orientation.Responsive)
            return root.orientation
        // 容器查询等价物：优先用最近的 FieldGroup 宽度（官方断点挂在 field-group 上）
        var o = root.parent
        var w = root.width
        while (o !== null && !("__isShadcnFieldGroup" in o))
            o = o.parent
        if (o !== null && o.width > 0)
            w = o.width
        return w >= root.responsiveBreakpoint
                ? ShadcnField.Orientation.Horizontal
                : ShadcnField.Orientation.Vertical
    }

    readonly property bool _isHorizontal: root.resolvedOrientation === ShadcnField.Orientation.Horizontal

    // 横向时每个可见子项占一列；隐藏的 FieldError 不占列（否则多出一个空列）。
    // 纵向恒为 1 列（等价 flex-col）。
    readonly property int _visibleChildCount: {
        var n = 0
        for (var i = 0; i < root.children.length; ++i) {
            if (root.children[i].visible)
                ++n
        }
        return n
    }

    columns: root._isHorizontal ? Math.max(1, root._visibleChildCount) : 1
    rowSpacing: theme.spacingSm      // gap-2 = 8px
    columnSpacing: theme.spacingSm   // gap-2 = 8px

    // 放进 Layout 时不要被隐式宽度顶住（同 ShadcnCard 的处理）
    Layout.minimumWidth: 0

    // 记录「Field 亲手写过的」Layout 附加属性：切换 orientation 时只回滚自己写过
    // 的那部分，不碰调用方显式设置的值
    property var _managed: []

    function _syncLayout() {
        var kids = root.children
        var prev = root._managed
        var next = []
        var horizontal = root._isHorizontal

        // 官方 horizontal: items-center；但一旦有 FieldContent 就 items-start
        // （说明文字贴顶，控件与 label 首行对齐）
        var hasContent = false
        for (var k = 0; k < kids.length; ++k) {
            if ("__isFieldContent" in kids[k]) {
                hasContent = true
                break
            }
        }

        for (var i = 0; i < kids.length; ++i) {
            var c = kids[i]
            var rec = null
            for (var j = 0; j < prev.length; ++j) {
                if (prev[j].item === c) {
                    rec = prev[j]
                    break
                }
            }
            if (rec === null)
                rec = { item: c, fill: false, align: false }

            // 纵向 *:w-full；横向只有 FieldLabel/FieldContent 这类 flex-auto 项拉伸，
            // 控件保持自然尺寸（等价 *:w-auto）
            // 横向时**显式**把非 flex 项按回 w-auto：否则子项自己声明的
            // Layout.fillWidth（如 FieldDescription 为换行而写的 true）会残留下来，
            // 把「控件/说明保持自然宽度」这条打破
            var flex = horizontal ? ("__fieldFlex" in c) : true
            if (flex) {
                c.Layout.fillWidth = true
                rec.fill = true
            } else if (rec.fill || c.Layout.fillWidth) {
                c.Layout.fillWidth = false
                rec.fill = false
            }

            if (horizontal) {
                if (!rec.align) {
                    c.Layout.alignment = hasContent ? Qt.AlignTop : Qt.AlignVCenter
                    rec.align = true
                }
            } else if (rec.align) {
                c.Layout.alignment = 0
                rec.align = false
            }

            next.push(rec)
        }
        root._managed = next
    }

    onChildrenChanged: root._syncLayout()
    onResolvedOrientationChanged: root._syncLayout()
    Component.onCompleted: root._syncLayout()

    // 官方 role="group"：让嵌套控件从 FieldLabel/FieldLegend 继承标签
    Accessible.role: Accessible.Grouping
}

import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段集标题（FieldLegend）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldLegend =
//   <legend class="mb-1.5 font-medium data-[variant=label]:text-sm
//                   data-[variant=legend]:text-base">
// 两个 variant：
//   Legend（默认）text-base 16px / Label text-sm 14px（嵌套 FieldSet 时用，与
//   FieldLabel 字号对齐）。两者都是 font-medium，下方 mb-1.5 = 6px。
//
// 用法:
//   ShadcnFieldLegend { text: qsTr("通知设置") }
//   ShadcnFieldLegend { text: qsTr("高级"); variant: ShadcnFieldLegend.Variant.Label }
Text {
    id: root

    enum Variant { Legend, Label }

    // ── 公开 API ──
    property int variant: ShadcnFieldLegend.Variant.Legend

    QtShadcnTheme { id: theme }

    // FieldSet 用它判断「Description 是否紧跟 Legend」（官方相邻兄弟选择器）
    readonly property bool __isShadcnFieldLegend: true

    // 在 FieldContent / FieldSet / FieldGroup 这些 ColumnLayout 里，不声明
    // fillWidth 的 Text 会停在 implicitWidth 上 —— 长文案不换行、直接溢出。
    // 放进横向 Field 时由 Field 统一按回 w-auto。
    Layout.fillWidth: true

    color: theme.foreground
    font.pixelSize: root.variant === ShadcnFieldLegend.Variant.Label ? 14 : 16
    font.weight: Font.Medium   // font-medium
    wrapMode: Text.WordWrap

    // mb-1.5 = 6px。在 FieldSet 的 ColumnLayout 里用 Layout 附加属性表达；
    // 单独使用时没有布局，该属性也无害（Layout 属性对非布局子项是空操作）
    Layout.bottomMargin: theme.spacingSm - theme.spacingXs / 2   // mb-1.5 = 6px

    Accessible.role: Accessible.Heading
}

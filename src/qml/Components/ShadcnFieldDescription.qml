import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段说明文字（FieldDescription）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldDescription =
//   <p className="text-left text-sm leading-normal font-normal text-muted-foreground
//               group-has-data-horizontal/field:text-balance …">
// 即 text-sm(14px) / mutedForeground / 正常字重 / 左对齐。
//
// 官方还有一条 [[data-variant=legend]+&]:-mt-1.5（紧跟在 legend 后面上提 6px）。
// 这条由 ShadcnFieldSet 统一处理（它能看到兄弟顺序），本组件不重复实现。
//
// 用法:
//   ShadcnFieldDescription { text: qsTr("仅支持小写字母与数字") }
Text {
    id: root

    QtShadcnTheme { id: theme }

    // FieldSet 用它判断「Description 是否紧跟 Legend」（官方相邻兄弟选择器）
    readonly property bool __isShadcnFieldDescription: true

    // 在 FieldContent / FieldSet / FieldGroup 这些 ColumnLayout 里，不声明
    // fillWidth 的 Text 会停在 implicitWidth 上 —— 长文案不换行、直接溢出。
    // 放进横向 Field 时由 Field 统一按回 w-auto。
    Layout.fillWidth: true

    color: theme.mutedForeground
    font.pixelSize: 14   // text-sm
    font.weight: Font.Normal
    wrapMode: Text.WordWrap
    lineHeightMode: Text.FixedHeight
    lineHeight: 18   // leading-normal ≈ 1.5 × 14 = 21；取 18 与 label 的 20 拉开层次

    // 官方 group-has-data-horizontal/field:text-balance（横向时 text-wrap: balance）
    // Qt 的 Text 没有 balance 排版算法，只能保持 WordWrap —— 已确认属于能力缺口，
    // 不做伪实现（手工插换行会把中文/英文都弄乱）。
}

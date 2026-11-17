import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段标题（FieldTitle）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldTitle =
//   <div data-slot="field-label" class="flex w-fit items-center gap-2 text-sm
//        font-medium group-data-[disabled=true]/field:opacity-50">
// 与 FieldLabel 的差别只有一处：不带 label 的交互态样式，专门用于
// **FieldContent 内部**（label 在控件旁边、描述在下面时，标题不该是可点击 label）。
// 注意官方它的 data-slot 也写成 "field-label"（registry 原文如此，疑似笔误；
// 因此 CSS 的 *:data-[slot=field-label]:flex-auto 会一并命中它 —— Qt 侧同样给
// __fieldFlex = true，行为与官方一致）。
//
// 用法:
//   ShadcnField {
//       ShadcnCheckbox {}
//       ShadcnFieldContent {
//           ShadcnFieldTitle { text: qsTr("启用 Touch ID") }
//           ShadcnFieldDescription { text: qsTr("更快解锁设备") }
//       }
//   }
Text {
    id: root

    QtShadcnTheme { id: theme }

    // 横向排布时与 FieldLabel 同等对待（flex-auto）
    readonly property bool __fieldFlex: true

    // 在 FieldContent / FieldSet / FieldGroup 这些 ColumnLayout 里，不声明
    // fillWidth 的 Text 会停在 implicitWidth 上 —— 长文案不换行、直接溢出。
    // 放进横向 Field 时由 Field 统一按回 w-auto。
    Layout.fillWidth: true

    // 与 FieldLabel 相同：跟随父级 Field 的 invalid / disabled
    property var __fieldOwner: {
        var o = root.parent
        while (o !== null && !("__isShadcnField" in o))
            o = o.parent
        return o
    }
    readonly property bool __fieldInvalid: root.__fieldOwner !== null && root.__fieldOwner.invalid === true
    readonly property bool __fieldDisabled: root.__fieldOwner !== null && root.__fieldOwner.enabled === false

    color: root.__fieldInvalid ? theme.destructive : theme.foreground
    font.pixelSize: 14   // text-sm
    font.weight: Font.Medium
    wrapMode: Text.WordWrap
    opacity: root.__fieldDisabled ? 0.5 : 1
}

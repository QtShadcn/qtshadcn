import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段内容块（FieldContent）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldContent =
//   <div data-slot="field-content" class="group/field-content flex flex-1 flex-col
//        gap-0.5 leading-snug">
// 用途：横向排布时把 **label + description** 打包成一列放在控件旁边，
// 这样描述文字与标题左对齐，而不是横到控件底下（官方 docs「Composition」）。
// 没有描述时不需要它（直接 FieldLabel 即可）。
//
// 它在 Field 里承担「flex-auto」角色：吃掉剩余宽度，控件保持自然宽度。
//
// 用法:
//   ShadcnField {
//       orientation: ShadcnField.Orientation.Horizontal
//       ShadcnSwitch {}
//       ShadcnFieldContent {
//           ShadcnFieldTitle { text: qsTr("订阅更新") }
//           ShadcnFieldDescription { text: qsTr("每周一封") }
//       }
//   }
ColumnLayout {
    id: root

    QtShadcnTheme { id: theme }

    // Field 的横向布局判据：有 FieldContent 时 items-start（对齐 CSS
    // has-[>[data-slot=field-content]]:items-start）
    readonly property bool __isFieldContent: true
    // flex-auto：横向时吃掉剩余宽度
    readonly property bool __fieldFlex: true

    // gap-0.5 = 2px。仓库刻度最小 4px(spacingXs)，这里用 2 表达 0.5 档
    // （shadcn 的 0.5 档在 Qt 侧没有对应 token，且 4px 会让 title 与 description 分家）
    spacing: 2

    // 不写 Layout.fillWidth：由父级 ShadcnField 统一接管（见其注释第 3 条）

    // leading-snug：子项行高由 ShadcnFieldTitle / FieldDescription 各自设置
}

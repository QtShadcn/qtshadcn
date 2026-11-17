import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段组（FieldGroup）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldGroup =
//   <div class="group/field-group @container/field-group flex w-full flex-col gap-5
//               data-[slot=checkbox-group]:gap-3 *:data-[slot=field-group]:gap-4">
// 即：纵向堆叠 Field，间距 gap-5(20px)；嵌套 FieldGroup 时收成 gap-4(16px)。
//
// 它同时是官方 responsive orientation 的**容器查询宿主**（@container/field-group）：
// ShadcnField 的 Responsive 变体按本组件宽度判断是否并排，所以 Field 一定要放在
// FieldGroup 里才能得到官方语义（见 ShadcnField 的注释）。
//
// 用法:
//   ShadcnFieldGroup {
//       ShadcnField { ... }
//       ShadcnFieldSeparator { text: qsTr("或") }
//       ShadcnField { ... }
//   }
ColumnLayout {
    id: root

    QtShadcnTheme { id: theme }

    // ShadcnField 的 responsive 用它当容器查询宿主
    readonly property bool __isShadcnFieldGroup: true

    // gap-5 = 20px。仓库 spacing 刻度最大到 spacingXl(24)，没有 20 这一档，
    // 用 spacingLg(16) + spacingXs(4) 表达，避免出现裸数字
    spacing: theme.spacingLg + theme.spacingXs

    Layout.fillWidth: true

    // 官方 *:data-[slot=field-group]:gap-4 —— 嵌套的 FieldGroup 间距收一档。
    // 用 onChildrenChanged 统一改写，调用方不用记这条
    onChildrenChanged: {
        for (var i = 0; i < root.children.length; ++i) {
            var c = root.children[i]
            if ("__isShadcnFieldGroup" in c)
                c.spacing = theme.spacingLg   // gap-4 = 16px
        }
    }

    Accessible.role: Accessible.Grouping
}

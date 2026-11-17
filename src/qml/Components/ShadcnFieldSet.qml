import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段集（FieldSet）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldSet =
//   <fieldset class="flex flex-col gap-4 has-[>[data-slot=checkbox-group]]:gap-3
//                    has-[>[data-slot=radio-group]]:gap-3">
// 语义容器：Legend + Description + FieldGroup 三件套，间距 gap-4(16px)，
// 内部有 checkbox-group / radio-group 时收成 gap-3(12px)（本库无这两个内部标记，
// 该分支不实现 —— 需要时由调用方直接设 spacing）。
//
// Qt 侧对齐语义：Accessible.role = Grouping（等价 fieldset 的分组语义）。
//
// 用法:
//   ShadcnFieldSet {
//       ShadcnFieldLegend { text: qsTr("通知设置") }
//       ShadcnFieldDescription { text: qsTr("选择你希望接收的通知") }
//       ShadcnFieldGroup { ... }
//   }
ColumnLayout {
    id: root

    QtShadcnTheme { id: theme }

    readonly property bool __isShadcnFieldSet: true

    spacing: theme.spacingLg   // gap-4 = 16px

    Layout.fillWidth: true

    Accessible.role: Accessible.Grouping

    // 官方 [[data-variant=legend]+&]:-mt-1.5 —— Description 紧跟 Legend 时上提 6px。
    // CSS 是靠选择器完成的，QML 没有相邻兄弟选择器，只能在容器里显式处理：
    // 用 Layout.topMargin 拉近（-6px = -(spacingMd / 2)）
    onChildrenChanged: {
        for (var i = 1; i < root.children.length; ++i) {
            var prev = root.children[i - 1]
            var cur = root.children[i]
            if ("__isShadcnFieldLegend" in prev && "__isShadcnFieldDescription" in cur)
                cur.Layout.topMargin = -(theme.spacingMd / 2)
        }
    }
}

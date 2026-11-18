import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格单选组
// 对齐 shadcn radio-group：grid gap-3（12px 间距）+ 单选互斥（同组仅一个选中）。
// 子项放 ShadcnRadio，互斥由 QQC ButtonGroup（exclusive）提供，键盘方向键切换。
//
// 用法:
//   ShadcnRadioGroup {
//       ShadcnRadio { text: "默认"; checked: true }
//       ShadcnRadio { text: "自定义" }
//   }
Column {
    id: root

    spacing: 12   // shadcn grid gap-3

    // 暴露 ButtonGroup（可用 buttons 数组 / checkedButton 查询）
    property alias buttons: bg.buttons
    property alias checkedButton: bg.checkedButton

    ButtonGroup {
        id: bg
        exclusive: true
    }

    // 坑：QQC ButtonGroup 的自动收集发生在 componentComplete（早于使用方子项创建），
    // 子 RadioButton 在此收集不到 → 组恒空、互斥不生效。延迟到 onCompleted 手动加入。
    Component.onCompleted: {
        for (var i = 0; i < root.children.length; ++i) {
            var c = root.children[i]
            if (c instanceof RadioButton)
                bg.buttons.push(c)
        }
    }
}

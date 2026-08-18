import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// 切换按钮组：圆角合并 + 可选互斥（单选/多选）
// 用法:
//   ShadcnToggleGroup {          // 多选（默认）
//       ShadcnToggle { text: "粗体" }
//       ShadcnToggle { text: "斜体" }
//   }
//   ShadcnToggleGroup { exclusive: true }   // 单选
ShadcnButtonGroup {
    id: root

    // true = 单选（同组仅一个 on）；false = 多选
    property bool exclusive: false

    ButtonGroup {
        id: bg
        exclusive: root.exclusive
    }

    // 坑：QQC ButtonGroup 的自动收集发生在 componentComplete（早于使用方子项创建），
    // 子 Toggle 在此收集不到 → 组恒空、exclusive 不生效（曾表现为"单选组实际多选"）。
    // 延迟到 onCompleted（此时子项已全部创建）手动加入组
    Component.onCompleted: {
        for (var i = 0; i < root.children.length; ++i) {
            var c = root.children[i]
            if (c instanceof Button)
                bg.buttons.push(c)
        }
    }
}

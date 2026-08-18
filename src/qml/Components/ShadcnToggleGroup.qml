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
        exclusive: root.exclusive
    }
}

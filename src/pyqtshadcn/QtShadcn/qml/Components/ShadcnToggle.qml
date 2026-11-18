import QtQuick
import QtShadcn

// shadcn/ui 风格切换按钮：outline 样式 + checkable，选中时 accent 背景
// 用法:
//   ShadcnToggle { text: "粗体" }
ShadcnButton {
    checkable: true
    variant: ShadcnButton.Variant.Outline
}

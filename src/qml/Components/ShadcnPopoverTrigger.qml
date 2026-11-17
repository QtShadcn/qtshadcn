// src/qml/Components/ShadcnPopoverTrigger.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格 Popover 触发按钮（issue #5）
// 本质就是一个 Button：官方 popover-trigger 也是「任意可聚焦元素」，Qt 侧直接
// 复用 ShadcnButton（键盘 / Focus / 无障碍白拿）。根组件按 objectName 收集它。
ShadcnButton {
    id: root
    objectName: "trigger"
}

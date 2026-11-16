// src/qml/Components/ShadcnScrollBar.qml
import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格滚动条（M3 导航与菜单 / Scroll Area）
//
// 对齐 shadcn scroll-area.tsx 的 ScrollBar：
//   vertical   : h-full w-2.5 border-l border-l-transparent   → 轨道占宽 10px
//   容器 p-px  : 1px padding                                  → thumb 实际 8px
//   thumb      : flex-1 rounded-full bg-border                 → 全圆角 + theme.border
//
// 单独抽成一个组件（而不是只在 ShadcnScrollArea 内部用）是因为库里有三处各自
// 附着了默认样式的 ScrollBar：Textarea 的 Flickable、DialogContent 的 ScrollView、
// Table 的 TableView。滚条样式散落各处，改一次得改三处。
//
// 用法（attach 到任意 Flickable / ScrollView / TableView / ListView）：
//   Flickable { ScrollBar.vertical: ShadcnScrollBar { policy: ScrollBar.AsNeeded } }
//   TableView { ScrollBar.vertical: ShadcnScrollBar {} }
ScrollBar {
    id: control

    QtShadcnTheme { id: theme }

    // 10px = shadcn w-2.5。竖直条取 implicitWidth、水平条取 implicitHeight，
    // 另一个方向由父容器布局覆盖，所以两个都给 10 是安全的。
    implicitWidth: 10
    implicitHeight: 10

    // 对应 shadcn 容器的 p-px：thumb 与轨道边缘留 1px
    padding: 1

    // 无轨道背景（shadcn 的 ScrollBar 只有 thumb，没有 track）
    background: Item {}

    contentItem: Rectangle {
        objectName: "thumb"
        implicitWidth: 8
        implicitHeight: 8

        // 关键：Qt 的 ScrollBar.policy 只控制「滚动条自身」的 visible，
        // AsNeeded 并不会在内容放得下时把控件隐藏（实测默认 ScrollBar 在
        // size=1 时 visible 依然是 true）。Qt Basic 的做法是让 contentItem
        // 自己判断 size < 1.0 —— 否则内容刚好放得下时会显示一根占满整个
        // 轨道的粗条，看起来像装饰条。这里必须照做。
        //
        // AlwaysOn 要额外放行：它的语义是「即使不需要滚动也显示」，
        // 若仍被 size < 1.0 卡住，AlwaysOn 就退化成了 AsNeeded
        // （此时 size=1 → thumb 撑满轨道，与 Radix type="always" 一致）。
        visible: control.policy === ScrollBar.AlwaysOn || control.size < 1.0

        // rounded-full：短边的一半即全圆角。用 min 而不是写死 4 ——
        // 水平条的 thumb 高度是 8，圆角同样取 4，两个方向一致
        radius: Math.min(width, height) / 2

        // shadcn 恒定 bg-border；pressed 加深是根据桌面端习惯补的拖拽反馈
        // （Web 版靠浏览器指针态表达，桌面没有等价物）
        color: control.pressed ? theme.mutedForeground : theme.border
        Behavior on color { ColorAnimation { duration: 100 } }
    }
}

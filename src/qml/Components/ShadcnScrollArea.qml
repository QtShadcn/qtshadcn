// src/qml/Components/ShadcnScrollArea.qml
import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格滚动区域（M3 导航与菜单 / Scroll Area）
//
// 对齐 shadcn scroll-area.tsx 的组成：
//   ScrollArea（Root）
//   └── Viewport（size-full rounded-[inherit]）
//   └── ScrollBar（横向需显式 orientation="horizontal"）
//
// 用法（内容放一个布局根，尺寸交给调用方指定）：
//   ShadcnScrollArea {
//       width: 350; height: 200
//       Column { width: parent.width; Repeater { ... } }
//   }
//
// 为什么基座是 Flickable 而不是 ScrollView —— 这是实测出来的，不是偏好：
// ScrollView **不会拉伸它 attached 的 ScrollBar 的几何**。实测
//   ScrollView { ScrollBar.vertical: ScrollBar {} }  → bar.height 停在 10px
//                                                      （implicitHeight，不是视口高）
// 于是 thumb 高度 = size × 10，内容再长也只有 6~10px，视觉上是个小圆点。
// 连 Qt 自带的 Basic ScrollBar 都是这样，不是自定义组件的问题。
// 换成 Flickable 后 bar.height = 398（视口高），thumb 按比例 131px，正常。
//
// 代价是内容尺寸要自己推导：Flickable 不会像 ScrollView 那样自动取
// 单个内容根的 implicitWidth/Height，所以下面显式绑定 contentWidth/Height。
Flickable {
    id: root

    // 滚动条显隐策略，直接透传给内部 ShadcnScrollBar
    property alias verticalPolicy: vbar.policy
    property alias horizontalPolicy: hbar.policy

    // shadcn 的默认只挂竖直条，横向要显式加 <ScrollBar orientation="horizontal"/>；
    // Qt 这边默认两向 AsNeeded —— 因为 Flickable 本来就支持横向拖动，
    // 隐藏条而不禁拖动会变成「能滚但看不见」的困惑体验。
    // 要严格对齐 shadcn 就把 horizontalPolicy 设为 ScrollBar.AlwaysOff。

    // 内容溢出时不要有橡皮筋回弹（桌面端列表的预期是滚到底就停）
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    // 内容尺寸：不能让 contentWidth 直接读 contentItem.childrenRect ——
    // Flickable 会把 contentItem 的尺寸设成 contentWidth/contentHeight，
    // 而 childrenRect 又建立在 contentItem 之上，两者互相触发，
    // 实测稳定复现 "Binding loop detected for property contentWidth"。
    //
    // 所以在中间放一个**不受 Flickable 管理**的 host Item：
    // host 的尺寸只由自己的 childrenRect 决定，contentWidth 再读 host 的
    // implicit 尺寸，链路是单向的（host ↔ 子项），不再回环。
    contentWidth: host.implicitWidth
    contentHeight: host.implicitHeight

    // 用户内容统一进 host（默认属性转发到 host.data）。
    // 注意子项的宽度不要写成 parent.width —— host.width 来自 childrenRect，
    // 形成 host ↔ 子项的回环。固定宽或绑 ShadcnScrollArea 的 id 都可以。
    default property alias contentData: host.data

    Item {
        id: host
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    ScrollBar.vertical: ShadcnScrollBar {
        id: vbar
        objectName: "verticalBar"
        policy: ScrollBar.AsNeeded
        parent: root
    }

    ScrollBar.horizontal: ShadcnScrollBar {
        id: hbar
        objectName: "horizontalBar"
        orientation: Qt.Horizontal
        policy: ScrollBar.AsNeeded
        parent: root
    }
}

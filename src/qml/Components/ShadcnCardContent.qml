import QtQuick
import QtQuick.Layouts

// 卡片内容区：透传容器，业务内容直接放（对齐 shadcn cn-card-content）
// 宽度由 ShadcnCard 的 ColumnLayout 管理（Layout.fillWidth）。
//
// 需要撑满卡片剩余高度时，在调用方写 Layout.fillHeight: true，
// 不要再手算「卡片高 - Header - Footer - 内边距」。
Item {
    id: root

    Layout.fillWidth: true

    // 设了 fillHeight 时高度由 Layout 决定，此时不能再用 childrenRect 反推
    // 隐式高度（子项若 anchors.fill: parent 会形成绑定循环）
    implicitHeight: root.Layout.fillHeight ? 0 : childrenRect.height
}

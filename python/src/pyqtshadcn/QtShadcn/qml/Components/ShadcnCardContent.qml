import QtQuick

// 卡片内容区：透传容器，业务内容直接放（对齐 shadcn cn-card-content）
Item {
    id: root

    width: parent ? parent.width : implicitWidth
    implicitHeight: childrenRect.height
}

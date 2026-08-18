import QtQuick
import QtShadcn

// shadcn/ui 风格 Dialog 内容容器：p-6 + gap-6 垂直堆叠（对齐 shadcn cn-dialog-content）
Item {
    id: root

    default property alias content: contentColumn.data

    QtShadcnTheme { id: theme }

    // 宽度撑满 Dialog 内部（Dialog 宽 448，内容占 448 - 0 = 448，留给内边距由 column 自身）
    width: parent ? parent.width : implicitWidth
    implicitHeight: contentColumn.implicitHeight

    Column {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: 24   // shadcn p-6
        spacing: 24           // shadcn gap-6
    }
}

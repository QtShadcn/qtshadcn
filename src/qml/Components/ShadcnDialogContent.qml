import QtQuick
import QtShadcn

// shadcn/ui 风格 Dialog 内容容器：p-6 + gap-6 垂直堆叠（对齐 shadcn cn-dialog-content）
Item {
    id: root

    default property alias content: contentColumn.data

    QtShadcnTheme { id: theme }

    readonly property int _pad: 24   // shadcn p-6
    readonly property int _gap: 24   // shadcn gap-6

    // 宽度撑满 Dialog 内部；implicit 尺寸必须显式包含上下 padding，否则 footer 被裁切
    width: parent ? parent.width : implicitWidth
    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight + _pad * 2

    Column {
        id: contentColumn

        x: _pad
        y: _pad
        width: parent.width - _pad * 2
        spacing: _gap
    }
}

import QtQuick
import QtQuick.Layouts
import QtShadcn

// 空状态操作区：按钮等内容垂直堆叠、水平居中
// 对齐 cn-empty-content: flex w-full max-w-sm min-w-0 flex-col items-center gap-2.5 text-sm
//   gap-2.5 = 10px / max-w-sm = 384
// 宽度由 ShadcnEmpty 的 ColumnLayout 管理（Layout.fillWidth + maximumWidth 384），
// 不要自己写 width。
ColumnLayout {
    id: root

    QtShadcnTheme { id: theme }

    spacing: 10   // gap-2.5（10px，非 4 的整数倍，故不用 spacing token 派生）

    Layout.fillWidth: true
    // items-center：内容块在 ShadcnEmpty 里水平居中，并限制到 max-w-sm
    Layout.alignment: Qt.AlignHCenter
    Layout.maximumWidth: 384
    Layout.minimumWidth: 0

    // CSS items-center：内容区内的直接子项（通常是按钮）默认水平居中；
    // 子项自己写过 Layout.alignment 时尊重它。
    // QML 无法跨文件共享函数，ShadcnEmpty / ShadcnEmptyHeader 里是同名副本。
    function centerChildren() {
        for (let i = 0; i < root.children.length; ++i) {
            const child = root.children[i]
            if (!child.Layout.alignment)
                child.Layout.alignment = Qt.AlignHCenter
        }
    }

    onChildrenChanged: centerChildren()
    Component.onCompleted: centerChildren()
}

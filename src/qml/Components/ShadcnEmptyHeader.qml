import QtQuick
import QtQuick.Layouts
import QtShadcn

// 空状态头部：EmptyMedia + EmptyTitle + EmptyDescription 垂直堆叠、整体水平居中
// 对齐 cn-empty-header: flex max-w-sm flex-col items-center gap-2
//   gap-2 = 2 × spacing 单位(4px) = 8 / max-w-sm = 24rem = 384
// 宽度由 ShadcnEmpty 的 ColumnLayout 管理（Layout.alignment 居中 + maximumWidth 384），
// 不要自己写 width。
ColumnLayout {
    id: root

    QtShadcnTheme { id: theme }

    spacing: Math.round(theme.spacingXs * 2)   // gap-2

    // items-center：整块在 ShadcnEmpty 的内容列里水平居中
    Layout.alignment: Qt.AlignHCenter
    // max-w-sm = 384（与 ShadcnEmptyContent 同值；Tailwind 的 max-w-sm 是固定刻度，非 token）
    Layout.maximumWidth: 384
    Layout.minimumWidth: 0

    // CSS items-center：头部内的直接子项（Media/Title/Description，以及用户塞进来的
    // 任意内容）默认水平居中；子项自己写过 Layout.alignment 时尊重它。
    // QML 无法跨文件共享函数，ShadcnEmpty / ShadcnEmptyContent 里是同名副本。
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

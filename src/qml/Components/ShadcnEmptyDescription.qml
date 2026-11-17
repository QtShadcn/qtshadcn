import QtQuick
import QtQuick.Layouts
import QtShadcn

// 空状态描述：text-sm/relaxed(14 / 行高 1.625) + mutedForeground
// 对齐 cn-empty-description: text-sm/relaxed text-muted-foreground
// 宽度由 ShadcnEmpty / ShadcnEmptyHeader 的布局管理，不要自己写 width。
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.mutedForeground
    font.pixelSize: 14            // text-sm
    // text-sm/relaxed：行高 1.625 → 14 × 1.625 = 22.75px（ProportionalHeight 即倍率）
    lineHeight: 1.625
    lineHeightMode: Text.ProportionalHeight

    horizontalAlignment: Text.AlignHCenter   // 父级 items-center
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
}

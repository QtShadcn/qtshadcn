import QtQuick
import QtQuick.Layouts
import QtShadcn

// 空状态标题：text-sm(14) + font-medium(500) + tracking-tight
// 对齐 cn-empty-title: text-sm font-medium tracking-tight
// 宽度由 ShadcnEmpty / ShadcnEmptyHeader 的布局管理，不要自己写 width。
Text {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.foreground
    font.pixelSize: 14            // text-sm
    font.weight: Font.Medium      // font-medium = 500
    // tracking-tight = -0.025em，14px 下约 -0.35px
    font.letterSpacing: -0.35

    horizontalAlignment: Text.AlignHCenter   // 父级 items-center
    wrapMode: Text.WordWrap
    Layout.fillWidth: true
}

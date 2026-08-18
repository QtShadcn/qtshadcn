import QtQuick
import QtShadcn

// shadcn/ui 风格徽标
// 6 variant（v4）：default / secondary / destructive（透明底红字）/ outline / ghost / link
// 高度 20px（h-5）、胶囊圆角、文字 12px Medium
//
// 用法:
//   ShadcnBadge { text: "New"; variant: ShadcnBadge.Variant.Default }
Item {
    id: root

    enum Variant { Default, Secondary, Destructive, Outline, Ghost, Link }

    property int variant: ShadcnBadge.Variant.Default
    property string text: ""

    QtShadcnTheme { id: theme }
    VariantTokens { id: vt }

    readonly property var _v: vt.badge[root.variant] ?? vt.badge[0]
    // 中转 color 类型：theme.tokens[..] 返回 QVariant(QString)，直接 .r/.g/.b 取不到
    // （undefined → Qt.rgba 变黑，曾致 Secondary badge 黑底深字看不见）
    readonly property color _bgColor: _v.bg === "" ? "transparent" : theme.tokens[_v.bg]
    readonly property color _bg: _v.bg === ""
        ? "transparent"
        : Qt.rgba(_bgColor.r, _bgColor.g, _bgColor.b,
                  _v.bgAlpha !== undefined ? _v.bgAlpha : 1.0)
    readonly property color _fg: theme.tokens[_v.fg]
    readonly property color _border: theme.tokens[_v.borderToken !== undefined ? _v.borderToken : "border"]

    implicitWidth: contentText.implicitWidth + 16   // px-2(8) * 2
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        radius: 999   // 胶囊
        color: root._bg
        border.width: root._v.border ? 1 : 0
        border.color: root._border
    }

    Text {
        id: contentText

        anchors.centerIn: parent
        text: root.text
        color: root._fg
        font.pixelSize: 12
        font.weight: Font.Medium
    }
}

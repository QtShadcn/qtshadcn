import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格组合输入（Input Group：前缀/后缀）
// 基于 ShadcnInput 扩展，对齐 shadcn input-group 规范：内嵌 addon（icon 或文本），
// 输入框 padding 自动让位；聚焦时整框（含 addon）一起 ring。
// （shadcn 的 InputGroup 是组合式容器，Qt 侧用属性驱动更实用）
//
// 用法:
//   ShadcnInputGroup { prefixIcon: "search"; placeholderText: "搜索..." }
//   ShadcnInputGroup { suffixIcon: "x"; suffixText: "可清除" }
//   ShadcnInputGroup { prefixText: "$"; placeholderText: "金额" }
TextField {
    id: root

    QtShadcnTheme { id: theme }

    // ── Input Group 专属 API ──
    property string prefixIcon: ""      // 前缀图标名（lucide）
    property string suffixIcon: ""      // 后缀图标名
    property string prefixText: ""      // 前缀文本（如 $ / ￥）
    property string suffixText: ""      // 后缀文本

    readonly property bool _hasPrefix: prefixIcon.length > 0 || prefixText.length > 0
    readonly property bool _hasSuffix: suffixIcon.length > 0 || suffixText.length > 0

    color: theme.foreground
    placeholderTextColor: theme.mutedForeground
    font.pixelSize: 14
    selectByMouse: true

    // 内容边距：有 addon 时让位（icon 24 + 间距 12 ≈ 36）
    leftPadding: _hasPrefix ? 36 : 12
    rightPadding: _hasSuffix ? 36 : 12
    topPadding: 4
    bottomPadding: 4

    implicitHeight: 36
    implicitWidth: 240

    background: Rectangle {
        radius: 6
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.5)
        border.width: 1
        border.color: root.activeFocus ? theme.ring : "transparent"

        Behavior on border.color { ColorAnimation { duration: 120 } }

        // 聚焦环（含 addon 的整框一起 ring）
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 9
            visible: root.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)
        }
    }

    // ── 前缀 addon（icon 或文本，text-muted-foreground）──
    ShadcnIcon {
        visible: root.prefixIcon.length > 0
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        name: root.prefixIcon
        size: 16
        color: theme.mutedForeground
    }
    Text {
        visible: root.prefixIcon.length === 0 && root.prefixText.length > 0
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.prefixText
        color: theme.mutedForeground
        font.pixelSize: 14
    }

    // ── 后缀 addon ──
    ShadcnIcon {
        visible: root.suffixIcon.length > 0
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        name: root.suffixIcon
        size: 16
        color: theme.mutedForeground
    }
    Text {
        visible: root.suffixIcon.length === 0 && root.suffixText.length > 0
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.suffixText
        color: theme.mutedForeground
        font.pixelSize: 14
    }

    // 禁用态：opacity 50%
    opacity: !enabled ? 0.5 : 1
}

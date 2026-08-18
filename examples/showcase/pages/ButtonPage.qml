import QtQuick
import QtQuick.Layouts
import QtShadcn

// Button 页：variant × size × 状态全展示
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnButton")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("基于 QQC Button（Basic style），6 种 variant × 5 种 size，支持 loading / disabled / 键盘焦点环。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // ── variant ──
    SectionTitle { text: qsTr("Variant") }
    Row {
        spacing: theme.spacingSm
        ShadcnButton { text: qsTr("Primary"); variant: ShadcnButton.Variant.Primary }
        ShadcnButton { text: qsTr("Secondary"); variant: ShadcnButton.Variant.Secondary }
        ShadcnButton { text: qsTr("Outline"); variant: ShadcnButton.Variant.Outline }
        ShadcnButton { text: qsTr("Ghost"); variant: ShadcnButton.Variant.Ghost }
        ShadcnButton { text: qsTr("Destructive"); variant: ShadcnButton.Variant.Destructive }
        ShadcnButton { text: qsTr("Link"); variant: ShadcnButton.Variant.Link }
    }

    // ── size ──
    SectionTitle { text: qsTr("Size") }
    Row {
        spacing: theme.spacingSm
        ShadcnButton { text: qsTr("XS"); size: ShadcnButton.Size.ExtraSmall }
        ShadcnButton { text: qsTr("Small"); size: ShadcnButton.Size.Small }
        ShadcnButton { text: qsTr("Medium"); size: ShadcnButton.Size.Medium }
        ShadcnButton { text: qsTr("Large"); size: ShadcnButton.Size.Large }
        ShadcnButton { text: qsTr("＋"); size: ShadcnButton.Size.Icon }
    }

    // 显式拉宽时文字仍居中（验证 contentItem 居中锚点）
    ShadcnButton {
        width: 240
        text: qsTr("拉伸宽度仍居中")
    }

    // ── disabled / loading ──
    SectionTitle { text: qsTr("Disabled / Loading") }
    Row {
        spacing: theme.spacingSm
        ShadcnButton { text: qsTr("Disabled"); enabled: false }
        ShadcnButton { text: qsTr("Disabled Outline"); variant: ShadcnButton.Variant.Outline; enabled: false }
        ShadcnButton { text: qsTr("Loading"); loading: true }
        ShadcnButton { text: qsTr("Loading Ghost"); variant: ShadcnButton.Variant.Ghost; loading: true }
    }

    // ── checkable（Toggle 基座）──
    SectionTitle { text: qsTr("Checkable") }
    Row {
        spacing: theme.spacingSm
        ShadcnButton { text: qsTr("未选中"); checkable: true }
        ShadcnButton { text: qsTr("已选中"); checkable: true; checked: true }
        ShadcnButton { text: qsTr("选中 Outline"); variant: ShadcnButton.Variant.Outline; checkable: true; checked: true }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnButton {\n    text: \"Deploy\"\n    variant: ShadcnButton.Variant.Primary\n    size: ShadcnButton.Size.Medium\n    loading: false\n    onClicked: { ... }\n}"
    }
}

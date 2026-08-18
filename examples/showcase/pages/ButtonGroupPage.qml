import QtQuick
import QtShadcn

// ButtonGroup 页：按钮组（边框合并 + 分隔线 + 圆角只留两端）
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnButtonGroup")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("相邻按钮间距 -1 合并边框、圆角只留两端；无边框 variant（如 Primary）中间自动加 1px 分隔线（按钮前景色 15%）。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    SectionTitle { text: qsTr("Primary 组（无边框，分隔线）") }
    ShadcnButtonGroup {
        ShadcnButton { text: "A"; variant: ShadcnButton.Variant.Primary }
        ShadcnButton { text: "B"; variant: ShadcnButton.Variant.Primary }
        ShadcnButton { text: "C"; variant: ShadcnButton.Variant.Primary }
    }

    SectionTitle { text: qsTr("Outline 组（各自边框合并）") }
    ShadcnButtonGroup {
        ShadcnButton { text: "A"; variant: ShadcnButton.Variant.Outline }
        ShadcnButton { text: "B"; variant: ShadcnButton.Variant.Outline }
        ShadcnButton { text: "C"; variant: ShadcnButton.Variant.Outline }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnButtonGroup {\n    ShadcnButton { text: \"A\"; variant: ShadcnButton.Variant.Primary }\n    ShadcnButton { text: \"B\"; variant: ShadcnButton.Variant.Primary }\n}"
    }
}

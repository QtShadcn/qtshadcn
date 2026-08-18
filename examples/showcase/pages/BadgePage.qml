import QtQuick
import QtQuick.Layouts
import QtShadcn

// Badge 页：6 variant 全展示
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnBadge")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("胶囊形徽标，6 种 variant。注意 destructive 是 v4 新风格「透明底红字」（旧版是实心红底白字）。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    SectionTitle { text: qsTr("Variant") }
    Flow {
        width: parent.width - 48
        spacing: theme.spacingSm

        ShadcnBadge { text: qsTr("Default"); variant: ShadcnBadge.Variant.Default }
        ShadcnBadge { text: qsTr("Secondary"); variant: ShadcnBadge.Variant.Secondary }
        ShadcnBadge { text: qsTr("Destructive"); variant: ShadcnBadge.Variant.Destructive }
        ShadcnBadge { text: qsTr("Outline"); variant: ShadcnBadge.Variant.Outline }
        ShadcnBadge { text: qsTr("Ghost"); variant: ShadcnBadge.Variant.Ghost }
        ShadcnBadge { text: qsTr("Link"); variant: ShadcnBadge.Variant.Link }
    }

    SectionTitle { text: qsTr("组合（Card Header + Badge）") }
    ShadcnCard {
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("功能开关") }
            ShadcnCardDescription { text: qsTr("实验性新功能，默认关闭。") }
        }
        ShadcnCardContent {
            Row {
                spacing: theme.spacingSm
                ShadcnBadge { text: qsTr("Beta"); variant: ShadcnBadge.Variant.Secondary }
                ShadcnBadge { text: qsTr("New"); variant: ShadcnBadge.Variant.Default }
                ShadcnBadge { text: qsTr("Deprecated"); variant: ShadcnBadge.Variant.Destructive }
            }
        }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnBadge {\n    text: \"New\"\n    variant: ShadcnBadge.Variant.Default\n}"
    }
}

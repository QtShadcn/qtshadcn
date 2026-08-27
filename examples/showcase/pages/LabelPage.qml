import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

Item {
    id: root

    QtShadcnTheme { id: theme }

    Column {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40
        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnLabel")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("语义化文本标签：3 variant × 3 size。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    ScrollView {
        id: sv
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            SectionTitle { text: qsTr("Variant") }
            Column {
                spacing: 12
                ShadcnLabel { text: qsTr("Default — 默认文本标签") }
                ShadcnLabel { text: qsTr("Muted — 弱化文本标签"); variant: ShadcnLabel.Variant.Muted }
                ShadcnLabel { text: qsTr("Destructive — 危险文本标签"); variant: ShadcnLabel.Variant.Destructive }
            }

            SectionTitle { text: qsTr("Size") }
            Column {
                spacing: 12
                ShadcnLabel { text: qsTr("Small — 小标签"); size: ShadcnLabel.Size.Small }
                ShadcnLabel { text: qsTr("Medium — 中等标签"); size: ShadcnLabel.Size.Medium }
                ShadcnLabel { text: qsTr("Large — 大标签"); size: ShadcnLabel.Size.Large }
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnLabel { text: \"标题\" }\nShadcnLabel { text: \"提示\"; variant: ShadcnLabel.Variant.Muted }\nShadcnLabel { text: \"大标题\"; size: ShadcnLabel.Size.Large }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

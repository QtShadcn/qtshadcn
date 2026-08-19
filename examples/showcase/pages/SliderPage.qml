import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Slider 页：全状态展示
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnSlider")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("8px 轨道 + primary range + 白色胶囊 thumb（ring + shadow，hover/focus ring-4）。")
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

            SectionTitle { text: qsTr("默认（0-100）") }
            ShadcnSlider {
                width: 360
                from: 0; to: 100
                value: 40
            }

            SectionTitle { text: qsTr("自定义范围（0-10）") }
            ShadcnSlider {
                width: 360
                from: 0; to: 10
                value: 3
            }

            SectionTitle { text: qsTr("disabled") }
            ShadcnSlider {
                width: 360
                from: 0; to: 100
                value: 75
                enabled: false
            }

            SectionTitle { text: qsTr("QML 用法") }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnSlider {\n    width: 360\n    from: 0; to: 100\n    value: 40\n    onValueChanged: ...\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

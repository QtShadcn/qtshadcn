import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// RadioGroup 页：单选组全状态展示
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
            text: qsTr("ShadcnRadio / ShadcnRadioGroup")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("16px 正圆单选组：选中 primary 底 + primaryForeground 内圆点；同组互斥、方向键切换。")
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

            SectionTitle { text: qsTr("默认单选组（互斥）") }
            ShadcnRadioGroup {
                ShadcnRadio { text: qsTr("默认主题"); checked: true }
                ShadcnRadio { text: qsTr("蓝色主题") }
                ShadcnRadio { text: qsTr("绿色主题") }
            }

            SectionTitle { text: qsTr("含 disabled") }
            ShadcnRadioGroup {
                ShadcnRadio { text: qsTr("选项 A"); checked: true }
                ShadcnRadio { text: qsTr("选项 B") }
                ShadcnRadio { text: qsTr("选项 C（不可用）"); enabled: false }
            }

            RowLayout {
                spacing: theme.spacingSm
                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: qsTr("查看文档 ›")
                    color: theme.primary
                    font.pixelSize: 12
                    font.underline: docHover.containsMouse
                    MouseArea {
                        id: docHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/radio-group")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnRadioGroup {\n    ShadcnRadio { text: \"A\"; checked: true }\n    ShadcnRadio { text: \"B\" }\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Select 页：下拉选择全状态展示
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
            text: qsTr("ShadcnSelect")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("基于 QQC.ComboBox：36/32px trigger + chevron-down；弹层 bg-popover + ring + shadow，item hover accent + 选中 check。")
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

            SectionTitle { text: qsTr("默认") }
            Row {
                spacing: theme.spacingLg
                ShadcnSelect {
                    model: [qsTr("苹果"), qsTr("香蕉"), qsTr("橙子"), qsTr("葡萄")]
                    onActivated: (index) => console.log("select:", currentText)
                }
                ShadcnSelect {
                    model: [qsTr("默认"), qsTr("已选中第二项"), qsTr("第三项")]
                    currentIndex: 1
                }
            }

            SectionTitle { text: qsTr("尺寸 sm / disabled") }
            Row {
                spacing: theme.spacingLg
                ShadcnSelect {
                    size: ShadcnSelect.Size.Sm
                    model: [qsTr("小"), qsTr("中"), qsTr("大")]
                }
                ShadcnSelect {
                    model: [qsTr("不可用")]
                    enabled: false
                }
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/select")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnSelect {\n    model: [\"苹果\", \"香蕉\", \"橙子\"]\n    onActivated: (index) => ...\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

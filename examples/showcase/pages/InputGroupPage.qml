import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// InputGroup 页：前缀/后缀组合输入展示
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
            text: qsTr("ShadcnInputGroup")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("输入框前缀/后缀（icon 或文本），padding 自动让位；聚焦时整框一起 ring。")
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

            SectionTitle { text: qsTr("前缀图标 / 前缀文本 / 后缀图标") }
            Column {
                spacing: theme.spacingMd
                ShadcnInputGroup {
                    width: 260
                    prefixIcon: "search"
                    placeholderText: qsTr("搜索...")
                }
                ShadcnInputGroup {
                    width: 260
                    prefixText: "￥"
                    placeholderText: qsTr("金额")
                }
                ShadcnInputGroup {
                    width: 260
                    suffixIcon: "chevron-down"
                    placeholderText: qsTr("下拉")
                }
            }

            SectionTitle { text: qsTr("disabled") }
            ShadcnInputGroup {
                width: 260
                prefixIcon: "lock"
                text: qsTr("锁定")
                enabled: false
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/input-group")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnInputGroup {\n    width: 260\n    prefixIcon: \"search\"      // 或 prefixText: \"$\"\n    suffixIcon: \"chevron-down\"  // 或 suffixText\n    placeholderText: \"搜索...\"\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

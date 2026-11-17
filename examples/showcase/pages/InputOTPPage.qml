// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// InputOTP 页：默认 / 长度变体 / 已填满 / 禁用 / 回调
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnInputOTP")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("验证码输入：一个透明 TextField 承接全部键盘输入，按字符自绘到 N 个 32×32 的格子里；首末格各占一侧圆角，选中格 border-ring + 3px 焦点环。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
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

            // ── 基础 ──
            SectionTitle {
                text: qsTr("Basic")
            }
            ShadcnInputOTP {
                length: 6
                onCompleted: function(value) {
                    status.text = qsTr("已填满：%1").arg(value)
                }
            }
            Text {
                id: status
                text: qsTr("输入 6 位验证码后触发 completed")
                color: theme.mutedForeground
                font.pixelSize: 12
            }

            // ── 长度变体 ──
            SectionTitle {
                text: qsTr("Length")
            }
            Row {
                spacing: theme.spacingMd
                ShadcnInputOTP {
                    length: 4
                }
                ShadcnInputOTP {
                    length: 8
                }
            }

            // ── 已填满（text 预置）──
            SectionTitle {
                text: qsTr("Filled")
            }
            ShadcnInputOTP {
                text: "123456"
            }

            // ── Disabled ──
            SectionTitle {
                text: qsTr("Disabled")
            }
            ShadcnInputOTP {
                enabled: false
                text: "000000"
            }

            // ── QML 用法 ──
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/input-otp")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnInputOTP {\n    length: 6\n    onCompleted: function(value) { console.log(value) }\n}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

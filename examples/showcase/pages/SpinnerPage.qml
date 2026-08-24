import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtShadcn

// Spinner 页：加载指示器（尺寸 × 颜色）
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
            text: qsTr("ShadcnSpinner")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("Shape 画 270° 弧线 + RotationAnimator（渲染线程动画，不走主线程 JS）。ShadcnButton 的 loading 状态内部即用它。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
    // 注：height: parent.height - y 会因 y 自引用形成绑定循环（高度塌缩 implicitHeight）
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

            SectionTitle {
                text: qsTr("尺寸")
            }
            Row {
                spacing: theme.spacingLg
                ShadcnSpinner {
                    width: 14
                    height: 14
                    color: theme.foreground
                }
                ShadcnSpinner {
                    width: 20
                    height: 20
                    color: theme.foreground
                }
                ShadcnSpinner {
                    width: 28
                    height: 28
                    color: theme.foreground
                }
                ShadcnSpinner {
                    width: 40
                    height: 40
                    color: theme.foreground
                }
            }

            SectionTitle {
                text: qsTr("颜色（随主题）")
            }
            Row {
                spacing: theme.spacingLg
                ShadcnSpinner {
                    width: 20
                    height: 20
                    color: theme.primary
                }
                ShadcnSpinner {
                    width: 20
                    height: 20
                    color: theme.mutedForeground
                }
                ShadcnSpinner {
                    width: 20
                    height: 20
                    color: theme.destructive
                }
                ShadcnSpinner {
                    width: 20
                    height: 20
                    color: theme.accentForeground
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/spinner")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnSpinner { width: 16; height: 16; color: theme.primary }\n// 或按钮加载态：ShadcnButton { loading: true }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Tabs 页：default + line 两种 variant，StackLayout 联动
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
            text: qsTr("ShadcnTabs")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("default variant：胶囊底容器，选中态白底；line variant：透明底 + 2px 下划线指示器。")
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
            id: outerCol
            width: sv.availableWidth
            spacing: theme.spacingLg

            SectionTitle {
                text: qsTr("Default Variant")
            }
            Column {
                width: 480
                spacing: theme.spacingMd

                ShadcnTabsList {
                    id: tabs1
                    width: parent.width

                    ShadcnTabsTrigger {
                        text: qsTr("账户")
                    }
                    ShadcnTabsTrigger {
                        text: qsTr("密码")
                    }
                    ShadcnTabsTrigger {
                        text: qsTr("通知")
                    }
                }

                StackLayout {
                    id: contentStack1
                    currentIndex: tabs1.currentIndex
                    width: parent.width
                    height: 80

                    ShadcnTabsContent {
                        Text {
                            text: qsTr("账户设置内容：邮箱 / 用户名 / 头像...")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                    ShadcnTabsContent {
                        Text {
                            text: qsTr("密码修改内容：旧密码 / 新密码 / 确认...")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                    ShadcnTabsContent {
                        Text {
                            text: qsTr("通知设置内容：邮件 / 推送 / 短信...")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            SectionTitle {
                text: qsTr("Line Variant")
            }
            Column {
                width: 480
                spacing: theme.spacingMd

                ShadcnTabsList {
                    id: tabs2
                    width: parent.width
                    variant: "line"

                    ShadcnTabsTrigger {
                        text: qsTr("总览")
                    }
                    ShadcnTabsTrigger {
                        text: qsTr("分析")
                    }
                    ShadcnTabsTrigger {
                        text: qsTr("报告")
                    }
                }

                StackLayout {
                    currentIndex: tabs2.currentIndex
                    width: parent.width
                    height: 80

                    ShadcnTabsContent {
                        Text {
                            text: qsTr("总览面板内容")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                    ShadcnTabsContent {
                        Text {
                            text: qsTr("分析图表内容")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                    ShadcnTabsContent {
                        Text {
                            text: qsTr("报告列表内容")
                            color: theme.foreground
                            font.pixelSize: 14
                        }
                    }
                }
            }

            SectionTitle {
                text: qsTr("QML 用法")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                color: theme.mutedForeground
                text: "ShadcnTabsList {\n    id: tabs\n    ShadcnTabsTrigger { text: \"A\" }\n    ShadcnTabsTrigger { text: \"B\" }\n}\nStackLayout { currentIndex: tabs.currentIndex; ... }"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

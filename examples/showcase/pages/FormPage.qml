import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Form 页：组合表单示例（各组件全状态展示见各自独立页面）
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("组合表单")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        // 文档站跳转链接（Form 为组合示例，指向表单控件文档首页 /components/input）
        Text {
            text: qsTr("查看文档 ›")
            color: theme.primary
            font.pixelSize: 12
            font.underline: formDocHover.containsMouse
            MouseArea {
                id: formDocHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/input")
            }
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("用 M3 表单控件组合的完整表单示例（各组件单独展示见 Textarea / Checkbox / Radio / Slider / Progress / Select / InputGroup 页）。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区
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

            SectionTitle { text: qsTr("新建项目") }

            ShadcnCard {
                width: Math.min(420, sv.availableWidth)
                ShadcnCardHeader {
                    ShadcnCardTitle { text: qsTr("新建项目") }
                    ShadcnCardDescription { text: qsTr("使用表单控件组合的完整表单。") }
                }
                ShadcnCardContent {
                    Column {
                        width: parent.width
                        spacing: theme.spacingLg

                        Column {
                            width: parent.width
                            spacing: theme.spacingSm
                            Text {
                                text: qsTr("项目名称")
                                color: theme.foreground
                                font.pixelSize: 13
                            }
                            ShadcnInputGroup {
                                width: parent.width
                                prefixIcon: "folder"
                                placeholderText: qsTr("my-awesome-project")
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: theme.spacingSm
                            Text {
                                text: qsTr("项目类型")
                                color: theme.foreground
                                font.pixelSize: 13
                            }
                            ShadcnSelect {
                                width: parent.width
                                model: [qsTr("应用"), qsTr("网站"), qsTr("库"), qsTr("其他")]
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: theme.spacingSm
                            Text {
                                text: qsTr("描述")
                                color: theme.foreground
                                font.pixelSize: 13
                            }
                            ShadcnTextarea {
                                width: parent.width
                                placeholderText: qsTr("一句话描述这个项目...")
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: theme.spacingSm
                            Text {
                                text: qsTr("进度预算")
                                color: theme.foreground
                                font.pixelSize: 13
                            }
                            ShadcnSlider {
                                width: parent.width
                                from: 0; to: 100
                                value: 50
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: theme.spacingSm
                            ShadcnCheckbox { text: qsTr("立即初始化 Git 仓库") }
                            ShadcnCheckbox { text: qsTr("创建 README"); checked: true }
                        }

                        ShadcnProgress {
                            width: parent.width
                            value: 0.5
                            showValue: true
                        }

                        Row {
                            spacing: theme.spacingSm
                            ShadcnButton {
                                text: qsTr("取消")
                                variant: ShadcnButton.Variant.Outline
                            }
                            ShadcnButton {
                                text: qsTr("创建项目")
                            }
                        }
                    }
                }
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

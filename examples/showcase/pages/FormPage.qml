import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// 表单控件页：M3 收尾组件（Textarea / Checkbox / RadioGroup / Slider / Progress / Select / InputGroup）
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
            text: qsTr("表单控件（M3 收尾）")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("Textarea / Checkbox / RadioGroup / Slider / Progress / Select / InputGroup，全部 token 驱动、dark/light 随动。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）
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

            // ── Textarea ──
            SectionTitle { text: qsTr("Textarea") }
            Row {
                spacing: theme.spacingLg
                ShadcnTextarea {
                    width: 300
                    placeholderText: qsTr("输入多行内容...")
                }
                Column {
                    spacing: theme.spacingSm
                    ShadcnTextarea {
                        width: 300
                        text: qsTr("带默认内容")
                        enabled: false
                    }
                    Text {
                        text: qsTr("disabled")
                        color: theme.mutedForeground
                        font.pixelSize: 12
                    }
                }
            }

            // ── Checkbox ──
            SectionTitle { text: qsTr("Checkbox") }
            Row {
                spacing: theme.spacingLg
                ShadcnCheckbox { text: qsTr("同意条款"); checked: true }
                ShadcnCheckbox { text: qsTr("订阅邮件") }
                ShadcnCheckbox { text: qsTr("不可用"); enabled: false }
            }

            // ── RadioGroup ──
            SectionTitle { text: qsTr("RadioGroup") }
            ShadcnRadioGroup {
                ShadcnRadio { text: qsTr("默认主题"); checked: true }
                ShadcnRadio { text: qsTr("蓝色主题") }
                ShadcnRadio { text: qsTr("绿色主题"); enabled: false }
            }

            // ── Slider ──
            SectionTitle { text: qsTr("Slider") }
            Column {
                width: 360
                spacing: theme.spacingMd
                ShadcnSlider {
                    width: parent.width
                    from: 0; to: 100
                    value: 40
                }
                ShadcnSlider {
                    width: parent.width
                    from: 0; to: 100
                    value: 75
                    enabled: false
                }
                Row {
                    width: parent.width
                    spacing: theme.spacingMd
                    Text { text: qsTr("范围 0-10:"); color: theme.foreground; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                    ShadcnSlider {
                        width: 200
                        from: 0; to: 10
                        value: 3
                    }
                }
            }

            // ── Progress ──
            SectionTitle { text: qsTr("Progress") }
            Column {
                width: 360
                spacing: theme.spacingMd
                ShadcnProgress {
                    width: parent.width
                    value: 0.6
                }
                ShadcnProgress {
                    width: parent.width
                    value: 0.3
                    showValue: true
                }
            }

            // ── Select ──
            SectionTitle { text: qsTr("Select") }
            Row {
                spacing: theme.spacingLg
                ShadcnSelect {
                    model: [qsTr("苹果"), qsTr("香蕉"), qsTr("橙子"), qsTr("葡萄")]
                    onActivated: (index) => console.log("select:", currentText)
                }
                ShadcnSelect {
                    size: ShadcnSelect.Size.Sm
                    model: [qsTr("小"), qsTr("中"), qsTr("大")]
                }
                ShadcnSelect {
                    model: [qsTr("不可用")]
                    enabled: false
                }
            }

            // ── InputGroup（前缀/后缀）──
            SectionTitle { text: qsTr("InputGroup（前缀/后缀）") }
            Row {
                spacing: theme.spacingLg
                ShadcnInputGroup {
                    width: 220
                    prefixIcon: "search"
                    placeholderText: qsTr("搜索...")
                }
                ShadcnInputGroup {
                    width: 220
                    prefixText: "￥"
                    placeholderText: qsTr("金额")
                }
                ShadcnInputGroup {
                    width: 220
                    suffixIcon: "chevron-down"
                    placeholderText: qsTr("下拉")
                }
            }

            // ── 组合表单示例 ──
            SectionTitle { text: qsTr("组合表单示例（新建项目）") }
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

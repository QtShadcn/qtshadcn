// 页内 SectionTitle 等内联组件要访问外层 theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Field 页：布局（纵向/横向/responsive）· 必填 · 错误态 · FieldSet/Group/Separator
Item {
    id: root

    property int errorCount: 0

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
            text: qsTr("ShadcnField")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("表单字段容器：把 label / 控件 / 描述 / 错误提示组合成一块，管它们之间的间距与 orientation。"
                       + "gap-2(8px)、FieldGroup gap-5(20px)、FieldSet gap-4(16px)；"
                       + "invalid 时标签转 destructive，FieldError 无内容不占位并按 message 去重。")
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

            // ── 纵向（默认）──
            SectionTitle {
                text: qsTr("纵向（默认 orientation）")
            }
            ShadcnField {
                width: Math.min(360, parent.width)

                ShadcnFieldLabel {
                    text: qsTr("用户名")
                    required: true
                }
                ShadcnInput {
                    placeholderText: qsTr("小写字母与数字")
                }
                ShadcnFieldDescription {
                    text: qsTr("用于登录，创建后不可修改。")
                }
            }

            // ── 带错误 ──
            SectionTitle {
                text: qsTr("错误态（invalid）")
            }
            ShadcnField {
                width: Math.min(360, parent.width)
                invalid: true

                ShadcnFieldLabel {
                    text: qsTr("邮箱")
                    required: true
                }
                ShadcnInput {
                    placeholderText: qsTr("you@example.com")
                }
                ShadcnFieldDescription {
                    text: qsTr("我们会发送验证邮件。")
                }
                ShadcnFieldError {
                    text: qsTr("请输入有效的邮箱地址")
                }
            }

            // ── 多条错误（去重 + 列表）──
            SectionTitle {
                text: qsTr("多条错误（按 message 去重，多条渲染为列表）")
            }
            ShadcnField {
                width: Math.min(360, parent.width)
                invalid: true

                ShadcnFieldLabel {
                    text: qsTr("密码")
                }
                ShadcnInput {
                    placeholderText: qsTr("至少 8 位")
                    echoMode: TextInput.Password
                }
                ShadcnFieldError {
                    errors: [qsTr("至少 8 位字符"), qsTr("至少 8 位字符"), qsTr("需包含一个数字")]
                }
            }

            // ── 横向：控件在右 ──
            SectionTitle {
                text: qsTr("横向（Horizontal）：label 左 · 控件右")
            }
            ShadcnField {
                width: Math.min(420, parent.width)
                orientation: ShadcnField.Orientation.Horizontal

                ShadcnFieldLabel {
                    text: qsTr("接收产品更新")
                }
                ShadcnSwitch {
                    checked: true
                }
            }

            // ── 横向 + FieldContent（描述与标题同列）──
            SectionTitle {
                text: qsTr("横向 + FieldContent（描述跟随 label，控件贴右）")
            }
            ShadcnField {
                width: Math.min(420, parent.width)
                orientation: ShadcnField.Orientation.Horizontal

                ShadcnFieldContent {
                    ShadcnFieldTitle {
                        text: qsTr("飞行模式")
                    }
                    ShadcnFieldDescription {
                        text: qsTr("关闭所有无线连接。")
                    }
                }
                ShadcnSwitch {
                    checked: false
                }
            }

            // ── 横向：开关在左 ──
            SectionTitle {
                text: qsTr("横向：控件在左（子项顺序即视觉顺序）")
            }
            ShadcnField {
                width: Math.min(420, parent.width)
                orientation: ShadcnField.Orientation.Horizontal

                ShadcnCheckbox {
                    checked: true
                }
                ShadcnFieldLabel {
                    text: qsTr("我已阅读并同意服务条款")
                }
            }

            // ── responsive ──
            SectionTitle {
                text: qsTr("Responsive：容器变窄自动回到上下堆叠（拖动窗口宽度看）")
            }
            RowLayout {
                width: Math.min(460, parent.width)
                spacing: theme.spacingLg

                ShadcnField {
                    Layout.fillWidth: true
                    orientation: ShadcnField.Orientation.Responsive
                    responsiveBreakpoint: 300

                    ShadcnFieldLabel {
                        text: qsTr("音量")
                    }
                    ShadcnSlider {
                        from: 0
                        to: 100
                        value: 40
                    }
                }
                ShadcnField {
                    Layout.fillWidth: true
                    orientation: ShadcnField.Orientation.Responsive
                    responsiveBreakpoint: 300

                    ShadcnFieldLabel {
                        text: qsTr("通知")
                    }
                    ShadcnSwitch {
                        checked: true
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("断点取容器宽度（优先最近的 FieldGroup，对齐官方 @container/field-group）；"
                           + "上面两块断点设成 300，在 460 宽的行里并排时会退化为纵向。")
                color: theme.mutedForeground
                font.pixelSize: 12
            }

            // ── FieldSet + Legend + Group + Separator ──
            SectionTitle {
                text: qsTr("FieldSet / FieldLegend / FieldGroup / FieldSeparator")
            }
            ShadcnFieldSet {
                width: Math.min(400, parent.width)

                ShadcnFieldLegend {
                    text: qsTr("通知设置")
                }
                ShadcnFieldDescription {
                    text: qsTr("选择你希望接收的通知类型。")
                }

                ShadcnFieldGroup {
                    ShadcnField {
                        orientation: ShadcnField.Orientation.Horizontal
                        ShadcnFieldLabel {
                            text: qsTr("评论回复")
                        }
                        ShadcnSwitch {
                            checked: true
                        }
                    }
                    ShadcnField {
                        orientation: ShadcnField.Orientation.Horizontal
                        ShadcnFieldLabel {
                            text: qsTr("每周摘要")
                        }
                        ShadcnSwitch {
                            checked: false
                        }
                    }
                }

                ShadcnFieldSeparator {
                    text: qsTr("或继续使用")
                }

                ShadcnFieldGroup {
                    ShadcnField {
                        ShadcnFieldLabel {
                            text: qsTr("第三方账号")
                        }
                        ShadcnInput {
                            placeholderText: qsTr("GitHub 用户名")
                        }
                        ShadcnFieldDescription {
                            text: qsTr("用于 OAuth 登录。")
                        }
                    }
                }
            }

            // ── 禁用 ──
            SectionTitle {
                text: qsTr("禁用态（整块 opacity 50%）")
            }
            ShadcnField {
                width: Math.min(360, parent.width)
                enabled: false

                ShadcnFieldLabel {
                    text: qsTr("组织 ID")
                }
                ShadcnInput {
                    placeholderText: qsTr("由管理员分配")
                }
                ShadcnFieldDescription {
                    text: qsTr("该字段当前不可编辑。")
                }
            }

            // ── Legend variant ──
            SectionTitle {
                text: qsTr("FieldLegend variant：Legend(16px) / Label(14px)")
            }
            Column {
                spacing: theme.spacingSm
                ShadcnFieldLegend {
                    text: qsTr("Legend 变体（text-base 16px）")
                }
                ShadcnFieldLegend {
                    text: qsTr("Label 变体（text-sm 14px）")
                    variant: ShadcnFieldLegend.Variant.Label
                }
            }

            // ── QML 用法 ──
            RowLayout {
                spacing: theme.spacingSm

                SectionTitle {
                    text: qsTr("QML 用法")
                }
                Item {
                    Layout.fillWidth: true
                }
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
                        onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/field")
                    }
                }
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                color: theme.mutedForeground
                font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                font.pixelSize: 12
                text: "ShadcnField {\n"
                      + "    invalid: input.text.length === 0 && touched\n"
                      + "    ShadcnFieldLabel { text: \"邮箱\"; required: true }\n"
                      + "    ShadcnInput { id: input }\n"
                      + "    ShadcnFieldDescription { text: \"不会公开\" }\n"
                      + "    ShadcnFieldError { errors: model.errors }\n"
                      + "}"
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}

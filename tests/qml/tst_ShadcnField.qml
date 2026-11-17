import QtQuick
import QtQuick.Layouts
import QtTest
import QtShadcn

// ShadcnField 组：布局 / orientation / 错误态 / 必填标记
//
// 对齐依据（registry base-nova/ui/field.tsx，2026-11-17 抓取）：
// - Field 是布局容器：纵向 flex-col *:w-full / 横向 flex-row（控件 w-auto）
// - FieldError 无内容返回 null（不占位），errors 按 message 去重，
//   去重后 1 条输出单行、多条输出 list-disc 列表
// - FieldLabel 在 Field data-invalid 时整块转 text-destructive
// - required 不是官方属性（官方 demo 手写 <span class="text-destructive">*</span>），
//   本库收敛成 FieldLabel.required 开关
Item {
    id: root
    width: 900
    height: 700

    QtShadcnTheme { id: theme }

    // ── 纵向（默认 orientation）──
    Component {
        id: verticalComp

        ShadcnField {
            width: 300

            ShadcnFieldLabel {
                objectName: "label"
                text: "Email"
            }
            ShadcnInput {
                objectName: "control"
                placeholderText: "you@example.com"
            }
            ShadcnFieldDescription {
                objectName: "desc"
                text: "We never share it."
            }
        }
    }

    // ── 横向 ──
    Component {
        id: horizontalComp

        ShadcnField {
            width: 400
            orientation: ShadcnField.Orientation.Horizontal

            ShadcnFieldLabel {
                objectName: "label"
                text: "Newsletter"
            }
            ShadcnSwitch {
                objectName: "control"
            }
        }
    }

    // ── 横向 + FieldContent（items-start）──
    Component {
        id: horizontalContentComp

        ShadcnField {
            width: 400
            orientation: ShadcnField.Orientation.Horizontal

            ShadcnFieldContent {
                objectName: "content"

                ShadcnFieldTitle {
                    objectName: "title"
                    text: "Airplane Mode"
                }
                ShadcnFieldDescription {
                    objectName: "desc"
                    text: "Disables all connections."
                }
            }
            ShadcnSwitch {
                objectName: "control"
            }
        }
    }

    // ── 错误态 ──
    Component {
        id: invalidComp

        ShadcnField {
            width: 300
            invalid: true

            ShadcnFieldLabel {
                objectName: "label"
                text: "Username"
            }
            ShadcnInput {
                objectName: "control"
            }
            ShadcnFieldDescription {
                objectName: "desc"
                text: "Lowercase only"
            }
        }
    }

    // ── 必填标记 ──
    Component {
        id: requiredComp

        ShadcnField {
            width: 300

            ShadcnFieldLabel {
                objectName: "label"
                text: "Email"
                required: true
            }
            ShadcnInput {
                objectName: "control"
            }
        }
    }

    // ── 错误：text / errors / 去重 / 隐藏 ──
    Component {
        id: errorHiddenComp
        ShadcnField {
            width: 300
            ShadcnFieldError {
                objectName: "error"
            }
        }
    }

    Component {
        id: errorTextComp
        ShadcnField {
            width: 300
            ShadcnFieldError {
                objectName: "error"
                text: "Already taken"
            }
        }
    }

    Component {
        id: errorDupComp
        ShadcnField {
            width: 300
            ShadcnFieldError {
                objectName: "error"
                errors: ["Same message", "Same message"]
            }
        }
    }

    Component {
        id: errorMultiComp
        ShadcnField {
            width: 300
            ShadcnFieldError {
                objectName: "error"
                errors: ["First problem", "Second problem"]
            }
        }
    }

    Component {
        id: errorObjectComp
        ShadcnField {
            width: 300
            ShadcnFieldError {
                objectName: "error"
                errors: [{
                    message: "Object message"
                }, {
                    message: ""
                }, undefined]
            }
        }
    }

    // ── 描述 + 错误共存 ──
    Component {
        id: descAndErrorComp

        ShadcnField {
            width: 300
            invalid: true

            ShadcnFieldLabel {
                objectName: "label"
                text: "Email"
            }
            ShadcnInput {
                objectName: "control"
            }
            ShadcnFieldDescription {
                objectName: "desc"
                text: "Helper text"
            }
            ShadcnFieldError {
                objectName: "error"
                text: "Invalid email"
            }
        }
    }

    // ── responsive ──
    Component {
        id: responsiveComp

        ShadcnField {
            id: responsiveField

            width: parent ? parent.width : 400
            orientation: ShadcnField.Orientation.Responsive
            responsiveBreakpoint: 480

            ShadcnFieldLabel {
                objectName: "label"
                text: "Volume"
            }
            ShadcnSlider {
                objectName: "control"
            }
        }
    }

    // ── FieldGroup / FieldSet / Separator ──
    Component {
        id: groupComp

        ShadcnFieldGroup {
            width: 300

            ShadcnField {
                objectName: "fieldA"
                ShadcnFieldLabel {
                    text: "A"
                }
            }
            ShadcnField {
                objectName: "fieldB"
                ShadcnFieldLabel {
                    text: "B"
                }
            }
        }
    }

    Component {
        id: legendComp

        ShadcnFieldSet {
            width: 300

            ShadcnFieldLegend {
                objectName: "legend"
                text: "Notifications"
            }
            ShadcnFieldDescription {
                objectName: "legendDesc"
                text: "Pick what you get."
            }
            ShadcnFieldGroup {
                ShadcnField {
                    ShadcnFieldLabel {
                        text: "Email"
                    }
                }
            }
        }
    }

    Component {
        id: separatorComp

        ShadcnFieldGroup {
            width: 300

            ShadcnField {
                ShadcnFieldLabel {
                    text: "A"
                }
            }
            ShadcnFieldSeparator {
                objectName: "sep"
                text: "Or continue"
            }
        }
    }

    // Separator 通常放在 FieldSet / FieldGroup 里（不是直接放 Field）——
    // 回归：它曾因为等着 Field 来接管宽度而拿到 width=0，中线文字溢出到左边。
    Component {
        id: separatorInSetComp

        ShadcnFieldSet {
            width: 400

            ShadcnFieldLegend {
                text: "Notifications"
            }
            ShadcnFieldGroup {
                ShadcnField {
                    ShadcnFieldLabel {
                        text: "A"
                    }
                }
            }
            ShadcnFieldSeparator {
                objectName: "sep"
                text: "Or continue with"
            }
            ShadcnFieldGroup {
                ShadcnField {
                    ShadcnFieldLabel {
                        text: "B"
                    }
                }
            }
        }
    }

    // 长文案在 FieldContent 里必须换行而不是溢出（描述/标题不写 fillWidth 时会这样）
    Component {
        id: wrappingComp

        ShadcnField {
            width: 260
            orientation: ShadcnField.Orientation.Horizontal

            ShadcnFieldContent {
                objectName: "content"

                ShadcnFieldTitle {
                    objectName: "title"
                    text: "A rather long field title that must wrap instead of overflowing the column"
                }
                ShadcnFieldDescription {
                    objectName: "desc"
                    text: "An equally long description used to verify that WordWrap actually applies inside FieldContent."
                }
            }
            ShadcnSwitch {
                objectName: "control"
            }
        }
    }

    TestCase {
        name: "ShadcnField"
        when: windowShown

        // ── 纵向（默认）──
        // 官方 vertical: flex-col + gap-2 + *:w-full
        function test_vertical_stacks_children_and_fills_width() {
            const field = createTemporaryObject(verticalComp, root)
            verify(!!field)
            compare(field.orientation, ShadcnField.Orientation.Vertical)
            compare(field.columns, 1, "纵向应为单列")
            compare(field.rowSpacing, theme.spacingSm, "gap-2 = 8px")

            const label = findChild(field, "label")
            const control = findChild(field, "control")
            const desc = findChild(field, "desc")
            verify(label && control && desc)

            // 纵向堆叠：y 依次增大，x 都是 0
            verify(label.y < control.y, "label 应在控件上方")
            verify(control.y < desc.y, "描述应在控件下方")
            compare(label.x, 0)
            compare(control.x, 0)

            // *:w-full：每个直接子项都撑满 Field 宽度
            tryVerify(function() {
                return Math.abs(label.width - field.width) <= 1
                        && Math.abs(control.width - field.width) <= 1
                        && Math.abs(desc.width - field.width) <= 1
            })
        }

        // 间距 = 8px（官方 gap-2）：控件 y = label 底部 + 8
        function test_vertical_spacing_matches_gap_2() {
            const field = createTemporaryObject(verticalComp, root)
            verify(!!field)

            const label = findChild(field, "label")
            const control = findChild(field, "control")

            tryVerify(function() { return control.y > label.y })
            compare(Math.round(control.y - (label.y + label.height)), theme.spacingSm)
        }

        // ── 横向 ──
        // 官方 horizontal: flex-row + items-center + FieldLabel flex-auto + 控件 w-auto
        function test_horizontal_places_children_side_by_side() {
            const field = createTemporaryObject(horizontalComp, root)
            verify(!!field)
            compare(field.orientation, ShadcnField.Orientation.Horizontal)
            compare(field.columns, 2, "横向每个可见子项一列")
            compare(field.columnSpacing, theme.spacingSm, "gap-2 = 8px")

            const label = findChild(field, "label")
            const control = findChild(field, "control")
            verify(label && control)

            tryVerify(function() { return control.x > label.x })
            // 同一行：两者垂直居中对齐，y 不应该相差太多
            verify(label.y < control.y + control.height && control.y < label.y + label.height,
                   "横向应在同一行")
            // FieldLabel 是 flex-auto：吃掉剩余宽度；控件保持自然宽度（*:w-auto）。
            // 断言到 implicitWidth 才拦得住「两者都 fillWidth 平分」这种错法。
            verify(Math.abs(control.width - control.implicitWidth) <= 1,
                   "控件应保持自然宽度 implicitWidth=" + control.implicitWidth
                   + "，实际 " + control.width)
            verify(Math.abs(label.width - (field.width - control.width - field.columnSpacing)) <= 1,
                   "label 应吃掉剩余宽度")
            // 右对齐：控件贴右边缘
            verify(Math.abs((control.x + control.width) - field.width) <= 1, "控件应贴右边缘")
        }

        // 官方 has-[>[data-slot=field-content]]:items-start —— 有 FieldContent 时贴顶对齐
        function test_horizontal_with_content_aligns_top() {
            const field = createTemporaryObject(horizontalContentComp, root)
            verify(!!field)

            const content = findChild(field, "content")
            const control = findChild(field, "control")
            verify(content && control)
            compare(field.columns, 2)

            tryVerify(function() { return control.x > content.x })
            compare(content.y, 0, "有 FieldContent 时内容块贴顶")
            verify(Math.abs(control.y - 0) <= 1, "控件与内容块首行对齐（items-start）")
            // FieldContent 里 title 在上、desc 在下
            const title = findChild(field, "title")
            const desc = findChild(field, "desc")
            verify(title.y < desc.y, "FieldContent 内 title 在 description 上方")
        }

        // ── 错误态 ──
        // 官方 data-invalid -> 整块 text-destructive
        function test_invalid_turns_text_destructive() {
            const field = createTemporaryObject(invalidComp, root)
            verify(!!field)
            compare(field.invalid, true)

            const label = findChild(field, "label")
            const desc = findChild(field, "desc")
            verify(label && desc)
            compare(String(label.color), String(theme.destructive))
            compare(String(desc.color), String(theme.mutedForeground),
                    "Description 保持 mutedForeground（官方只覆盖 Field 的继承色，desc 自带 text-muted-foreground）")

            // 非错误态回到 foreground
            field.invalid = false
            compare(String(label.color), String(theme.foreground))
        }

        // ── 必填标记 ──
        function test_required_marker() {
            const field = createTemporaryObject(requiredComp, root)
            verify(!!field)

            const label = findChild(field, "label")
            verify(label)
            compare(label.required, true)
            compare(label.rightPadding, theme.spacingSm, "必填时为星号预留右侧空间")

            // 星号是一个可见的红色子 Text
            const mark = findChild(label, "requiredMark")
            verify(!!mark, "必填星号存在")
            compare(mark.visible, true)
            compare(String(mark.color), String(theme.destructive))

            // 关掉 required：星号隐藏，padding 归零
            label.required = false
            compare(mark.visible, false)
            compare(label.rightPadding, 0)
        }

        // ── FieldError：无内容不占位 ──
        // 官方 return null
        function test_error_hidden_when_empty() {
            const field = createTemporaryObject(errorHiddenComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            verify(error)
            compare(error.visible, false, "无错误时不显示")
            compare(error.implicitHeight, 0, "无错误时不占高度")
            // Field 高度只剩这一个不可见子项 -> 0
            tryVerify(function() { return field.implicitHeight === 0 })
        }

        function test_error_shows_text() {
            const field = createTemporaryObject(errorTextComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            verify(error)
            compare(error.visible, true)
            compare(error.messages.length, 1)
            compare(error.messages[0], "Already taken")
            tryVerify(function() { return error.implicitHeight > 0 }, 1000, "有错误时占据高度")
        }

        // 官方 Map 去重：同一条错误信息只渲染一次
        function test_error_deduplicates_messages() {
            const field = createTemporaryObject(errorDupComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            verify(error)
            compare(error.messages.length, 1, "重复 message 去重后只剩 1 条")
            compare(error._isList, false, "单条渲染为纯文本，不是列表")
        }

        // 去重后多条 -> list-disc 列表
        function test_error_renders_list_for_multiple() {
            const field = createTemporaryObject(errorMultiComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            verify(error)
            compare(error.messages.length, 2)
            compare(error._isList, true, "多条渲染为列表")
        }

        // errors 接受 { message } 对象数组（对齐 react-hook-form），空 message 与 undefined 跳过
        function test_error_accepts_object_errors() {
            const field = createTemporaryObject(errorObjectComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            verify(error)
            compare(error.messages.length, 1)
            compare(error.messages[0], "Object message")
        }

        // ── description 与 error 共存 ──
        // 官方无「互斥」逻辑：两者各占一行（Field 的 gap-2 分隔），desc 在前 error 在后
        function test_description_and_error_coexist() {
            const field = createTemporaryObject(descAndErrorComp, root)
            verify(!!field)

            const desc = findChild(field, "desc")
            const error = findChild(field, "error")
            verify(desc && error)
            compare(desc.visible, true, "错误态下描述仍显示")
            compare(error.visible, true)
            tryVerify(function() { return error.y > desc.y }, 1000, "顺序：description 在前，error 在后")
            tryVerify(function() {
                return Math.abs(error.y - (desc.y + desc.height) - field.rowSpacing) <= 1
            }, 1000, "两者间距 = gap-2")
        }

        // ── responsive ──
        function test_responsive_switches_by_width() {
            const field = createTemporaryObject(responsiveComp, root)
            verify(!!field)
            compare(field.orientation, ShadcnField.Orientation.Responsive)

            // 宽容器 -> 横向
            field.width = 600
            compare(field.resolvedOrientation, ShadcnField.Orientation.Horizontal)
            compare(field.columns, 2)

            // 窄容器 -> 纵向
            field.width = 320
            compare(field.resolvedOrientation, ShadcnField.Orientation.Vertical)
            compare(field.columns, 1)

            const label = findChild(field, "label")
            const control = findChild(field, "control")
            tryVerify(function() { return control.y > label.y }, 1000, "窄容器应回到上下堆叠")
        }

        // ── FieldGroup / FieldSet / Separator ──
        function test_field_group_stacks_fields() {
            const group = createTemporaryObject(groupComp, root)
            verify(!!group)

            const a = findChild(group, "fieldA")
            const b = findChild(group, "fieldB")
            verify(a && b)
            compare(group.spacing, theme.spacingLg + theme.spacingXs, "gap-5 = 20px")
            tryVerify(function() { return b.y > a.y })
            compare(Math.round(b.y - (a.y + a.height)), group.spacing)
        }

        // 官方 mb-1.5：Legend 与紧随其后的 Description 之间上提 6px
        function test_field_set_legend_spacing() {
            const set = createTemporaryObject(legendComp, root)
            verify(!!set)

            const legend = findChild(set, "legend")
            const desc = findChild(set, "legendDesc")
            verify(legend && desc)
            compare(legend.Layout.bottomMargin, theme.spacingSm - theme.spacingXs / 2)
            tryVerify(function() { return desc.Layout.topMargin === -(theme.spacingMd / 2) },
                      1000, "Description 紧跟 Legend 时应上提 6px")
            // CSS 里 gap 不与 margin 折叠：Legend 的 mb-1.5(6) 与紧跟其后的
            // Description 的 -mt-1.5(-6) 相互抵消 → 净间距回到容器 gap-4(16px)。
            // 若 Legend 后面直接跟 FieldGroup，则只有 mb 生效（gap + 6 = 22px）。
            tryVerify(function() { return desc.y > legend.y }, 1000)
            tryVerify(function() {
                const gap = desc.y - (legend.y + legend.height)
                return Math.abs(gap - set.spacing) <= 1
            }, 1000, "Legend 后紧跟 Description 时净间距应回到容器 gap")
        }

        function test_field_separator_negative_margins() {
            const group = createTemporaryObject(separatorComp, root)
            verify(!!group)

            const sep = findChild(group, "sep")
            verify(sep)
            compare(sep.implicitHeight, theme.spacingLg + theme.spacingXs, "h-5 = 20px")
            compare(sep.Layout.topMargin, -theme.spacingSm, "-my-2 = -8px")
            compare(sep.Layout.bottomMargin, -theme.spacingSm)
        }

        // 回归：Separator 放在 FieldSet 里也必须拿到宽度（曾 width=0，文字溢出）
        function test_field_separator_gets_width_in_field_set() {
            const set = createTemporaryObject(separatorInSetComp, root)
            verify(!!set)

            const sep = findChild(set, "sep")
            verify(sep)
            tryVerify(function() { return sep.width > 0 }, 1000, "分隔线必须有宽度")
            verify(Math.abs(sep.width - set.width) <= 1, "分隔线应撑满容器宽度")

            // 中线与文字块都必须落在分隔线内部（文字块是 bg-background 那块蒙版）
            const line = sep.children[0]
            const box = sep.children[1]
            verify(Math.abs(line.width - sep.width) <= 1, "横线应撑满")
            verify(box.x >= 0 && box.x + box.width <= sep.width + 1, "文字块不该溢出分隔线")
            verify(Math.abs((box.x + box.width / 2) - sep.width / 2) <= 1, "文字应水平居中")
        }

        // 回归：FieldContent 里的长 title/description 要真的换行，不能停在 implicitWidth
        function test_field_content_text_wraps() {
            const field = createTemporaryObject(wrappingComp, root)
            verify(!!field)

            const content = findChild(field, "content")
            const title = findChild(field, "title")
            const desc = findChild(field, "desc")
            const control = findChild(field, "control")
            verify(content && title && desc && control)

            tryVerify(function() { return content.width > 0 }, 1000)
            tryVerify(function() {
                return Math.abs(title.width - content.width) <= 1
            }, 1000, "title 应撑满 FieldContent 宽度")
            tryVerify(function() { return title.lineCount > 1 }, 1000, "长 title 应换行")
            tryVerify(function() { return desc.lineCount > 1 }, 1000, "长描述应换行")
            // 横向时控件仍保持自然宽度
            verify(Math.abs(control.width - control.implicitWidth) <= 1, "控件不该被拉伸")
        }

        // 隐藏的 FieldError 不该在横向布局里多占一列
        function test_hidden_error_does_not_add_column() {
            const field = createTemporaryObject(horizontalContentComp, root)
            verify(!!field)

            const error = Qt.createQmlObject(
                'import QtShadcn; ShadcnFieldError { text: "" }', field, "dynError")
            verify(error)
            // 隐藏（无内容）-> 可见子项计数不含它
            tryVerify(function() { return field.columns === 2 })
            compare(error.visible, false)

            // 有内容 -> 多一列（横向时各占一列，与官方 flex-row 一致）
            error.text = "Boom"
            tryVerify(function() { return field.columns === 3 })
        }

        // 动态增删子项（如错误提示按条件创建）后，布局接管表不能留下悬空引用，
        // 也不能把「控件保持自然宽度」这条丢掉
        function test_dynamic_child_add_remove_keeps_layout() {
            const field = createTemporaryObject(horizontalComp, root)
            verify(!!field)

            const label = findChild(field, "label")
            const control = findChild(field, "control")
            tryVerify(function() { return field.columns === 2 })

            const error = Qt.createQmlObject('import QtShadcn; ShadcnFieldError { text: "E" }',
                                             field, "dynamicError")
            verify(error)
            tryVerify(function() { return field.columns === 3 }, 1000, "新增错误后应多一列")

            error.destroy()
            tryVerify(function() { return field.columns === 2 }, 1000, "销毁后列数应还原")

            // 重新加入后，控件仍然是自然宽度（横向 *:w-auto 没被破坏）
            const error2 = Qt.createQmlObject('import QtShadcn; ShadcnFieldError { text: "E2" }',
                                              field, "dynamicError2")
            verify(error2)
            tryVerify(function() { return field.columns === 3 }, 1000)
            tryVerify(function() {
                // 此时 3 列（label / 控件 / 错误）→ 2 个列间距
                const gaps = (field.columns - 1) * field.columnSpacing
                return Math.abs(control.width - control.implicitWidth) <= 1
                        && Math.abs(label.width - (field.width - control.width - gaps)) <= 1
            }, 1000, "重新布局后 label 仍吃满剩余宽度、控件保持自然宽度")
        }

        // ── 圆角 / 颜色不硬编码（回归防护）──
        function test_error_uses_theme_destructive() {
            const field = createTemporaryObject(errorTextComp, root)
            verify(!!field)

            const error = findChild(field, "error")
            const textItem = error.children[0].children[0]
            verify(textItem)
            compare(String(textItem.color), String(theme.destructive))
        }
    }
}

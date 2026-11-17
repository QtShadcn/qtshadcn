import QtQuick
import QtShadcn

// shadcn/ui 风格字段标签（FieldLabel）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldLabel =
//   <Label className="group/field-label peer/field-label flex w-fit gap-2
//                     leading-snug group-data-[disabled=true]/field:opacity-50 …">
// 即 Label 基础样式（text-sm 14px / font-medium）+ 单行紧凑行高。
// 父级 ShadcnField 处于 invalid 时整块转 text-destructive（官方
// `data-[invalid=true]:text-destructive` 从 Field 继承下来的行为）。
//
// required 是 Qt 侧扩展：官方 registry **没有** required 属性，demo 里是手写
//   <FieldLabel>Required Field <span className="text-destructive">*</span></FieldLabel>
// 这里把它收敛成一个开关，省掉每个表单重复写星号与其配色。
//
// 用法:
//   ShadcnFieldLabel { text: qsTr("邮箱"); required: true }
Text {
    id: root

    // 必填标记：文字右侧追加 destructive 的 "*"
    property bool required: false

    QtShadcnTheme { id: theme }

    // 横向排布时 label 是 flex-auto 的那一类（吃掉剩余宽度，控件保持自然宽）
    readonly property bool __fieldFlex: true

    // 向上找最近的 ShadcnField（等价 CSS 的 group/field + data-invalid 继承）。
    // 用 property var 存指针：qmllint 因此不校验成员，运行时仍是真实 QObject，
    // 属性绑定照常依赖 invalid，切换时重新求值
    property var __fieldOwner: {
        var o = root.parent
        while (o !== null && !("__isShadcnField" in o))
            o = o.parent
        return o
    }
    readonly property bool __fieldInvalid: root.__fieldOwner !== null && root.__fieldOwner.invalid === true
    // 官方 group-data-[disabled=true]/field:opacity-50
    readonly property bool __fieldDisabled: root.__fieldOwner !== null && root.__fieldOwner.enabled === false

    color: root.__fieldInvalid ? theme.destructive : theme.foreground
    font.pixelSize: 14   // text-sm
    font.weight: Font.Medium   // font-medium = 500
    lineHeightMode: Text.FixedHeight
    lineHeight: 20   // leading-snug ≈ 1.375 × 14 = 19.25，取 20 便于与控件对齐
    wrapMode: Text.WordWrap
    opacity: root.__fieldDisabled ? 0.5 : 1

    // 给必填星号预留右侧空间，星号才能落在文字后面而不被裁掉
    rightPadding: root.required ? theme.spacingSm : 0

    // 无障碍：必填标记是视觉装饰，读屏用文字表达
    Accessible.name: root.required ? root.text + qsTr("（必填）") : root.text

    // 必填星号：叠在文字后（contentWidth 之后，不参与文本排版）
    // 已知限制：label 换行时星号放到最后一行的右侧边缘（Qt 拿不到逐行宽度，
    // 没法贴在最后一个字后面）。官方 demo 的必填标记也都是单行短标签。
    Text {
        id: requiredMark

        objectName: "requiredMark"

        readonly property real _naturalRight: root.contentWidth + theme.spacingXs

        visible: root.required
        // 单行：紧跟文字；换行：贴最后一行的右边缘
        x: Math.min(root._wrapped ? root.width - width : requiredMark._naturalRight,
                    root.width - width)
        y: root._wrapped ? (root.lineCount - 1) * root.lineHeight : 0
        text: "*"
        color: theme.destructive
        font.pixelSize: root.font.pixelSize
        font.weight: Font.Medium
    }

    readonly property bool _wrapped: root.lineCount > 1
}

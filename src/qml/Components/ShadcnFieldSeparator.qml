import QtQuick
import QtQuick.Layouts
import QtShadcn

// shadcn/ui 风格字段分隔线（FieldSeparator）
//
// 对照来源：base-nova/ui/field.tsx 的 FieldSeparator =
//   <div class="relative -my-2 h-5 text-sm">
//     <Separator class="absolute inset-0 top-1/2" />
//     {children && <span class="relative mx-auto block w-fit bg-background px-2
//                                text-muted-foreground">{children}</span>}
//   </div>
// 三个要点：
//   - 高 h-5(20px)，线画在垂直中线（top-1/2）
//   - 上下的 -my-2(-8px) 是给它自己的：在 FieldGroup 的 gap 之上再收回 8px，
//     让分隔线两侧间距不会比普通 Field 间距更大
//   - 带文字时文字块用 **bg-background** 盖住线（不是变粗的线），左右 px-2(8px)
//
// 与 ShadcnSeparator 的区别：ShadcnSeparator 是通用分隔线（可竖可横、文字两侧
// 各画一段线）；FieldSeparator 是**表单分组专用**，线是贯穿的、文字压在线上。
//
// 用法:
//   ShadcnFieldSeparator {}
//   ShadcnFieldSeparator { text: qsTr("或继续使用") }
Item {
    id: root

    // 中间的说明文字（为空则只画贯通线）
    property string text: ""

    QtShadcnTheme { id: theme }

    // h-5 = 20px
    implicitHeight: theme.spacingLg + theme.spacingXs

    // 它是线条，必须有宽度才能画出来。它通常放在 FieldGroup / FieldSet 里
    // （而不是直接放 Field），所以不能指望 Field 的布局接管 —— 自己声明。
    // 放进横向 Field 时，Field 会把它按回 w-auto（见 ShadcnField 的说明）。
    Layout.fillWidth: true

    // -my-2 = -8px：在父布局里上下各收回 8px（对齐官方 -my-2）
    Layout.topMargin: -theme.spacingSm
    Layout.bottomMargin: -theme.spacingSm

    // 线：绝对居中那一根（Separator 的 absolute inset-0 top-1/2）
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 1
        color: theme.border
    }

    // 文字块：bg-background 盖住线，左右各 8px（px-2）
    Rectangle {
        anchors.centerIn: parent
        visible: root.text.length > 0
        width: label.implicitWidth + theme.spacingLg
        height: label.implicitHeight
        color: theme.background

        Text {
            id: label

            anchors.centerIn: parent
            text: root.text
            color: theme.mutedForeground
            font.pixelSize: 14   // text-sm
        }
    }

    // 分隔线本身是纯装饰，但不该让读屏静音掉中间文字
    Accessible.role: Accessible.Separator
    Accessible.name: root.text
}

// src/qml/Components/ShadcnLabel.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格文本标签（M6）
// 用法:
//   ShadcnLabel { text: "标题" }
//   ShadcnLabel { text: "副标题"; size: ShadcnLabel.Size.Small }
//   ShadcnLabel { text: "必填"; variant: ShadcnLabel.Variant.Destructive }
Text {
    id: root

    enum Variant { Default, Muted, Destructive }
    enum Size { Small, Medium, Large }

    property int variant: ShadcnLabel.Variant.Default
    property int size: ShadcnLabel.Size.Medium

    QtShadcnTheme { id: theme }

    color: variant === ShadcnLabel.Variant.Muted ? theme.mutedForeground
         : variant === ShadcnLabel.Variant.Destructive ? theme.destructive
         : theme.foreground

    font.pixelSize: size === ShadcnLabel.Size.Small ? 12
                  : size === ShadcnLabel.Size.Large ? 18 : 14

    font.bold: size === ShadcnLabel.Size.Large
}

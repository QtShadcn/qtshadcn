import QtQuick
import QtShadcn

// 明暗主题切换（直接用 ThemeManager singleton，无需额外 theme 实例）
ShadcnButton {
    variant: ShadcnButton.Variant.Outline
    size: ShadcnButton.Size.Small
    text: ThemeManager.mode === "dark" ? qsTr("浅色模式") : qsTr("深色模式")
    iconName: ThemeManager.mode === "dark" ? "sun" : "moon"
    onClicked: ThemeManager.mode = ThemeManager.mode === "dark" ? "light" : "dark"
}

import QtQuick
import QtShadcn

// Spinner 页：加载指示器（尺寸 × 颜色）
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

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

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    SectionTitle { text: qsTr("尺寸") }
    Row {
        spacing: theme.spacingLg
        ShadcnSpinner { width: 14; height: 14; color: theme.foreground }
        ShadcnSpinner { width: 20; height: 20; color: theme.foreground }
        ShadcnSpinner { width: 28; height: 28; color: theme.foreground }
        ShadcnSpinner { width: 40; height: 40; color: theme.foreground }
    }

    SectionTitle { text: qsTr("颜色（随主题）") }
    Row {
        spacing: theme.spacingLg
        ShadcnSpinner { width: 20; height: 20; color: theme.primary }
        ShadcnSpinner { width: 20; height: 20; color: theme.mutedForeground }
        ShadcnSpinner { width: 20; height: 20; color: theme.destructive }
        ShadcnSpinner { width: 20; height: 20; color: theme.accentForeground }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnSpinner { width: 16; height: 16; color: theme.primary }\n// 或按钮加载态：ShadcnButton { loading: true }"
    }
}

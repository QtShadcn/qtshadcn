import QtQuick
import QtShadcn

// shadcn/lucide 风格图标组件
// 从 IconRegistry 取 lucide svg（data URL：替换 currentColor → base64 内联），
// 颜色由 IconRegistry 替换 → 可随主题/状态动态变色；无需 ImageProvider，开箱即用。
//
// 用法:
//   ShadcnIcon { name: "check"; size: 16 }
//   ShadcnIcon { name: "trash-2"; color: theme.destructive }
Item {
    id: root

    // 图标名（lucide 命名，见 IconRegistry.names，如 check / chevron-down / x）
    property string name: ""
    // 显示尺寸（px，默认 24 = lucide 设计尺寸）
    property int size: 24
    // 颜色（默认跟随主题正文色；支持任意 color）
    property color color: theme.foreground

    QtShadcnTheme { id: theme }

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        // 本地图标立即有值；远程图标首次为空，iconReady 后重设
        source: root.name ? IconRegistry.dataUrl(root.name, root.color) : ""
        sourceSize: Qt.size(root.size, root.size)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    // 远程兜底：本地没有的图标首次请求触发下载（dataUrl 返回空），
    // 下载完成（iconReady）后清空再重设 source，渲染出真图。
    Connections {
        target: IconRegistry

        function onIconReady(readyName) {
            if (readyName === root.name) {
                img.source = ""
                img.source = root.name ? IconRegistry.dataUrl(root.name, root.color) : ""
            }
        }
    }
}

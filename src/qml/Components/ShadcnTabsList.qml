import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格 Tabs 容器（基于 QQC.TabBar）
// variant: "default"（胶囊底容器）/ "line"（下划线指示器，透明底）
// 用法（与外部 StackLayout 联动）:
//   ShadcnTabsList {
//       id: tabs
//       ShadcnTabsTrigger { text: "A" }
//       ShadcnTabsTrigger { text: "B" }
//   }
//   StackLayout { currentIndex: tabs.currentIndex; ... }
Item {
    id: root

    property int currentIndex: 0
    property string variant: "default"   // "default" | "line"

    // 子项（ShadcnTabsTrigger）自动进 tabBar
    default property alias content: tabBar.data

    QtShadcnTheme { id: theme }
    readonly property bool _isLine: variant === "line"

    implicitWidth: tabBar.implicitWidth + (_isLine ? 0 : 8)
    implicitHeight: tabBar.implicitHeight + (_isLine ? 0 : 8)

    // default variant 容器背景：bg-muted 圆角（line variant 透明）
    Rectangle {
        anchors.fill: parent
        visible: !root._isLine
        color: theme.muted
        radius: theme.radius
    }

    TabBar {
        id: tabBar

        anchors.fill: parent
        anchors.margins: root._isLine ? 0 : 4

        // currentIndex 双向同步用事件驱动（坑：属性绑定 root.currentIndex ↔ tabBar.currentIndex
        // 会构成绑定循环，QML 打破后 currentIndex 变静态，点击无法切换）
        onCurrentIndexChanged: {
            if (currentIndex !== root.currentIndex)
                root.currentIndex = currentIndex
        }

        // TabBar 内部子项同步 variant（Trigger 据此选白底或下划线样式）
        onCountChanged: root._syncVariant()
    }

    // 外部设置 currentIndex（程序化切页）→ 同步给 tabBar（值相同不触发，无死循环）
    onCurrentIndexChanged: tabBar.currentIndex = root.currentIndex

    // 把 root.variant 同步到每个 ShadcnTabsTrigger（Trigger 有 variant 属性）
    function _syncVariant() {
        for (var i = 0; i < tabBar.count; i++) {
            var item = tabBar.itemAt(i)
            if (item && item.variant !== undefined)
                item.variant = root.variant
        }
    }
    onVariantChanged: _syncVariant()
    Component.onCompleted: _syncVariant()
}

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui v4 TabsList（对齐官方源码）：
//   <div role="tablist" class="... inline-flex w-fit items-center justify-center rounded-lg
//        p-[3px] ... h-8 ... bg-muted">
// - default：bg-muted 胶囊容器，rounded-lg(8px) + p-[3px] + h-8(32px)
// - line：透明底（容器无背景），trigger 用下划线指示
// 用法（与外部 StackLayout 联动）:
//   ShadcnTabsList {
//       id: tabs
//       ShadcnTabsTrigger { text: "A" }
//   }
//   StackLayout { currentIndex: tabs.currentIndex; ... }
Item {
    id: root

    readonly property bool _isLine: variant === "line"

    // 子项（ShadcnTabsTrigger）自动进 tabBar.contentData
    // 坑：必须用 contentData（Container 的内容属性），不能用 data（Item 通用属性）——
    //    data 添加的 TabButton 成为视觉子项但不被 Container 布局识别（count=0），
    //    全部停在 (0,0) 重叠
    default property alias content: tabBar.contentData
    property int currentIndex: 0
    property string variant: "default"   // "default" | "line"

    // 把 root.variant 同步到每个 ShadcnTabsTrigger（Trigger 有 variant 属性）
    function _syncVariant() {
        for (var i = 0; i < tabBar.count; i++) {
            var item = tabBar.itemAt(i);
            if (item && item.variant !== undefined)
                item.variant = root.variant;
        }
    }

    // 坑：Item 的 height 不会自动采用 implicitHeight（默认 0）——组件自包含显式高度，
    // 否则容器/TabBar 高度塌缩、标签文字全部重叠
    height: 32
    implicitHeight: 32

    // 对齐官方：h-8 = 32px（含 p-[3px] 上下 → trigger 区 26px）
    implicitWidth: tabBar.implicitWidth + (_isLine ? 0 : 6)

    Component.onCompleted: {
        tabBar.currentIndex = root.currentIndex;   // 强制同步，确保初始选中 TabButton.checked=true
        _syncVariant();
    }

    // 外部设置 currentIndex（程序化切页）→ 同步给 tabBar（值相同不触发，无死循环）
    onCurrentIndexChanged: tabBar.currentIndex = root.currentIndex
    onVariantChanged: _syncVariant()

    QtShadcnTheme {
        id: theme
    }

    // 胶囊容器（default variant）：bg-muted + rounded-lg；line 透明
    Rectangle {
        anchors.fill: parent
        color: theme.muted
        radius: 8
        visible: !root._isLine
    }
    TabBar {
        id: tabBar

        anchors.fill: parent
        anchors.margins: root._isLine ? 0 : 3
        spacing: root._isLine ? 4 : 0

        // 关闭 Qt Quick Controls 自带背景
        background: Item {
        }

        onCountChanged: root._syncVariant()
        onCurrentIndexChanged: {
            if (currentIndex !== root.currentIndex)
                root.currentIndex = currentIndex;
        }
    }
}

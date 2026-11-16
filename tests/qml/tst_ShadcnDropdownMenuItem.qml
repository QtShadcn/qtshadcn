import QtQuick
import QtTest
import QtShadcn

// ShadcnDropdownMenuItem：菜单项文本 + 快捷键子组件的布局
//
// 回归锁定：快捷键组件曾缺 import QtQuick.Layouts 却写 Layout.alignment，
// 同时加 anchors.verticalCenter —— 整块加载失败（Non-existent attached
// object）且 anchors 在 RowLayout 里非法。
Item {
    id: root
    width: 500
    height: 400

    Component {
        id: itemComp
        ShadcnDropdownMenuItem {
            objectName: "menuItem"
            width: 200
            text: qsTr("复制")

            ShadcnDropdownMenuShortcut {
                objectName: "shortcut"
                text: qsTr("⌘C")
            }
        }
    }

    TestCase {
        name: "ShadcnDropdownMenuItem"
        when: windowShown

        // 快捷键组件在 RowLayout 里应拿到合理几何：可见、有尺寸、位于右侧
        function test_shortcut_is_laid_out() {
            const item = createTemporaryObject(itemComp, root)
            verify(!!item, "Component exists")
            compare(item.text, qsTr("复制"))
            compare(item.height, 32)

            const shortcut = findChild(item, "shortcut")
            verify(!!shortcut, "Object exists")
            compare(shortcut.visible, true)
            verify(shortcut.width > 0)
            verify(shortcut.height > 0)
            // 右对齐：起始点在菜单项中线右侧，且不越出右内边距
            verify(shortcut.x > item.width / 2)
            verify(shortcut.x + shortcut.width <= item.width)
        }

        // 内置 shortcut 属性（不走子组件）只影响文本显示
        function test_builtin_shortcut_property() {
            const item = createTemporaryObject(itemComp, root, { shortcut: qsTr("⌘V") })
            verify(!!item, "Component exists")
            compare(item.shortcut, qsTr("⌘V"))
        }

        function test_click_emits_clicked() {
            const item = createTemporaryObject(itemComp, root)
            verify(!!item, "Component exists")

            const spy = createTemporaryObject(spyComp, root, { target: item })
            verify(!!spy, "Component exists")

            mouseClick(item)
            tryCompare(spy, "count", 1)
        }

        // 禁用态：半透明且不响应点击
        function test_disabled_does_not_emit() {
            const item = createTemporaryObject(itemComp, root, { enabled: false })
            verify(!!item, "Component exists")
            compare(item.opacity, 0.5)

            const spy = createTemporaryObject(spyComp, root, { target: item })
            verify(!!spy, "Component exists")

            mouseClick(item)
            compare(spy.count, 0)
        }
    }

    Component {
        id: spyComp
        SignalSpy {
            signalName: "clicked"
        }
    }
}

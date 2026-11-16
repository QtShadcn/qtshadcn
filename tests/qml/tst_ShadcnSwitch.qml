import QtQuick
import QtTest
import QtShadcn

// ShadcnSwitch：尺寸映射、点击切换、滑块位移
Item {
    id: root
    width: 400
    height: 300

    QtShadcnTheme { id: theme }

    Component {
        id: switchComp
        ShadcnSwitch {
            width: 32
            height: 18
        }
    }

    TestCase {
        name: "ShadcnSwitch"
        when: windowShown

        function test_default_size() {
            const item = createTemporaryObject(switchComp, root)
            verify(!!item, "Component exists")
            compare(item.implicitWidth, 32)
            compare(item.implicitHeight, 18)
        }

        function test_small_size() {
            const item = createTemporaryObject(switchComp, root, {
                size: ShadcnSwitch.Size.Small
            })
            verify(!!item, "Component exists")
            compare(item.implicitWidth, 24)
            compare(item.implicitHeight, 14)
        }

        // 关闭态：滑块贴左；轨道用 input 色
        function test_unchecked_state() {
            const item = createTemporaryObject(switchComp, root)
            verify(!!item, "Component exists")
            compare(item.checked, false)
            compare(item.indicator.x, 0)
            compare(item.background.color.toString(), theme.input.toString())
        }

        // 点击后：选中 + 滑块右移 16px（32 - 16），轨道变 primary
        function test_click_toggles_and_moves_thumb() {
            const item = createTemporaryObject(switchComp, root)
            verify(!!item, "Component exists")

            mouseClick(item)
            tryCompare(item, "checked", true)
            tryCompare(item.indicator, "x", 16)
            tryVerify(function() {
                return item.background.color.toString() === theme.primary.toString()
            })
        }

        // 禁用态不可点击
        function test_disabled_ignores_click() {
            const item = createTemporaryObject(switchComp, root, { enabled: false })
            verify(!!item, "Component exists")
            compare(item.opacity, 0.5)

            mouseClick(item)
            compare(item.checked, false)
        }
    }
}

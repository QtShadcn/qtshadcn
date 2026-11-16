import QtQuick
import QtTest
import QtShadcn

// ShadcnCheckbox：方框尺寸、点击切换、选中底色
Item {
    id: root
    width: 400
    height: 300

    QtShadcnTheme { id: theme }

    Component {
        id: checkboxComp
        ShadcnCheckbox {
            text: qsTr("同意条款")
            width: 160
            height: 24
        }
    }

    TestCase {
        name: "ShadcnCheckbox"
        when: windowShown

        // 方框固定 16px（size-4）
        function test_indicator_size() {
            const item = createTemporaryObject(checkboxComp, root)
            verify(!!item, "Component exists")
            compare(item.indicator.implicitWidth, 16)
            compare(item.indicator.implicitHeight, 16)
            compare(item.indicator.radius, 5)
        }

        // 点击切换选中态，方框底色从 input 变 primary
        function test_click_toggles_and_colors() {
            const item = createTemporaryObject(checkboxComp, root)
            verify(!!item, "Component exists")
            compare(item.checked, false)

            const uncheckedColor = item.indicator.color.toString()
            verify(uncheckedColor !== theme.primary.toString())

            mouseClick(item)
            tryCompare(item, "checked", true)
            tryVerify(function() {
                return item.indicator.color.toString() === theme.primary.toString()
            })
        }

        // 禁用态不可点击且半透明
        function test_disabled_ignores_click() {
            const item = createTemporaryObject(checkboxComp, root, { enabled: false })
            verify(!!item, "Component exists")
            compare(item.opacity, 0.5)

            mouseClick(item)
            compare(item.checked, false)
        }
    }
}

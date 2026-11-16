import QtQuick
import QtTest
import QtShadcn

// ShadcnButton：variant / size / loading 的可见契约
Item {
    id: root
    width: 600
    height: 500

    QtShadcnTheme { id: theme }

    Component {
        id: buttonComp
        ShadcnButton {
            text: qsTr("Deploy")
        }
    }

    TestCase {
        name: "ShadcnButton"
        when: windowShown

        function test_size_maps_to_height() {
            const medium = createTemporaryObject(buttonComp, root)
            verify(!!medium, "Component exists")
            compare(medium.implicitHeight, 40)

            const small = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Small })
            verify(!!small, "Component exists")
            compare(small.implicitHeight, 36)

            const extraSmall = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.ExtraSmall })
            verify(!!extraSmall, "Component exists")
            compare(extraSmall.implicitHeight, 32)

            const large = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Large })
            verify(!!large, "Component exists")
            compare(large.implicitHeight, 44)
        }

        // 默认 variant 用主题 primary 作底色
        function test_primary_background() {
            const button = createTemporaryObject(buttonComp, root)
            verify(!!button, "Component exists")
            compare(button.background.color.toString(), theme.primary.toString())
            compare(button.background.border.width, 0)
        }

        // outline 无底色但有 1px 描边
        function test_outline_variant_has_border() {
            const button = createTemporaryObject(buttonComp, root, {
                variant: ShadcnButton.Variant.Outline
            })
            verify(!!button, "Component exists")
            compare(button.background.border.width, 1)
            compare(button.background.color.toString(), "#00000000")
            compare(button.background.border.color.toString(), theme.border.toString())
        }

        // ghost 既无底色也无描边
        function test_ghost_variant_is_flat() {
            const button = createTemporaryObject(buttonComp, root, {
                variant: ShadcnButton.Variant.Ghost
            })
            verify(!!button, "Component exists")
            compare(button.background.color.toString(), "#00000000")
            compare(button.background.border.width, 0)
        }

        // destructive 用 destructive 底色
        function test_destructive_background() {
            const button = createTemporaryObject(buttonComp, root, {
                variant: ShadcnButton.Variant.Destructive
            })
            verify(!!button, "Component exists")
            compare(button.background.color.toString(), theme.destructive.toString())
        }

        // loading：交互禁用 + 半透明
        function test_loading_disables_and_dims() {
            const button = createTemporaryObject(buttonComp, root, { loading: true })
            verify(!!button, "Component exists")
            compare(button.enabled, false)
            compare(button.opacity, 0.5)
        }

        // checkable 按钮点击后进入选中态（点击路径 + 状态断言）
        function test_click_toggles_checked() {
            const button = createTemporaryObject(buttonComp, root, {
                checkable: true,
                width: 120,
                height: 40
            })
            verify(!!button, "Component exists")
            compare(button.checked, false)

            mouseClick(button)
            tryCompare(button, "checked", true)
        }
    }
}

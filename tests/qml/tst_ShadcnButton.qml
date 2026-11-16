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

        // 对齐 shadcn v4 base / style-nova：xs 24 / sm 28 / default 32 / lg 36 / icon 32
        // （旧值是 v3 口径 32/36/40/44，肉眼就能看出比官网大一圈）
        function test_size_maps_to_height() {
            const medium = createTemporaryObject(buttonComp, root)
            verify(!!medium, "Component exists")
            compare(medium.implicitHeight, 32)

            const small = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Small })
            verify(!!small, "Component exists")
            compare(small.implicitHeight, 28)

            const extraSmall = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.ExtraSmall })
            verify(!!extraSmall, "Component exists")
            compare(extraSmall.implicitHeight, 24)

            const large = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Large })
            verify(!!large, "Component exists")
            compare(large.implicitHeight, 36)

            // icon 尺寸是正方形 size-8 = 32
            const icon = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Icon })
            verify(!!icon, "Component exists")
            compare(icon.implicitHeight, 32)
            compare(icon.implicitWidth, 32)
        }

        // 横向内边距：px-2(8) / px-2.5(10)
        function test_horizontal_padding() {
            const medium = createTemporaryObject(buttonComp, root)
            compare(medium.implicitWidth - medium.contentItem.implicitWidth, 20)

            const small = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Small })
            compare(small.implicitWidth - small.contentItem.implicitWidth, 20)

            const extraSmall = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.ExtraSmall })
            compare(extraSmall.implicitWidth - extraSmall.contentItem.implicitWidth, 16)
        }

        // 内部 RowLayout：spacing = gap-1(4) / gap-1.5(6)
        function internalRow(button) {
            return button.contentItem.children[0]
        }

        function textItemOf(button) {
            var kids = internalRow(button).children
            for (var i = 0; i < kids.length; ++i)
                if (kids[i].text !== undefined && kids[i].font !== undefined)
                    return kids[i]
            return null
        }

        function test_gap_and_font_size() {
            const medium = createTemporaryObject(buttonComp, root)
            compare(internalRow(medium).spacing, 6)
            compare(textItemOf(medium).font.pixelSize, 14)

            const small = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Small })
            compare(internalRow(small).spacing, 4)
            compare(textItemOf(small).font.pixelSize, 13)      // text-[0.8rem]=12.8，int 就近取 13

            const extraSmall = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.ExtraSmall })
            compare(internalRow(extraSmall).spacing, 4)
            compare(textItemOf(extraSmall).font.pixelSize, 12) // text-xs
        }

        // 圆角从 theme.radius 派生：默认 rounded-lg = radius，xs/sm 用 radius×0.8
        function test_radius_follows_theme() {
            const medium = createTemporaryObject(buttonComp, root)
            compare(medium.background.topLeftRadius, theme.radiusLg)

            const small = createTemporaryObject(buttonComp, root, { size: ShadcnButton.Size.Small })
            compare(small.background.topLeftRadius, theme.radiusMd)
        }

        // 内联图标随尺寸缩放：size-3(12) / size-3.5(14) / size-4(16)
        function test_inline_icon_size() {
            const cases = [
                { size: ShadcnButton.Size.ExtraSmall, expected: 12 },
                { size: ShadcnButton.Size.Small, expected: 14 },
                { size: ShadcnButton.Size.Medium, expected: 16 }
            ]
            for (var i = 0; i < cases.length; ++i) {
                const b = createTemporaryObject(buttonComp, root, {
                    size: cases[i].size, iconName: "plus"
                })
                var kids = internalRow(b).children
                var icon = null
                for (var j = 0; j < kids.length; ++j)
                    if (kids[j].name !== undefined && kids[j].size !== undefined)
                        icon = kids[j]
                verify(icon, "找不到内联图标")
                compare(icon.width, cases[i].expected)
            }
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
